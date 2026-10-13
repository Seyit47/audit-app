import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'

let app: FastifyInstance
before(async (t) => { app = await build(t as never) })
beforeEach(async () => { await resetDb(app) })

test('product categories: admins add, rename and delete them; agents cannot', async () => {
  const a = await f.admin(app)
  const h = bearer(app, { id: a.id, role: 'ADMIN' })
  const g = await f.agent(app)
  const gh = bearer(app, { id: g.userId, role: 'AGENT' })
  assert.strictEqual((await app.inject({ method: 'POST', url: '/v1/product-categories', headers: gh, payload: { name: 'X' } })).statusCode, 403)

  const created = await app.inject({ method: 'POST', url: '/v1/product-categories', headers: h, payload: { name: '  Hair Care  ' } })
  assert.strictEqual(created.statusCode, 200, created.body)
  assert.strictEqual(created.json().name, 'Hair Care', 'names are trimmed')

  const renamed = await app.inject({ method: 'PATCH', url: `/v1/product-categories/${created.json().id}`, headers: h, payload: { name: 'Hair' } })
  assert.strictEqual(renamed.json().name, 'Hair')
  const list = await app.inject({ url: '/v1/product-categories', headers: h })
  assert.deepStrictEqual(list.json().map((c: { name: string }) => c.name), ['Hair'])

  const duplicate = await app.inject({ method: 'POST', url: '/v1/product-categories', headers: h, payload: { name: 'Hair' } })
  assert.strictEqual(duplicate.statusCode, 409)
  const blank = await app.inject({ method: 'POST', url: '/v1/product-categories', headers: h, payload: { name: '   ' } })
  assert.strictEqual(blank.statusCode, 400)

  assert.strictEqual((await app.inject({ method: 'DELETE', url: `/v1/product-categories/${created.json().id}`, headers: h })).statusCode, 204)
  assert.strictEqual((await app.inject({ method: 'PATCH', url: `/v1/product-categories/${created.json().id}`, headers: h, payload: { name: 'Y' } })).statusCode, 404)
})

test('a category used by a product cannot be deleted', async () => {
  const a = await f.admin(app)
  const h = bearer(app, { id: a.id, role: 'ADMIN' })
  const c = await f.productCategory(app)
  const product = await app.inject({ method: 'POST', url: '/v1/products', headers: h, payload: { sku: 'SKU-1', name: 'Mask', categoryId: c.id, retailPrice: 10 } })
  assert.strictEqual(product.statusCode, 201, product.body)
  assert.strictEqual((await app.inject({ method: 'DELETE', url: `/v1/product-categories/${c.id}`, headers: h })).statusCode, 409)
})
