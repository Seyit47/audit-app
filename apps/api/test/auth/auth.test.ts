import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import { createHash } from 'node:crypto'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'

let app: FastifyInstance
before(async (t) => { app = await build(t as never) })
beforeEach(async () => { await resetDb(app) })

const login = (payload: object) => app.inject({ method: 'POST', url: '/v1/auth/login', payload })
const refresh = (refreshToken: string) => app.inject({ method: 'POST', url: '/v1/auth/refresh', payload: { refreshToken } })
const hash = (t: string) => createHash('sha256').update(t).digest('hex')
const device = (installId = 'install-1') => ({ installId, model: 'Galaxy A52' })

test('admin logs in by email and gets tokens and the user', async () => {
  const a = await f.admin(app, 'boss@test.local')
  const res = await login({ login: 'boss@test.local', password: f.PASSWORD })
  assert.strictEqual(res.statusCode, 200, res.body)
  const body = res.json()
  assert.ok(body.accessToken && body.refreshToken)
  assert.deepStrictEqual(body.user, { id: a.id, role: 'ADMIN', agentId: null })

  const me = await app.inject({ url: '/v1/me', headers: { authorization: `Bearer ${body.accessToken}` } })
  assert.strictEqual(me.statusCode, 200, me.body)
  assert.strictEqual(me.json().config.companyName, 'COMPANY NAME')
  assert.strictEqual(me.json().config.defaultAuditRadiusM, 100)
})

test('wrong password → 401', async () => {
  await f.admin(app, 'boss@test.local')
  const res = await login({ login: 'boss@test.local', password: 'nope' })
  assert.strictEqual(res.statusCode, 401)
  assert.strictEqual(res.json().error.code, 'UNAUTHENTICATED')
})

test('agent logs in by phone; the first login binds the device, another device → 403, none → 400', async () => {
  const g = await f.agent(app)
  const first = await login({ login: g.phone, password: f.PASSWORD, device: device() })
  assert.strictEqual(first.statusCode, 200, first.body)
  assert.deepStrictEqual(first.json().user, { id: g.userId, role: 'AGENT', agentId: g.userId })
  const bound = await app.prisma.device.findUniqueOrThrow({ where: { agentId: g.userId } })
  assert.strictEqual(bound.installId, 'install-1')
  assert.ok(bound.boundAt)

  assert.strictEqual((await login({ login: g.phone, password: f.PASSWORD, device: device() })).statusCode, 200)
  const other = await login({ login: g.phone, password: f.PASSWORD, device: device('install-2') })
  assert.strictEqual(other.statusCode, 403)
  assert.strictEqual(other.json().error.code, 'DEVICE_NOT_BOUND')
  const none = await login({ login: g.phone, password: f.PASSWORD })
  assert.strictEqual(none.statusCode, 400)
})

test('refresh rotates the token; the old one is rejected', async () => {
  await f.admin(app, 'boss@test.local')
  const { refreshToken } = (await login({ login: 'boss@test.local', password: f.PASSWORD })).json()
  const rotated = await refresh(refreshToken)
  assert.strictEqual(rotated.statusCode, 200, rotated.body)
  assert.notStrictEqual(rotated.json().refreshToken, refreshToken)
  assert.strictEqual((await refresh(refreshToken)).statusCode, 401)
  assert.strictEqual((await refresh(rotated.json().refreshToken)).statusCode, 200)
})

test('refresh fails after the idle limit: web 12 h, mobile 30 days', async () => {
  await f.admin(app, 'boss@test.local')
  const g = await f.agent(app)
  const web = (await login({ login: 'boss@test.local', password: f.PASSWORD })).json().refreshToken
  const mobile = (await login({ login: g.phone, password: f.PASSWORD, device: device() })).json().refreshToken
  const idle = (token: string, hours: number) => app.prisma.refreshToken.update({
    where: { tokenHash: hash(token) }, data: { lastUsedAt: new Date(Date.now() - hours * 3_600_000) }
  })

  await idle(web, 13)
  assert.strictEqual((await refresh(web)).statusCode, 401)

  await idle(mobile, 24 * 29)
  const stillOk = await refresh(mobile)
  assert.strictEqual(stillOk.statusCode, 200, stillOk.body)
  const next = stillOk.json().refreshToken
  await idle(next, 24 * 31)
  assert.strictEqual((await refresh(next)).statusCode, 401)
})

test('deactivated: no login; for 72 h the session may refresh and submit data recorded before deactivation', async () => {
  const g = await f.agent(app)
  const tokens = (await login({ login: g.phone, password: f.PASSWORD, device: device() })).json()
  const recordedAt = new Date(Date.now() - 60_000).toISOString()
  await app.prisma.user.update({ where: { id: g.userId }, data: { status: 'DEACTIVATED', deactivatedAt: new Date() } })

  assert.strictEqual((await login({ login: g.phone, password: f.PASSWORD, device: device() })).statusCode, 401)
  const renewed = await refresh(tokens.refreshToken)
  assert.strictEqual(renewed.statusCode, 200, 'refresh works during the grace period')

  const auth = { authorization: `Bearer ${renewed.json().accessToken}` }
  const upload = (takenAt: string) => app.inject({
    method: 'POST', url: '/v1/uploads', headers: auth,
    payload: { id: crypto.randomUUID(), kind: 'AUDIT', mime: 'image/jpeg', sizeBytes: 10, sha256: 'a'.repeat(64), takenAt }
  })
  assert.strictEqual((await upload(recordedAt)).statusCode, 200)
  assert.strictEqual((await upload(new Date(Date.now() + 60_000).toISOString())).statusCode, 401, 'recorded after deactivation')
  assert.strictEqual((await app.inject({ url: '/v1/me', headers: auth })).statusCode, 401, 'only outbox submissions')

  await app.prisma.user.update({ where: { id: g.userId }, data: { deactivatedAt: new Date(Date.now() - 73 * 3_600_000) } })
  assert.strictEqual((await upload(new Date(Date.now() - 74 * 3_600_000).toISOString())).statusCode, 401)
  assert.strictEqual((await refresh(renewed.json().refreshToken)).statusCode, 401, 'no refresh after 72 h')
})

test('logout revokes the refresh token', async () => {
  await f.admin(app, 'boss@test.local')
  const { accessToken, refreshToken } = (await login({ login: 'boss@test.local', password: f.PASSWORD })).json()
  const out = await app.inject({ method: 'POST', url: '/v1/auth/logout', headers: { authorization: `Bearer ${accessToken}` }, payload: { refreshToken } })
  assert.strictEqual(out.statusCode, 204)
  assert.strictEqual((await refresh(refreshToken)).statusCode, 401)
})

test('the 6th failed login within a minute → 429', async () => {
  await f.admin(app, 'boss@test.local')
  for (let i = 0; i < 5; i++) assert.strictEqual((await login({ login: 'boss@test.local', password: 'bad' })).statusCode, 401)
  const sixth = await login({ login: 'boss@test.local', password: 'bad' })
  assert.strictEqual(sixth.statusCode, 429)
  assert.strictEqual(sixth.json().error.code, 'RATE_LIMITED')
})
