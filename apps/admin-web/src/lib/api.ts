import 'server-only'
import { ApiError, type ApiErrorBody } from './api-error'
import { authorizedFetch } from './session'

export { ApiError }

const base = () => {
  const url = process.env.API_URL
  if (!url) throw new Error('API_URL is not set')
  return url
}

/** Typed JSON request to the API, authenticated with the session (refreshes once on 401). */
export async function api<T> (path: string, init: { method?: string, body?: unknown, query?: Record<string, unknown> } = {}): Promise<T> {
  const qs = init.query
    ? '?' + new URLSearchParams(Object.entries(init.query).filter(([, v]) => v !== undefined && v !== '').flatMap(([k, v]) => Array.isArray(v) ? v.map((x) => [k, String(x)]) : [[k, String(v)]])).toString()
    : ''
  const res = await authorizedFetch(`${base()}${path}${qs}`, {
    method: init.method ?? 'GET',
    headers: init.body === undefined ? {} : { 'content-type': 'application/json' },
    body: init.body === undefined ? undefined : JSON.stringify(init.body),
    cache: 'no-store'
  })
  if (res.status === 204) return undefined as T
  const data = await res.json().catch(() => null)
  if (!res.ok) throw ApiError.from(res.status, data as ApiErrorBody | null)
  return data as T
}

export interface Page<T> { items: T[], total: number, page: number, size: number }
export interface CursorPage<T> { items: T[], nextCursor: string | null }
