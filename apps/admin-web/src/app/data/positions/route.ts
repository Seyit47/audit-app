import { NextResponse } from 'next/server'
import { api, ApiError } from '@/lib/api'

/** Live agent positions for the map, polled from the browser instead of re-rendering the whole page. */
export async function GET () {
  try {
    return NextResponse.json(await api('/v1/agents/positions'), { headers: { 'cache-control': 'private, no-store' } })
  } catch (err) {
    const status = err instanceof ApiError ? err.status : 502
    return NextResponse.json({ error: err instanceof ApiError ? err.code : 'UNAVAILABLE' }, { status })
  }
}
