import { test } from 'node:test'
import * as assert from 'node:assert'
import Fastify from 'fastify'
import fp from 'fastify-plugin'
import auth from '../../src/plugins/auth.js'
import errors from '../../src/plugins/errors.js'

async function buildAuthApp () {
  const app = Fastify()
  await app.register(fp(async (i) => { i.decorate('config', { jwtSecret: 'x'.repeat(32) } as never) }, { name: 'env' }))
  await app.register(errors)
  await app.register(auth)
  app.get('/admin', { config: { auth: 'ADMIN' } }, async (req) => ({ user: req.user }))
  app.get('/agent', { config: { auth: 'AGENT' } }, async () => ({ ok: true }))
  app.get('/any', { config: { auth: 'ANY' } }, async (req) => ({ user: req.user }))
  app.get('/public', async () => ({ ok: true }))
  await app.ready()
  return app
}

test('missing bearer → 401 UNAUTHENTICATED', async () => {
  const app = await buildAuthApp()
  const res = await app.inject({ url: '/any' })
  assert.strictEqual(res.statusCode, 401)
  assert.strictEqual(res.json().error.code, 'UNAUTHENTICATED')
})

test('expired token → 401', async () => {
  const app = await buildAuthApp()
  const token = app.jwt.sign({ sub: 'u1', role: 'ADMIN' }, { expiresIn: -10 })
  const res = await app.inject({ url: '/any', headers: { authorization: `Bearer ${token}` } })
  assert.strictEqual(res.statusCode, 401)
})

test('role mismatch → 403 FORBIDDEN', async () => {
  const app = await buildAuthApp()
  const token = app.jwt.sign({ sub: 'u1', role: 'AGENT', agentId: 'u1' })
  const res = await app.inject({ url: '/admin', headers: { authorization: `Bearer ${token}` } })
  assert.strictEqual(res.statusCode, 403)
  assert.strictEqual(res.json().error.code, 'FORBIDDEN')
})

test('request.user exposes id, role and agentId', async () => {
  const app = await buildAuthApp()
  const token = app.jwt.sign({ sub: 'a1', role: 'AGENT', agentId: 'a1' })
  const res = await app.inject({ url: '/any', headers: { authorization: `Bearer ${token}` } })
  assert.strictEqual(res.statusCode, 200)
  assert.deepStrictEqual(res.json().user, { id: 'a1', role: 'AGENT', agentId: 'a1' })
})

test('routes without auth config stay public', async () => {
  const app = await buildAuthApp()
  const res = await app.inject({ url: '/public' })
  assert.strictEqual(res.statusCode, 200)
})
