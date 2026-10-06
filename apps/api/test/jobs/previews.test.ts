import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import { randomUUID } from 'node:crypto'
import sharp from 'sharp'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { generatePreviews } from '../../src/jobs/previews.js'

let app: FastifyInstance
before(async (t) => { app = await build(t as never) })
beforeEach(async () => { await resetDb(app) })

test('previews are generated as 400/1200 WebP and the original is untouched', async () => {
  const agent = await f.agent(app)
  const original = await sharp({ create: { width: 2000, height: 1000, channels: 3, background: '#493ee5' } }).jpeg().toBuffer()
  const id = randomUUID()
  const key = `audit/${id}.jpg`
  await app.storage.putObject(key, original, 'image/jpeg')
  await app.prisma.photo.create({ data: { id, kind: 'AUDIT', uploadedById: agent.userId, storageKey: key, mime: 'image/jpeg', sizeBytes: original.length, sha256: 'x', takenAt: new Date(), status: 'READY' } })

  await generatePreviews(app, id)

  const photo = await app.prisma.photo.findUniqueOrThrow({ where: { id } })
  assert.deepStrictEqual([photo.width, photo.height], [2000, 1000])
  const keys = photo.previewKeys as Record<string, string>
  const p400 = await sharp(await app.storage.getObject(keys['400']!)).metadata()
  assert.strictEqual(p400.format, 'webp')
  assert.strictEqual(p400.width, 400)
  assert.ok((await app.storage.getObject(key)).equals(original))
})
