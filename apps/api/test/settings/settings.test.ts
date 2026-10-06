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

test('GET and PATCH /v1/settings are admin only', async () => {
  const a = await f.admin(app)
  const g = await f.agent(app)
  assert.strictEqual((await app.inject({ url: '/v1/settings', headers: bearer(app, { id: g.userId, role: 'AGENT' }) })).statusCode, 403)
  const res = await app.inject({ url: '/v1/settings', headers: bearer(app, { id: a.id, role: 'ADMIN' }) })
  assert.strictEqual(res.statusCode, 200)
  assert.strictEqual(res.json().companyName, 'COMPANY NAME')
})

test('PATCH validates ranges and working hours', async () => {
  const a = await f.admin(app)
  const h = bearer(app, { id: a.id, role: 'ADMIN' })
  const patch = (payload: object) => app.inject({ method: 'PATCH', url: '/v1/settings', headers: h, payload })
  assert.strictEqual((await patch({ workStart: '19:00', workEnd: '08:00' })).statusCode, 400)
  assert.strictEqual((await patch({ defaultAuditRadiusM: 5 })).statusCode, 400)
  assert.strictEqual((await patch({ minGpsAccuracyM: 300 })).statusCode, 400)
  assert.strictEqual((await patch({ visitFrequencyDays: 0 })).statusCode, 400)
  assert.strictEqual((await patch({ noSignalMinutes: 500 })).statusCode, 400)
  const ok = await patch({ companyName: 'Acme', workStart: '09:00', workEnd: '18:00', visitFrequencyDays: 14 })
  assert.strictEqual(ok.statusCode, 200, ok.body)
  assert.strictEqual(ok.json().visitFrequencyDays, 14)
})

test('a change notifies settings listeners (route jobs re-schedule on it)', async () => {
  const a = await f.admin(app)
  let notified = 0
  app.services.settings.onChange(async () => { notified++ })
  await app.inject({ method: 'PATCH', url: '/v1/settings', headers: bearer(app, { id: a.id, role: 'ADMIN' }), payload: { workStart: '07:00' } })
  assert.strictEqual(notified, 1)
})

test('regions: agents may only GET; a region in use cannot be deleted', async () => {
  const a = await f.admin(app)
  const h = bearer(app, { id: a.id, role: 'ADMIN' })
  const g = await f.agent(app)
  const gh = bearer(app, { id: g.userId, role: 'AGENT' })
  assert.strictEqual((await app.inject({ url: '/v1/regions', headers: gh })).statusCode, 200)
  assert.strictEqual((await app.inject({ method: 'POST', url: '/v1/regions', headers: gh, payload: { name: 'X' } })).statusCode, 403)
  const created = await app.inject({ method: 'POST', url: '/v1/regions', headers: h, payload: { name: 'Region West' } })
  assert.strictEqual(created.statusCode, 200)
  const renamed = await app.inject({ method: 'PATCH', url: `/v1/regions/${created.json().id}`, headers: h, payload: { name: 'Region West 2' } })
  assert.strictEqual(renamed.json().name, 'Region West 2')
  const inUse = await app.inject({ method: 'DELETE', url: `/v1/regions/${g.regionId}`, headers: h })
  assert.strictEqual(inUse.statusCode, 409)
  assert.strictEqual((await app.inject({ method: 'DELETE', url: `/v1/regions/${created.json().id}`, headers: h })).statusCode, 204)
})
