import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'
import { newId } from '../../src/lib/ids.js'

// SC-007: an agent reaches only their own shops, routes, audits and photos, and no admin endpoint.
let app: FastifyInstance
before(async (t) => { app = await build(t as never) })
beforeEach(async () => { await resetDb(app) })

async function world () {
  const adminId = (await f.admin(app)).id
  const region = await f.region(app)
  const mine = await f.agent(app, { regionId: region.id })
  const other = await f.agent(app, { regionId: region.id })
  const myShop = await f.shop(app, { createdById: adminId, agentId: mine.userId, regionId: region.id })
  const theirShop = await f.shop(app, { createdById: adminId, agentId: other.userId, regionId: region.id })
  const at = new Date()
  const theirAudit = newId()
  await app.prisma.audit.create({ data: { id: theirAudit, shopId: theirShop.id, agentId: other.userId, startedAtDevice: at, finishedAtDevice: at, durationMin: 5, lat: 37.95, lng: 58.38, gpsAccuracyM: 5, distanceM: 5, withinRadius: true, comment: 'ok' } })
  const theirPhoto = newId()
  await app.prisma.photo.create({ data: { id: theirPhoto, kind: 'AUDIT', auditId: theirAudit, shopId: theirShop.id, uploadedById: other.userId, storageKey: `audit/${theirPhoto}.jpg`, mime: 'image/jpeg', sizeBytes: 1, sha256: 'a'.repeat(64), takenAt: at, status: 'READY' } })
  return { adminId, region, mine, other, myShop, theirShop, theirAudit, theirPhoto, h: bearer(app, { id: mine.userId, role: 'AGENT' }) }
}

test("an agent cannot read another agent's shop, visits, audit or photo", async () => {
  const w = await world()
  const get = (url: string) => app.inject({ url, headers: w.h })
  assert.strictEqual((await get(`/v1/shops/${w.myShop.id}`)).statusCode, 200)
  assert.strictEqual((await get(`/v1/shops/${w.theirShop.id}`)).statusCode, 404)
  assert.strictEqual((await get(`/v1/shops/${w.theirShop.id}/visits`)).statusCode, 404)
  assert.strictEqual((await get(`/v1/audits/${w.theirAudit}`)).statusCode, 404)
  assert.strictEqual((await get(`/v1/photos/${w.theirPhoto}`)).statusCode, 404)
})

test('agent lists contain only their own records', async () => {
  const w = await world()
  const get = async (url: string) => (await app.inject({ url, headers: w.h })).json()
  const sync = await get('/v1/shops')
  assert.deepStrictEqual(sync.items.map((s: { id: string }) => s.id), [w.myShop.id])
  const map = await get('/v1/shops/map')
  assert.deepStrictEqual(map.map((s: { id: string }) => s.id), [w.myShop.id])
  const photos = await get('/v1/photos')
  assert.strictEqual(photos.items.length, 0)
  assert.strictEqual((await get('/v1/photos/summary')).total, 0)
})

test("an agent cannot audit another agent's shop or complete another's upload", async () => {
  const w = await world()
  const check = await app.inject({ method: 'POST', url: '/v1/audits/check-start', headers: w.h, payload: { shopId: w.theirShop.id, lat: 37.95, lng: 58.38, accuracyM: 5 } })
  assert.ok([403, 404].includes(check.statusCode), `check-start ${check.statusCode}`)
  const audit = await app.inject({
    method: 'POST', url: '/v1/audits', headers: w.h,
    payload: { id: newId(), shopId: w.theirShop.id, startedAt: new Date().toISOString(), finishedAt: new Date().toISOString(), lat: 37.95, lng: 58.38, accuracyM: 5, comment: 'x', photoIds: [w.theirPhoto] }
  })
  assert.ok([400, 403, 404].includes(audit.statusCode), `audit ${audit.statusCode}`)
  assert.strictEqual(await app.prisma.audit.count({ where: { agentId: w.mine.userId } }), 0)
  assert.strictEqual((await app.inject({ method: 'POST', url: `/v1/uploads/${w.theirPhoto}/complete`, headers: w.h })).statusCode, 404)
})

test('admin endpoints answer 403 to an agent', async () => {
  const w = await world()
  const id = w.theirShop.id
  const calls: Array<[string, string, object?]> = [
    ['GET', '/v1/agents'], ['GET', '/v1/agents/summary'], ['GET', '/v1/agents/positions'], ['GET', `/v1/agents/${w.other.userId}`],
    ['GET', `/v1/agents/${w.other.userId}/track`], ['POST', '/v1/agents', {}], ['GET', '/v1/settings'], ['PATCH', '/v1/settings', {}],
    ['POST', '/v1/regions', { name: 'X' }], ['GET', '/v1/feed'], ['POST', '/v1/exports', { type: 'SHOPS_XLSX' }],
    ['PATCH', `/v1/shops/${id}`, { version: 1 }], ['PUT', `/v1/shops/${id}/contacts`, { contacts: [] }], ['POST', '/v1/shops/bulk/delete', { shopIds: [id] }], ['POST', '/v1/shops/bulk/assign', { shopIds: [id], agentId: null }],
    ['POST', '/v1/products', {}], ['GET', '/v1/routes', undefined]
  ]
  for (const [method, url, payload] of calls) {
    const res = await app.inject({ method: method as 'GET', url, headers: w.h, payload })
    assert.ok([403, 404].includes(res.statusCode), `${method} ${url} → ${res.statusCode}`)
    if (res.statusCode === 404) assert.strictEqual(res.json().error.message, 'Route not found', `${method} ${url} must not exist rather than leak`)
  }
})

test('CORS allows only WEB_ORIGIN', async () => {
  const ok = await app.inject({ method: 'OPTIONS', url: '/v1/me', headers: { origin: app.config.webOrigin.split(',')[0], 'access-control-request-method': 'GET' } })
  assert.strictEqual(ok.headers['access-control-allow-origin'], app.config.webOrigin.split(',')[0])
  const bad = await app.inject({ method: 'OPTIONS', url: '/v1/me', headers: { origin: 'https://evil.example', 'access-control-request-method': 'GET' } })
  assert.strictEqual(bad.headers['access-control-allow-origin'], undefined)
})
