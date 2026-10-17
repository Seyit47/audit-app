import type { PrismaClient } from '../../generated/prisma/client.js'
import { newId } from '../../lib/ids.js'
import { AppError, conflict, notFound } from '../../lib/app-error.js'
import { isUniqueViolation } from '../shops/shops.repository.js'

/** Districts: where shops are; the shop lists start with them. Admins add, rename and delete them. */
export class DistrictsRepository {
  private readonly prisma: PrismaClient
  constructor (prisma: PrismaClient) { this.prisma = prisma }

  /**
   * Every district with its shop count (an agent's: their own shops), and a last entry with no id for the
   * shops without a district (from before districts), when there are any.
   */
  async list (agentId?: string) {
    const where = {
      deletedAt: null,
      ...(agentId == null ? {} : { status: { not: 'INACTIVE' as const }, assignments: { some: { agentId, to: null } } })
    }
    const [districts, counts] = await Promise.all([
      this.prisma.district.findMany({ orderBy: { name: 'asc' } }),
      this.prisma.shop.groupBy({ by: ['districtId'], where, _count: true })
    ])
    const n = new Map(counts.map((c) => [c.districtId, c._count]))
    const none = n.get(null) ?? 0
    return [
      ...districts.map((d) => ({ id: d.id as string | null, name: d.name as string | null, shops: n.get(d.id) ?? 0 })),
      ...(none > 0 ? [{ id: null, name: null, shops: none }] : [])
    ]
  }

  async create (name: string) {
    try {
      const d = await this.prisma.district.create({ data: { id: newId(), name: clean(name) } })
      return { id: d.id, name: d.name, shops: 0 }
    } catch (e) {
      if (isUniqueViolation(e)) throw conflict('A district with this name exists')
      throw e
    }
  }

  async rename (id: string, name: string) {
    if (await this.prisma.district.findUnique({ where: { id } }) == null) throw notFound('District')
    try {
      const d = await this.prisma.district.update({ where: { id }, data: { name: clean(name) } })
      return { id: d.id, name: d.name, shops: await this.prisma.shop.count({ where: { districtId: id, deletedAt: null } }) }
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
