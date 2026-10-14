import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import { mkdtemp, writeFile } from 'node:fs/promises'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'

let app: FastifyInstance
let dir: string
before(async (t) => { app = await build(t as never) })
beforeEach(async () => {
  dir = await mkdtemp(join(tmpdir(), 'updates-'))
  app.config.updatesDir = dir
})

test('no updates folder configured or nothing published: 404', async () => {
  app.config.updatesDir = ''
  assert.strictEqual((await app.inject({ url: '/v1/app/latest' })).statusCode, 404)
  app.config.updatesDir = dir
  assert.strictEqual((await app.inject({ url: '/v1/app/latest' })).statusCode, 500, 'folder set but no latest.json')
})

test('latest.json and the APK it names: public, with the download size; the APK streams', async () => {
  await writeFile(join(dir, 'audit-app-1.0.29.apk'), Buffer.alloc(1234, 7))
  // FTP clients and Notepad may add a BOM.
  await writeFile(join(dir, 'latest.json'), '﻿' + JSON.stringify({ version: '1.0.29', build: 30, file: 'audit-app-1.0.29.apk', notes: 'Fixes', required: true }))
  const res = await app.inject({ url: '/v1/app/latest' })
  assert.strictEqual(res.statusCode, 200, res.body)
  assert.deepStrictEqual(res.json(), { version: '1.0.29', build: 30, notes: 'Fixes', required: true, url: '/v1/app/apk/audit-app-1.0.29.apk', sizeBytes: 1234 })

  const apk = await app.inject({ url: res.json().url })
  assert.strictEqual(apk.statusCode, 200)
  assert.strictEqual(apk.headers['content-type'], 'application/vnd.android.package-archive')
  assert.strictEqual(apk.rawPayload.length, 1234)
})

test('a broken latest.json or a missing APK is a server error; file names cannot leave the folder', async () => {
  await writeFile(join(dir, 'latest.json'), '{"version": "1.0.29"')
  assert.strictEqual((await app.inject({ url: '/v1/app/latest' })).statusCode, 500)
  await writeFile(join(dir, 'latest.json'), JSON.stringify({ version: '1.0.29', build: 30, file: 'missing.apk' }))
  assert.strictEqual((await app.inject({ url: '/v1/app/latest' })).statusCode, 500)

  assert.strictEqual((await app.inject({ url: '/v1/app/apk/..%2F..%2Fsettings.apk' })).statusCode, 400)
  assert.strictEqual((await app.inject({ url: '/v1/app/apk/latest.json' })).statusCode, 400)
  assert.strictEqual((await app.inject({ url: '/v1/app/apk/nothing.apk' })).statusCode, 404)
})
