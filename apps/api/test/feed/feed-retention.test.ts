import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'
import { newId } from '../../src/lib/ids.js'
import { runRetention } from '../../src/jobs/retention.js'

let app: FastifyInstance
before(async (t) => { app = await build(t as never) })
beforeEach(async () => { await resetDb(app) })

test('feed: violations and missed visits newest first, cursor, unread count, seen, admins only', async () => {
  const a = await f.admin(app)
  const h = bearer(app, { id: a.id, role: 'ADMIN' })
  const g = await f.agent(app)
  const shop = await f.shop(app, { createdById: a.id, agentId: g.userId })
  const at = (minsAgo: number) => new Date(Date.now() - minsAgo * 60_000)
  for (const [mins, violation] of [[30, true], [20, false], [10, true]] as const) {
    await app.prisma.audit.create({ data: { id: newId(), shopId: shop.id, agentId: g.userId, startedAtDevice: at(mins), finishedAtDevice: at(mins), durationMin: 5, lat: 1, lng: 1, gpsAccuracyM: 1, distanceM: 1, withinRadius: true, comment: violation ? 'Нет ценников' : 'ok', hasViolation: violation } })
  }
  const route = await app.prisma.route.create({ data: { id: newId(), agentId: g.userId, date: new Date('2026-01-01') } })
  await app.prisma.routeStop.create({ data: { id: newId(), routeId: route.id, shopId: shop.id, position: 0, plannedAt: at(5), status: 'MISSED' } })

  const page = (await app.inject({ url: '/v1/feed?limit=2', headers: h })).json()
  assert.deepStrictEqual(page.items.map((i: { type: string }) => i.type), ['MISSED_VISIT', 'VIOLATION'])
  assert.strictEqual(page.unreadCount, 3)
  const next = (await app.inject({ url: `/v1/feed?limit=2&cursor=${encodeURIComponent(page.nextCursor)}`, headers: h })).json()
  assert.deepStrictEqual(next.items.map((i: { type: string }) => i.type), ['VIOLATION'])
  assert.strictEqual(next.items[0].comment, 'Нет ценников')

  assert.strictEqual((await app.inject({ method: 'POST', url: '/v1/feed/seen', headers: h })).statusCode, 204)
  assert.strictEqual((await app.inject({ url: '/v1/feed', headers: h })).json().unreadCount, 0)
  assert.strictEqual((await app.inject({ url: '/v1/feed', headers: bearer(app, { id: g.userId, role: 'AGENT' }) })).statusCode, 403)
})

test('retention purges pings and exports older than RETENTION_YEARS', async () => {
  const a = await f.admin(app)
  const g = await f.agent(app)
  const old = new Date(Date.now() - 6 * 365 * 86_400_000)
  await app.prisma.locationPing.createMany({ data: [{ agentId: g.userId, recordedAt: old, lat: 1, lng: 1, accuracyM: 1 }, { agentId: g.userId, recordedAt: new Date(), lat: 1, lng: 1, accuracyM: 1 }] })
  await app.prisma.export.create({ data: { id: newId(), requestedById: a.id, type: 'SHOPS_XLSX', params: {}, createdAt: old } })
  const result = await runRetention(app, 5)
  assert.deepStrictEqual(result, { pings: 1, exports: 1 })
  assert.strictEqual(await app.prisma.locationPing.count(), 1)
})
