import { Type, type Static } from '@sinclair/typebox'
import type { Prisma, PrismaClient } from '../../generated/prisma/client.js'
import type { AuthUser } from '../../plugins/auth.js'
import type { Storage } from '../../plugins/storage.js'
import { notFound } from '../../lib/app-error.js'
import { decodeCursor, encodeCursor } from '../../lib/pagination.js'
import { localDate, startOfLocalDay } from '../../lib/time.js'
import type { SettingsService } from '../settings/settings.service.js'
import { photoView } from './photo.view.js'

const Uuid = Type.String({ format: 'uuid' })
export const GalleryQuery = Type.Object({
  type: Type.Optional(Type.Union([Type.Literal('AUDIT'), Type.Literal('FACADE'), Type.Literal('ADMIN_UPLOAD')])),
  shopId: Type.Optional(Uuid),
  agentId: Type.Optional(Uuid),
  regionId: Type.Optional(Uuid),
  verified: Type.Optional(Type.Boolean()),
  from: Type.Optional(Type.String({ format: 'date-time' })),
  to: Type.Optional(Type.String({ format: 'date-time' })),
  q: Type.Optional(Type.String({ maxLength: 100 })),
  cursor: Type.Optional(Type.String()),
  limit: Type.Optional(Type.Integer({ minimum: 1, maximum: 100 })),
  /** Add per-day counts of the whole filtered set (grouped view, B4). */
  groups: Type.Optional(Type.Boolean())
}, { additionalProperties: false })
export type GalleryQuery = Static<typeof GalleryQuery>

const GALLERY_KINDS = ['AUDIT', 'FACADE', 'ADMIN_UPLOAD'] as const
const include = {
  shop: { select: { id: true, name: true, code: true, address: true, lat: true, lng: true } },
  audit: { select: { id: true, comment: true, hasViolation: true, startedAtDevice: true, finishedAtDevice: true, durationMin: true, withinRadius: true, shop: { select: { id: true, name: true, code: true, address: true, lat: true, lng: true } } } },
  uploadedBy: { select: { id: true, role: true, agent: { select: { fullName: true, code: true, phone: true } } } }
} as const
type Row = Prisma.PhotoGetPayload<{ include: typeof include }>

/** Pictures / Галерея (53:1375, 138:11987, 83:17954, 248:24311). */
export class GalleryService {
  private readonly prisma: PrismaClient
  private readonly storage: Storage
  private readonly settings: SettingsService
  constructor (prisma: PrismaClient, storage: Storage, settings: SettingsService) {
    this.prisma = prisma
    this.storage = storage
    this.settings = settings
  }

  private where (user: AuthUser, q: GalleryQuery): Prisma.PhotoWhereInput {
    const and: Prisma.PhotoWhereInput[] = [{ status: 'READY', kind: q.type ?? { in: [...GALLERY_KINDS] } }]
    if (user.role === 'AGENT') and.push({ uploadedById: user.id })
    else if (q.agentId) and.push({ uploadedById: q.agentId })
    if (q.shopId) and.push({ OR: [{ shopId: q.shopId }, { audit: { shopId: q.shopId } }] })
    if (q.regionId) and.push({ OR: [{ shop: { regionId: q.regionId } }, { audit: { shop: { regionId: q.regionId } } }] })
    if (q.verified !== undefined) and.push({ verifiedAt: q.verified ? { not: null } : null })
    if (q.from || q.to) and.push({ takenAt: { ...(q.from ? { gte: new Date(q.from) } : {}), ...(q.to ? { lt: new Date(q.to) } : {}) } })
    if (q.q) {
      const m = { contains: q.q, mode: 'insensitive' as const }
      and.push({ OR: [{ shop: { name: m } }, { audit: { shop: { name: m } } }, { uploadedBy: { agent: { fullName: m } } }] })
    }
    return { AND: and }
  }

  async list (user: AuthUser, q: GalleryQuery) {
    const limit = q.limit ?? 24
    const where = this.where(user, q)
    const cur = decodeCursor(q.cursor)
    const rows = await this.prisma.photo.findMany({
      where: cur ? { AND: [where, { OR: [{ takenAt: { lt: cur.at } }, { takenAt: cur.at, id: { lt: cur.id } }] }] } : where,
      include,
      orderBy: [{ takenAt: 'desc' }, { id: 'desc' }],
      take: limit + 1
    })
    const page = rows.slice(0, limit)
    const last = page.at(-1)
    return {
      items: await Promise.all(page.map((p) => this.item(p))),
      nextCursor: rows.length > limit && last ? encodeCursor(last.takenAt, last.id) : null,
      ...(q.groups ? { groups: await this.groups(where) } : {})
    }
  }

  private async groups (where: Prisma.PhotoWhereInput) {
    const tz = (await this.settings.get()).timezone
    const all = await this.prisma.photo.findMany({ where, select: { takenAt: true } })
    const counts = new Map<string, number>()
    for (const p of all) { const d = localDate(p.takenAt, tz); counts.set(d, (counts.get(d) ?? 0) + 1) }
    return [...counts.entries()].sort((a, b) => b[0].localeCompare(a[0])).map(([date, count]) => ({ date, count }))
  }

  async summary (user: AuthUser) {
    const tz = (await this.settings.get()).timezone
    const where = this.where(user, {})
    const [total, today] = await Promise.all([
      this.prisma.photo.count({ where }),
      this.prisma.photo.count({ where: { AND: [where, { takenAt: { gte: startOfLocalDay(localDate(new Date(), tz), tz) } }] } })
    ])
    return { total, today }
  }

  async detail (user: AuthUser, id: string) {
    const p = await this.prisma.photo.findFirst({ where: { AND: [{ id }, this.where(user, {})] }, include })
    if (p == null) throw notFound('Photo')
    const shopId = p.audit?.shop.id ?? p.shop?.id
    const related = await this.prisma.photo.findMany({
      where: { id: { not: p.id }, status: 'READY', ...(p.auditId ? { auditId: p.auditId } : shopId ? { OR: [{ shopId }, { audit: { shopId } }] } : { uploadedById: p.uploadedById }) },
      include,
      orderBy: { takenAt: 'desc' },
      take: 12
    })
    const shop = shopId == null
      ? null
      : await this.prisma.shop.findUnique({ where: { id: shopId }, include: { assignedAgent: { select: { userId: true, fullName: true, phone: true } }, contacts: { orderBy: { position: 'asc' }, take: 1 } } })
    return {
      ...await this.item(p),
      lat: p.lat,
      lng: p.lng,
      accuracyM: p.accuracyM,
      shop: shop == null
        ? null
        : {
            id: shop.id, name: shop.name, code: shop.code, address: shop.address, status: shop.status, lat: shop.lat, lng: shop.lng,
            facade: shop.facadePhotoId == null ? null : await this.facade(shop.facadePhotoId),
            phone: shop.contacts[0]?.phone ?? null,
            agent: shop.assignedAgent == null ? null : { id: shop.assignedAgent.userId, fullName: shop.assignedAgent.fullName, phone: shop.assignedAgent.phone }
          },
      audit: p.audit == null
        ? null
        : { id: p.audit.id, comment: p.audit.comment, hasViolation: p.audit.hasViolation, startedAt: p.audit.startedAtDevice.toISOString(), finishedAt: p.audit.finishedAtDevice.toISOString(), durationMin: p.audit.durationMin, withinRadius: p.audit.withinRadius },
      related: await Promise.all(related.map((r) => this.item(r)))
    }
  }

  private async facade (photoId: string) {
    const f = await this.prisma.photo.findUnique({ where: { id: photoId } })
    return f?.status === 'READY' ? photoView(this.storage, f) : null
  }

  private async item (p: Row) {
    const shop = p.audit?.shop ?? p.shop
    return {
      ...await photoView(this.storage, p),
      kind: p.kind,
      verified: p.verifiedAt != null,
      auditId: p.auditId,
      shop: shop == null ? null : { id: shop.id, name: shop.name, code: shop.code, address: shop.address },
      agent: p.uploadedBy.agent == null ? null : { id: p.uploadedBy.id, fullName: p.uploadedBy.agent.fullName, code: p.uploadedBy.agent.code, phone: p.uploadedBy.agent.phone }
    }
  }
}
