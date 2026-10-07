import { Prisma, type PrismaClient } from '../../generated/prisma/client.js'
import { newId } from '../../lib/ids.js'

export const shopInclude = {
  region: true,
  assignedAgent: { select: { userId: true, fullName: true, code: true, phone: true } },
  contacts: { orderBy: { position: 'asc' } }
} as const
export type ShopRow = Prisma.ShopGetPayload<{ include: typeof shopInclude }>

export interface ShopFilter { q?: string, status?: 'PENDING_REVIEW' | 'ACTIVE' | 'INACTIVE', regionId?: string, agentId?: string }

export class ShopsRepository {
  private readonly prisma: PrismaClient
  constructor (prisma: PrismaClient) { this.prisma = prisma }

  where (f: ShopFilter): Prisma.ShopWhereInput {
    const where: Prisma.ShopWhereInput = { deletedAt: null }
    if (f.status) where.status = f.status
    if (f.regionId) where.regionId = f.regionId
    if (f.agentId) where.assignedAgentId = f.agentId
    if (f.q) {
      // Trigram-indexed ILIKE (migration: gin_trgm_ops on name, code, ownerName, address).
      where.OR = ['name', 'code', 'ownerName', 'address'].map((k) => ({ [k]: { contains: f.q, mode: 'insensitive' } }))
    }
    return where
  }

  async list (f: ShopFilter, orderBy: Prisma.ShopOrderByWithRelationInput, skip: number, take: number) {
    const where = this.where(f)
    const [items, total] = await this.prisma.$transaction([
      this.prisma.shop.findMany({ where, include: shopInclude, orderBy: [orderBy, { id: 'asc' }], skip, take }),
      this.prisma.shop.count({ where })
    ])
    return { items, total }
  }

  all (f: ShopFilter) {
    return this.prisma.shop.findMany({ where: this.where(f), include: shopInclude, orderBy: { code: 'asc' } })
  }

  get (id: string) {
    return this.prisma.shop.findFirst({ where: { id, deletedAt: null }, include: shopInclude })
  }

  findAny (id: string) {
    return this.prisma.shop.findUnique({ where: { id }, include: shopInclude })
  }

  /** Latest audit per shop (time + performer) for list rows. */
  async lastVisits (shopIds: string[]) {
    if (shopIds.length === 0) return new Map<string, { at: Date, agentName: string }>()
    const rows = await this.prisma.$queryRaw<Array<{ shopId: string, at: Date, agentName: string }>>`
      SELECT DISTINCT ON (a."shopId") a."shopId", a."finishedAtDevice" AS at, ag."fullName" AS "agentName"
      FROM "Audit" a JOIN "Agent" ag ON ag."userId" = a."agentId"
      WHERE a."shopId" = ANY(${shopIds}::uuid[])
      ORDER BY a."shopId", a."finishedAtDevice" DESC`
    return new Map(rows.map((r) => [r.shopId, { at: r.at, agentName: r.agentName }]))
  }

  /** The region whose centroid is closest to a point (the edit dialog has no region field). */
  async nearestRegion (lat: number, lng: number): Promise<string | null> {
    const regions = await this.prisma.region.findMany({ where: { centroidLat: { not: null }, centroidLng: { not: null } } })
    let best: { id: string, d: number } | null = null
    for (const r of regions) {
      const d = (r.centroidLat! - lat) ** 2 + ((r.centroidLng! - lng) * Math.cos(lat * Math.PI / 180)) ** 2
      if (best == null || d < best.d) best = { id: r.id, d }
    }
    return best?.id ?? null
  }

  async nextCode (): Promise<string> {
    const [row] = await this.prisma.$queryRaw<Array<{ n: bigint }>>`SELECT nextval('shop_code_seq') AS n`
    return `CL-${row!.n}`
  }

  create (data: Omit<Prisma.ShopUncheckedCreateInput, 'code' | 'id'> & { id?: string }, contacts: Array<{ phone: string, label?: string | null }>) {
    return this.prisma.$transaction(async (tx) => {
      const [row] = await tx.$queryRaw<Array<{ n: bigint }>>`SELECT nextval('shop_code_seq') AS n`
      const id = data.id ?? newId()
      await tx.shop.create({
        data: {
          ...data,
          id,
          code: `CL-${row!.n}`,
          contacts: { create: contacts.map((c, position) => ({ id: newId(), phone: c.phone, label: c.label ?? null, position })) }
        }
      })
      if (data.assignedAgentId) await tx.shopAssignment.create({ data: { id: newId(), shopId: id, agentId: data.assignedAgentId, from: new Date() } })
      return tx.shop.findUniqueOrThrow({ where: { id }, include: shopInclude })
    })
  }

  /** Optimistic update; reassignment closes the open assignment row and opens a new one. */
  async update (id: string, version: number, data: Prisma.ShopUncheckedUpdateManyInput, reassignTo?: string | null): Promise<boolean> {
    return this.prisma.$transaction(async (tx) => {
      const { count } = await tx.shop.updateMany({ where: { id, version, deletedAt: null }, data: { ...data, version: { increment: 1 } } })
      if (count === 1 && reassignTo !== undefined) await this.reassign(tx, [id], reassignTo)
      return count === 1
    })
  }

  private async reassign (tx: Prisma.TransactionClient, shopIds: string[], agentId: string | null) {
    const now = new Date()
    await tx.shopAssignment.updateMany({ where: { shopId: { in: shopIds }, to: null }, data: { to: now } })
    await tx.shopAssignment.createMany({ data: shopIds.map((shopId) => ({ id: newId(), shopId, agentId, from: now })) })
    await tx.shop.updateMany({ where: { id: { in: shopIds } }, data: { assignedAgentId: agentId } })
  }

  bulkAssign (shopIds: string[], agentId: string | null) {
    return this.prisma.$transaction((tx) => this.reassign(tx, shopIds, agentId))
  }

  /** Soft delete; audits and photos stay. Removes the shops from today's and future planned stops. */
  bulkDelete (shopIds: string[]) {
    const today = new Date(new Date().toISOString().slice(0, 10))
    return this.prisma.$transaction([
      this.prisma.shop.updateMany({ where: { id: { in: shopIds }, deletedAt: null }, data: { deletedAt: new Date() } }),
      this.prisma.routeStop.deleteMany({ where: { shopId: { in: shopIds }, status: 'PLANNED', route: { date: { gte: today } } } })
    ])
  }

  replaceContacts (shopId: string, contacts: Array<{ phone: string, label?: string | null }>) {
    return this.prisma.$transaction([
      this.prisma.shopContact.deleteMany({ where: { shopId } }),
      this.prisma.shopContact.createMany({ data: contacts.map((c, position) => ({ id: newId(), shopId, phone: c.phone, label: c.label ?? null, position })) }),
      this.prisma.shop.update({ where: { id: shopId }, data: { version: { increment: 1 } } })
    ])
  }

  /** Agent sync: own changed shops and ids that left the agent's set since `after`. */
  async syncChanges (agentId: string, after: Date) {
    const items = await this.prisma.shop.findMany({
      where: { assignedAgentId: agentId, deletedAt: null, status: { not: 'INACTIVE' }, updatedAt: { gt: after } },
      include: shopInclude,
      orderBy: { updatedAt: 'asc' }
    })
    const gone = await this.prisma.shop.findMany({
      where: {
        updatedAt: { gt: after },
        OR: [
          { assignedAgentId: agentId, OR: [{ deletedAt: { not: null } }, { status: 'INACTIVE' }] },
          { assignments: { some: { agentId, to: { gt: after } } }, NOT: { assignedAgentId: agentId } }
        ]
      },
      select: { id: true }
    })
    return { items, tombstones: gone.map((s) => s.id) }
  }

  kpis (shopId: string) {
    const since = new Date(Date.now() - 90 * 86_400_000)
    return Promise.all([
      this.prisma.audit.count({ where: { shopId } }),
      this.prisma.audit.findFirst({ where: { shopId }, orderBy: { finishedAtDevice: 'desc' }, select: { finishedAtDevice: true } }),
      this.prisma.shopProduct.count({ where: { shopId } }),
      this.prisma.audit.count({ where: { shopId, finishedAtDevice: { gte: since } } }),
      this.prisma.audit.count({ where: { shopId, finishedAtDevice: { gte: since }, hasViolation: false } }),
      this.prisma.photo.count({ where: { kind: 'AUDIT', audit: { shopId } } }),
      this.prisma.photo.count({ where: { kind: 'AUDIT', audit: { shopId }, lat: { not: null } } })
    ])
  }

  visitTotals (shopId: string) {
    return Promise.all([
      this.prisma.audit.count({ where: { shopId } }),
      this.prisma.routeStop.count({ where: { shopId, status: 'MISSED' } })
    ])
  }

  auditsBefore (shopId: string, before: Date | null, take: number) {
    return this.prisma.audit.findMany({
      where: { shopId, ...(before ? { finishedAtDevice: { lt: before } } : {}) },
      orderBy: { finishedAtDevice: 'desc' },
      take,
      include: { agent: { select: { userId: true, fullName: true } }, photos: { where: { status: 'READY' }, orderBy: { takenAt: 'asc' } } }
    })
  }

  missedBefore (shopId: string, before: Date | null, take: number) {
    return this.prisma.routeStop.findMany({
      where: { shopId, status: 'MISSED', ...(before ? { plannedAt: { lt: before } } : {}) },
      orderBy: { plannedAt: 'desc' },
      take,
      include: { route: { select: { agent: { select: { userId: true, fullName: true } } } } }
    })
  }

  mapShops (where: Prisma.ShopWhereInput) {
    return this.prisma.shop.findMany({
      where: { deletedAt: null, ...where },
      select: { id: true, code: true, name: true, address: true, lat: true, lng: true, status: true, assignedAgentId: true, facadePhotoId: true, lastVisitAt: true, nextDueAt: true },
      orderBy: { code: 'asc' }
    })
  }

  /** Shops on the agent's route for the date that are still to visit. */
  async plannedToday (agentId: string | null, date: Date) {
    const stops = await this.prisma.routeStop.findMany({
      where: { route: { date, ...(agentId ? { agentId } : {}) }, status: { in: ['PLANNED', 'IN_PROGRESS'] } },
      select: { shopId: true }
    })
    return new Set(stops.map((s) => s.shopId))
  }

  isAssigned (shopId: string, agentId: string) {
    return this.prisma.shop.count({ where: { id: shopId, assignedAgentId: agentId, deletedAt: null } }).then((n) => n > 0)
  }
}

export const isUniqueViolation = (e: unknown): boolean => e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002'
