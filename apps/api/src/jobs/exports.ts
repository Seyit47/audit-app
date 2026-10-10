import ExcelJS from 'exceljs'
import { createRequire } from 'node:module'
import { dirname, join } from 'node:path'
import type { FastifyInstance } from 'fastify'
import { EXPORTS_QUEUE } from '../modules/exports/exports.service.js'

type Params = Record<string, string | number | null | undefined>
type Locale = 'ru' | 'en' | 'tk'
type Sheet = { columns: Array<{ header: string, key: string, width: number }>, rows: Array<Record<string, unknown>> }
/** A builder returns rows for an XLSX sheet, or a ready PDF. */
export type ExportBuilder = (app: FastifyInstance, params: Params, locale: Locale) => Promise<Sheet | { pdf: Buffer }>

const XLSX = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
const str = (v: unknown) => (typeof v === 'string' && v !== '' ? v : undefined)

const SHOP_STATUS: Record<Locale, Record<string, string>> = {
  en: { ACTIVE: 'Active', INACTIVE: 'Inactive', PENDING_REVIEW: 'Pending Review' },
  ru: { ACTIVE: 'Активен', INACTIVE: 'Неактивен', PENDING_REVIEW: 'На проверке' },
  tk: { ACTIVE: 'Işjeň', INACTIVE: 'Işjeň däl', PENDING_REVIEW: 'Barlagda' }
}

const SHOP_HEADERS: Record<Locale, string[]> = {
  ru: ['Код', 'Название', 'Владелец', 'Телефон', 'Адрес', 'Регион', 'Агент', 'Статус', 'Последний визит'],
  en: ['Code', 'Shop', 'Owner', 'Phone', 'Address', 'Region', 'Assigned salesman', 'Status', 'Last visit'],
  tk: ['Kod', 'Ady', 'Eýesi', 'Telefon', 'Salgy', 'Sebit', 'Agent', 'Ýagdaý', 'Soňky sapar']
}

const AGENT_HEADERS: Record<Locale, string[]> = {
  ru: ['Код', 'ФИО', 'Телефон', 'Регион', 'Статус', 'Точки', 'Визиты', 'Фото', 'Последняя активность'],
  en: ['Code', 'Salesman', 'Phone', 'Region', 'Status', 'Locations', 'Visits', 'Photos', 'Last activity'],
  tk: ['Kod', 'F.A.A.', 'Telefon', 'Sebit', 'Ýagdaý', 'Nokatlar', 'Saparlar', 'Surat', 'Soňky işjeňlik']
}

const AGENT_STATUS: Record<Locale, { inactive: string, leave: string, active: string }> = {
  ru: { inactive: 'Неактивен', leave: 'Отпуск', active: 'Активен' },
  en: { inactive: 'Inactive', leave: 'On leave', active: 'Active' },
  tk: { inactive: 'Işjeň däl', leave: 'Rugsatda', active: 'Işjeň' }
}

async function shopsSheet (app: FastifyInstance, p: Params, l: Locale): Promise<Sheet> {
  const repo = app.services.repositories.shops
  const shops = await repo.all({ q: str(p.q), status: str(p.status) as never, regionId: str(p.regionId), agentId: str(p.agentId) })
  const last = await repo.lastVisits(shops.map((s) => s.id))
  const h = SHOP_HEADERS[l]
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
  const h = AGENT_HEADERS[l]
  const keys = ['code', 'name', 'phone', 'region', 'status', 'locations', 'visits', 'photos', 'last']
  const widths = [12, 28, 18, 22, 14, 10, 10, 10, 22]
  const t = AGENT_STATUS[l]
  const status = (a: { active: boolean, workStatus: string }) => !a.active ? t.inactive : a.workStatus === 'ON_LEAVE' ? t.leave : t.active
  return {
    columns: keys.map((key, i) => ({ header: h[i]!, key, width: widths[i]! })),
    rows: page.items.map((a) => ({
      code: a.code, name: a.fullName, phone: a.phone, region: a.region.name, status: status(a),
      locations: a.locations, visits: a.visits, photos: a.photos, last: a.lastActivityAt != null ? new Date(a.lastActivityAt) : null
    }))
  }
}

/** Visits of one agent in a period, for the salesman report (Экспорт отчёта, 122:7981). */
async function agentReportRows (app: FastifyInstance, p: Params, l: Locale) {
  const agentId = str(p.agentId)
  if (agentId == null) throw new Error('agentId is required')
  const agent = await app.prisma.agent.findUniqueOrThrow({ where: { userId: agentId }, include: { region: true } })
  const period = await app.services.agentInsights.period(str(p.from), str(p.to))
  const kpis = await app.services.agentInsights.kpis(agentId, str(p.from), str(p.to))
  const [audits, missed] = await Promise.all([
    app.prisma.audit.findMany({ where: { agentId, finishedAtDevice: { gte: period.start, lt: period.end } }, include: { shop: true, _count: { select: { photos: true } } }, orderBy: { finishedAtDevice: 'asc' } }),
    app.prisma.routeStop.findMany({ where: { status: 'MISSED', route: { agentId }, plannedAt: { gte: period.start, lt: period.end } }, include: { shop: true }, orderBy: { plannedAt: 'asc' } })
  ])
  const t = REPORT_STATUS[l]
  const rows = [
    ...audits.map((a) => ({ at: a.finishedAtDevice, shop: a.shop.name, code: a.shop.code, status: t.done, duration: a.durationMin as number | null, photos: a._count.photos, violation: a.hasViolation ? t.yes : t.no, comment: a.comment })),
    ...missed.map((m) => ({ at: m.plannedAt, shop: m.shop.name, code: m.shop.code, status: t.missed, duration: null, photos: 0, violation: '', comment: '' }))
  ].sort((a, b) => a.at.getTime() - b.at.getTime())
  return { agent, kpis, rows, from: str(p.from), to: str(p.to) }
}

const REPORT_HEADERS: Record<Locale, string[]> = {
  ru: ['Дата и время', 'Магазин', 'Код', 'Статус', 'Длительность, мин', 'Фото', 'Нарушение', 'Комментарий'],
  en: ['Date and time', 'Shop', 'Code', 'Status', 'Duration, min', 'Photos', 'Violation', 'Comment'],
  tk: ['Sene we wagt', 'Dükan', 'Kod', 'Ýagdaý', 'Dowamlylygy, min', 'Surat', 'Bozulma', 'Teswir']
}
const REPORT_STATUS: Record<Locale, { done: string, missed: string, yes: string, no: string }> = {
  ru: { done: 'Завершён', missed: 'Пропущен', yes: 'Да', no: 'Нет' },
  en: { done: 'Completed', missed: 'Missed', yes: 'Yes', no: 'No' },
  tk: { done: 'Tamamlandy', missed: 'Galdyryldy', yes: 'Hawa', no: 'Ýok' }
}
const REPORT_KEYS = ['at', 'shop', 'code', 'status', 'duration', 'photos', 'violation', 'comment']

async function agentReportXlsx (app: FastifyInstance, p: Params, l: Locale): Promise<Sheet> {
  const { rows } = await agentReportRows(app, p, l)
  const widths = [20, 30, 12, 14, 18, 8, 12, 60]
  return { columns: REPORT_KEYS.map((key, i) => ({ header: REPORT_HEADERS[l][i]!, key, width: widths[i]! })), rows }
}

const REPORT_KPIS: Record<Locale, string[]> = {
  ru: ['Аудиты', 'Назначено магазинов', 'Посещено', 'Фото'],
  en: ['Audits', 'Assigned shops', 'Visited', 'Photos'],
  tk: ['Auditler', 'Berkidilen dükanlar', 'Barlanan', 'Surat']
}
const DATE_TAG: Record<Locale, string> = { ru: 'ru-RU', en: 'en-GB', tk: 'tk-TM' }

let fontsReady = false
async function agentReportPdf (app: FastifyInstance, p: Params, l: Locale): Promise<{ pdf: Buffer }> {
  const { agent, kpis, rows, from, to } = await agentReportRows(app, p, l)
  const require = createRequire(import.meta.url)
  const pdfmake = require('pdfmake')
  if (!fontsReady) {
    const dir = join(dirname(require.resolve('pdfmake/package.json')), 'fonts', 'Roboto')
    pdfmake.addFonts({ Roboto: { normal: join(dir, 'Roboto-Regular.ttf'), bold: join(dir, 'Roboto-Medium.ttf'), italics: join(dir, 'Roboto-Italic.ttf'), bolditalics: join(dir, 'Roboto-MediumItalic.ttf') } })
    pdfmake.setUrlAccessPolicy(() => false)
    fontsReady = true
  }
  const fmt = new Intl.DateTimeFormat(DATE_TAG[l], { dateStyle: 'short', timeStyle: 'short' })
  const k = REPORT_KPIS[l].map((label, i) => `${label}: ${[kpis.audits, kpis.assignedShops, kpis.visitedShops, kpis.photos][i]}`)
  const doc = {
    pageOrientation: 'landscape',
    defaultStyle: { font: 'Roboto', fontSize: 9 },
    content: [
      { text: `${agent.fullName} (${agent.code})`, fontSize: 16, bold: true },
      { text: `${agent.region.name} · ${from ?? ''}${to != null && to !== from ? ` — ${to}` : ''}`, margin: [0, 2, 0, 8], color: '#464555' },
      { text: k.join('   ·   '), margin: [0, 0, 0, 12] },
      {
        table: {
          headerRows: 1,
          widths: [70, 110, 45, 55, 50, 30, 50, '*'],
          body: [REPORT_HEADERS[l].map((h) => ({ text: h, bold: true })), ...rows.map((r) => [fmt.format(r.at), r.shop, r.code, r.status, r.duration ?? '', r.photos, r.violation, r.comment])]
        },
        layout: 'lightHorizontalLines'
      }
    ]
  }
  return { pdf: Buffer.from(await pdfmake.createPdf(doc).getBuffer()) }
}

const PRODUCT_HEADERS: Record<Locale, string[]> = {
  ru: ['Артикул', 'Название', 'Категория', 'Бренд', 'Цена', 'Статус', 'Точки', 'Покрытие, %', 'Регионы', 'Соответствие, %', 'Остаток'],
  en: ['SKU', 'Product', 'Category', 'Brand', 'Price', 'Status', 'Locations', 'Coverage, %', 'Regions', 'Compliance, %', 'Stock'],
  tk: ['Artikul', 'Ady', 'Kategoriýa', 'Brend', 'Bahasy', 'Ýagdaý', 'Nokatlar', 'Gurşaw, %', 'Sebitler', 'Laýyklyk, %', 'Galyndy']
}
const PRODUCT_STATUS: Record<Locale, Record<string, string>> = {
  ru: { ACTIVE: 'Активен', INACTIVE: 'Архив', DRAFT: 'Черновик' },
  en: { ACTIVE: 'Active', INACTIVE: 'Archived', DRAFT: 'Draft' },
  tk: { ACTIVE: 'Işjeň', INACTIVE: 'Arhiw', DRAFT: 'Garalama' }
}

async function productsSheet (app: FastifyInstance, p: Params, l: Locale): Promise<Sheet> {
  const rows = await app.services.products.all({ q: str(p.q), status: str(p.status) as never, categoryId: str(p.categoryId), regionId: str(p.regionId) })
  const h = PRODUCT_HEADERS[l]
  const keys = ['sku', 'name', 'category', 'brand', 'price', 'status', 'locations', 'coverage', 'regions', 'compliance', 'stock']
  const widths = [12, 36, 18, 16, 10, 12, 10, 12, 30, 14, 10]
  const status = PRODUCT_STATUS[l]
  return {
    columns: keys.map((key, i) => ({ header: h[i]!, key, width: widths[i]! })),
    rows: rows.map((r) => ({
      sku: r.sku, name: r.name, category: r.category.name, brand: r.brand ?? '', price: r.retailPrice, status: status[r.status],
      locations: r.locations, coverage: r.coveragePct ?? '', regions: r.regions.join(', '), compliance: r.compliancePct ?? '', stock: r.stockTracked ? r.stockQty : ''
    }))
  }
}

/** One builder per export type. */
export const BUILDERS: Record<string, ExportBuilder> = {
  SHOPS_XLSX: shopsSheet,
  AGENTS_XLSX: agentsSheet,
  PRODUCTS_XLSX: productsSheet,
  AGENT_REPORT_XLSX: agentReportXlsx,
  AGENT_REPORT_PDF: agentReportPdf
}

/** Builds one export and stores it; QUEUED → RUNNING → DONE / FAILED. */
export async function runExport (app: FastifyInstance, exportId: string): Promise<void> {
  const row = await app.prisma.export.findUnique({ where: { id: exportId } })
  if (row == null || row.status === 'DONE') return
  await app.prisma.export.update({ where: { id: exportId }, data: { status: 'RUNNING' } })
  try {
    const params = (row.params ?? {}) as Params
    const locale: Locale = params.locale === 'en' || params.locale === 'tk' ? params.locale : 'ru'
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
