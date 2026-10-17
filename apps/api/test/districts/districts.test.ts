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
  assert.deepStrictEqual(created.json(), { id: created.json().id, name: 'Köpetdag', shops: 0 })
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
