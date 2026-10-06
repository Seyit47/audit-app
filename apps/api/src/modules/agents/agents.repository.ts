import { Prisma, type PrismaClient } from '../../generated/prisma/client.js'
import { newId } from '../../lib/ids.js'

const detail = { user: { select: { status: true, deactivatedAt: true, lastActiveAt: true } }, region: true, device: true, position: true } as const
export type AgentDetail = Prisma.AgentGetPayload<{ include: typeof detail }>

export interface AgentFilter { q?: string, status?: 'ACTIVE' | 'ON_LEAVE' | 'INACTIVE', regionId?: string }

export class AgentsRepository {
  private readonly prisma: PrismaClient
  constructor (prisma: PrismaClient) { this.prisma = prisma }

  private where (f: AgentFilter): Prisma.AgentWhereInput {
    const where: Prisma.AgentWhereInput = {}
    if (f.regionId) where.regionId = f.regionId
    if (f.q) {
      where.OR = [
        { fullName: { contains: f.q, mode: 'insensitive' } },
        { code: { contains: f.q, mode: 'insensitive' } },
        { phone: { contains: f.q.replace(/\s/g, '') } }
      ]
    }
    if (f.status === 'INACTIVE') where.user = { status: 'DEACTIVATED' }
    else if (f.status) { where.workStatus = f.status; where.user = { status: 'ACTIVE' } }
    return where
  }

  /** All matching agents (a company has ~100); the service sorts by period counts and pages. */
  listAll (f: AgentFilter) {
    return this.prisma.agent.findMany({ where: this.where(f), include: detail, orderBy: { code: 'asc' } })
  }

  get (id: string) {
    return this.prisma.agent.findUnique({ where: { userId: id }, include: detail })
  }

  /** Per-agent counts for list rows: assigned shops, audits and photos in the period. */
  async counts (agentIds: string[], from: Date, to: Date) {
    const [shops, audits, photos] = await Promise.all([
      this.prisma.shop.groupBy({ by: ['assignedAgentId'], where: { assignedAgentId: { in: agentIds }, deletedAt: null }, _count: true }),
      this.prisma.audit.groupBy({ by: ['agentId'], where: { agentId: { in: agentIds }, finishedAtDevice: { gte: from, lt: to } }, _count: true }),
      this.prisma.photo.groupBy({ by: ['uploadedById'], where: { uploadedById: { in: agentIds }, takenAt: { gte: from, lt: to } }, _count: true })
    ])
    return {
      shops: new Map(shops.map((r) => [r.assignedAgentId!, r._count])),
      audits: new Map(audits.map((r) => [r.agentId, r._count])),
      photos: new Map(photos.map((r) => [r.uploadedById, r._count]))
    }
  }

  /** The most audits by any active agent in the period ("Top Performer"). */
  async topAudits (from: Date, to: Date): Promise<number> {
    const rows = await this.prisma.audit.groupBy({
      by: ['agentId'], where: { finishedAtDevice: { gte: from, lt: to } }, _count: { _all: true }, orderBy: { _count: { agentId: 'desc' } }, take: 1
    })
    return rows[0]?._count._all ?? 0
  }

  /** The code the next agent would get, without using it up ("Сгенерировать код"). */
  async peekCode (): Promise<string> {
    const [row] = await this.prisma.$queryRaw<Array<{ n: bigint }>>`SELECT CASE WHEN is_called THEN last_value + 1 ELSE last_value END AS n FROM agent_code_seq`
    return `SL-${row!.n}`
  }

  async nextCode (): Promise<string> {
    const [row] = await this.prisma.$queryRaw<Array<{ n: bigint }>>`SELECT nextval('agent_code_seq') AS n`
    return `SL-${row!.n}`
  }

  create (data: { code: string, passwordHash: string, fullName: string, phone: string, whatsappPhone: string | null, regionId: string, photoId: string | null, routeNotes: string | null, dailyVisitPlan: number, dailyAuditPlan: number, workStatus: 'ACTIVE' | 'ON_LEAVE', imeiLabel: string | null }) {
    const id = newId()
    const { passwordHash, imeiLabel, ...agent } = data
    return this.prisma.$transaction(async (tx) => {
      await tx.user.create({ data: { id, role: 'AGENT', phone: data.phone, passwordHash } })
      return tx.agent.create({
        data: { userId: id, ...agent, device: { create: { id: newId(), imeiLabel } } },
        include: detail
      })
    })
  }

  /** Optimistic update: false when the version is stale. */
  async update (id: string, version: number, data: Prisma.AgentUncheckedUpdateManyInput, phone?: string): Promise<boolean> {
    return this.prisma.$transaction(async (tx) => {
      const { count } = await tx.agent.updateMany({ where: { userId: id, version }, data: { ...data, version: { increment: 1 } } })
      if (count === 1 && phone != null) await tx.user.update({ where: { id }, data: { phone } })
      return count === 1
    })
  }

  setImeiLabel (id: string, imeiLabel: string | null) {
    return this.prisma.device.upsert({ where: { agentId: id }, update: { imeiLabel }, create: { id: newId(), agentId: id, imeiLabel } })
  }

  /**
   * Deactivates the account and unassigns its shops (closing assignment history). Sessions are kept:
   * for 72 h they may only submit data recorded before deactivation (auth guard + grace routes).
   */
  deactivate (id: string) {
    const now = new Date()
    return this.prisma.$transaction(async (tx) => {
      await tx.user.update({ where: { id }, data: { status: 'DEACTIVATED', deactivatedAt: now } })
      const shops = await tx.shop.findMany({ where: { assignedAgentId: id }, select: { id: true } })
      const shopIds = shops.map((s) => s.id)
      await tx.shopAssignment.updateMany({ where: { shopId: { in: shopIds }, to: null }, data: { to: now } })
      await tx.shopAssignment.createMany({ data: shopIds.map((shopId) => ({ id: newId(), shopId, agentId: null, from: now })) })
      await tx.shop.updateMany({ where: { id: { in: shopIds } }, data: { assignedAgentId: null } })
    })
  }

  reactivate (id: string) {
    return this.prisma.user.update({ where: { id }, data: { status: 'ACTIVE', deactivatedAt: null } })
  }

  setPassword (id: string, passwordHash: string) {
    return this.prisma.$transaction([
      this.prisma.user.update({ where: { id }, data: { passwordHash } }),
      this.prisma.refreshToken.updateMany({ where: { userId: id, revokedAt: null }, data: { revokedAt: new Date() } })
    ])
  }

  /** Clears the binding so the next sign-in binds a new phone; ends its sessions. */
  rebindDevice (id: string, imeiLabel: string | null | undefined) {
    return this.prisma.$transaction([
      this.prisma.device.upsert({
        where: { agentId: id },
        update: { installId: null, model: null, boundAt: null, ...(imeiLabel !== undefined ? { imeiLabel } : {}) },
        create: { id: newId(), agentId: id, imeiLabel: imeiLabel ?? null }
      }),
      this.prisma.refreshToken.updateMany({ where: { userId: id, revokedAt: null }, data: { revokedAt: new Date() } })
    ])
  }
}

export const isUniqueViolation = (e: unknown): boolean => e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002'
