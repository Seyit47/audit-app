import { NextResponse } from 'next/server'
import { loadShopCard } from '@/features/map/card'
import { ApiError } from '@/lib/api'
import { parseAsUuid } from '@/lib/search-params'

/**
 * The map's shop card as a plain GET, so selecting a shop doesn't re-render the whole map page on the
 * server, and cards can be prefetched in parallel on hover.
 */
export async function GET (_request: Request, ctx: RouteContext<'/data/shops/[id]/card'>) {
  const id = parseAsUuid.parseServerSide((await ctx.params).id)
  if (id == null) return NextResponse.json(null, { status: 404 })
  try {
    const card = await loadShopCard(id)
    return NextResponse.json(card, { status: card == null ? 404 : 200, headers: { 'cache-control': 'private, no-store' } })
  } catch (err) {
    return NextResponse.json(null, { status: err instanceof ApiError ? err.status : 502 })
  }
}
