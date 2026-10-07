import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import type { FastifyInstance } from 'fastify'
import { build } from './helper.js'
import { resetDb } from './helpers/db.js'
import * as f from './helpers/factories.js'
import { bearer } from './helpers/auth.js'
import { newId } from '../src/lib/ids.js'

// SC-002: a device that was offline replays its outbox with retries, duplicates and reordering.
// The server must end with exactly one audit per client id and every photo linked.
let app: FastifyInstance
before(async (t) => { app = await build(t as never) })
beforeEach(async () => { await resetDb(app) })

const SHOP = { lat: 37.95, lng: 58.38 }

function shuffle<T> (xs: T[], seed = 7): T[] {
  const out = [...xs]
  let s = seed
  for (let i = out.length - 1; i > 0; i--) {
    s = (s * 1103515245 + 12345) % 2 ** 31
    const j = s % (i + 1)
    ;[out[i], out[j]] = [out[j], out[i]]
  }
  return out
}

test('100 queued audits with retries and duplicates sent out of order → exactly 100 audits, no lost photos', async () => {
  const adminId = (await f.admin(app)).id
  const g = await f.agent(app)
  const h = bearer(app, { id: g.userId, role: 'AGENT' })
  const shops = await Promise.all(Array.from({ length: 10 }, () => f.shop(app, { createdById: adminId, agentId: g.userId, ...SHOP })))

  const audits = []
  for (let i = 0; i < 100; i++) {
    const photoIds = [newId(), newId()]
    for (const id of photoIds) {
      // The upload finished on an earlier sync; its retried create must stay idempotent.
      await app.prisma.photo.create({ data: { id, kind: 'AUDIT', uploadedById: g.userId, storageKey: `audit/${id}.jpg`, mime: 'image/jpeg', sizeBytes: 10, sha256: 'a'.repeat(64), takenAt: new Date(), status: 'READY', lat: SHOP.lat, lng: SHOP.lng } })
    }
    const finished = new Date(Date.now() - (100 - i) * 60_000)
    audits.push({
      id: newId(), shopId: shops[i % shops.length].id, startedAt: new Date(finished.getTime() - 10 * 60_000).toISOString(), finishedAt: finished.toISOString(),
      lat: SHOP.lat, lng: SHOP.lng, accuracyM: 6, comment: `Аудит ${i}`, hasViolation: i % 7 === 0, photoIds
    })
  }

  // Every audit is sent 1–3 times (lost responses), in shuffled order, partly concurrently.
  const sends = shuffle(audits.flatMap((a, i) => Array.from({ length: 1 + (i % 3) }, () => a)))
  const repeatUploads = audits.slice(0, 20).flatMap((a) => a.photoIds)
  for (const id of repeatUploads) {
    const res = await app.inject({ method: 'POST', url: '/v1/uploads', headers: h, payload: { id, kind: 'AUDIT', mime: 'image/jpeg', sizeBytes: 10, sha256: 'a'.repeat(64), takenAt: new Date().toISOString() } })
    assert.strictEqual(res.statusCode, 200, res.body)
    assert.strictEqual(res.json().status, 'READY')
  }
  for (let i = 0; i < sends.length; i += 8) {
    const batch = sends.slice(i, i + 8)
    const results = await Promise.all(batch.map((body) => app.inject({ method: 'POST', url: '/v1/audits', headers: h, payload: body })))
    for (const r of results) assert.ok([200, 201].includes(r.statusCode), `${r.statusCode} ${r.body}`)
  }

  assert.strictEqual(await app.prisma.audit.count(), 100)
  assert.strictEqual(await app.prisma.photo.count({ where: { auditId: null, kind: 'AUDIT' } }), 0)
  for (const a of audits) {
    assert.strictEqual(await app.prisma.photo.count({ where: { auditId: a.id } }), 2, `photos of ${a.id}`)
  }
  assert.strictEqual(await app.prisma.audit.count({ where: { hasViolation: true } }), audits.filter((a) => a.hasViolation).length)
})
