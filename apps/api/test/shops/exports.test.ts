import { test, before, beforeEach } from 'node:test'
import * as assert from 'node:assert'
import ExcelJS from 'exceljs'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'
import { bearer } from '../helpers/auth.js'
import { runExport } from '../../src/jobs/exports.js'

let app: FastifyInstance
before(async (t) => { app = await build(t as never) })
beforeEach(async () => { await resetDb(app) })

test('SHOPS_XLSX goes QUEUED → DONE and its rows match the filters', async () => {
  const a = await f.admin(app)
  const h = bearer(app, { id: a.id, role: 'ADMIN' })
  await f.shop(app, { createdById: a.id })
  await f.shop(app, { createdById: a.id, status: 'INACTIVE' })
  const created = await app.inject({ method: 'POST', url: '/v1/exports', headers: h, payload: { type: 'SHOPS_XLSX', params: { status: 'INACTIVE' } } })
  assert.strictEqual(created.statusCode, 201, created.body)
  assert.strictEqual(created.json().status, 'QUEUED')

  await runExport(app, created.json().id)

  const done = (await app.inject({ url: `/v1/exports/${created.json().id}`, headers: h })).json()
  assert.strictEqual(done.status, 'DONE')
  assert.ok(done.url)
  const file = await app.storage.getObject((await app.prisma.export.findUniqueOrThrow({ where: { id: created.json().id } })).fileKey!)
  const book = new ExcelJS.Workbook()
  await book.xlsx.load(file as unknown as ArrayBuffer)
  assert.strictEqual(book.worksheets[0]!.rowCount, 2, 'header + one INACTIVE shop')
})
