import { Prisma, type PrismaClient } from '../../generated/prisma/client.js'
import { newId } from '../../lib/ids.js'

const detail = { user: { select: { status: true, deactivatedAt: true, lastActiveAt: true } }, device: true, position: true } as const
export type AgentDetail = Prisma.AgentGetPayload<{ include: typeof detail }>

/**
 * When the server received each agent's latest ping, by the server's own clock. "Online" compares this with
 * the server's now: the ping's `recordedAt` is the phone's clock, and the two clocks may differ (the
 * production server runs hours ahead). One index lookup per agent.
 */
export async function lastSignalAt (prisma: PrismaClient, agentIds: string[]): Promise<Map<string, Date>> {
  if (agentIds.length === 0) return new Map()
  const rows = await prisma.$queryRaw<Array<{ agentId: string, receivedAt: Date }>>`
    SELECT a.id::text AS "agentId", p."receivedAt"
    FROM unnest(${agentIds}::uuid[]) AS a(id)
    CROSS JOIN LATERAL (
      SELECT "receivedAt" FROM "LocationPing" WHERE "agentId" = a.id ORDER BY "recordedAt" DESC LIMIT 1
    ) p`
  return new Map(rows.map((r) => [r.agentId, r.receivedAt]))
}

export interface AgentFilter { q?: string, status?: 'ACTIVE' | 'ON_LEAVE' | 'INACTIVE' }

export class AgentsRepository {
  private readonly prisma: PrismaClient
  constructor (prisma: PrismaClient) { this.prisma = prisma }

  lastSignal (agentIds: string[]) { return lastSignalAt(this.prisma, agentIds) }

  private where (f: AgentFilter): Prisma.AgentWhereInput {
    const where: Prisma.AgentWhereInput = {}
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
      // A shop counts for each of its agents.
      this.prisma.shopAssignment.groupBy({ by: ['agentId'], where: { agentId: { in: agentIds }, to: null, shop: { deletedAt: null } }, _count: true }),
      this.prisma.audit.groupBy({ by: ['agentId'], where: { agentId: { in: agentIds }, finishedAtDevice: { gte: from, lt: to } }, _count: true }),
      // Audit photos only, as the gallery and the agent's KPIs count them (no storefronts).
      this.prisma.photo.groupBy({ by: ['uploadedById'], where: { uploadedById: { in: agentIds }, kind: 'AUDIT', status: 'READY', takenAt: { gte: from, lt: to } }, _count: true })
    ])
    return {
      shops: new Map(shops.map((r) => [r.agentId!, r._count])),
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
  /**
   * The next free SL- number: past the counter and past every SL-<n> already used. The admin form sends the
   * previewed code back (so the counter alone never moved on) and codes can be typed by hand.
   */
  private readonly nextFree = Prisma.sql`GREATEST(
    (SELECT CASE WHEN is_called THEN last_value + 1 ELSE last_value END FROM agent_code_seq),
    (SELECT COALESCE(MAX(substring("code" FROM 4)::bigint), 0) + 1 FROM "Agent" WHERE "code" ~ '^SL-[0-9]{1,18}$')
  )`

  async peekCode (): Promise<string> {
    const [row] = await this.prisma.$queryRaw<Array<{ n: bigint }>>`SELECT ${this.nextFree} AS n`
    return `SL-${row!.n}`
  }

  /** Takes the next free code (the counter moves to it). */
  async nextCode (): Promise<string> {
    const [row] = await this.prisma.$queryRaw<Array<{ n: bigint }>>`SELECT setval('agent_code_seq', ${this.nextFree}) AS n`
    return `SL-${row!.n}`
  }

  create (data: { code: string, passwordHash: string, fullName: string, phone: string, whatsappPhone: string | null, photoId: string | null, routeNotes: string | null, dailyVisitPlan: number, dailyAuditPlan: number, workStatus: 'ACTIVE' | 'ON_LEAVE', imeiLabel: string | null }) {
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
   * Deactivates the account and takes it off its shops (closing its assignments; other agents stay). Sessions are kept:
   * for 72 h they may only submit data recorded before deactivation (auth guard + grace routes).
   */
  deactivate (id: string) {
    const now = new Date()
    return this.prisma.$transaction(async (tx) => {
      await tx.user.update({ where: { id }, data: { status: 'DEACTIVATED', deactivatedAt: now } })
      const open = await tx.shopAssignment.findMany({ where: { agentId: id, to: null }, select: { shopId: true } })
      await tx.shopAssignment.updateMany({ where: { agentId: id, to: null }, data: { to: now } })
      await tx.shop.updateMany({ where: { id: { in: open.map((a) => a.shopId) } }, data: { updatedAt: now } })
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
