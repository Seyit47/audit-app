import { test, before } from 'node:test'
import * as assert from 'node:assert'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'

let app: FastifyInstance
before(async (t) => { app = await build(t as never) })

test('/health reuses the storage check instead of a storage read per probe', async () => {
  let heads = 0
  const head = app.storage.head
  app.storage.head = async (key) => { heads++; return head(key) }
  for (let i = 0; i < 5; i++) assert.strictEqual((await app.inject({ url: '/health' })).statusCode, 200)
  assert.strictEqual(heads, 1)
})
