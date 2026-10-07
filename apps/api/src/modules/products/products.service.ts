import { Prisma, type PrismaClient } from '../../generated/prisma/client.js'
import type { Storage } from '../../plugins/storage.js'
import { AppError, conflict, notFound } from '../../lib/app-error.js'
import { newId } from '../../lib/ids.js'
import { pageArgs } from '../../lib/pagination.js'
import { photoView } from '../photos/photo.view.js'
import type { CreateProductBody, ListProductsQuery, PatchProductBody } from './products.schema.js'

const pct = (part: number, all: number) => (all === 0 ? null : Math.round((part / all) * 100))
const invalid = (m: string) => new AppError(400, 'VALIDATION_FAILED', m)
const unique = (e: unknown) => e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2002'

/** Products catalog and distribution (US8, 30:574, 495:2311). Compliance per research R-09. */
export class ProductsService {
  private readonly prisma: PrismaClient
  private readonly storage: Storage
  constructor (prisma: PrismaClient, storage: Storage) {
    this.prisma = prisma
    this.storage = storage
  }

  private where (q: ListProductsQuery): Prisma.ProductWhereInput {
    return {
      ...(q.status ? { status: q.status } : {}),
      ...(q.categoryId ? { categoryId: q.categoryId } : {}),
      ...(q.regionId ? { shops: { some: { shop: { regionId: q.regionId, deletedAt: null } } } } : {}),
      ...(q.q ? { OR: [{ name: { contains: q.q, mode: 'insensitive' } }, { sku: { contains: q.q, mode: 'insensitive' } }, { brand: { contains: q.q, mode: 'insensitive' } }] } : {})
    }
  }

  async list (q: ListProductsQuery) {
    const { skip, take, page, size } = pageArgs(q.page, q.size)
    const where = this.where(q)
    const [items, total, activeShops] = await Promise.all([
      this.prisma.product.findMany({ where, include: { category: true }, orderBy: [{ createdAt: 'desc' }, { id: 'asc' }], skip, take }),
      this.prisma.product.count({ where }),
      this.prisma.shop.count({ where: { deletedAt: null, status: 'ACTIVE' } })
    ])
    return { items: await Promise.all(items.map((p) => this.row(p, activeShops))), total, page, size }
  }

  async all (q: ListProductsQuery) {
    const activeShops = await this.prisma.shop.count({ where: { deletedAt: null, status: 'ACTIVE' } })
    const items = await this.prisma.product.findMany({ where: this.where(q), include: { category: true }, orderBy: { sku: 'asc' } })
    return Promise.all(items.map((p) => this.row(p, activeShops)))
  }

  private async row (p: Prisma.ProductGetPayload<{ include: { category: true } }>, activeShops: number) {
    const shops = await this.prisma.shop.findMany({ where: { deletedAt: null, products: { some: { productId: p.id } } }, select: { id: true, region: { select: { name: true } } } })
    const ids = shops.map((s) => s.id)
    const [audits, clean, last] = ids.length === 0
      ? [0, 0, null]
      : await Promise.all([
        this.prisma.audit.count({ where: { shopId: { in: ids } } }),
        this.prisma.audit.count({ where: { shopId: { in: ids }, hasViolation: false } }),
        this.prisma.audit.findFirst({ where: { shopId: { in: ids } }, orderBy: { finishedAtDevice: 'desc' }, select: { finishedAtDevice: true } })
      ])
    const image = p.imageId == null ? null : await this.prisma.photo.findUnique({ where: { id: p.imageId } })
    return {
      id: p.id,
      sku: p.sku,
      name: p.name,
      description: p.description,
      category: { id: p.category.id, name: p.category.name },
      brand: p.brand,
      retailPrice: p.retailPriceMinor / 100,
      image: image?.status === 'READY' ? await photoView(this.storage, image) : null,
      status: p.status,
      stockTracked: p.stockTracked,
      stockQty: p.stockQty,
      minStockAlert: p.minStockAlert,
      locations: shops.length,
      coveragePct: pct(shops.length, activeShops),
      regions: [...new Set(shops.map((s) => s.region?.name).filter((n): n is string => n != null))].sort(),
      compliancePct: pct(clean, audits),
      lastActivityAt: last?.finishedAtDevice.toISOString() ?? null,
      updatedAt: p.updatedAt.toISOString()
    }
  }

  async get (id: string) {
    const p = await this.prisma.product.findUnique({ where: { id }, include: { category: true } })
    if (p == null) throw notFound('Product')
    return this.row(p, await this.prisma.shop.count({ where: { deletedAt: null, status: 'ACTIVE' } }))
  }

  async summary () {
    const [total, active, inactive, draft, carried, activeShops, links, audits, clean] = await Promise.all([
      this.prisma.product.count(),
      this.prisma.product.count({ where: { status: 'ACTIVE' } }),
      this.prisma.product.count({ where: { status: 'INACTIVE' } }),
      this.prisma.product.count({ where: { status: 'DRAFT' } }),
      this.prisma.shop.count({ where: { deletedAt: null, status: 'ACTIVE', products: { some: {} } } }),
      this.prisma.shop.count({ where: { deletedAt: null, status: 'ACTIVE' } }),
      this.prisma.shopProduct.count({ where: { shop: { deletedAt: null } } }),
      this.prisma.audit.count({ where: { shop: { products: { some: {} } } } }),
      this.prisma.audit.count({ where: { shop: { products: { some: {} } }, hasViolation: false } })
    ])
    return {
      total, active, inactive, draft,
      reachPct: pct(carried, activeShops),
      avgOutletsPerSku: total === 0 ? 0 : Math.round((links / total) * 10) / 10,
      compliancePct: pct(clean, audits)
    }
  }

  categories () {
    return this.prisma.productCategory.findMany({ orderBy: { name: 'asc' } })
  }

  private async checkImage (imageId: string | null | undefined) {
    if (imageId == null) return
    const img = await this.prisma.photo.findUnique({ where: { id: imageId } })
    if (img == null || img.kind !== 'PRODUCT') throw invalid('The image must be an uploaded product image (PNG/JPG up to 5 MB)')
  }

  async create (body: CreateProductBody) {
    await this.checkImage(body.imageId)
    const { retailPrice, ...rest } = body
    try {
      const p = await this.prisma.product.create({ data: { id: newId(), ...rest, retailPriceMinor: Math.round(retailPrice * 100) } })
      return this.get(p.id)
    } catch (e) {
      if (unique(e)) throw conflict('A product with this SKU already exists')
      throw e
    }
  }

  async patch (id: string, body: PatchProductBody) {
    await this.checkImage(body.imageId)
    const { retailPrice, ...rest } = body
    try {
      await this.prisma.product.update({ where: { id }, data: { ...rest, ...(retailPrice !== undefined ? { retailPriceMinor: Math.round(retailPrice * 100) } : {}) } })
    } catch (e) {
      if (unique(e)) throw conflict('A product with this SKU already exists')
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === 'P2025') throw notFound('Product')
      throw e
    }
    return this.get(id)
  }

  /** Products carried by a shop (edit dialog multi-select, gap A11). */
  async setShopProducts (shopId: string, productIds: string[]) {
    const shop = await this.prisma.shop.findFirst({ where: { id: shopId, deletedAt: null } })
    if (shop == null) throw notFound('Shop')
    await this.prisma.$transaction([
      this.prisma.shopProduct.deleteMany({ where: { shopId } }),
      this.prisma.shopProduct.createMany({ data: productIds.map((productId) => ({ shopId, productId })) })
    ])
    return { shopId, productIds }
  }

  shopProducts (shopId: string) {
    return this.prisma.shopProduct.findMany({ where: { shopId }, select: { productId: true } }).then((r) => r.map((x) => x.productId))
  }
}
