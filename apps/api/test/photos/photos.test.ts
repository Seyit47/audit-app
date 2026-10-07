import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'
import { newId } from '../../src/lib/ids.js'

let app: FastifyInstance
let adminId: string
let admin: { authorization: string }
before(async (t) => { app = await build(t as never) })
beforeEach(async () => {
  await resetDb(app)
  adminId = (await f.admin(app)).id
  admin = bearer(app, { id: adminId, role: 'ADMIN' })
})

async function seed () {
  const r1 = await f.region(app)
  const r2 = await f.region(app)
  const g = await f.agent(app, { regionId: r1.id })
  const other = await f.agent(app, { regionId: r2.id })
  const s1 = await f.shop(app, { createdById: adminId, agentId: g.userId, regionId: r1.id })
  const s2 = await f.shop(app, { createdById: adminId, agentId: other.userId, regionId: r2.id })
  const audit = async (agentId: string, shopId: string, hasViolation: boolean, daysAgo: number, n: number, verified: boolean) => {
    const id = newId()
    const at = new Date(Date.now() - daysAgo * 86_400_000)
    await app.prisma.audit.create({ data: { id, shopId, agentId, startedAtDevice: at, finishedAtDevice: at, durationMin: 10, lat: 37.95, lng: 58.38, gpsAccuracyM: 5, distanceM: 5, withinRadius: true, comment: hasViolation ? 'Нет ценников' : 'ok', hasViolation } })
    for (let i = 0; i < n; i++) {
      await app.prisma.photo.create({ data: { id: newId(), kind: 'AUDIT', auditId: id, uploadedById: agentId, storageKey: `a/${newId()}.jpg`, mime: 'image/jpeg', sizeBytes: 1, sha256: 'a'.repeat(64), takenAt: at, status: 'READY', verifiedAt: verified ? at : null } })
    }
    return id
  }
  await audit(g.userId, s1.id, true, 0, 3, true)
  await audit(other.userId, s2.id, false, 2, 2, false)
  await app.prisma.photo.create({ data: { id: newId(), kind: 'ADMIN_UPLOAD', shopId: s2.id, uploadedById: adminId, storageKey: 'x/1.jpg', mime: 'image/jpeg', sizeBytes: 1, sha256: 'a'.repeat(64), takenAt: new Date(), status: 'READY' } })
  return { g, other, s1, s2, r1, r2 }
}

test('list filters with cursor and day counts', async () => {
  const { g, s2, r1 } = await seed()
  const list = async (qs: string) => (await app.inject({ url: `/v1/photos?${qs}`, headers: admin })).json()
  assert.strictEqual((await list('')).items.length, 6)
  assert.strictEqual((await list('type=ADMIN_UPLOAD')).items.length, 1)
  assert.strictEqual((await list(`shopId=${s2.id}`)).items.length, 3)
  assert.strictEqual((await list(`agentId=${g.userId}`)).items.length, 3)
  assert.strictEqual((await list(`regionId=${r1.id}`)).items.length, 3)
  assert.strictEqual((await list('verified=true')).items.length, 3)
  const from = new Date(Date.now() - 86_400_000).toISOString()
  assert.strictEqual((await list(`from=${encodeURIComponent(from)}`)).items.length, 4)
  const page1 = await list('limit=4&groups=true')
  assert.strictEqual(page1.items.length, 4)
  assert.ok(page1.nextCursor)
  assert.deepStrictEqual(page1.groups.map((x: { count: number }) => x.count).reduce((a: number, b: number) => a + b), 6)
  const page2 = await list(`limit=4&cursor=${encodeURIComponent(page1.nextCursor)}`)
  assert.strictEqual(page2.items.length, 2)
})

test('summary: total and today', async () => {
  await seed()
  const s = (await app.inject({ url: '/v1/photos/summary', headers: admin })).json()
  assert.deepStrictEqual(s, { total: 6, today: 4 })
})

test('detail has shop, agent, audit comment, violation and related photos', async () => {
  const { g } = await seed()
  const mine = (await app.inject({ url: `/v1/photos?agentId=${g.userId}`, headers: admin })).json().items[0]
  const d = (await app.inject({ url: `/v1/photos/${mine.id}`, headers: admin })).json()
  assert.strictEqual(d.agent.id, g.userId)
  assert.strictEqual(d.audit.hasViolation, true)
  assert.strictEqual(d.audit.comment, 'Нет ценников')
  assert.ok(d.shop.name)
  assert.strictEqual(d.related.length, 2)
})

test('an agent sees own photos only', async () => {
  const { g, other } = await seed()
  const h = bearer(app, { id: g.userId, role: 'AGENT' })
  const list = (await app.inject({ url: '/v1/photos', headers: h })).json()
  assert.strictEqual(list.items.length, 3)
  const theirs = (await app.inject({ url: `/v1/photos?agentId=${other.userId}`, headers: admin })).json().items[0]
  assert.strictEqual((await app.inject({ url: `/v1/photos/${theirs.id}`, headers: h })).statusCode, 404)
})
