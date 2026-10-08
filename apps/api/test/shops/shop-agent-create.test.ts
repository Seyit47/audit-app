import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'
import { newId } from '../../src/lib/ids.js'

let app: FastifyInstance
before(async (t) => { app = await build(t as never) })
beforeEach(async () => { await resetDb(app) })

async function facade (userId: string) {
  return app.prisma.photo.create({
    data: { id: newId(), kind: 'FACADE', uploadedById: userId, storageKey: `facade/${newId()}.jpg`, mime: 'image/jpeg', sizeBytes: 10, sha256: 'a'.repeat(64), takenAt: new Date(), status: 'READY' }
  })
}

test('agent create → PENDING_REVIEW assigned to self; repeated id is idempotent', async () => {
  const g = await f.agent(app)
  const h = bearer(app, { id: g.userId, role: 'AGENT' })
  const photo = await facade(g.userId)
  const body = { id: newId(), name: 'Maya shop', address: 'West Boulevard', ownerName: 'John Doe', lat: 37.95, lng: 58.38, accuracyM: 12, facadePhotoId: photo.id, contacts: [{ phone: '+99362112233' }] }
  const first = await app.inject({ method: 'POST', url: '/v1/shops', headers: h, payload: body })
  assert.strictEqual(first.statusCode, 201, first.body)
  assert.strictEqual(first.json().status, 'PENDING_REVIEW')
  assert.strictEqual(first.json().agent.id, g.userId)
  const again = await app.inject({ method: 'POST', url: '/v1/shops', headers: h, payload: body })
  assert.strictEqual(again.statusCode, 200)
  assert.strictEqual(again.json().id, first.json().id)
  assert.strictEqual(await app.prisma.shop.count(), 1)
})

test('agent create requires a facade photo and GPS accuracy within the limit', async () => {
  const g = await f.agent(app)
  const h = bearer(app, { id: g.userId, role: 'AGENT' })
  const photo = await facade(g.userId)
  const base = { name: 'X', address: 'Y', lat: 37.95, lng: 58.38 }
  assert.strictEqual((await app.inject({ method: 'POST', url: '/v1/shops', headers: h, payload: { ...base, accuracyM: 10 } })).statusCode, 400)
  const far = await app.inject({ method: 'POST', url: '/v1/shops', headers: h, payload: { ...base, accuracyM: 80, facadePhotoId: photo.id } })
  assert.strictEqual(far.statusCode, 422)
  assert.strictEqual(far.json().error.code, 'GPS_ACCURACY')
})

test('an admin approves a pending shop with the status toggle', async () => {
  const a = await f.admin(app)
  const g = await f.agent(app)
  const photo = await facade(g.userId)
  const created = (await app.inject({ method: 'POST', url: '/v1/shops', headers: bearer(app, { id: g.userId, role: 'AGENT' }), payload: { name: 'X', address: 'Y', lat: 37.95, lng: 58.38, accuracyM: 5, facadePhotoId: photo.id } })).json()
  const res = await app.inject({ method: 'PATCH', url: `/v1/shops/${created.id}`, headers: bearer(app, { id: a.id, role: 'ADMIN' }), payload: { version: created.version, status: 'ACTIVE' } })
  assert.strictEqual(res.json().status, 'ACTIVE')
})

test('agent create with a point picked on the map: within the audit radius of the device only', async () => {
  const g = await f.agent(app)
  const h = bearer(app, { id: g.userId, role: 'AGENT' })
  const photo = await facade(g.userId)
  const base = { name: 'X', address: 'Y', accuracyM: 5, facadePhotoId: photo.id, deviceLat: 37.95, deviceLng: 58.38 }
  // ~0.002° of latitude ≈ 220 m: beyond the default 100 m radius.
  const far = await app.inject({ method: 'POST', url: '/v1/shops', headers: h, payload: { ...base, lat: 37.952, lng: 58.38 } })
  assert.strictEqual(far.statusCode, 422, far.body)
  assert.strictEqual(far.json().error.code, 'GEOFENCE')
  const near = await app.inject({ method: 'POST', url: '/v1/shops', headers: h, payload: { ...base, lat: 37.9504, lng: 58.38 } })
  assert.strictEqual(near.statusCode, 201, near.body)
  assert.strictEqual(near.json().lat, 37.9504)
})
