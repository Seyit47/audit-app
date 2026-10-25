import type { PrismaClient } from '../../generated/prisma/client.js'
import { newId } from '../../lib/ids.js'
import { AppError, conflict, notFound } from '../../lib/app-error.js'
import { isUniqueViolation } from '../shops/shops.repository.js'
import { visitState } from '../shops/shops.service.js'
import type { SettingsService } from '../settings/settings.service.js'
import { localDate, startOfLocalDay } from '../../lib/time.js'

/** A district card: its shops, the agents working them, and today's visits. */
export interface DistrictStats { id: string | null, name: string | null, shops: number, agents: number, visitedToday: number, overdue: number }

/** Districts: where shops are; the shop lists start with them. Admins add, rename and delete them. */
export class DistrictsRepository {
  private readonly prisma: PrismaClient
  private readonly settings: SettingsService
  constructor (prisma: PrismaClient, settings: SettingsService) { this.prisma = prisma; this.settings = settings }

  /**
   * Every district with its shops (an agent's: their own), the agents assigned to them, and today's visited
   * and overdue shops (as the map's visit states); a last entry with no id for the shops without a district,
   * when there are any.
   */
  async list (agentId?: string): Promise<DistrictStats[]> {
    const tz = (await this.settings.get()).timezone
    const dayStart = startOfLocalDay(localDate(new Date(), tz), tz)
    const [districts, shops] = await Promise.all([
      this.prisma.district.findMany({ orderBy: { name: 'asc' }, include: { agents: { where: { agent: { user: { status: 'ACTIVE' } } }, select: { agentId: true } } } }),
      this.prisma.shop.findMany({
        where: {
          deletedAt: null,
          ...(agentId == null ? {} : { status: { not: 'INACTIVE' as const }, assignments: { some: { agentId, to: null } } })
        },
        select: { id: true, districtId: true, status: true, lastVisitAt: true, nextDueAt: true, assignments: { where: { to: null, agentId: { not: null } }, select: { agentId: true } } }
      })
    ])
    const by = new Map<string | null, { shops: number, agents: Set<string>, visitedToday: number, overdue: number }>()
    for (const s of shops) {
      const d = by.get(s.districtId) ?? { shops: 0, agents: new Set<string>(), visitedToday: 0, overdue: 0 }
      d.shops++
      for (const a of s.assignments) if (a.agentId != null) d.agents.add(a.agentId)
      if (s.status === 'ACTIVE') {
        const state = visitState(s, dayStart, new Set())
        if (state === 'VISITED') d.visitedToday++
        if (state === 'OVERDUE') d.overdue++
      }
      by.set(s.districtId, d)
    }
    // Agents: the ones linked to the district and the ones assigned to its shops by hand.
    const stats = (id: string | null, name: string | null, linked: string[] = []): DistrictStats => {
      const d = by.get(id)
      return { id, name, shops: d?.shops ?? 0, agents: new Set([...linked, ...(d?.agents ?? [])]).size, visitedToday: d?.visitedToday ?? 0, overdue: d?.overdue ?? 0 }
    }
    return [...districts.map((d) => stats(d.id, d.name, d.agents.map((a) => a.agentId))), ...(by.has(null) ? [stats(null, null)] : [])]
  }

  async create (name: string) {
    try {
      const d = await this.prisma.district.create({ data: { id: newId(), name: clean(name) } })
      return { id: d.id, name: d.name, shops: 0, agents: 0, visitedToday: 0, overdue: 0 }
    } catch (e) {
      if (isUniqueViolation(e)) throw conflict('A district with this name exists')
      throw e
    }
  }

  async rename (id: string, name: string) {
    if (await this.prisma.district.findUnique({ where: { id } }) == null) throw notFound('District')
    try {
      const d = await this.prisma.district.update({ where: { id }, data: { name: clean(name) } })
      return (await this.list()).find((x) => x.id === d.id)!
    } catch (e) {
      if (isUniqueViolation(e)) throw conflict('A district with this name exists')
      throw e
    }
  }

  /** A district with shops cannot be deleted (move them first). */
  async delete (id: string) {
    if (await this.prisma.district.findUnique({ where: { id } }) == null) throw notFound('District')
    if (await this.prisma.shop.count({ where: { districtId: id, deletedAt: null } }) > 0) throw conflict('The district has shops')
    await this.prisma.shop.updateMany({ where: { districtId: id }, data: { districtId: null } })
    await this.prisma.district.delete({ where: { id } })
  }
}

function clean (name: string) {
  const n = name.trim()
  if (n === '') throw new AppError(400, 'VALIDATION_FAILED', 'A name is required')
  return n
}
