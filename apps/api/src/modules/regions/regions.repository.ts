import type { PrismaClient } from '../../lib/prisma.js'
import { newId } from '../../lib/ids.js'
import { conflict, notFound } from '../../lib/app-error.js'

export class RegionsRepository {
  private readonly prisma: PrismaClient
  constructor (prisma: PrismaClient) { this.prisma = prisma }

  list () { return this.prisma.region.findMany({ orderBy: { name: 'asc' } }) }

  create (data: { name: string, centroidLat?: number, centroidLng?: number }) {
    return this.prisma.region.create({ data: { id: newId(), ...data } })
  }

  async update (id: string, data: { name?: string, centroidLat?: number, centroidLng?: number }) {
    if (!await this.prisma.region.findUnique({ where: { id } })) throw notFound('Region')
    return this.prisma.region.update({ where: { id }, data })
  }

  async delete (id: string) {
    const used = await this.prisma.agent.count({ where: { regionId: id } }) + await this.prisma.shop.count({ where: { regionId: id } })
    if (used > 0) throw conflict('Region is in use')
    await this.prisma.region.delete({ where: { id } })
  }
}
