import 'dotenv/config'
import { test } from 'node:test'
import * as assert from 'node:assert'
import Fastify from 'fastify'
import fp from 'fastify-plugin'
import storage from '../../src/plugins/storage.js'
import { loadConfig } from '../../src/plugins/env.js'

async function buildStorageApp () {
  const app = Fastify()
  const config = { ...loadConfig(), s3: { ...loadConfig().s3, bucket: process.env.S3_BUCKET_TEST ?? 'audit-photos-test' } }
  await app.register(fp(async (i) => { i.decorate('config', config) }, { name: 'env' }))
  await app.register(storage)
  await app.ready()
  return app
}

test('presigned PUT then presigned GET round-trips the bytes, and head reports size and type', async (t) => {
  const app = await buildStorageApp()
  t.after(() => app.close())
  const key = `test/${Date.now()}.txt`
  const body = Buffer.from('hello audit')

  const put = await app.storage.presignPut(key, 'text/plain', body.length)
  const putRes = await fetch(put.url, { method: 'PUT', body, headers: put.headers })
  assert.strictEqual(putRes.status, 200)

  const head = await app.storage.head(key)
  assert.deepStrictEqual(head, { sizeBytes: body.length, contentType: 'text/plain' })

  const getRes = await fetch(await app.storage.presignGet(key))
  assert.strictEqual(await getRes.text(), 'hello audit')
})

test('head of a missing object returns null', async (t) => {
  const app = await buildStorageApp()
  t.after(() => app.close())
  assert.strictEqual(await app.storage.head('missing/none.bin'), null)
})

test('read URLs stay the same within the hour, so clients reuse cached images', async (t) => {
  const app = await buildStorageApp()
  t.after(() => app.close())
  assert.strictEqual(await app.storage.presignGet('a/b.jpg'), await app.storage.presignGet('a/b.jpg'))
})

test('with S3_PUBLIC_ENDPOINT, presigned URLs are signed for the public address and work there', async (t) => {
  // The API talks to localhost; phones get 127.0.0.1 (a stand-in for the server's public IP).
  const base = loadConfig()
  const app = Fastify()
  const s3 = { ...base.s3, bucket: process.env.S3_BUCKET_TEST ?? 'audit-photos-test', endpoint: base.s3.endpoint, publicEndpoint: base.s3.endpoint.replace('localhost', '127.0.0.1') }
  await app.register(fp(async (i) => { i.decorate('config', { ...base, s3 }) }, { name: 'env' }))
  await app.register(storage)
  await app.ready()
  t.after(() => app.close())

  const key = `test/public-${Date.now()}.txt`
  const put = await app.storage.presignPut(key, 'text/plain', 2)
  assert.strictEqual(new URL(put.url).hostname, '127.0.0.1')
  assert.strictEqual((await fetch(put.url, { method: 'PUT', body: 'ok', headers: put.headers })).status, 200)
  const get = await app.storage.presignGet(key)
  assert.strictEqual(new URL(get).hostname, '127.0.0.1')
  assert.strictEqual(await (await fetch(get)).text(), 'ok')
})
