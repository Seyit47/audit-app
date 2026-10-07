import { test, beforeEach, before } from 'node:test'
import * as assert from 'node:assert'
import { createHash, randomUUID } from 'node:crypto'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'

let app: FastifyInstance
before(async (t) => { app = await build(t as never) })
beforeEach(async () => { await resetDb(app) })

const png = Buffer.from('89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c4890000000d4944415478da63f8cfc0f01f0005000201a5f6c7a60000000049454e44ae426082', 'hex')
const sha = (b: Buffer) => createHash('sha256').update(b).digest('hex')

async function createUpload (headers: Record<string, string>, body: Record<string, unknown>) {
  return app.inject({ method: 'POST', url: '/v1/uploads', headers, payload: body })
}

test('POST /v1/uploads returns a presigned PUT, is idempotent per id, and accepts no auditId', async () => {
  const agent = await f.agent(app)
  const h = bearer(app, { id: agent.userId, role: 'AGENT' })
  const id = randomUUID()
  const body = { id, kind: 'AUDIT', mime: 'image/png', sizeBytes: png.length, sha256: sha(png), takenAt: new Date().toISOString() }
  const r1 = await createUpload(h, body)
  assert.strictEqual(r1.statusCode, 200, r1.body)
  assert.ok(r1.json().uploadUrl)
  const r2 = await createUpload(h, body)
  assert.strictEqual(r2.statusCode, 200)
  assert.strictEqual(await app.prisma.photo.count(), 1)
  const withAudit = await createUpload(h, { ...body, id: randomUUID(), auditId: randomUUID() })
  assert.strictEqual(withAudit.statusCode, 400)
})

test('rejects unsupported mime, > 10 MB, and > 5 MB or non PNG/JPG for PRODUCT', async () => {
  const a = await f.admin(app)
  const h = bearer(app, { id: a.id, role: 'ADMIN' })
  const base = { kind: 'FACADE', sha256: sha(png), takenAt: new Date().toISOString() }
  assert.strictEqual((await createUpload(h, { ...base, id: randomUUID(), mime: 'image/gif', sizeBytes: 10 })).statusCode, 400)
  assert.strictEqual((await createUpload(h, { ...base, id: randomUUID(), mime: 'image/jpeg', sizeBytes: 10 * 1024 * 1024 + 1 })).statusCode, 400)
  assert.strictEqual((await createUpload(h, { ...base, id: randomUUID(), kind: 'PRODUCT', mime: 'image/png', sizeBytes: 5 * 1024 * 1024 + 1 })).statusCode, 400)
  assert.strictEqual((await createUpload(h, { ...base, id: randomUUID(), kind: 'PRODUCT', mime: 'image/webp', sizeBytes: 10 })).statusCode, 400)
})

test('complete verifies size and sha256 then marks READY; another user gets 404', async () => {
  const agent = await f.agent(app)
  const other = await f.agent(app)
  const h = bearer(app, { id: agent.userId, role: 'AGENT' })
  const id = randomUUID()
  const res = await createUpload(h, { id, kind: 'AUDIT', mime: 'image/png', sizeBytes: png.length, sha256: sha(png), takenAt: new Date().toISOString() })
  const { uploadUrl, headers } = res.json()

  const early = await app.inject({ method: 'POST', url: `/v1/uploads/${id}/complete`, headers: h })
  assert.strictEqual(early.statusCode, 400, 'not uploaded yet')

  const put = await fetch(uploadUrl, { method: 'PUT', body: png, headers })
  assert.strictEqual(put.status, 200)

  const foreign = await app.inject({ method: 'POST', url: `/v1/uploads/${id}/complete`, headers: bearer(app, { id: other.userId, role: 'AGENT' }) })
  assert.strictEqual(foreign.statusCode, 404)

  const done = await app.inject({ method: 'POST', url: `/v1/uploads/${id}/complete`, headers: h })
  assert.strictEqual(done.statusCode, 200, done.body)
  assert.strictEqual((await app.prisma.photo.findUniqueOrThrow({ where: { id } })).status, 'READY')
})

test('ADMIN_UPLOAD requires shopId and is admin only', async () => {
  const a = await f.admin(app)
  const agent = await f.agent(app)
  const s = await f.shop(app, { createdById: a.id })
  const base = { kind: 'ADMIN_UPLOAD', mime: 'image/png', sizeBytes: png.length, sha256: sha(png), takenAt: new Date().toISOString() }
  assert.strictEqual((await createUpload(bearer(app, { id: a.id, role: 'ADMIN' }), { ...base, id: randomUUID() })).statusCode, 400)
  assert.strictEqual((await createUpload(bearer(app, { id: agent.userId, role: 'AGENT' }), { ...base, id: randomUUID(), shopId: s.id })).statusCode, 403)
  assert.strictEqual((await createUpload(bearer(app, { id: a.id, role: 'ADMIN' }), { ...base, id: randomUUID(), shopId: s.id })).statusCode, 200)
  const unknownShop = await createUpload(bearer(app, { id: a.id, role: 'ADMIN' }), { ...base, id: randomUUID(), shopId: randomUUID() })
  assert.strictEqual(unknownShop.statusCode, 400)
  assert.strictEqual(unknownShop.json().error.code, 'VALIDATION_FAILED')
})

test('DB trigger allows preview fields on a READY audit photo but rejects storageKey changes', async () => {
  const agent = await f.agent(app)
  const id = randomUUID()
  await app.prisma.photo.create({ data: { id, kind: 'AUDIT', uploadedById: agent.userId, storageKey: 'k', mime: 'image/png', sizeBytes: 1, sha256: 'x', takenAt: new Date(), status: 'READY' } })
  await app.prisma.photo.update({ where: { id }, data: { previewKeys: { '400': 'p' }, width: 1, height: 1 } })
  await assert.rejects(app.prisma.photo.update({ where: { id }, data: { storageKey: 'other' } }))
})
