import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'
import { localDate } from '../../src/lib/time.js'

let app: FastifyInstance
before(async (t) => { app = await build(t as never) })
beforeEach(async () => { await resetDb(app) })

test('routes/today is the agent own route; counts and map match visit states', async () => {
  const a = await f.admin(app)
  const g = await f.agent(app)
  const other = await f.agent(app)
  const overdue = await f.shop(app, { createdById: a.id, agentId: g.userId, nextDueAt: new Date(Date.now() - 3 * 86_400_000) })
  const visited = await f.shop(app, { createdById: a.id, agentId: g.userId, nextDueAt: new Date(Date.now() + 7 * 86_400_000) })
  await app.prisma.shop.update({ where: { id: visited.id }, data: { lastVisitAt: new Date() } })
  await f.shop(app, { createdById: a.id, agentId: g.userId, nextDueAt: new Date(Date.now() + 5 * 86_400_000) })
  await f.shop(app, { createdById: a.id, agentId: other.userId, nextDueAt: new Date(Date.now() - 86_400_000) })
  await app.services.routes.generate(g.userId, localDate(new Date(), 'Asia/Ashgabat'))
  await app.services.routes.generate(other.userId, localDate(new Date(), 'Asia/Ashgabat'))

  const h = bearer(app, { id: g.userId, role: 'AGENT' })
  const route = (await app.inject({ url: '/v1/routes/today', headers: h })).json()
  assert.deepStrictEqual(route.stops.map((s: { shopId: string }) => s.shopId), [overdue.id])

  const counts = (await app.inject({ url: '/v1/shops/counts', headers: h })).json()
  assert.deepStrictEqual(counts, { all: 3, scheduled: 0, overdue: 1, visited: 1, assigned: 1 })

  const map = (await app.inject({ url: '/v1/shops/map', headers: h })).json()
  assert.strictEqual(map.length, 3)
  assert.strictEqual(map.find((m: { id: string }) => m.id === overdue.id).visitState, 'OVERDUE')
  assert.strictEqual(map.find((m: { id: string }) => m.id === visited.id).visitState, 'VISITED')

  const adminMap = (await app.inject({ url: '/v1/shops/map', headers: bearer(app, { id: a.id, role: 'ADMIN' }) })).json()
  assert.strictEqual(adminMap.length, 4)
  const filtered = (await app.inject({ url: `/v1/shops/map?agentIds=${other.userId}`, headers: bearer(app, { id: a.id, role: 'ADMIN' }) })).json()
  assert.strictEqual(filtered.length, 1)
})
