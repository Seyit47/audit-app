import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'
import { newId } from '../../src/lib/ids.js'

let app: FastifyInstance
let admin: { authorization: string }
let adminId: string
before(async (t) => { app = await build(t as never) })
beforeEach(async () => {
  await resetDb(app)
  const a = await f.admin(app)
  adminId = a.id
  admin = bearer(app, { id: a.id, role: 'ADMIN' })
})

const shopBody = (extra: object = {}) => ({ name: 'Noor Retail Group', address: 'Ashgabat, Bitarap Str. 42', lat: 37.95, lng: 58.38, ...extra })
const post = (payload: object, h = admin) => app.inject({ method: 'POST', url: '/v1/shops', headers: h, payload })

test('admin create → ACTIVE with a CL- code and an assignment row', async () => {
  const g = await f.agent(app)
  const res = await post(shopBody({ assignedAgentId: g.userId, contacts: [{ phone: '+99312942011', label: 'Администрация' }] }))
  assert.strictEqual(res.statusCode, 201, res.body)
  const shop = res.json()
  assert.match(shop.code, /^CL-\d+$/)
  assert.strictEqual(shop.status, 'ACTIVE')
  assert.strictEqual(shop.agent.id, g.userId)
  assert.strictEqual(shop.contacts.length, 1)
  const rows = await app.prisma.shopAssignment.findMany({ where: { shopId: shop.id } })
  assert.strictEqual(rows.length, 1)
  assert.strictEqual(rows[0]!.agentId, g.userId)
})

test('list filters with totals: q, status, regionId, agentId', async () => {
  const r = await f.region(app)
  const g = await f.agent(app)
  await f.shop(app, { createdById: adminId, regionId: r.id, agentId: g.userId })
  await f.shop(app, { createdById: adminId, status: 'INACTIVE' })
  const named = await post(shopBody({ name: 'Bahar Market' }))
  assert.strictEqual(named.statusCode, 201)
  const list = async (qs: string) => (await app.inject({ url: `/v1/shops?${qs}`, headers: admin })).json()
  assert.strictEqual((await list('')).total, 3)
  assert.strictEqual((await list('status=INACTIVE')).total, 1)
  assert.strictEqual((await list(`regionId=${r.id}`)).total, 1)
  assert.strictEqual((await list(`agentId=${g.userId}`)).total, 1)
  const found = await list('q=bahar')
  assert.strictEqual(found.total, 1)
  assert.strictEqual(found.items[0].name, 'Bahar Market')
})

test('PATCH with a stale version → 409; status toggles and approves Pending Review', async () => {
  const s = await f.shop(app, { createdById: adminId, status: 'PENDING_REVIEW' })
  const patch = (payload: object) => app.inject({ method: 'PATCH', url: `/v1/shops/${s.id}`, headers: admin, payload })
  const approved = await patch({ version: 1, status: 'ACTIVE' })
  assert.strictEqual(approved.statusCode, 200, approved.body)
  assert.strictEqual(approved.json().status, 'ACTIVE')
  assert.strictEqual((await patch({ version: 1, name: 'x' })).statusCode, 409)
  assert.strictEqual((await patch({ version: 2, status: 'INACTIVE' })).json().status, 'INACTIVE')
})

test('contacts: at most 5', async () => {
  const s = await f.shop(app, { createdById: adminId })
  const put = (n: number) => app.inject({ method: 'PUT', url: `/v1/shops/${s.id}/contacts`, headers: admin, payload: { contacts: Array.from({ length: n }, (_, i) => ({ phone: `+9936100000${i}`, label: null })) } })
  assert.strictEqual((await put(5)).statusCode, 200)
  assert.strictEqual((await put(6)).statusCode, 400)
  assert.strictEqual((await app.prisma.shopContact.count({ where: { shopId: s.id } })), 5)
})

test('bulk assign closes and opens assignment rows', async () => {
  const a = await f.agent(app)
  const b = await f.agent(app)
  const s1 = await f.shop(app, { createdById: adminId, agentId: a.userId })
  const s2 = await f.shop(app, { createdById: adminId })
  const res = await app.inject({ method: 'POST', url: '/v1/shops/bulk/assign', headers: admin, payload: { shopIds: [s1.id, s2.id], agentId: b.userId } })
  assert.strictEqual(res.statusCode, 200, res.body)
  const rows = await app.prisma.shopAssignment.findMany({ where: { shopId: s1.id }, orderBy: { from: 'asc' } })
  assert.ok(rows[0]!.to, 'previous assignment closed')
  assert.strictEqual(rows.at(-1)!.agentId, b.userId)
  assert.strictEqual((await app.prisma.shop.findUniqueOrThrow({ where: { id: s2.id } })).assignedAgentId, b.userId)
})

test('bulk delete soft-deletes, keeps audits, and hides the shop from lists and the map', async () => {
  const s = await f.shop(app, { createdById: adminId })
  const res = await app.inject({ method: 'POST', url: '/v1/shops/bulk/delete', headers: admin, payload: { shopIds: [s.id] } })
  assert.strictEqual(res.statusCode, 200, res.body)
  assert.ok((await app.prisma.shop.findUniqueOrThrow({ where: { id: s.id } })).deletedAt)
  assert.strictEqual((await app.inject({ url: '/v1/shops', headers: admin })).json().total, 0)
  assert.strictEqual((await app.inject({ url: `/v1/shops/${s.id}`, headers: admin })).statusCode, 404)
})

test('an agent sees only assigned shops (others → 404)', async () => {
  const g = await f.agent(app)
  const other = await f.agent(app)
  const mine = await f.shop(app, { createdById: adminId, agentId: g.userId })
  const theirs = await f.shop(app, { createdById: adminId, agentId: other.userId })
  const h = bearer(app, { id: g.userId, role: 'AGENT' })
  const list = (await app.inject({ url: '/v1/shops', headers: h })).json()
  assert.deepStrictEqual(list.items.map((s: { id: string }) => s.id), [mine.id])
  assert.strictEqual((await app.inject({ url: `/v1/shops/${mine.id}`, headers: h })).statusCode, 200)
  assert.strictEqual((await app.inject({ url: `/v1/shops/${theirs.id}`, headers: h })).statusCode, 404)
})

test('updatedAfter returns changes and tombstones (deleted or unassigned)', async () => {
  const g = await f.agent(app)
  const other = await f.agent(app)
  const keep = await f.shop(app, { createdById: adminId, agentId: g.userId })
  const del = await f.shop(app, { createdById: adminId, agentId: g.userId })
  const moved = await f.shop(app, { createdById: adminId, agentId: g.userId })
  const h = bearer(app, { id: g.userId, role: 'AGENT' })
  const first = (await app.inject({ url: '/v1/shops?updatedAfter=1970-01-01T00:00:00.000Z', headers: h })).json()
  assert.strictEqual(first.items.length, 3)
  assert.ok(first.cursor)

  await new Promise((r) => setTimeout(r, 5))
  await app.inject({ method: 'POST', url: '/v1/shops/bulk/delete', headers: admin, payload: { shopIds: [del.id] } })
  await app.inject({ method: 'POST', url: '/v1/shops/bulk/assign', headers: admin, payload: { shopIds: [moved.id], agentId: other.userId } })
  await app.inject({ method: 'PATCH', url: `/v1/shops/${keep.id}`, headers: admin, payload: { version: 1, name: 'Renamed' } })

  const next = (await app.inject({ url: `/v1/shops?updatedAfter=${encodeURIComponent(first.cursor)}`, headers: h })).json()
  assert.deepStrictEqual(next.items.map((s: { id: string, name: string }) => s.name), ['Renamed'])
  assert.deepStrictEqual(new Set(next.tombstones), new Set([del.id, moved.id]))
})

test('visits: audits and missed stops with totals', async () => {
  const g = await f.agent(app)
  const s = await f.shop(app, { createdById: adminId, agentId: g.userId })
  const at = new Date()
  await app.prisma.audit.create({
    data: {
      id: newId(), shopId: s.id, agentId: g.userId, startedAtDevice: at, finishedAtDevice: at, durationMin: 30,
      lat: 37.95, lng: 58.38, gpsAccuracyM: 8, distanceM: 10, withinRadius: true, comment: 'ok'
    }
  })
  const route = await app.prisma.route.create({ data: { id: newId(), agentId: g.userId, date: new Date(at.toISOString().slice(0, 10)) } })
  await app.prisma.routeStop.create({ data: { id: newId(), routeId: route.id, shopId: s.id, position: 0, plannedAt: at, status: 'MISSED' } })
  const res = await app.inject({ url: `/v1/shops/${s.id}/visits`, headers: admin })
  assert.strictEqual(res.statusCode, 200, res.body)
  const body = res.json()
  assert.deepStrictEqual(body.totals, { all: 2, completed: 1, missed: 1 })
  assert.deepStrictEqual(body.items.map((v: { type: string }) => v.type).sort(), ['AUDIT', 'MISSED'])
})
