import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { orderStops, pathLength } from '../../src/modules/routes/route-generator.js'
import { localDate } from '../../src/lib/time.js'

let app: FastifyInstance
let adminId: string
before(async (t) => { app = await build(t as never) })
beforeEach(async () => { await resetDb(app); adminId = (await f.admin(app)).id })

const today = () => localDate(new Date(), 'Asia/Ashgabat')
const past = (days: number) => new Date(Date.now() - days * 86_400_000)
const routes = () => app.services.routes

test('selects assigned ACTIVE non-deleted due shops, overdue first, capped by the visit plan', async () => {
  const g = await f.agent(app)
  await app.prisma.agent.update({ where: { userId: g.userId }, data: { dailyVisitPlan: 2, dailyAuditPlan: 1 } })
  const old = await f.shop(app, { createdById: adminId, agentId: g.userId, nextDueAt: past(10) })
  const mid = await f.shop(app, { createdById: adminId, agentId: g.userId, nextDueAt: past(3) })
  await f.shop(app, { createdById: adminId, agentId: g.userId, nextDueAt: past(1) })
  await f.shop(app, { createdById: adminId, agentId: g.userId, nextDueAt: new Date(Date.now() + 5 * 86_400_000) })
  await f.shop(app, { createdById: adminId, agentId: g.userId, status: 'INACTIVE', nextDueAt: past(20) })
  const del = await f.shop(app, { createdById: adminId, agentId: g.userId, nextDueAt: past(30) })
  await app.prisma.shop.update({ where: { id: del.id }, data: { deletedAt: new Date() } })

  const route = await routes().generate(g.userId, today())
  assert.ok(route)
  const stops = await app.prisma.routeStop.findMany({ where: { routeId: route.id }, orderBy: { position: 'asc' } })
  assert.deepStrictEqual(new Set(stops.map((s) => s.shopId)), new Set([old.id, mid.id]))
  assert.strictEqual(stops.filter((s) => s.isAuditTask).length, 1)
  assert.strictEqual(stops[0]!.isAuditTask, true)
})

test('agents on leave or deactivated get no route; generation is idempotent', async () => {
  const leave = await f.agent(app, { workStatus: 'ON_LEAVE' })
  await f.shop(app, { createdById: adminId, agentId: leave.userId, nextDueAt: past(2) })
  assert.strictEqual(await routes().generate(leave.userId, today()), null)

  const g = await f.agent(app)
  await f.shop(app, { createdById: adminId, agentId: g.userId, nextDueAt: past(2) })
  const a = await routes().generate(g.userId, today())
  const b = await routes().generate(g.userId, today())
  assert.strictEqual(a!.id, b!.id)
  assert.strictEqual(await app.prisma.routeStop.count(), 1)

  await app.prisma.user.update({ where: { id: g.userId }, data: { status: 'DEACTIVATED', deactivatedAt: new Date() } })
  assert.strictEqual(await routes().generate(g.userId, '2030-01-01'), null)
})

test('nearest-neighbour + 2-opt is never longer than the input order', () => {
  for (let run = 0; run < 20; run++) {
    const pts = Array.from({ length: 12 }, (_, i) => ({ id: String(i), lat: 37.9 + Math.random() * 0.1, lng: 58.3 + Math.random() * 0.1 }))
    const start = { lat: 37.95, lng: 58.35 }
    const ordered = orderStops(start, pts)
    assert.strictEqual(ordered.length, pts.length)
    assert.ok(pathLength(start, ordered) <= pathLength(start, pts) + 1e-9)
  }
})

test('end of day marks remaining stops MISSED; re-order after DONE starts from that shop', async () => {
  const g = await f.agent(app)
  for (let i = 0; i < 4; i++) await f.shop(app, { createdById: adminId, agentId: g.userId, nextDueAt: past(1), lat: 37.95 + i * 0.01, lng: 58.38 })
  const route = await routes().generate(g.userId, today())
  const stops = await app.prisma.routeStop.findMany({ where: { routeId: route!.id }, orderBy: { position: 'asc' } })
  const done = stops[2]!
  await app.prisma.routeStop.update({ where: { id: done.id }, data: { status: 'DONE' } })
  await routes().reorderAfter(done.id)
  const after = await app.prisma.routeStop.findMany({ where: { routeId: route!.id, status: 'PLANNED' }, orderBy: { position: 'asc' }, include: { shop: true } })
  const doneShop = await app.prisma.shop.findUniqueOrThrow({ where: { id: done.shopId } })
  const dist = (s: { lat: number }) => Math.abs(s.lat - doneShop.lat)
  assert.ok(dist(after[0]!.shop) <= Math.min(...after.map((s) => dist(s.shop))) + 1e-9, 'next stop is the nearest to the finished shop')
  assert.ok(after.every((s) => s.position > done.position))

  await routes().endOfDay(today())
  assert.strictEqual(await app.prisma.routeStop.count({ where: { routeId: route!.id, status: 'MISSED' } }), 3)
  assert.strictEqual(await app.prisma.routeStop.count({ where: { routeId: route!.id, status: 'DONE' } }), 1)
})
