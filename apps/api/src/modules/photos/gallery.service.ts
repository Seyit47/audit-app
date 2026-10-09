import { Type, type Static } from '@sinclair/typebox'
import { Prisma, type PrismaClient } from '../../generated/prisma/client.js'
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
/** The admin web gallery counts audit photos only (type=AUDIT). */
export const GallerySummaryQuery = Type.Pick(GalleryQuery, ['type'], { additionalProperties: false })
export type GallerySummaryQuery = Static<typeof GallerySummaryQuery>

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
    // Only photos filed under a shop or an audit: an upload whose form was abandoned belongs nowhere.
    const and: Prisma.PhotoWhereInput[] = [{ status: 'READY', kind: q.type ?? { in: [...GALLERY_KINDS] }, OR: [{ shopId: { not: null } }, { auditId: { not: null } }] }]
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
      ...(q.groups ? { groups: await this.groups(user, q) } : {})
    }
  }

  /** Per-day counts of the filtered set, counted in SQL (the same filters as [where]). */
  private async groups (user: AuthUser, q: GalleryQuery) {
    const tz = (await this.settings.get()).timezone
    const cond: Prisma.Sql[] = [Prisma.sql`p."status" = 'READY'`, Prisma.sql`(p."shopId" IS NOT NULL OR p."auditId" IS NOT NULL)`, Prisma.sql`p."kind"::text = ANY(${q.type ? [q.type] : [...GALLERY_KINDS]})`]
    const uploader = user.role === 'AGENT' ? user.id : q.agentId
    if (uploader) cond.push(Prisma.sql`p."uploadedById" = ${uploader}::uuid`)
    if (q.shopId) cond.push(Prisma.sql`(p."shopId" = ${q.shopId}::uuid OR a."shopId" = ${q.shopId}::uuid)`)
    if (q.regionId) cond.push(Prisma.sql`(s."regionId" = ${q.regionId}::uuid OR sa."regionId" = ${q.regionId}::uuid)`)
    if (q.verified !== undefined) cond.push(q.verified ? Prisma.sql`p."verifiedAt" IS NOT NULL` : Prisma.sql`p."verifiedAt" IS NULL`)
    if (q.from) cond.push(Prisma.sql`p."takenAt" >= ${new Date(q.from)}`)
    if (q.to) cond.push(Prisma.sql`p."takenAt" < ${new Date(q.to)}`)
    if (q.q) {
      const like = `%${q.q}%`
      cond.push(Prisma.sql`(s."name" ILIKE ${like} OR sa."name" ILIKE ${like} OR g."fullName" ILIKE ${like})`)
    }
    const rows = await this.prisma.$queryRaw<Array<{ date: string, count: number }>>`
      SELECT to_char((p."takenAt" AT TIME ZONE ${tz})::date, 'YYYY-MM-DD') AS date, count(*)::int AS count
      FROM "Photo" p
      LEFT JOIN "Shop" s ON s."id" = p."shopId"
      LEFT JOIN "Audit" a ON a."id" = p."auditId"
      LEFT JOIN "Shop" sa ON sa."id" = a."shopId"
      LEFT JOIN "Agent" g ON g."userId" = p."uploadedById"
      WHERE ${Prisma.join(cond, ' AND ')}
      GROUP BY 1 ORDER BY 1 DESC`
    return rows
  }

  async summary (user: AuthUser, q: GallerySummaryQuery = {}) {
    const tz = (await this.settings.get()).timezone
    const where = this.where(user, { type: q.type })
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
    const related = shopId == null
      ? []
      : await this.prisma.photo.findMany({
        where: { id: { not: p.id }, status: 'READY', ...(p.auditId ? { auditId: p.auditId } : { OR: [{ shopId }, { audit: { shopId } }] }) },
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
