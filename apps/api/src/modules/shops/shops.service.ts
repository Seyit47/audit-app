import type { AuthUser } from '../../plugins/auth.js'
import type { Storage } from '../../plugins/storage.js'
import { AppError, conflict, notFound } from '../../lib/app-error.js'
import { decodeCursor, encodeCursor, pageArgs } from '../../lib/pagination.js'
import type { PhotosRepository } from '../photos/photos.repository.js'
import { photoView } from '../photos/photo.view.js'
import type { SettingsService } from '../settings/settings.service.js'
import { isUniqueViolation, type ShopsRepository } from './shops.repository.js'
import type { ContactsBody, CreateShopBody, ListShopsQuery, MapQuery, PatchShopBody } from './shops.schema.js'
import { localDate, startOfLocalDay } from '../../lib/time.js'
import { facadeView, shopView } from './shop.view.js'

const pct = (part: number, all: number) => (all === 0 ? null : Math.round((part / all) * 100))

export type VisitState = 'VISITED' | 'OVERDUE' | 'SCHEDULED' | 'ASSIGNED'

/** Пройден > Просрочен > Запланирован > Assigned (83:16884 chips). */
export function visitState (s: { lastVisitAt: Date | null, nextDueAt: Date | null, id: string }, dayStart: Date, planned: Set<string>): VisitState {
  const dayEnd = new Date(dayStart.getTime() + 86_400_000)
  if (s.lastVisitAt != null && s.lastVisitAt >= dayStart) return 'VISITED'
  if (s.nextDueAt != null && s.nextDueAt < dayStart) return 'OVERDUE'
  if (planned.has(s.id) || (s.nextDueAt != null && s.nextDueAt < dayEnd)) return 'SCHEDULED'
  return 'ASSIGNED'
}

/** Shops (US4, US5): admin management, agent scope and sync, visit history. */
export class ShopsService {
  private readonly repo: ShopsRepository
  private readonly photos: PhotosRepository
  private readonly storage: Storage
  private readonly settings: SettingsService
  constructor (repo: ShopsRepository, photos: PhotosRepository, storage: Storage, settings: SettingsService) {
    this.repo = repo
    this.photos = photos
    this.storage = storage
    this.settings = settings
  }

  private view = (s: Parameters<typeof shopView>[0]) => shopView(s, this.photos, this.storage)

  async list (user: AuthUser, q: ListShopsQuery) {
    if (user.role === 'AGENT') return this.sync(user.id, q.updatedAfter)
    const { skip, take, page, size } = pageArgs(q.page, q.size)
    const sortKey = q.sort ?? 'createdAt'
    const dir = q.dir ?? (sortKey === 'createdAt' ? 'desc' : 'asc')
    const { items, total } = await this.repo.list(q, { [sortKey]: dir }, skip, take)
    const last = await this.repo.lastVisits(items.map((s) => s.id))
    return {
      items: await Promise.all(items.map(async (s) => {
        const v = last.get(s.id)
        return { ...await this.view(s), lastVisit: v == null ? null : { at: v.at.toISOString(), agentName: v.agentName } }
      })),
      total,
      page,
      size
    }
  }

  /** Agent sync (contracts/sync.md): changes since the cursor plus tombstones. */
  private async sync (agentId: string, updatedAfter?: string) {
    const cursor = new Date()
    const { items, tombstones } = await this.repo.syncChanges(agentId, new Date(updatedAfter ?? 0))
    return {
      items: await Promise.all(items.map(async (s) => ({ ...await this.view(s), latestVisits: await this.latestVisits(s.id) }))),
      tombstones,
      cursor: cursor.toISOString()
    }
  }

  private async latestVisits (shopId: string) {
    return (await this.visits(shopId, undefined, 3)).items
  }

  async get (user: AuthUser, id: string) {
    const s = await this.repo.get(id)
    if (s == null || (user.role === 'AGENT' && s.assignedAgentId !== user.id)) throw notFound('Shop')
    const [audits, lastAudit, products, recent, recentClean, photos, geotagged] = await this.repo.kpis(id)
    return {
      ...await this.view(s),
      kpis: {
        totalAudits: audits,
        lastAuditAt: lastAudit?.finishedAtDevice.toISOString() ?? null,
        productsCarried: products,
        /** Share of the last 90 days' audits without a recorded violation. */
        compliancePct: pct(recentClean, recent),
        auditPhotos: photos,
        geotaggedPct: pct(geotagged, photos)
      }
    }
  }

  async create (user: AuthUser, body: CreateShopBody) {
    if (body.id != null) {
      const existing = await this.repo.findAny(body.id)
      if (existing != null) {
        if (existing.createdById !== user.id) throw conflict('Shop id already used')
        return { status: 200, shop: await this.view(existing) }
      }
    }
    const settings = await this.settings.get()
    const agent = user.role === 'AGENT'
    if (agent) {
      if (body.facadePhotoId == null) throw new AppError(400, 'VALIDATION_FAILED', 'A storefront photo is required')
      if (body.accuracyM == null || body.accuracyM > settings.minGpsAccuracyM) {
        throw new AppError(422, 'GPS_ACCURACY', `GPS accuracy must be at most ${settings.minGpsAccuracyM} m`)
      }
    }
    const { contacts = [], ...rest } = body
    // accuracyM is checked above; it is not stored on the shop.
    const fields = Object.fromEntries(Object.entries(rest).filter(([k]) => k !== 'accuracyM')) as Omit<typeof rest, 'accuracyM'>
    try {
      const shop = await this.repo.create({
        ...fields,
        type: fields.type ?? 'OTHER',
        regionId: fields.regionId === undefined ? await this.repo.nearestRegion(fields.lat, fields.lng) : fields.regionId,
        auditRadiusM: fields.auditRadiusM ?? settings.defaultAuditRadiusM,
        status: agent ? 'PENDING_REVIEW' : 'ACTIVE',
        assignedAgentId: agent ? user.id : (fields.assignedAgentId ?? null),
        createdById: user.id,
        nextDueAt: new Date()
      }, contacts)
      return { status: 201, shop: await this.view(shop) }
    } catch (e) {
      if (isUniqueViolation(e)) throw conflict('Shop already exists')
      throw e
    }
  }

  async patch (id: string, body: PatchShopBody) {
    const current = await this.repo.get(id)
    if (current == null) throw notFound('Shop')
    const { version, assignedAgentId, ...data } = body
    const reassign = assignedAgentId !== undefined && assignedAgentId !== current.assignedAgentId ? assignedAgentId : undefined
    if (!await this.repo.update(id, version, data, reassign)) throw conflict('The shop was changed by someone else; reload and try again')
    return this.get({ id: 'admin', role: 'ADMIN' }, id)
  }

  async contacts (id: string, body: ContactsBody) {
    if (await this.repo.get(id) == null) throw notFound('Shop')
    await this.repo.replaceContacts(id, body.contacts)
    return this.get({ id: 'admin', role: 'ADMIN' }, id)
  }

  async bulkAssign (shopIds: string[], agentId: string | null) {
    await this.repo.bulkAssign(shopIds, agentId)
    return { updated: shopIds.length }
  }

  async bulkDelete (shopIds: string[]) {
    await this.repo.bulkDelete(shopIds)
    return { deleted: shopIds.length }
  }

  /** Visit history: audits and missed stops, newest first (missed visits carry no reason, gap A2). */
  async visits (shopId: string, cursor?: string, limit = 20) {
    const before = decodeCursor(cursor)?.at ?? null
    const [audits, missed] = await Promise.all([
      this.repo.auditsBefore(shopId, before, limit + 1),
      this.repo.missedBefore(shopId, before, limit + 1)
    ])
    const merged = [
      ...audits.map((a) => ({ at: a.finishedAtDevice, id: a.id, audit: a })),
      ...missed.map((m) => ({ at: m.plannedAt, id: m.id, stop: m }))
    ].sort((x, y) => y.at.getTime() - x.at.getTime())
    const page = merged.slice(0, limit)
    const items = await Promise.all(page.map(async (v) => {
      if ('audit' in v && v.audit != null) {
        const a = v.audit
        return {
          type: 'AUDIT' as const,
          id: a.id,
          at: a.finishedAtDevice.toISOString(),
          startedAt: a.startedAtDevice.toISOString(),
          durationMin: a.durationMin,
          agent: { id: a.agent.userId, fullName: a.agent.fullName },
          comment: a.comment,
          hasViolation: a.hasViolation,
          withinRadius: a.withinRadius,
          lat: a.lat,
          lng: a.lng,
          gpsAccuracyM: a.gpsAccuracyM,
          photoCount: a.photos.length,
          photos: await Promise.all(a.photos.slice(0, 8).map((p) => photoView(this.storage, p)))
        }
      }
      const m = (v as { stop: Awaited<ReturnType<ShopsRepository['missedBefore']>>[number] }).stop
      return { type: 'MISSED' as const, id: m.id, at: m.plannedAt.toISOString(), agent: { id: m.route.agent.userId, fullName: m.route.agent.fullName } }
    }))
    const [completed, missedCount] = await this.repo.visitTotals(shopId)
    const lastItem = page.at(-1)
    return {
      items,
      nextCursor: merged.length > limit && lastItem != null ? encodeCursor(lastItem.at, lastItem.id) : null,
      totals: { all: completed + missedCount, completed, missed: missedCount }
    }
  }

  private async today () {
    const tz = (await this.settings.get()).timezone
    const day = localDate(new Date(), tz)
    return { dayStart: startOfLocalDay(day, tz), date: new Date(`${day}T00:00:00Z`) }
  }

  /** Chip counts of the agent Shops screen (83:16884). */
  async counts (agentId: string) {
    const { dayStart, date } = await this.today()
    const [shops, planned] = await Promise.all([
      this.repo.mapShops({ assignedAgentId: agentId, status: { not: 'INACTIVE' } }),
      this.repo.plannedToday(agentId, date)
    ])
    const c = { all: shops.length, scheduled: 0, overdue: 0, visited: 0, assigned: 0 }
    for (const s of shops) {
      const st = visitState(s, dayStart, planned)
      c[st === 'VISITED' ? 'visited' : st === 'OVERDUE' ? 'overdue' : st === 'SCHEDULED' ? 'scheduled' : 'assigned']++
    }
    return c
  }

  /** Map markers (21:2, 83:17636): agents get their own shops; admins can filter. */
  async map (user: AuthUser, q: MapQuery) {
    const { dayStart, date } = await this.today()
    const where = user.role === 'AGENT'
      ? { assignedAgentId: user.id, status: { not: 'INACTIVE' as const } }
      : {
          ...(q.agentIds?.length ? { assignedAgentId: { in: q.agentIds } } : {}),
          ...(q.regionIds?.length ? { regionId: { in: q.regionIds } } : {}),
          ...(q.ids?.length ? { id: { in: q.ids } } : {}),
          ...(q.status ? { status: q.status } : {})
        }
    const [shops, planned] = await Promise.all([this.repo.mapShops(where), this.repo.plannedToday(user.role === 'AGENT' ? user.id : null, date)])
    return Promise.all(shops.map(async (s) => ({
      id: s.id,
      code: s.code,
      name: s.name,
      address: s.address,
      lat: s.lat,
      lng: s.lng,
      status: s.status,
      agentId: s.assignedAgentId,
      regionId: s.regionId,
      visitState: visitState(s, dayStart, planned),
      lastVisitAt: s.lastVisitAt?.toISOString() ?? null,
      thumbUrl: (await this.facade(s.facadePhotoId))?.previewUrl400 ?? null
    })))
  }

  async assertVisible (user: AuthUser, shopId: string) {
    if (user.role === 'AGENT' && !await this.repo.isAssigned(shopId, user.id)) throw notFound('Shop')
    if (user.role === 'ADMIN' && await this.repo.get(shopId) == null) throw notFound('Shop')
  }

  facade (id: string | null) {
    return facadeView(this.photos, this.storage, id)
  }
}
