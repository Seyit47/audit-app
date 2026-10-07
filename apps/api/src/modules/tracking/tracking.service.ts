import { Type, type Static } from '@sinclair/typebox'
import type { PrismaClient } from '../../generated/prisma/client.js'
import type { AuthUser } from '../../plugins/auth.js'
import { isWithinWorkingHours } from '../../lib/time.js'
import type { SettingsService } from '../settings/settings.service.js'

export const PingsBody = Type.Object({
  pings: Type.Array(Type.Object({
    recordedAt: Type.String({ format: 'date-time' }),
    lat: Type.Number({ minimum: -90, maximum: 90 }),
    lng: Type.Number({ minimum: -180, maximum: 180 }),
    accuracyM: Type.Number({ minimum: 0 }),
    speedKmh: Type.Optional(Type.Union([Type.Number({ minimum: 0 }), Type.Null()])),
    batteryPct: Type.Optional(Type.Union([Type.Integer({ minimum: 0, maximum: 100 }), Type.Null()])),
    trigger: Type.Optional(Type.Union([Type.Literal('HEARTBEAT'), Type.Literal('GEOFENCE_ENTER'), Type.Literal('GEOFENCE_EXIT')]))
  }, { additionalProperties: false }), { minItems: 1, maxItems: 200 })
}, { additionalProperties: false })
export type PingsBody = Static<typeof PingsBody>

/** Location pings (FR-017, research R-11): only an ACTIVE agent's pings within working hours are kept. */
export class TrackingService {
  private readonly prisma: PrismaClient
  private readonly settings: SettingsService
  constructor (prisma: PrismaClient, settings: SettingsService) {
    this.prisma = prisma
    this.settings = settings
  }

  async ingest (user: AuthUser, body: PingsBody) {
    const agent = await this.prisma.agent.findUnique({ where: { userId: user.id }, select: { workStatus: true } })
    if (agent == null || agent.workStatus !== 'ACTIVE') return { accepted: 0, rejected: body.pings.length }
    const s = await this.settings.get()
    const keep = body.pings
      .map((p) => ({ ...p, at: new Date(p.recordedAt) }))
      .filter((p) => isWithinWorkingHours(p.at, s) && (user.deactivatedAt == null || p.at < user.deactivatedAt))
    if (keep.length > 0) {
      await this.prisma.locationPing.createMany({
        data: keep.map((p) => ({ agentId: user.id, recordedAt: p.at, lat: p.lat, lng: p.lng, accuracyM: p.accuracyM, speedKmh: p.speedKmh ?? null, batteryPct: p.batteryPct ?? null, trigger: p.trigger ?? 'HEARTBEAT' }))
      })
      const latest = keep.reduce((a, b) => (b.at > a.at ? b : a))
      const current = await this.prisma.agentPosition.findUnique({ where: { agentId: user.id } })
      if (current == null || latest.at > current.recordedAt) {
        const data = { recordedAt: latest.at, lat: latest.lat, lng: latest.lng, accuracyM: latest.accuracyM, speedKmh: latest.speedKmh ?? null, batteryPct: latest.batteryPct ?? null }
        await this.prisma.agentPosition.upsert({ where: { agentId: user.id }, update: data, create: { agentId: user.id, ...data } })
      }
    }
    return { accepted: keep.length, rejected: body.pings.length - keep.length }
  }

  /** Latest position of working agents (admin map, polled every 30 s). */
  async positions () {
    const rows = await this.prisma.agentPosition.findMany({
      where: { agent: { workStatus: 'ACTIVE', user: { status: 'ACTIVE' } } },
      include: { agent: { select: { userId: true, fullName: true, code: true, regionId: true } } }
    })
    return rows.map((p) => ({
      agentId: p.agentId, fullName: p.agent.fullName, code: p.agent.code, regionId: p.agent.regionId,
      lat: p.lat, lng: p.lng, accuracyM: p.accuracyM, speedKmh: p.speedKmh, batteryPct: p.batteryPct, recordedAt: p.recordedAt.toISOString()
    }))
  }
}
