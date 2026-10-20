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

test('districts: admins add, rename and delete; agents only read; names are trimmed and unique', async () => {
  const a = await f.admin(app)
  const h = bearer(app, { id: a.id, role: 'ADMIN' })
  const g = await f.agent(app)
  const gh = bearer(app, { id: g.userId, role: 'AGENT' })
  assert.strictEqual((await app.inject({ method: 'POST', url: '/v1/districts', headers: gh, payload: { name: 'X' } })).statusCode, 403)

  const created = await app.inject({ method: 'POST', url: '/v1/districts', headers: h, payload: { name: '  Köpetdag  ' } })
  assert.strictEqual(created.statusCode, 200, created.body)
  assert.deepStrictEqual(created.json(), { id: created.json().id, name: 'Köpetdag', shops: 0, agents: 0, visitedToday: 0, overdue: 0 })
  assert.strictEqual((await app.inject({ method: 'POST', url: '/v1/districts', headers: h, payload: { name: 'Köpetdag' } })).statusCode, 409)
  assert.strictEqual((await app.inject({ method: 'POST', url: '/v1/districts', headers: h, payload: { name: '  ' } })).statusCode, 400)

  const renamed = await app.inject({ method: 'PATCH', url: `/v1/districts/${created.json().id}`, headers: h, payload: { name: 'Berkararlyk' } })
  assert.strictEqual(renamed.json().name, 'Berkararlyk')
  assert.strictEqual((await app.inject({ url: '/v1/districts', headers: gh })).statusCode, 200)

  assert.strictEqual((await app.inject({ method: 'DELETE', url: `/v1/districts/${created.json().id}`, headers: h })).statusCode, 204)
  assert.deepStrictEqual((await app.inject({ url: '/v1/districts', headers: h })).json(), [])
})

test('shop counts per district: all shops for admins, their own for agents; shops without a district last', async () => {
  const a = await f.admin(app)
  const h = bearer(app, { id: a.id, role: 'ADMIN' })
  const g = await f.agent(app)
  const d1 = await f.district(app, 'A')
  const d2 = await f.district(app, 'B')
  await f.shop(app, { createdById: a.id, districtId: d1.id, agentId: g.userId })
  await f.shop(app, { createdById: a.id, districtId: d1.id })
  await f.shop(app, { createdById: a.id, districtId: d2.id })
  await f.shop(app, { createdById: a.id, agentId: g.userId })

  const admin = (await app.inject({ url: '/v1/districts', headers: h })).json()
  assert.deepStrictEqual(admin.map((d: { name: string | null, shops: number }) => [d.name, d.shops]), [['A', 2], ['B', 1], [null, 1]])
  const agent = (await app.inject({ url: '/v1/districts', headers: bearer(app, { id: g.userId, role: 'AGENT' }) })).json()
  assert.deepStrictEqual(agent.map((d: { name: string | null, shops: number }) => [d.name, d.shops]), [['A', 1], ['B', 0], [null, 1]])

  // A district with shops can't be deleted.
  assert.strictEqual((await app.inject({ method: 'DELETE', url: `/v1/districts/${d1.id}`, headers: h })).statusCode, 409)
})

test('district cards: agents working the shops, visited today, overdue', async () => {
  const a = await f.admin(app)
  const h = bearer(app, { id: a.id, role: 'ADMIN' })
  const g1 = await f.agent(app)
  const g2 = await f.agent(app)
  const d = await f.district(app, 'A')
  const visited = await f.shop(app, { createdById: a.id, districtId: d.id, agentId: g1.userId })
  await app.prisma.shop.update({ where: { id: visited.id }, data: { lastVisitAt: new Date() } })
  await f.shop(app, { createdById: a.id, districtId: d.id, agentId: g2.userId, nextDueAt: new Date(Date.now() - 3 * 86_400_000) })
  await f.shop(app, { createdById: a.id, districtId: d.id, agentId: g1.userId, nextDueAt: new Date(Date.now() + 3 * 86_400_000) })

  const [card] = (await app.inject({ url: '/v1/districts', headers: h })).json()
  assert.deepStrictEqual(card, { id: d.id, name: 'A', shops: 3, agents: 2, visitedToday: 1, overdue: 1 })
})

test('bulk move to a district (and out of one); admins only', async () => {
  const a = await f.admin(app)
  const h = bearer(app, { id: a.id, role: 'ADMIN' })
  const g = await f.agent(app)
  const d = await f.district(app, 'A')
  const s1 = await f.shop(app, { createdById: a.id })
  const s2 = await f.shop(app, { createdById: a.id })
  const body = { shopIds: [s1.id, s2.id], districtId: d.id }
  assert.strictEqual((await app.inject({ method: 'POST', url: '/v1/shops/bulk/district', headers: bearer(app, { id: g.userId, role: 'AGENT' }), payload: body })).statusCode, 403)

  const moved = await app.inject({ method: 'POST', url: '/v1/shops/bulk/district', headers: h, payload: body })
  assert.deepStrictEqual(moved.json(), { updated: 2 })
  assert.strictEqual((await app.prisma.shop.findUniqueOrThrow({ where: { id: s1.id } })).districtId, d.id)
  assert.strictEqual((await app.prisma.shop.findUniqueOrThrow({ where: { id: s1.id } })).version, s1.version + 1)

  await app.inject({ method: 'POST', url: '/v1/shops/bulk/district', headers: h, payload: { shopIds: [s2.id], districtId: null } })
  assert.strictEqual((await app.prisma.shop.findUniqueOrThrow({ where: { id: s2.id } })).districtId, null)
  const unknown = await app.inject({ method: 'POST', url: '/v1/shops/bulk/district', headers: h, payload: { shopIds: [s1.id], districtId: '01a15b52-391c-7455-9dca-147338959144' } })
  assert.strictEqual(unknown.statusCode, 404)
})
