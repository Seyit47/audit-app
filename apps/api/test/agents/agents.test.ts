import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'

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

const create = async (payload: object) => app.inject({ method: 'POST', url: '/v1/agents', headers: admin, payload })
const valid = async (extra: object = {}) => ({ fullName: 'Ahmed Karimov', phone: '+99365124582', regionId: (await f.region(app)).id, ...extra })

test('create returns a sequential SL- code and a temporary password that signs in', async () => {
  const one = await create(await valid({ phone: '+99365000001' }))
  const two = await create(await valid({ phone: '+99365000002' }))
  assert.strictEqual(one.statusCode, 201, one.body)
  const [a, b] = [one.json(), two.json()]
  assert.match(a.code, /^SL-\d+$/)
  assert.strictEqual(Number(b.code.slice(3)), Number(a.code.slice(3)) + 1)
  assert.ok(a.temporaryPassword.length >= 8)

  const signIn = await app.inject({ method: 'POST', url: '/v1/auth/login', payload: { login: '+99365000001', password: a.temporaryPassword, device: { installId: 'x', model: 'm' } } })
  assert.strictEqual(signIn.statusCode, 200, signIn.body)
})

test('next-code previews the next SL- code; a custom unique code is accepted', async () => {
  const peek = (await app.inject({ url: '/v1/agents/next-code', headers: admin })).json().code
  assert.match(peek, /^SL-\d+$/)
  assert.strictEqual((await app.inject({ url: '/v1/agents/next-code', headers: admin })).json().code, peek, 'peeking does not consume')
  const created = await create(await valid({ phone: '+99365000031' }))
  assert.strictEqual(created.json().code, peek)
  const custom = await create(await valid({ phone: '+99365000032', code: 'sl-900' }))
  assert.strictEqual(custom.json().code, 'SL-900')
  assert.strictEqual((await create(await valid({ phone: '+99365000033', code: 'SL-900' }))).statusCode, 409)
})

test('validation: fullName and regionId required, visit plan 1–100, audit plan ≤ visit plan', async () => {
  const base = await valid()
  for (const bad of [
    { ...base, fullName: undefined },
    { ...base, regionId: undefined },
    { ...base, dailyVisitPlan: 0 },
    { ...base, dailyVisitPlan: 101 },
    { ...base, dailyVisitPlan: 10, dailyAuditPlan: 11 }
  ]) {
    const res = await create(bad)
    assert.strictEqual(res.statusCode, 400, JSON.stringify(bad))
    assert.strictEqual(res.json().error.code, 'VALIDATION_FAILED')
  }
  assert.strictEqual((await create({ ...base, phone: '+99365000009' })).statusCode, 201)
  assert.strictEqual((await create({ ...base, phone: '+99365000009' })).statusCode, 409, 'phone is unique')
})

test('PATCH sets workStatus (Активен/Отпуск) with optimistic versioning', async () => {
  const g = await f.agent(app)
  const patch = (payload: object) => app.inject({ method: 'PATCH', url: `/v1/agents/${g.userId}`, headers: admin, payload })
  const res = await patch({ version: 1, workStatus: 'ON_LEAVE' })
  assert.strictEqual(res.statusCode, 200, res.body)
  assert.strictEqual(res.json().workStatus, 'ON_LEAVE')
  assert.strictEqual(res.json().version, 2)
  assert.strictEqual((await patch({ version: 1, workStatus: 'ACTIVE' })).statusCode, 409)
})

test('deactivate unassigns shops (closing assignment rows) and reactivate restores sign-in', async () => {
  const g = await f.agent(app)
  const s = await f.shop(app, { agentId: g.userId, createdById: adminId })
  const patch = (payload: object) => app.inject({ method: 'PATCH', url: `/v1/agents/${g.userId}`, headers: admin, payload })

  const off = await patch({ version: 1, active: false })
  assert.strictEqual(off.statusCode, 200, off.body)
  assert.strictEqual(off.json().active, false)
  const shop = await app.prisma.shop.findUniqueOrThrow({ where: { id: s.id } })
  assert.strictEqual(shop.assignedAgentId, null)
  const rows = await app.prisma.shopAssignment.findMany({ where: { shopId: s.id }, orderBy: { from: 'asc' } })
  assert.ok(rows[0]!.to, 'agent row closed')
  assert.strictEqual(rows.at(-1)!.agentId, null, 'unassigned period opened')

  const on = await patch({ version: 2, active: true })
  assert.strictEqual(on.json().active, true)
  const signIn = await app.inject({ method: 'POST', url: '/v1/auth/login', payload: { login: g.phone, password: f.PASSWORD, device: { installId: 'i', model: 'm' } } })
  assert.strictEqual(signIn.statusCode, 200)
})

test('PUT /agents/:id/device clears the binding and sets the IMEI label', async () => {
  const g = await f.agent(app, { installId: 'old-phone' })
  const res = await app.inject({ method: 'PUT', url: `/v1/agents/${g.userId}/device`, headers: admin, payload: { imeiLabel: '35-209900-176148-1' } })
  assert.strictEqual(res.statusCode, 200, res.body)
  const d = await app.prisma.device.findUniqueOrThrow({ where: { agentId: g.userId } })
  assert.strictEqual(d.installId, null)
  assert.strictEqual(d.imeiLabel, '35-209900-176148-1')
  const signIn = await app.inject({ method: 'POST', url: '/v1/auth/login', payload: { login: g.phone, password: f.PASSWORD, device: { installId: 'new-phone', model: 'm' } } })
  assert.strictEqual(signIn.statusCode, 200, 'a new phone binds')
})

test('list: search, status and region filters, pagination', async () => {
  const r1 = await f.region(app)
  const r2 = await f.region(app)
  const a = await f.agent(app, { regionId: r1.id })
  await f.agent(app, { regionId: r1.id, workStatus: 'ON_LEAVE' })
  await f.agent(app, { regionId: r2.id })
  const list = (qs: string) => app.inject({ url: `/v1/agents?${qs}`, headers: admin })

  const all = (await list('page=1&size=2')).json()
  assert.strictEqual(all.total, 3)
  assert.strictEqual(all.items.length, 2)
  assert.strictEqual(all.size, 2)
  assert.strictEqual((await list('page=2&size=2')).json().items.length, 1)
  assert.strictEqual((await list(`regionId=${r1.id}`)).json().total, 2)
  assert.strictEqual((await list('status=ON_LEAVE')).json().total, 1)
  const found = (await list(`q=${encodeURIComponent(a.fullName)}`)).json()
  assert.strictEqual(found.total, 1)
  const row = found.items[0]
  for (const key of ['id', 'code', 'fullName', 'phone', 'region', 'locations', 'visits', 'photos', 'lastActivityAt', 'workStatus', 'active']) {
    assert.ok(key in row, key)
  }
})

test('list sorts by a column and direction', async () => {
  const r = await f.region(app)
  const a = await f.agent(app, { regionId: r.id })
  const b = await f.agent(app, { regionId: r.id })
  await app.prisma.agent.update({ where: { userId: a.userId }, data: { fullName: 'Zarina' } })
  await app.prisma.agent.update({ where: { userId: b.userId }, data: { fullName: 'Aman' } })
  const names = async (qs: string) => (await app.inject({ url: `/v1/agents?${qs}`, headers: admin })).json().items.map((i: { fullName: string }) => i.fullName)
  assert.deepStrictEqual(await names('sort=fullName'), ['Aman', 'Zarina'])
  assert.deepStrictEqual(await names('sort=fullName&dir=desc'), ['Zarina', 'Aman'])
})

test('agents get 403 on every agents endpoint', async () => {
  const g = await f.agent(app)
  const h = bearer(app, { id: g.userId, role: 'AGENT' })
  assert.strictEqual((await app.inject({ url: '/v1/agents', headers: h })).statusCode, 403)
  assert.strictEqual((await app.inject({ method: 'POST', url: '/v1/agents', headers: h, payload: await valid() })).statusCode, 403)
  assert.strictEqual((await app.inject({ url: `/v1/agents/${g.userId}`, headers: h })).statusCode, 403)
})

test('phones: Turkmen mobile only, stored as +993XXXXXXXX; sign-in accepts any common form', async () => {
  const created = await create(await valid({ phone: '8 65 00 00 77', whatsappPhone: '993 71 123456' }))
  assert.strictEqual(created.statusCode, 201, created.body)
  const agent = await app.prisma.agent.findUniqueOrThrow({ where: { userId: created.json().id } })
  assert.strictEqual(agent.phone, '+99365000077')
  assert.strictEqual(agent.whatsappPhone, '+99371123456')

  for (const phone of ['+993 12 345678', '+7 912 345 67 89', '+993 65 12345']) {
    const bad = await create(await valid({ phone }))
    assert.strictEqual(bad.statusCode, 400, phone)
    assert.strictEqual(bad.json().error.code, 'VALIDATION_FAILED')
  }

  const signIn = await app.inject({ method: 'POST', url: '/v1/auth/login', payload: { login: '65 000077', password: created.json().temporaryPassword, device: { installId: 'i-1', model: 'm' } } })
  assert.strictEqual(signIn.statusCode, 200, signIn.body)
})

test('the admin form sends the previewed code: the next preview moves on, so a second create works', async () => {
  const peek = async () => (await app.inject({ url: '/v1/agents/next-code', headers: admin })).json().code
  const first = await peek()
  assert.strictEqual((await create(await valid({ phone: '+99365000041', code: first }))).statusCode, 201)
  const second = await peek()
  assert.notStrictEqual(second, first)
  assert.strictEqual((await create(await valid({ phone: '+99365000042', code: second }))).statusCode, 201)

  // A hand-typed code ahead of the counter is skipped too, by the preview and by a create without a code.
  const ahead = Number((await peek()).slice(3)) + 50
  assert.strictEqual((await create(await valid({ phone: '+99365000043', code: `SL-${ahead}` }))).statusCode, 201)
  assert.strictEqual(await peek(), `SL-${ahead + 1}`)
  const auto = await create(await valid({ phone: '+99365000044' }))
  assert.strictEqual(auto.json().code, `SL-${ahead + 1}`)
})

test('the admin types the password on create and changes it from the actions; the old one and sessions stop working', async () => {
  const signIn = (login: string, password: string) => app.inject({ method: 'POST', url: '/v1/auth/login', payload: { login, password, device: { installId: 'pw', model: 'm' } } })
  const created = await create(await valid({ phone: '+99365000051', password: 'Kamil-2026' }))
  assert.strictEqual(created.statusCode, 201, created.body)
  assert.strictEqual(created.json().temporaryPassword, undefined, 'a typed password is not echoed back')
  const first = await signIn('+99365000051', 'Kamil-2026')
  assert.strictEqual(first.statusCode, 200)

  const id = created.json().id
  const change = (payload: object) => app.inject({ method: 'PUT', url: `/v1/agents/${id}/password`, headers: admin, payload })
  assert.strictEqual((await change({ password: 'short' })).statusCode, 400)
  assert.strictEqual((await change({})).statusCode, 400, 'a password is required')
  assert.strictEqual((await change({ password: 'New-pass-77' })).statusCode, 204)
  assert.strictEqual((await signIn('+99365000051', 'Kamil-2026')).statusCode, 401)
  assert.strictEqual((await signIn('+99365000051', 'New-pass-77')).statusCode, 200)
  const refresh = await app.inject({ method: 'POST', url: '/v1/auth/refresh', payload: { refreshToken: first.json().refreshToken } })
  assert.strictEqual(refresh.statusCode, 401, 'old sessions are signed out')

  const other = await app.inject({ method: 'PUT', url: '/v1/agents/00000000-0000-7000-8000-000000000000/password', headers: admin, payload: { password: 'Whatever-1' } })
  assert.strictEqual(other.statusCode, 404)
})
