import type { PrismaClient } from '../../lib/prisma.js'
import { newId } from '../../lib/ids.js'
import { conflict, notFound } from '../../lib/app-error.js'

/** Product categories, managed in Settings like regions. A category with products cannot be deleted. */
export class CategoriesRepository {
  private readonly prisma: PrismaClient
  constructor (prisma: PrismaClient) { this.prisma = prisma }

  list () { return this.prisma.productCategory.findMany({ orderBy: { name: 'asc' } }) }

  create (name: string) {
    return this.prisma.productCategory.create({ data: { id: newId(), name } })
  }

  async rename (id: string, name: string) {
    if (!await this.prisma.productCategory.findUnique({ where: { id } })) throw notFound('Category')
    return this.prisma.productCategory.update({ where: { id }, data: { name } })
  }

  async delete (id: string) {
    if (await this.prisma.product.count({ where: { categoryId: id } }) > 0) throw conflict('Category is in use')
    await this.prisma.productCategory.delete({ where: { id } })
  }
}
