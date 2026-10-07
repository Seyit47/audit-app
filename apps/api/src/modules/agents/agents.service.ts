import argon2 from 'argon2'
import { randomBytes } from 'node:crypto'
import type { Storage } from '../../plugins/storage.js'
import { AppError, conflict, notFound } from '../../lib/app-error.js'
import { pageArgs, type Page } from '../../lib/pagination.js'
import { isWithinWorkingHours, localDate, startOfLocalDay } from '../../lib/time.js'
import type { SettingsService } from '../settings/settings.service.js'
import type { PhotosRepository } from '../photos/photos.repository.js'
import { photoView, type PhotoView } from '../photos/photo.view.js'
import { isUniqueViolation, type AgentDetail, type AgentsRepository } from './agents.repository.js'
import type { CreateAgentBody, ListAgentsQuery, PatchAgentBody } from './agents.schema.js'
import type { AgentInsights } from './agent-insights.js'

const invalid = (message: string) => new AppError(400, 'VALIDATION_FAILED', message)
const temporaryPassword = () => randomBytes(9).toString('base64url')
const hashPassword = (p: string) => argon2.hash(p, { type: argon2.argon2id })
const normalizePhone = (p: string) => p.replace(/[\s()-]/g, '')

/** Salesmen (Figma 31:2307, 495:3932): accounts, plans, status, device binding. */
export class AgentsService {
  private readonly repo: AgentsRepository
  private readonly settings: SettingsService
  private readonly photos: PhotosRepository
  private readonly storage: Storage
  private readonly insights: AgentInsights
  constructor (repo: AgentsRepository, settings: SettingsService, photos: PhotosRepository, storage: Storage, insights: AgentInsights) {
    this.repo = repo
    this.settings = settings
    this.photos = photos
    this.storage = storage
    this.insights = insights
  }

  async list (query: ListAgentsQuery): Promise<Page<Awaited<ReturnType<AgentsService['row']>>>> {
    const settings = await this.settings.get()
    const { from, to } = this.period(query.from, query.to, settings.timezone)
    const { skip, take, page, size } = pageArgs(query.page, query.size)
    const agents = await this.repo.listAll(query)
    const counts = await this.repo.counts(agents.map((a) => a.userId), from, to)
    const top = await this.repo.topAudits(from, to)
    const now = new Date()
    const rows = await Promise.all(agents.map((a) => this.row(a, counts, top, settings, now)))
    const key = query.sort ?? 'code'
    const sign = query.dir === 'desc' ? -1 : 1
    rows.sort((x, y) => {
      const a = x[key] ?? ''
      const b = y[key] ?? ''
      return (typeof a === 'number' && typeof b === 'number' ? a - b : String(a).localeCompare(String(b), 'ru', { numeric: true })) * sign
    })
    return { items: rows.slice(skip, skip + take), total: rows.length, page, size }
  }

  async get (id: string, period?: { from?: string, to?: string }) {
    const agent = await this.repo.get(id)
    if (agent == null) throw notFound('Agent')
    const settings = await this.settings.get()
    const seenAt = agent.position?.recordedAt
    return {
      ...await this.view(agent),
      online: seenAt != null && Date.now() - seenAt.getTime() <= settings.noSignalMinutes * 60_000,
      kpis: await this.insights.kpis(id, period?.from, period?.to)
    }
  }

  async create (body: CreateAgentBody) {
    const dailyVisitPlan = body.dailyVisitPlan ?? 25
    const dailyAuditPlan = body.dailyAuditPlan ?? Math.min(20, dailyVisitPlan)
    if (dailyAuditPlan > dailyVisitPlan) throw invalid('dailyAuditPlan must not exceed dailyVisitPlan')
    const password = temporaryPassword()
    try {
      const agent = await this.repo.create({
        code: body.code?.toUpperCase() ?? await this.repo.nextCode(),
        passwordHash: await hashPassword(password),
        fullName: body.fullName.trim(),
        phone: normalizePhone(body.phone),
        whatsappPhone: body.whatsappPhone != null ? normalizePhone(body.whatsappPhone) : null,
        regionId: body.regionId,
        photoId: body.photoId ?? null,
        routeNotes: body.routeNotes ?? null,
        dailyVisitPlan,
        dailyAuditPlan,
        workStatus: body.workStatus ?? 'ACTIVE',
        imeiLabel: body.imeiLabel ?? null
      })
      return { ...await this.view(agent), temporaryPassword: password }
    } catch (e) {
      if (isUniqueViolation(e)) throw conflict('An account with this phone or code already exists')
      throw e
    }
  }

  nextCode () {
    return this.repo.peekCode()
  }

  async patch (id: string, body: PatchAgentBody) {
    const current = await this.repo.get(id)
    if (current == null) throw notFound('Agent')
    const visit = body.dailyVisitPlan ?? current.dailyVisitPlan
    const audit = body.dailyAuditPlan ?? current.dailyAuditPlan
    if (audit > visit) throw invalid('dailyAuditPlan must not exceed dailyVisitPlan')

    const { version, active, imeiLabel, phone, whatsappPhone, code, ...fields } = body
    const data = {
      ...fields,
      ...(code !== undefined ? { code: code.toUpperCase() } : {}),
      ...(phone !== undefined ? { phone: normalizePhone(phone) } : {}),
      ...(whatsappPhone !== undefined ? { whatsappPhone: whatsappPhone != null ? normalizePhone(whatsappPhone) : null } : {})
    }
    try {
      if (!await this.repo.update(id, version, data, data.phone)) throw conflict('The salesman was changed by someone else; reload and try again')
    } catch (e) {
      if (isUniqueViolation(e)) throw conflict('An account with this phone or code already exists')
      throw e
    }
    if (imeiLabel !== undefined) await this.repo.setImeiLabel(id, imeiLabel)
    const wasActive = current.user.status === 'ACTIVE'
    if (active === false && wasActive) await this.repo.deactivate(id)
    if (active === true && !wasActive) await this.repo.reactivate(id)
    return this.get(id)
  }

  async resetPassword (id: string) {
    if (await this.repo.get(id) == null) throw notFound('Agent')
    const password = temporaryPassword()
    await this.repo.setPassword(id, await hashPassword(password))
    return { temporaryPassword: password }
  }

  async rebindDevice (id: string, imeiLabel: string | null | undefined) {
    if (await this.repo.get(id) == null) throw notFound('Agent')
    await this.repo.rebindDevice(id, imeiLabel)
    return this.get(id)
  }

  /** The list period: `from`..`to` inclusive company-local days, today by default. */
  private period (from: string | undefined, to: string | undefined, timezone: string) {
    const today = localDate(new Date(), timezone)
    const start = startOfLocalDay(from ?? today, timezone)
    const end = new Date(startOfLocalDay(to ?? from ?? today, timezone).getTime() + 86_400_000)
    if (end <= start) throw invalid('"to" must not be before "from"')
    return { from: start, to: end }
  }

  private async photo (id: string | null): Promise<PhotoView | null> {
    if (id == null) return null
    const p = await this.photos.findById(id)
    return p?.status === 'READY' ? photoView(this.storage, p) : null
  }

  private async view (a: AgentDetail) {
    return {
      id: a.userId,
      code: a.code,
      fullName: a.fullName,
      phone: a.phone,
      whatsappPhone: a.whatsappPhone,
      photo: await this.photo(a.photoId),
      region: { id: a.region.id, name: a.region.name },
      routeNotes: a.routeNotes,
      dailyVisitPlan: a.dailyVisitPlan,
      dailyAuditPlan: a.dailyAuditPlan,
      workStatus: a.workStatus,
      active: a.user.status === 'ACTIVE',
      version: a.version,
      device: a.device == null ? null : { model: a.device.model, imeiLabel: a.device.imeiLabel, boundAt: a.device.boundAt?.toISOString() ?? null },
      position: a.position == null
        ? null
        : { lat: a.position.lat, lng: a.position.lng, accuracyM: a.position.accuracyM, speedKmh: a.position.speedKmh, batteryPct: a.position.batteryPct, recordedAt: a.position.recordedAt.toISOString() }
    }
  }

  private async row (
    a: AgentDetail,
    counts: Awaited<ReturnType<AgentsRepository['counts']>>,
    top: number,
    settings: { noSignalMinutes: number, workStart: string, workEnd: string, timezone: string },
    now: Date
  ) {
    const active = a.user.status === 'ACTIVE'
    const working = active && a.workStatus === 'ACTIVE'
    const seenAt = a.position?.recordedAt
    const fresh = seenAt != null && now.getTime() - seenAt.getTime() <= settings.noSignalMinutes * 60_000
    const visits = counts.audits.get(a.userId) ?? 0
    const lastActivity = [a.user.lastActiveAt, seenAt].filter((d): d is Date => d != null).sort((x, y) => y.getTime() - x.getTime())[0]
    return {
      id: a.userId,
      code: a.code,
      fullName: a.fullName,
      phone: a.phone,
      photo: await this.photo(a.photoId),
      region: { id: a.region.id, name: a.region.name },
      locations: counts.shops.get(a.userId) ?? 0,
      visits,
      photos: counts.photos.get(a.userId) ?? 0,
      lastActivityAt: lastActivity?.toISOString() ?? null,
      workStatus: a.workStatus,
      active,
      onRoute: working && fresh,
      needsContact: working && isWithinWorkingHours(now, settings) && !fresh,
      topPerformer: visits > 0 && visits === top
    }
  }
}
