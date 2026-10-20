import { Prisma, type PrismaClient } from '../../generated/prisma/client.js'
import type { AssignMode } from './shops.schema.js'
import { newId } from '../../lib/ids.js'

/** The shop's agents: its open assignment rows (a shop can have several). */
export const currentAgents = { where: { to: null, agentId: { not: null } }, orderBy: { from: 'asc' } } as const

/** Shops the agent is assigned to now. */
export const assignedTo = (agentId: string): Prisma.ShopWhereInput => ({ assignments: { some: { agentId, to: null } } })

export const shopInclude = {
  district: true,
  assignments: { ...currentAgents, include: { agent: { select: { userId: true, fullName: true, code: true, phone: true } } } },
  contacts: { orderBy: { position: 'asc' } }
} as const
export type ShopRow = Prisma.ShopGetPayload<{ include: typeof shopInclude }>

/** [districtId] 'none': shops without a district (from before districts). */
export interface ShopFilter { q?: string, status?: 'PENDING_REVIEW' | 'ACTIVE' | 'INACTIVE', districtId?: string, agentId?: string }

/** The storefront photo belongs to its shop, so the gallery files it there (an upload has no shop yet). */
const linkPhoto = (tx: Prisma.TransactionClient, photoId: string, shopId: string) =>
  tx.photo.updateMany({ where: { id: photoId, shopId: null, auditId: null }, data: { shopId } })

export class ShopsRepository {
  private readonly prisma: PrismaClient
  constructor (prisma: PrismaClient) { this.prisma = prisma }

  where (f: ShopFilter): Prisma.ShopWhereInput {
    const where: Prisma.ShopWhereInput = { deletedAt: null }
    if (f.status) where.status = f.status
    if (f.districtId) where.districtId = f.districtId === 'none' ? null : f.districtId
    if (f.agentId) Object.assign(where, assignedTo(f.agentId))
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

  async nextCode (): Promise<string> {
    const [row] = await this.prisma.$queryRaw<Array<{ n: bigint }>>`SELECT nextval('shop_code_seq') AS n`
    return `CL-${row!.n}`
  }

  create (data: Omit<Prisma.ShopUncheckedCreateInput, 'code' | 'id'> & { id?: string }, contacts: Array<{ phone: string, label?: string | null }>, agentIds: string[]) {
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
      if (agentIds.length > 0) await tx.shopAssignment.createMany({ data: agentIds.map((agentId) => ({ id: newId(), shopId: id, agentId, from: new Date() })) })
      if (data.facadePhotoId) await linkPhoto(tx, data.facadePhotoId, id)
      return tx.shop.findUniqueOrThrow({ where: { id }, include: shopInclude })
    })
  }

  /** Optimistic update; [agentIds] (when given) become the shop's agents. */
  async update (id: string, version: number, data: Prisma.ShopUncheckedUpdateManyInput, agentIds?: string[]): Promise<boolean> {
    return this.prisma.$transaction(async (tx) => {
      const { count } = await tx.shop.updateMany({ where: { id, version, deletedAt: null }, data: { ...data, version: { increment: 1 } } })
      if (count === 1 && agentIds !== undefined) await this.setAgents(tx, [id], agentIds)
      if (count === 1 && typeof data.facadePhotoId === 'string') await linkPhoto(tx, data.facadePhotoId, id)
      return count === 1
    })
  }

  /**
   * Makes [agentIds] the shops' agents: assignments of others end now, new ones start now (the history stays,
   * for offline audits made before a change). The shops' updatedAt moves, so the agents' phones pick it up.
   */
  private async setAgents (tx: Prisma.TransactionClient, shopIds: string[], agentIds: string[]) {
    const now = new Date()
    await tx.shopAssignment.updateMany({
      where: { shopId: { in: shopIds }, to: null, OR: [{ agentId: null }, { agentId: { notIn: agentIds } }] },
      data: { to: now }
    })
    const open = await tx.shopAssignment.findMany({ where: { shopId: { in: shopIds }, to: null }, select: { shopId: true, agentId: true } })
    const have = new Set(open.map((a) => `${a.shopId}/${a.agentId}`))
    const add = shopIds.flatMap((shopId) => agentIds.filter((agentId) => !have.has(`${shopId}/${agentId}`)).map((agentId) => ({ id: newId(), shopId, agentId, from: now })))
    if (add.length > 0) await tx.shopAssignment.createMany({ data: add })
    await tx.shop.updateMany({ where: { id: { in: shopIds } }, data: { updatedAt: now } })
  }

  /** Bulk "Назначить": [agentIds] become the shops' agents, join them, or leave them. */
  bulkAssign (shopIds: string[], agentIds: string[], mode: AssignMode) {
    return this.prisma.$transaction(async (tx) => {
      if (mode === 'replace') return this.setAgents(tx, shopIds, agentIds)
      const now = new Date()
      if (mode === 'remove') {
        await tx.shopAssignment.updateMany({ where: { shopId: { in: shopIds }, to: null, agentId: { in: agentIds } }, data: { to: now } })
      } else {
        const open = await tx.shopAssignment.findMany({ where: { shopId: { in: shopIds }, to: null }, select: { shopId: true, agentId: true } })
        const have = new Set(open.map((a) => `${a.shopId}/${a.agentId}`))
        const add = shopIds.flatMap((shopId) => agentIds.filter((agentId) => !have.has(`${shopId}/${agentId}`)).map((agentId) => ({ id: newId(), shopId, agentId, from: now })))
        if (add.length > 0) await tx.shopAssignment.createMany({ data: add })
      }
      await tx.shop.updateMany({ where: { id: { in: shopIds } }, data: { updatedAt: now } })
    })
  }

  async districtExists (id: string) {
    return await this.prisma.district.count({ where: { id } }) > 0
  }

  /** Bulk "Перенести в район" (null: no district); the agents' phones pick the change up on their next sync. */
  bulkDistrict (shopIds: string[], districtId: string | null) {
    return this.prisma.shop.updateMany({
      where: { id: { in: shopIds }, deletedAt: null },
      data: { districtId, version: { increment: 1 }, updatedAt: new Date() }
    })
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
      where: { ...assignedTo(agentId), deletedAt: null, status: { not: 'INACTIVE' }, updatedAt: { gt: after } },
      include: shopInclude,
      orderBy: { updatedAt: 'asc' }
    })
    const gone = await this.prisma.shop.findMany({
      where: {
        updatedAt: { gt: after },
        OR: [
          { ...assignedTo(agentId), OR: [{ deletedAt: { not: null } }, { status: 'INACTIVE' }] },
          { assignments: { some: { agentId, to: { gt: after } } }, NOT: assignedTo(agentId) }
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

  /** Audits per shop for the admin list cards (246:23300 "32 аудита всего"). */
  async auditCounts (shopIds: string[]) {
    const rows = await this.prisma.audit.groupBy({ by: ['shopId'], where: { shopId: { in: shopIds } }, _count: true })
    return new Map(rows.map((r) => [r.shopId, r._count]))
  }

  mapShops (where: Prisma.ShopWhereInput) {
    return this.prisma.shop.findMany({
      where: { deletedAt: null, ...where },
      select: { id: true, code: true, name: true, address: true, lat: true, lng: true, auditRadiusM: true, status: true, districtId: true, facadePhotoId: true, lastVisitAt: true, nextDueAt: true, assignments: { ...currentAgents, select: { agentId: true } } },
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
    return this.prisma.shop.count({ where: { id: shopId, deletedAt: null, ...assignedTo(agentId) } }).then((n) => n > 0)
  }
}

export const isUniqueViolation = (e: unknown): boolean => e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002'
