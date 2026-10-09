import type { PrismaClient } from '../../generated/prisma/client.js'
import type { Storage } from '../../plugins/storage.js'
import { decodeCursor, encodeCursor } from '../../lib/pagination.js'
import { isWithinWorkingHours, localDate, startOfLocalDay } from '../../lib/time.js'
import { photoView } from '../photos/photo.view.js'
import type { SettingsService } from '../settings/settings.service.js'

const pct = (part: number, all: number) => (all === 0 ? null : Math.round((part / all) * 1000) / 10)

/** Salesmen KPIs, timeline, track and visit history (31:2307, 122:7981, 265:27616, 273:153). */
export class AgentInsights {
  private readonly prisma: PrismaClient
  private readonly settings: SettingsService
  private readonly storage: Storage
  constructor (prisma: PrismaClient, settings: SettingsService, storage: Storage) {
    this.prisma = prisma
    this.settings = settings
    this.storage = storage
  }

  /** Inclusive company-local days → [start, end). Defaults to today. */
  async period (from?: string, to?: string) {
    const tz = (await this.settings.get()).timezone
    const today = localDate(new Date(), tz)
    const start = startOfLocalDay(from ?? today, tz)
    const end = new Date(startOfLocalDay(to ?? from ?? today, tz).getTime() + 86_400_000)
    return { start, end, firstDay: new Date(`${from ?? today}T00:00:00Z`), lastDay: new Date(`${to ?? from ?? today}T00:00:00Z`) }
  }

  async summary (from?: string, to?: string) {
    const s = await this.settings.get()
    const p = await this.period(from, to)
    const now = new Date()
    const [total, working, positions, audits, stops, photos, verified] = await Promise.all([
      this.prisma.agent.count({ where: { user: { status: 'ACTIVE' } } }),
      this.prisma.agent.findMany({ where: { workStatus: 'ACTIVE', user: { status: 'ACTIVE' } }, select: { userId: true } }),
      this.prisma.agentPosition.findMany({ select: { agentId: true, recordedAt: true } }),
      this.prisma.audit.count({ where: { finishedAtDevice: { gte: p.start, lt: p.end } } }),
      this.prisma.routeStop.groupBy({ by: ['status'], where: { route: { date: { gte: p.firstDay, lte: p.lastDay } } }, _count: true }),
      this.prisma.photo.count({ where: { kind: 'AUDIT', status: 'READY', takenAt: { gte: p.start, lt: p.end } } }),
      this.prisma.photo.count({ where: { kind: 'AUDIT', status: 'READY', takenAt: { gte: p.start, lt: p.end }, verifiedAt: { not: null } } })
    ])
    const seen = new Map(positions.map((x) => [x.agentId, x.recordedAt]))
    const fresh = (id: string) => { const at = seen.get(id); return at != null && now.getTime() - at.getTime() <= s.noSignalMinutes * 60_000 }
    const onRoute = working.filter((a) => fresh(a.userId)).length
    const working_hours = isWithinWorkingHours(now, s)
    const byStatus = Object.fromEntries(stops.map((x) => [x.status, x._count])) as Record<string, number>
    const planned = Object.values(byStatus).reduce((a, b) => a + b, 0)
    const auditPlan = await this.prisma.agent.aggregate({ where: { workStatus: 'ACTIVE', user: { status: 'ACTIVE' } }, _sum: { dailyAuditPlan: true } })
    const days = Math.round((p.end.getTime() - p.start.getTime()) / 86_400_000)
    const plannedAudits = (auditPlan._sum.dailyAuditPlan ?? 0) * days
    return {
      totalStaff: total,
      activeStaff: working.length,
      activePct: pct(working.length, total),
      onRoute,
      onRoutePct: pct(onRoute, working.length),
      audits,
      auditsVsPlanPct: plannedAudits === 0 ? null : Math.round(((audits - plannedAudits) / plannedAudits) * 100),
      shopsVisited: byStatus.DONE ?? 0,
      shopsPlanned: planned,
      shopsRemaining: (byStatus.PLANNED ?? 0) + (byStatus.IN_PROGRESS ?? 0),
      photos,
      photosVerifiedPct: pct(verified, photos),
      inactiveStaff: total - working.length,
      needsContact: working_hours ? working.length - onRoute : 0,
      noSignalMinutes: s.noSignalMinutes
    }
  }

  async kpis (agentId: string, from?: string, to?: string) {
    const p = await this.period(from, to)
    const [audits, assigned, visited, photos] = await Promise.all([
      this.prisma.audit.count({ where: { agentId, finishedAtDevice: { gte: p.start, lt: p.end } } }),
      this.prisma.shop.count({ where: { assignedAgentId: agentId, deletedAt: null } }),
      this.prisma.audit.findMany({ where: { agentId, finishedAtDevice: { gte: p.start, lt: p.end } }, distinct: ['shopId'], select: { shopId: true } }),
      this.prisma.photo.count({ where: { uploadedById: agentId, kind: 'AUDIT', status: 'READY', takenAt: { gte: p.start, lt: p.end } } })
    ])
    return { audits, assignedShops: assigned, visitedShops: visited.length, photos }
  }

  /**
   * The day's checkpoints: the planned route's stops, plus audits at shops that were not on it (an audit is
   * started at whatever shop the agent stands in, and some days have no route), in time order.
   */
  async timeline (agentId: string, date?: string) {
    const tz = (await this.settings.get()).timezone
    const day = date ?? localDate(new Date(), tz)
    const start = startOfLocalDay(day, tz)
    const shop = { select: { id: true, name: true, code: true, lat: true, lng: true } } as const
    const withPhotos = { _count: { select: { photos: true } } } as const
    const [route, audits] = await Promise.all([
      this.prisma.route.findUnique({
        where: { agentId_date: { agentId, date: new Date(`${day}T00:00:00Z`) } },
        include: { stops: { orderBy: { position: 'asc' }, include: { shop, audit: { include: withPhotos } } } }
      }),
      this.prisma.audit.findMany({
        where: { agentId, startedAtDevice: { gte: start, lt: new Date(start.getTime() + 86_400_000) }, stop: { is: null } },
        orderBy: { startedAtDevice: 'asc' },
        include: { shop, ...withPhotos }
      })
    ])
    const auditView = (a: { id: string, startedAtDevice: Date, finishedAtDevice: Date, durationMin: number }) =>
      ({ id: a.id, startedAt: a.startedAtDevice.toISOString(), finishedAt: a.finishedAtDevice.toISOString(), durationMin: a.durationMin })
    const planned = (route?.stops ?? []).map((st) => ({
      id: st.id,
      status: st.status,
      plannedAt: st.plannedAt.toISOString(),
      isAuditTask: st.isAuditTask,
      shop: st.shop,
      photoCount: st.audit?._count.photos ?? 0,
      audit: st.audit == null ? null : auditView(st.audit)
    }))
    const unplanned = audits.map((a) => ({
      id: a.id,
      status: 'DONE' as const,
      plannedAt: a.startedAtDevice.toISOString(),
      isAuditTask: true,
      shop: a.shop,
      photoCount: a._count.photos,
      audit: auditView(a)
    }))
    // Each checkpoint at its real time: the audit's start when done, otherwise the planned time.
    const at = (x: { plannedAt: string, audit: { startedAt: string } | null }) => x.audit?.startedAt ?? x.plannedAt
    return [...planned, ...unplanned].sort((x, y) => at(x).localeCompare(at(y)))
  }

  async track (agentId: string, date?: string) {
    const tz = (await this.settings.get()).timezone
    const day = date ?? localDate(new Date(), tz)
    const start = startOfLocalDay(day, tz)
    const [points, stops, current] = await Promise.all([
      this.prisma.locationPing.findMany({ where: { agentId, recordedAt: { gte: start, lt: new Date(start.getTime() + 86_400_000) } }, orderBy: { recordedAt: 'asc' }, select: { lat: true, lng: true, recordedAt: true, trigger: true } }),
      this.timeline(agentId, day),
      this.prisma.agentPosition.findUnique({ where: { agentId } })
    ])
    return {
      points: points.map((x) => ({ lat: x.lat, lng: x.lng, recordedAt: x.recordedAt.toISOString(), trigger: x.trigger })),
      checkpoints: stops.map((st) => ({ id: st.id, status: st.status, lat: st.shop.lat, lng: st.shop.lng, name: st.shop.name, at: st.audit?.startedAt ?? st.plannedAt })),
      current: current == null ? null : { lat: current.lat, lng: current.lng, accuracyM: current.accuracyM, recordedAt: current.recordedAt.toISOString() }
    }
  }

  /** The agent's audits and missed stops, newest first, with totals. */
  async visits (agentId: string, cursor?: string, limit = 20) {
    const before = decodeCursor(cursor)?.at ?? null
    const [audits, missed, completed, missedCount] = await Promise.all([
      this.prisma.audit.findMany({
        where: { agentId, ...(before ? { finishedAtDevice: { lt: before } } : {}) },
        orderBy: { finishedAtDevice: 'desc' },
        take: limit + 1,
        include: { shop: { select: { id: true, name: true, code: true, address: true, facadePhotoId: true } }, photos: { where: { status: 'READY' }, orderBy: { takenAt: 'asc' } } }
      }),
      this.prisma.routeStop.findMany({
        where: { status: 'MISSED', route: { agentId }, ...(before ? { plannedAt: { lt: before } } : {}) },
        orderBy: { plannedAt: 'desc' },
        take: limit + 1,
        include: { shop: { select: { id: true, name: true, code: true, address: true } } }
      }),
      this.prisma.audit.count({ where: { agentId } }),
      this.prisma.routeStop.count({ where: { status: 'MISSED', route: { agentId } } })
    ])
    const merged = [...audits.map((a) => ({ at: a.finishedAtDevice, id: a.id, a })), ...missed.map((m) => ({ at: m.plannedAt, id: m.id, m }))]
      .sort((x, y) => y.at.getTime() - x.at.getTime())
    const page = merged.slice(0, limit)
    const items = await Promise.all(page.map(async (v) => 'a' in v
      ? {
          type: 'AUDIT' as const, id: v.a.id, at: v.a.finishedAtDevice.toISOString(), startedAt: v.a.startedAtDevice.toISOString(), durationMin: v.a.durationMin,
          shop: v.a.shop, comment: v.a.comment, hasViolation: v.a.hasViolation, photoCount: v.a.photos.length,
          photos: await Promise.all(v.a.photos.slice(0, 8).map((ph) => photoView(this.storage, ph)))
        }
      : { type: 'MISSED' as const, id: v.m.id, at: v.m.plannedAt.toISOString(), shop: v.m.shop }))
    const last = page.at(-1)
    return { items, nextCursor: merged.length > limit && last ? encodeCursor(last.at, last.id) : null, totals: { all: completed + missedCount, completed, missed: missedCount } }
  }
}
