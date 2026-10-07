import { NextResponse } from 'next/server'
import { api, ApiError } from '@/lib/api'
import { uuid } from '@/lib/params'

/**
 * Photo details for the gallery panel as a plain GET, so the browser can prefetch several in parallel
 * on hover (server actions run one at a time).
 */
export async function GET (_request: Request, ctx: RouteContext<'/data/photos/[id]'>) {
  const id = uuid((await ctx.params).id)
  if (id == null) return NextResponse.json({ error: 'NOT_FOUND' }, { status: 404 })
  try {
    return NextResponse.json(await api(`/v1/photos/${id}`), { headers: { 'cache-control': 'private, no-store' } })
  } catch (err) {
    const status = err instanceof ApiError ? err.status : 502
    return NextResponse.json({ error: err instanceof ApiError ? err.code : 'UNAVAILABLE' }, { status })
  }
}
