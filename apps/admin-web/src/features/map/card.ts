import 'server-only'
import type { GalleryPage } from '@/features/photos/types'
import { getShop, type Visit } from '@/features/shops/api'
import { api, ApiError, type CursorPage } from '@/lib/api'
import type { ShopCardData } from './types'

/** Everything the map's shop card shows; null when the shop is gone. */
export async function loadShopCard (id: string): Promise<ShopCardData | null> {
  try {
    const [shop, visits, photos] = await Promise.all([
      getShop(id),
      api<CursorPage<Visit> & { totals: { all: number, completed: number, missed: number } }>(`/v1/shops/${id}/visits`, { query: { limit: 3 } }),
      api<GalleryPage>('/v1/photos', { query: { type: 'AUDIT', shopId: id, limit: 5 } })
    ])
    return { shop, visits: visits.items, totals: visits.totals, photos: photos.items }
  } catch (err) {
    if (err instanceof ApiError && (err.status === 404 || err.status === 400)) return null
    throw err
  }
}
