import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import ExcelJS from 'exceljs'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'
import { newId } from '../../src/lib/ids.js'
import { runExport } from '../../src/jobs/exports.js'

let app: FastifyInstance
let adminId: string
let admin: { authorization: string }
before(async (t) => { app = await build(t as never) })
beforeEach(async () => {
  await resetDb(app)
  adminId = (await f.admin(app)).id
  admin = bearer(app, { id: adminId, role: 'ADMIN' })
})

const create = (payload: object) => app.inject({ method: 'POST', url: '/v1/products', headers: admin, payload })

test('create validation: SKU unique; name, category and price required; image must be a PRODUCT upload', async () => {
  const c = await f.productCategory(app)
  const body = { sku: 'SKU-204', name: 'Маска 500мл', categoryId: c.id, retailPrice: 185 }
  const ok = await create(body)
  assert.strictEqual(ok.statusCode, 201, ok.body)
  assert.strictEqual(ok.json().retailPrice, 185)
  assert.strictEqual((await create(body)).statusCode, 409)
  for (const k of ['sku', 'name', 'categoryId', 'retailPrice']) {
    const b: Record<string, unknown> = { ...body, sku: `SKU-${k}` }
    delete b[k]
    assert.strictEqual((await create(b)).statusCode, 400, k)
  }
  const avatar = await app.prisma.photo.create({ data: { id: newId(), kind: 'AVATAR', uploadedById: adminId, storageKey: 'x', mime: 'image/png', sizeBytes: 1, sha256: 'a'.repeat(64), takenAt: new Date(), status: 'READY' } })
  assert.strictEqual((await create({ ...body, sku: 'SKU-9', imageId: avatar.id })).statusCode, 400)
})

test('list filters, distribution, compliance, shop products carried, export', async () => {
  const c = await f.productCategory(app)
  const r = await f.region(app)
  const g = await f.agent(app)
  const p1 = (await create({ sku: 'SKU-1', name: 'Shampoo', categoryId: c.id, retailPrice: 10 })).json()
  await create({ sku: 'SKU-2', name: 'Spray', categoryId: c.id, retailPrice: 12, status: 'INACTIVE' })
  const s1 = await f.shop(app, { createdById: adminId, agentId: g.userId, regionId: r.id })
  await f.shop(app, { createdById: adminId })
  const put = await app.inject({ method: 'PUT', url: `/v1/shops/${s1.id}/products`, headers: admin, payload: { productIds: [p1.id] } })
  assert.strictEqual(put.statusCode, 200, put.body)
  const at = new Date()
  for (const v of [false, true]) {
    await app.prisma.audit.create({ data: { id: newId(), shopId: s1.id, agentId: g.userId, startedAtDevice: at, finishedAtDevice: at, durationMin: 5, lat: 1, lng: 1, gpsAccuracyM: 1, distanceM: 1, withinRadius: true, comment: 'x', hasViolation: v } })
  }

  const list = (await app.inject({ url: '/v1/products?q=sham', headers: admin })).json()
  assert.strictEqual(list.total, 1)
  const row = list.items[0]
  assert.strictEqual(row.locations, 1)
  assert.strictEqual(row.coveragePct, 50)
  assert.deepStrictEqual(row.regions, [r.name])
  assert.strictEqual(row.compliancePct, 50)
  assert.ok(row.lastActivityAt)
  assert.strictEqual((await app.inject({ url: '/v1/products?status=INACTIVE', headers: admin })).json().total, 1)

  const summary = (await app.inject({ url: '/v1/products/summary', headers: admin })).json()
  assert.strictEqual(summary.total, 2)
  assert.strictEqual(summary.active, 1)

  assert.strictEqual((await app.inject({ url: `/v1/shops/${s1.id}`, headers: admin })).json().kpis.productsCarried, 1)
  assert.strictEqual((await app.inject({ url: '/v1/product-categories', headers: admin })).json().length, 1)

  const job = (await app.inject({ method: 'POST', url: '/v1/exports', headers: admin, payload: { type: 'PRODUCTS_XLSX', params: {} } })).json()
  await runExport(app, job.id)
  const row2 = await app.prisma.export.findUniqueOrThrow({ where: { id: job.id } })
  const book = new ExcelJS.Workbook()
  await book.xlsx.load((await app.storage.getObject(row2.fileKey!)) as unknown as ArrayBuffer)
  assert.strictEqual(book.worksheets[0]!.rowCount, 3)
})

test('agents get 403', async () => {
  const g = await f.agent(app)
  const h = bearer(app, { id: g.userId, role: 'AGENT' })
  assert.strictEqual((await app.inject({ url: '/v1/products', headers: h })).statusCode, 403)
})
