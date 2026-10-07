import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import ExcelJS from 'exceljs'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'
import { newId } from '../../src/lib/ids.js'
import { localDate } from '../../src/lib/time.js'
import { runExport } from '../../src/jobs/exports.js'

let app: FastifyInstance
let adminId: string
let admin: { authorization: string }
before(async (t) => { app = await build(t as never) })
beforeEach(async () => {
  await resetDb(app)
  adminId = (await f.admin(app)).id
  admin = bearer(app, { id: adminId, role: 'ADMIN' })
})

const ping = (minsAgo: number, extra: object = {}) => ({ recordedAt: new Date(Date.now() - minsAgo * 60_000).toISOString(), lat: 37.95, lng: 58.38, accuracyM: 5, batteryPct: 80, trigger: 'HEARTBEAT', ...extra })

test('pings: accepted for ACTIVE agents within working hours, batches of ≤200, position upserted', async () => {
  const g = await f.agent(app)
  const h = bearer(app, { id: g.userId, role: 'AGENT' })
  const post = (pings: object[], headers = h) => app.inject({ method: 'POST', url: '/v1/tracking/pings', headers, payload: { pings } })
  const res = await post([ping(10), ping(5, { trigger: 'GEOFENCE_ENTER', lat: 37.96 })])
  assert.strictEqual(res.statusCode, 200, res.body)
  assert.strictEqual(res.json().accepted, 2)
  assert.strictEqual(await app.prisma.locationPing.count({ where: { trigger: 'GEOFENCE_ENTER' } }), 1)
  assert.strictEqual((await app.prisma.agentPosition.findUniqueOrThrow({ where: { agentId: g.userId } })).lat, 37.96)

  assert.strictEqual((await post(Array.from({ length: 201 }, () => ping(1)))).statusCode, 400)

  const leave = await f.agent(app, { workStatus: 'ON_LEAVE' })
  assert.strictEqual((await post([ping(1)], bearer(app, { id: leave.userId, role: 'AGENT' }))).json().accepted, 0)

  await app.prisma.companySettings.update({ where: { id: 1 }, data: { workStart: '00:00', workEnd: '00:01' } })
  app.services.settings.invalidate()
  assert.strictEqual((await post([ping(1)])).json().accepted, 0, 'outside working hours')
})

test('summary, detail KPIs, timeline, track and reports', async () => {
  const g = await f.agent(app)
  await f.agent(app, { workStatus: 'ON_LEAVE' })
  const s1 = await f.shop(app, { createdById: adminId, agentId: g.userId, nextDueAt: new Date(Date.now() - 86_400_000) })
  await f.shop(app, { createdById: adminId, agentId: g.userId, nextDueAt: new Date(Date.now() - 86_400_000), lat: 37.96 })
  const day = localDate(new Date(), 'Asia/Ashgabat')
  const route = await app.services.routes.generate(g.userId, day)
  const stop = await app.prisma.routeStop.findFirstOrThrow({ where: { routeId: route!.id, shopId: s1.id } })
  const auditId = newId()
  const at = new Date()
  await app.prisma.audit.create({ data: { id: auditId, shopId: s1.id, agentId: g.userId, startedAtDevice: new Date(at.getTime() - 900_000), finishedAtDevice: at, durationMin: 15, lat: 37.95, lng: 58.38, gpsAccuracyM: 5, distanceM: 3, withinRadius: true, comment: 'ok' } })
  await app.prisma.photo.create({ data: { id: newId(), kind: 'AUDIT', auditId, uploadedById: g.userId, storageKey: 'a/1.jpg', mime: 'image/jpeg', sizeBytes: 1, sha256: 'a'.repeat(64), takenAt: at, status: 'READY', verifiedAt: at } })
  await app.prisma.routeStop.update({ where: { id: stop.id }, data: { status: 'DONE', auditId } })
  await app.inject({ method: 'POST', url: '/v1/tracking/pings', headers: bearer(app, { id: g.userId, role: 'AGENT' }), payload: { pings: [ping(20), ping(2, { lat: 37.951 })] } })

  const summary = (await app.inject({ url: `/v1/agents/summary?from=${day}&to=${day}`, headers: admin })).json()
  assert.strictEqual(summary.totalStaff, 2)
  assert.strictEqual(summary.activeStaff, 1)
  assert.strictEqual(summary.onRoute, 1)
  assert.strictEqual(summary.audits, 1)
  assert.strictEqual(summary.shopsVisited, 1)
  assert.strictEqual(summary.shopsPlanned, 2)
  assert.strictEqual(summary.photos, 1)
  assert.strictEqual(summary.photosVerifiedPct, 100)
  assert.strictEqual(summary.needsContact, 0)

  const detail = (await app.inject({ url: `/v1/agents/${g.userId}?from=${day}&to=${day}`, headers: admin })).json()
  assert.deepStrictEqual(detail.kpis, { audits: 1, assignedShops: 2, visitedShops: 1, photos: 1 })
  assert.strictEqual(detail.online, true)

  const timeline = (await app.inject({ url: `/v1/agents/${g.userId}/timeline?date=${day}`, headers: admin })).json()
  assert.strictEqual(timeline.length, 2)
  const done = timeline.find((t: { status: string }) => t.status === 'DONE')
  assert.strictEqual(done.photoCount, 1)
  assert.strictEqual(done.audit.durationMin, 15)

  const track = (await app.inject({ url: `/v1/agents/${g.userId}/track?date=${day}`, headers: admin })).json()
  assert.strictEqual(track.points.length, 2)
  assert.strictEqual(track.checkpoints.length, 2)
  assert.ok(track.current)

  const positions = (await app.inject({ url: '/v1/agents/positions', headers: admin })).json()
  assert.strictEqual(positions.length, 1)

  const visits = (await app.inject({ url: `/v1/agents/${g.userId}/visits`, headers: admin })).json()
  assert.strictEqual(visits.totals.completed, 1)

  for (const type of ['AGENT_REPORT_XLSX', 'AGENT_REPORT_PDF']) {
    const job = (await app.inject({ method: 'POST', url: '/v1/exports', headers: admin, payload: { type, params: { agentId: g.userId, from: day, to: day } } })).json()
    await runExport(app, job.id)
    const row = await app.prisma.export.findUniqueOrThrow({ where: { id: job.id } })
    assert.strictEqual(row.status, 'DONE', type)
    const file = await app.storage.getObject(row.fileKey!)
    if (type === 'AGENT_REPORT_PDF') assert.strictEqual(file.subarray(0, 4).toString(), '%PDF')
    else {
      const book = new ExcelJS.Workbook()
      await book.xlsx.load(file as unknown as ArrayBuffer)
      assert.ok(book.worksheets[0]!.rowCount >= 2)
    }
  }
})
