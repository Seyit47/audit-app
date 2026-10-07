import { Prisma, type PrismaClient } from '../../generated/prisma/client.js'

export const auditInclude = {
  shop: { select: { id: true, name: true, code: true, address: true } },
  agent: { select: { userId: true, fullName: true, code: true } },
  photos: { orderBy: { takenAt: 'asc' } }
} as const
export type AuditRow = Prisma.AuditGetPayload<{ include: typeof auditInclude }>

/** Audits are insert-only (Constitution VII): this repository has no update or delete. */
export class AuditsRepository {
  private readonly prisma: PrismaClient
  constructor (prisma: PrismaClient) { this.prisma = prisma }

  get (id: string) {
    return this.prisma.audit.findUnique({ where: { id }, include: auditInclude })
  }

  list (where: Prisma.AuditWhereInput, take: number) {
    return this.prisma.audit.findMany({ where, include: auditInclude, orderBy: [{ finishedAtDevice: 'desc' }, { id: 'desc' }], take })
  }

  shop (id: string) {
    return this.prisma.shop.findUnique({ where: { id }, select: { id: true, lat: true, lng: true, auditRadiusM: true, assignedAgentId: true, deletedAt: true } })
  }

  /** Was the agent assigned the shop at that instant (assignment history)? */
  async wasAssigned (shopId: string, agentId: string, at: Date): Promise<boolean> {
    const n = await this.prisma.shopAssignment.count({
      where: { shopId, agentId, from: { lte: at }, OR: [{ to: null }, { to: { gt: at } }] }
    })
    return n > 0
  }

  photos (ids: string[]) {
    return this.prisma.photo.findMany({ where: { id: { in: ids } } })
  }

  /** Inserts the audit and links photos, shop and stop in one transaction. */
  create (data: {
    audit: Prisma.AuditUncheckedCreateInput
    photoIds: string[]
    verify: boolean
    shopId: string
    nextDueAt: Date
    stopId: string | null
  }) {
    return this.prisma.$transaction(async (tx) => {
      await tx.audit.create({ data: data.audit })
      const linked = await tx.photo.updateMany({
        where: { id: { in: data.photoIds }, auditId: null },
        data: { auditId: data.audit.id, ...(data.verify ? { verifiedAt: new Date() } : {}) }
      })
      if (linked.count !== data.photoIds.length) throw new PhotoAlreadyLinked()
      await tx.shop.update({ where: { id: data.shopId }, data: { lastVisitAt: data.audit.finishedAtDevice, nextDueAt: data.nextDueAt } })
      if (data.stopId != null) await tx.routeStop.update({ where: { id: data.stopId }, data: { status: 'DONE', auditId: data.audit.id } })
    })
  }

  /** Today's open stop for this agent and shop, or the given one when it belongs to the agent. */
  async stopFor (agentId: string, shopId: string, routeStopId: string | null | undefined, date: Date) {
    const stop = await this.prisma.routeStop.findFirst({
      where: routeStopId != null
        ? { id: routeStopId, shopId, route: { agentId }, auditId: null }
        : { shopId, route: { agentId, date }, status: { in: ['PLANNED', 'IN_PROGRESS'] }, auditId: null },
      select: { id: true }
    })
    return stop?.id ?? null
  }
}

export class PhotoAlreadyLinked extends Error {}
export const isUniqueViolation = (e: unknown): boolean => e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002'
