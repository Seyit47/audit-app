import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'
import { newId } from '../../src/lib/ids.js'
import { localDate } from '../../src/lib/time.js'

let app: FastifyInstance
let adminId: string
before(async (t) => { app = await build(t as never) })
beforeEach(async () => { await resetDb(app); adminId = (await f.admin(app)).id })

const SHOP = { lat: 37.95, lng: 58.38 }

async function photo (userId: string, extra: object = {}) {
  return app.prisma.photo.create({
    data: { id: newId(), kind: 'AUDIT', uploadedById: userId, storageKey: `audit/${newId()}.jpg`, mime: 'image/jpeg', sizeBytes: 10, sha256: 'a'.repeat(64), takenAt: new Date(), status: 'READY', lat: SHOP.lat, lng: SHOP.lng, ...extra }
  })
}

function auditBody (shopId: string, photoIds: string[], extra: object = {}) {
  const finished = new Date()
  return {
    id: newId(), shopId, startedAt: new Date(finished.getTime() - 30 * 60_000).toISOString(), finishedAt: finished.toISOString(),
    lat: SHOP.lat + 0.0001, lng: SHOP.lng, accuracyM: 8, comment: 'Выкладка обновлена', hasViolation: false, photoIds, ...extra
  }
}

async function setup () {
  const g = await f.agent(app)
  const shop = await f.shop(app, { createdById: adminId, agentId: g.userId, ...SHOP, nextDueAt: new Date(Date.now() - 86_400_000) })
  return { g, shop, h: bearer(app, { id: g.userId, role: 'AGENT' }) }
}

test('check-start: 422 GEOFENCE outside the radius, 422 GPS_ACCURACY above the limit, ok inside', async () => {
  const { shop, h } = await setup()
  const check = (payload: object) => app.inject({ method: 'POST', url: '/v1/audits/check-start', headers: h, payload: { shopId: shop.id, ...payload } })
  const far = await check({ lat: 37.96, lng: 58.38, accuracyM: 5 })
  assert.strictEqual(far.statusCode, 422)
  assert.strictEqual(far.json().error.code, 'GEOFENCE')
  assert.ok(far.json().error.details.distanceM > 1000)
  const blurry = await check({ ...SHOP, accuracyM: 80 })
  assert.strictEqual(blurry.json().error.code, 'GPS_ACCURACY')
  assert.strictEqual((await check({ ...SHOP, accuracyM: 5 })).statusCode, 200)
})

test('create links the photos, computes distance, updates shop and stop, verifies photos; idempotent', async () => {
  const { g, shop, h } = await setup()
  await app.services.routes.generate(g.userId, localDate(new Date(), 'Asia/Ashgabat'))
  const p1 = await photo(g.userId)
  const p2 = await photo(g.userId)
  const body = auditBody(shop.id, [p1.id, p2.id])
  const res = await app.inject({ method: 'POST', url: '/v1/audits', headers: h, payload: body })
  assert.strictEqual(res.statusCode, 201, res.body)
  const a = res.json()
  assert.ok(a.distanceM < 20)
  assert.strictEqual(a.withinRadius, true)
  assert.strictEqual(a.clockSkewFlag, false)
  assert.strictEqual(a.durationMin, 30)
  assert.strictEqual(a.photos.length, 2)
  assert.ok(a.photos.every((p: { verified: boolean }) => p.verified))
  const s = await app.prisma.shop.findUniqueOrThrow({ where: { id: shop.id } })
  assert.ok(s.lastVisitAt && s.nextDueAt && s.nextDueAt > new Date())
  assert.strictEqual((await app.prisma.routeStop.findFirstOrThrow({ where: { shopId: shop.id } })).status, 'DONE')

  const again = await app.inject({ method: 'POST', url: '/v1/audits', headers: h, payload: body })
  assert.strictEqual(again.statusCode, 200)
  assert.strictEqual(await app.prisma.audit.count(), 1)
})

test('create requires 1–20 own READY unlinked photos and a comment; a linked photo → 409', async () => {
  const { g, shop, h } = await setup()
  const post = (payload: object) => app.inject({ method: 'POST', url: '/v1/audits', headers: h, payload })
  assert.strictEqual((await post(auditBody(shop.id, []))).statusCode, 400)
  const p = await photo(g.userId)
  assert.strictEqual((await post(auditBody(shop.id, [p.id], { comment: '' }))).statusCode, 400)
  const other = await f.agent(app)
  const foreign = await photo(other.userId)
  assert.strictEqual((await post(auditBody(shop.id, [foreign.id]))).statusCode, 400)
  assert.strictEqual((await post(auditBody(shop.id, [p.id]))).statusCode, 201)
  assert.strictEqual((await post(auditBody(shop.id, [p.id]))).statusCode, 409, 'photo already linked')
})

test('clock skew: a finish time far in the future is flagged and photos are not auto-verified', async () => {
  const { g, shop, h } = await setup()
  const p = await photo(g.userId)
  const future = new Date(Date.now() + 60 * 60_000)
  const res = await app.inject({ method: 'POST', url: '/v1/audits', headers: h, payload: auditBody(shop.id, [p.id], { startedAt: new Date(future.getTime() - 600_000).toISOString(), finishedAt: future.toISOString() }) })
  assert.strictEqual(res.json().clockSkewFlag, true)
  assert.strictEqual(res.json().photos[0].verified, false)
})

test('scope: assigned at startedAt is accepted after reassignment; another agent shop → 404', async () => {
  const { g, shop, h } = await setup()
  const other = await f.agent(app)
  const p = await photo(g.userId)
  const body = auditBody(shop.id, [p.id])
  await app.inject({ method: 'POST', url: '/v1/shops/bulk/assign', headers: bearer(app, { id: adminId, role: 'ADMIN' }), payload: { shopIds: [shop.id], agentId: other.userId } })
  assert.strictEqual((await app.inject({ method: 'POST', url: '/v1/audits', headers: h, payload: body })).statusCode, 201)

  const theirs = await f.shop(app, { createdById: adminId, agentId: other.userId })
  const p2 = await photo(g.userId)
  assert.strictEqual((await app.inject({ method: 'POST', url: '/v1/audits', headers: h, payload: auditBody(theirs.id, [p2.id]) })).statusCode, 404)
})

test('immutability: no PATCH/DELETE routes, and SQL UPDATE is rejected', async () => {
  const { g, shop, h } = await setup()
  const p = await photo(g.userId)
  const a = (await app.inject({ method: 'POST', url: '/v1/audits', headers: h, payload: auditBody(shop.id, [p.id]) })).json()
  assert.strictEqual((await app.inject({ method: 'PATCH', url: `/v1/audits/${a.id}`, headers: h, payload: {} })).statusCode, 405)
  assert.strictEqual((await app.inject({ method: 'DELETE', url: `/v1/audits/${a.id}`, headers: h })).statusCode, 405)
  await assert.rejects(app.prisma.$executeRawUnsafe(`UPDATE "Audit" SET comment = 'x' WHERE id = '${a.id}'`))
})

test('violation is stored and shown in shop visits; list and detail filters', async () => {
  const { g, shop, h } = await setup()
  const p = await photo(g.userId)
  await app.inject({ method: 'POST', url: '/v1/audits', headers: h, payload: auditBody(shop.id, [p.id], { hasViolation: true, comment: 'Нет ценников' }) })
  const admin = bearer(app, { id: adminId, role: 'ADMIN' })
  const visits = (await app.inject({ url: `/v1/shops/${shop.id}/visits`, headers: admin })).json()
  assert.strictEqual(visits.items[0].hasViolation, true)
  const list = (await app.inject({ url: '/v1/audits?hasViolation=true', headers: admin })).json()
  assert.strictEqual(list.items.length, 1)
  assert.strictEqual(list.items[0].comment, 'Нет ценников')
  const detail = (await app.inject({ url: `/v1/audits/${list.items[0].id}`, headers: admin })).json()
  assert.strictEqual(detail.hasViolation, true)
})

test('a shop pending review (or inactive) cannot be audited until an admin makes it active', async () => {
  const g = await f.agent(app)
  const h = bearer(app, { id: g.userId, role: 'AGENT' })
  for (const status of ['PENDING_REVIEW', 'INACTIVE'] as const) {
    const shop = await f.shop(app, { createdById: adminId, agentId: g.userId, ...SHOP, status })
    const check = await app.inject({ method: 'POST', url: '/v1/audits/check-start', headers: h, payload: { shopId: shop.id, ...SHOP, accuracyM: 5 } })
    assert.strictEqual(check.statusCode, 409, `${status}: ${check.body}`)
    assert.strictEqual(check.json().error.code, 'SHOP_NOT_ACTIVE')
    const p = await photo(g.userId)
    const create = await app.inject({ method: 'POST', url: '/v1/audits', headers: h, payload: auditBody(shop.id, [p.id]) })
    assert.strictEqual(create.statusCode, 409, `${status}: ${create.body}`)
    assert.strictEqual(create.json().error.code, 'SHOP_NOT_ACTIVE')
  }
  assert.strictEqual(await app.prisma.audit.count(), 0)
})
