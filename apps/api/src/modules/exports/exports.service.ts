import type { AuthUser } from '../../plugins/auth.js'
import type { Jobs } from '../../plugins/jobs.js'
import type { Storage } from '../../plugins/storage.js'
import type { PrismaClient } from '../../generated/prisma/client.js'
import { notFound } from '../../lib/app-error.js'
import { newId } from '../../lib/ids.js'
import type { CreateExportBody } from './exports.schema.js'

export const EXPORTS_QUEUE = 'exports'

const FILE_NAMES: Record<string, string> = {
  SHOPS_XLSX: 'shops.xlsx',
  AGENTS_XLSX: 'salesmen.xlsx',
  PRODUCTS_XLSX: 'products.xlsx',
  AGENT_REPORT_PDF: 'salesman-report.pdf',
  AGENT_REPORT_XLSX: 'salesman-report.xlsx'
}

/** Export Shops / Export Roster / Export Catalog / Экспорт отчёта: queued files in storage. */
export class ExportsService {
  private readonly prisma: PrismaClient
  private readonly jobs: Jobs
  private readonly storage: Storage
  constructor (prisma: PrismaClient, jobs: Jobs, storage: Storage) {
    this.prisma = prisma
    this.jobs = jobs
    this.storage = storage
  }

  async create (user: AuthUser, body: CreateExportBody) {
    const row = await this.prisma.export.create({ data: { id: newId(), requestedById: user.id, type: body.type, params: body.params ?? {} } })
    await this.jobs.send(EXPORTS_QUEUE, { exportId: row.id })
    return this.view(row)
  }

  async get (user: AuthUser, id: string) {
    const row = await this.prisma.export.findFirst({ where: { id, requestedById: user.id } })
    if (row == null) throw notFound('Export')
    return this.view(row)
  }

  private async view (row: { id: string, type: string, status: string, fileKey: string | null, createdAt: Date, finishedAt: Date | null }) {
    const fileName = FILE_NAMES[row.type] ?? 'export'
    return {
      id: row.id,
      type: row.type,
      status: row.status,
      fileName,
      url: row.status === 'DONE' && row.fileKey != null ? await this.storage.presignGet(row.fileKey, fileName) : null,
      createdAt: row.createdAt.toISOString(),
      finishedAt: row.finishedAt?.toISOString() ?? null
    }
  }
}
