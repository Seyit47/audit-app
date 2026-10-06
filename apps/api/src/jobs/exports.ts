import ExcelJS from 'exceljs'
import type { FastifyInstance } from 'fastify'
import { EXPORTS_QUEUE } from '../modules/exports/exports.service.js'

type Params = Record<string, string | number | null | undefined>
type Locale = 'ru' | 'en'
type Sheet = { columns: Array<{ header: string, key: string, width: number }>, rows: Array<Record<string, unknown>> }
/** A builder returns rows for an XLSX sheet, or a ready PDF. */
export type ExportBuilder = (app: FastifyInstance, params: Params, locale: Locale) => Promise<Sheet | { pdf: Buffer }>

const XLSX = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
const str = (v: unknown) => (typeof v === 'string' && v !== '' ? v : undefined)

const SHOP_STATUS: Record<Locale, Record<string, string>> = {
  en: { ACTIVE: 'Active', INACTIVE: 'Inactive', PENDING_REVIEW: 'Pending Review' },
  ru: { ACTIVE: 'Активен', INACTIVE: 'Неактивен', PENDING_REVIEW: 'На проверке' }
}

async function shopsSheet (app: FastifyInstance, p: Params, l: Locale): Promise<Sheet> {
  const repo = app.services.repositories.shops
  const shops = await repo.all({ q: str(p.q), status: str(p.status) as never, regionId: str(p.regionId), agentId: str(p.agentId) })
  const last = await repo.lastVisits(shops.map((s) => s.id))
  const h = l === 'ru'
    ? ['Код', 'Название', 'Владелец', 'Телефон', 'Адрес', 'Регион', 'Агент', 'Статус', 'Последний визит']
    : ['Code', 'Shop', 'Owner', 'Phone', 'Address', 'Region', 'Assigned salesman', 'Status', 'Last visit']
  const keys = ['code', 'name', 'owner', 'phone', 'address', 'region', 'agent', 'status', 'lastVisit']
  const widths = [12, 32, 22, 18, 40, 20, 24, 16, 20]
  return {
    columns: keys.map((key, i) => ({ header: h[i]!, key, width: widths[i]! })),
    rows: shops.map((s) => ({
      code: s.code,
      name: s.name,
      owner: s.ownerName ?? '',
      phone: s.contacts[0]?.phone ?? '',
      address: s.address,
      region: s.region?.name ?? '',
      agent: s.assignedAgent?.fullName ?? '',
      status: SHOP_STATUS[l][s.status],
      lastVisit: last.get(s.id)?.at ?? null
    }))
  }
}

async function agentsSheet (app: FastifyInstance, p: Params, l: Locale): Promise<Sheet> {
  const page = await app.services.agents.list({
    page: 1, size: 100_000, q: str(p.q), status: str(p.status) as never, regionId: str(p.regionId), from: str(p.from), to: str(p.to)
  })
  const h = l === 'ru'
    ? ['Код', 'ФИО', 'Телефон', 'Регион', 'Статус', 'Точки', 'Визиты', 'Фото', 'Последняя активность']
    : ['Code', 'Salesman', 'Phone', 'Region', 'Status', 'Locations', 'Visits', 'Photos', 'Last activity']
  const keys = ['code', 'name', 'phone', 'region', 'status', 'locations', 'visits', 'photos', 'last']
  const widths = [12, 28, 18, 22, 14, 10, 10, 10, 22]
  const status = (a: { active: boolean, workStatus: string }) =>
    !a.active ? (l === 'ru' ? 'Неактивен' : 'Inactive') : a.workStatus === 'ON_LEAVE' ? (l === 'ru' ? 'Отпуск' : 'On leave') : (l === 'ru' ? 'Активен' : 'Active')
  return {
    columns: keys.map((key, i) => ({ header: h[i]!, key, width: widths[i]! })),
    rows: page.items.map((a) => ({
      code: a.code, name: a.fullName, phone: a.phone, region: a.region.name, status: status(a),
      locations: a.locations, visits: a.visits, photos: a.photos, last: a.lastActivityAt != null ? new Date(a.lastActivityAt) : null
    }))
  }
}

/** One builder per export type. */
export const BUILDERS: Record<string, ExportBuilder> = {
  SHOPS_XLSX: shopsSheet,
  AGENTS_XLSX: agentsSheet
}

/** Builds one export and stores it; QUEUED → RUNNING → DONE / FAILED. */
export async function runExport (app: FastifyInstance, exportId: string): Promise<void> {
  const row = await app.prisma.export.findUnique({ where: { id: exportId } })
  if (row == null || row.status === 'DONE') return
  await app.prisma.export.update({ where: { id: exportId }, data: { status: 'RUNNING' } })
  try {
    const params = (row.params ?? {}) as Params
    const locale: Locale = params.locale === 'en' ? 'en' : 'ru'
    const build = BUILDERS[row.type]
    if (build == null) throw new Error(`No builder for ${row.type}`)
    const result = await build(app, params, locale)
    let body: Buffer
    let contentType = XLSX
    if ('pdf' in result) {
      body = result.pdf
      contentType = 'application/pdf'
    } else {
      const book = new ExcelJS.Workbook()
      const sheet = book.addWorksheet('Export')
      sheet.columns = result.columns
      sheet.getRow(1).font = { bold: true }
      result.rows.forEach((r) => sheet.addRow(r))
      body = Buffer.from(await book.xlsx.writeBuffer())
    }
    const key = `exports/${row.id}.${contentType === XLSX ? 'xlsx' : 'pdf'}`
    await app.storage.putObject(key, body, contentType)
    await app.prisma.export.update({ where: { id: exportId }, data: { status: 'DONE', fileKey: key, finishedAt: new Date() } })
  } catch (err) {
    app.log.error({ err, exportId }, 'export failed')
    await app.prisma.export.update({ where: { id: exportId }, data: { status: 'FAILED', finishedAt: new Date() } })
  }
}

export async function registerExportWorker (app: FastifyInstance): Promise<void> {
  await app.jobs.work<{ exportId: string }>(EXPORTS_QUEUE, async ({ exportId }) => runExport(app, exportId))
}
