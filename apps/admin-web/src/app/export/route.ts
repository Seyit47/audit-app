import { NextResponse, type NextRequest } from 'next/server'
import { api } from '@/lib/api'
import { getLocale } from '@/lib/locale'

interface ExportView { id: string, status: 'QUEUED' | 'RUNNING' | 'DONE' | 'FAILED', url: string | null }

const TYPES = new Set(['SHOPS_XLSX', 'AGENTS_XLSX', 'PRODUCTS_XLSX', 'AGENT_REPORT_PDF', 'AGENT_REPORT_XLSX'])

/**
 * `/export?type=SHOPS_XLSX&status=…` — starts an export with the page's filters, waits for the
 * worker (up to 60 s) and redirects to the file.
 */
export async function GET (request: NextRequest) {
  const params = Object.fromEntries(request.nextUrl.searchParams)
  const { type, back, ...filters } = params
  if (!TYPES.has(type ?? '')) return NextResponse.json({ error: 'Unknown export type' }, { status: 400 })
  let job = await api<ExportView>('/v1/exports', { method: 'POST', body: { type, params: { ...filters, locale: await getLocale() } } })
  for (let i = 0; i < 60 && (job.status === 'QUEUED' || job.status === 'RUNNING'); i++) {
    await new Promise((r) => setTimeout(r, 1000))
    job = await api<ExportView>(`/v1/exports/${job.id}`)
  }
  if (job.status !== 'DONE' || job.url == null) {
    return NextResponse.redirect(new URL(`${back ?? '/'}${(back ?? '/').includes('?') ? '&' : '?'}exportFailed=1`, request.url))
  }
  return NextResponse.redirect(job.url)
}
