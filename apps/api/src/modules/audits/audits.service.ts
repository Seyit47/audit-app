import type { AuthUser } from '../../plugins/auth.js'
import type { Jobs } from '../../plugins/jobs.js'
import type { Storage } from '../../plugins/storage.js'
import { AppError, conflict, notFound } from '../../lib/app-error.js'
import { distanceM } from '../../lib/geo.js'
import { decodeCursor, encodeCursor } from '../../lib/pagination.js'
import { localDate } from '../../lib/time.js'
import { photoView } from '../photos/photo.view.js'
import type { SettingsService } from '../settings/settings.service.js'
import { ROUTES_REORDER } from '../../jobs/routes.js'
import { PhotoAlreadyLinked, type AuditRow, type AuditsRepository } from './audits.repository.js'
import type { CheckStartBody, CreateAuditBody, ListAuditsQuery } from './audits.schema.js'

const SKEW_MS = 10 * 60_000
const invalid = (message: string) => new AppError(400, 'VALIDATION_FAILED', message)

/** Audits (US2): geofenced start, idempotent immutable create, server-side evidence checks. */
export class AuditsService {
  private readonly repo: AuditsRepository
  private readonly settings: SettingsService
  private readonly storage: Storage
  private readonly jobs: Jobs
  constructor (repo: AuditsRepository, settings: SettingsService, storage: Storage, jobs: Jobs) {
    this.repo = repo
    this.settings = settings
    this.storage = storage
    this.jobs = jobs
  }

  async checkStart (user: AuthUser, body: CheckStartBody) {
    const shop = await this.repo.shop(body.shopId)
    if (shop == null || shop.deletedAt != null || shop.assignedAgentId !== user.id) throw notFound('Shop')
    const s = await this.settings.get()
    if (body.accuracyM > s.minGpsAccuracyM) {
      throw new AppError(422, 'GPS_ACCURACY', 'GPS accuracy is too low', { accuracyM: body.accuracyM, limitM: s.minGpsAccuracyM })
    }
    const d = Math.round(distanceM(body, shop))
    if (d > shop.auditRadiusM) throw new AppError(422, 'GEOFENCE', 'Outside the shop radius', { distanceM: d, radiusM: shop.auditRadiusM })
    return { ok: true, distanceM: d, radiusM: shop.auditRadiusM }
  }

  async create (user: AuthUser, body: CreateAuditBody): Promise<{ status: number, audit: Awaited<ReturnType<AuditsService['view']>> }> {
    const existing = await this.repo.get(body.id)
    if (existing != null) {
      if (existing.agentId !== user.id) throw conflict('Audit id already used')
      return { status: 200, audit: await this.view(existing) }
    }
    const started = new Date(body.startedAt)
    const finished = new Date(body.finishedAt)
    if (user.deactivatedAt != null && finished >= user.deactivatedAt) throw new AppError(401, 'UNAUTHENTICATED', 'Account deactivated')
    if (body.comment.trim() === '') throw invalid('A comment is required')

    const shop = await this.repo.shop(body.shopId)
    if (shop == null || !await this.repo.wasAssigned(shop.id, user.id, started)) throw notFound('Shop')

    const photos = await this.repo.photos(body.photoIds)
    const usable = photos.filter((p) => p.uploadedById === user.id && p.kind === 'AUDIT' && p.status === 'READY')
    if (usable.length !== body.photoIds.length) throw invalid('Photos must be your own uploaded audit photos')
    if (usable.some((p) => p.auditId != null)) throw conflict('A photo is already linked to another audit')

    const s = await this.settings.get()
    const received = new Date()
    const distance = Math.round(distanceM(body, shop))
    const withinRadius = distance <= shop.auditRadiusM
    // Offline audits arrive late legitimately; a device clock running ahead or backwards is the signal.
    const clockSkewFlag = finished.getTime() - received.getTime() > SKEW_MS || finished < started
    const stopId = await this.repo.stopFor(user.id, shop.id, body.routeStopId, new Date(`${localDate(finished, s.timezone)}T00:00:00Z`))

    try {
      await this.repo.create({
        audit: {
          id: body.id,
          shopId: shop.id,
          agentId: user.id,
          startedAtDevice: started,
          finishedAtDevice: finished,
          receivedAt: received,
          clockSkewFlag,
          durationMin: Math.max(0, Math.round((finished.getTime() - started.getTime()) / 60_000)),
          lat: body.lat,
          lng: body.lng,
          gpsAccuracyM: body.accuracyM,
          distanceM: distance,
          withinRadius,
          comment: body.comment.trim(),
          hasViolation: body.hasViolation
        },
        photoIds: body.photoIds,
        verify: withinRadius && !clockSkewFlag,
        shopId: shop.id,
        nextDueAt: new Date(finished.getTime() + s.visitFrequencyDays * 86_400_000),
        stopId
      })
    } catch (e) {
      if (e instanceof PhotoAlreadyLinked) throw conflict('A photo is already linked to another audit')
      const again = await this.repo.get(body.id)
      if (again != null && again.agentId === user.id) return { status: 200, audit: await this.view(again) }
      throw e
    }
    if (stopId != null) await this.jobs.send(ROUTES_REORDER, { stopId }).catch(() => null)
    return { status: 201, audit: await this.view((await this.repo.get(body.id))!) }
  }

  async get (user: AuthUser, id: string) {
    const a = await this.repo.get(id)
    if (a == null || (user.role === 'AGENT' && a.agentId !== user.id)) throw notFound('Audit')
    return this.view(a)
  }

  async list (user: AuthUser, q: ListAuditsQuery) {
    const limit = q.limit ?? 20
    const cur = decodeCursor(q.cursor)
    const rows = await this.repo.list({
      ...(user.role === 'AGENT' ? { agentId: user.id } : q.agentId ? { agentId: q.agentId } : {}),
      ...(q.shopId ? { shopId: q.shopId } : {}),
      ...(q.hasViolation !== undefined ? { hasViolation: q.hasViolation } : {}),
      ...(q.from || q.to ? { finishedAtDevice: { ...(q.from ? { gte: new Date(q.from) } : {}), ...(q.to ? { lt: new Date(q.to) } : {}) } } : {}),
      ...(cur ? { OR: [{ finishedAtDevice: { lt: cur.at } }, { finishedAtDevice: cur.at, id: { lt: cur.id } }] } : {})
    }, limit + 1)
    const page = rows.slice(0, limit)
    const last = page.at(-1)
    return {
      items: await Promise.all(page.map((a) => this.view(a))),
      nextCursor: rows.length > limit && last != null ? encodeCursor(last.finishedAtDevice, last.id) : null
    }
  }

  async view (a: AuditRow) {
    return {
      id: a.id,
      shop: a.shop,
      agent: { id: a.agent.userId, fullName: a.agent.fullName, code: a.agent.code },
      startedAt: a.startedAtDevice.toISOString(),
      finishedAt: a.finishedAtDevice.toISOString(),
      receivedAt: a.receivedAt.toISOString(),
      durationMin: a.durationMin,
      lat: a.lat,
      lng: a.lng,
      gpsAccuracyM: a.gpsAccuracyM,
      distanceM: a.distanceM,
      withinRadius: a.withinRadius,
      clockSkewFlag: a.clockSkewFlag,
      comment: a.comment,
      hasViolation: a.hasViolation,
      photos: await Promise.all(a.photos.filter((p) => p.status === 'READY').map(async (p) => ({ ...await photoView(this.storage, p), verified: p.verifiedAt != null })))
    }
  }
}
