import { AutoRefresh } from '@/components/ui/AutoRefresh'
import { listAgentOptions, getShop, type Visit } from '@/features/shops/api'
import { listRegions } from '@/features/agents/api'
import { AdminMap } from '@/features/map/components/AdminMap'
import { ShopCard } from '@/features/map/components/ShopCard'
import { mapCopy } from '@/features/map/copy'
import type { AgentPosition, MapShop } from '@/features/map/types'
import type { GalleryPage } from '@/features/photos/types'
import { shopsCopy } from '@/features/shops/copy'
import { api, ApiError, type CursorPage } from '@/lib/api'
import { getLocale } from '@/lib/locale'
import { uuid, uuids } from '@/lib/params'

type Search = Record<string, string | undefined>

const SATELLITE = process.env.SATELLITE_TILES_URL ?? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
async function card (id: string) {
  try {
    const [shop, visits, photos] = await Promise.all([
      getShop(id),
      api<CursorPage<Visit> & { totals: { all: number, completed: number, missed: number } }>(`/v1/shops/${id}/visits`, { query: { limit: 3 } }),
      api<GalleryPage>('/v1/photos', { query: { shopId: id, limit: 5 } })
    ])
    return { shop, visits, photos: photos.items }
  } catch (err) {
    if (err instanceof ApiError && (err.status === 404 || err.status === 400)) return null
    throw err
  }
}

/** Map of 21:2 / 3:2. Filters live in the URL (`agents`, `regions`, `ids` from Shops "View on Map", `shop`). */
export default async function MapPage ({ searchParams }: PageProps<'/map'>) {
  const sp = (await searchParams) as Search
  const locale = await getLocale()
  const copy = mapCopy[locale]
  const filters = { agentIds: uuids(sp.agents), regionIds: uuids(sp.regions), ids: uuids(sp.ids) }
  const shopId = uuid(sp.shop)
  const [shops, positions, regions, agents, selected] = await Promise.all([
    api<MapShop[]>('/v1/shops/map', { query: { agentIds: filters.agentIds, regionIds: filters.regionIds, ids: filters.ids } }),
    api<AgentPosition[]>('/v1/agents/positions'),
    listRegions(),
    listAgentOptions(),
    shopId != null ? card(shopId) : Promise.resolve(null)
  ])
  const d = shopsCopy[locale].details
  const closeHref = `/map?${new URLSearchParams(Object.entries(sp).filter((e): e is [string, string] => e[1] != null && e[0] !== 'shop')).toString()}`
  const shown = filters.agentIds.length > 0 ? positions.filter((p) => filters.agentIds.includes(p.agentId)) : positions

  return (
    <div className='h-screen pl-4'>
      <AutoRefresh seconds={30} />
      <AdminMap
        shops={shops} positions={shown} regions={regions} agents={agents.items.filter((a) => a.active)}
        filters={filters} selectedId={selected?.shop.id ?? null} copy={copy} locale={locale} satelliteTiles={SATELLITE}
      >
        {selected != null && (
          <ShopCard
            shop={selected.shop} visits={selected.visits.items} totals={selected.visits.totals} photos={selected.photos}
            closeHref={closeHref} copy={copy} locale={locale}
            history={{ title: d.history, updatedAt: d.updatedAt, total: d.total, completed: d.completed, missed: d.missed, duration: d.duration, comment: d.comment, violation: d.violation, missedStatus: d.missedStatus, noVisits: d.noVisits }}
          />
        )}
      </AdminMap>
    </div>
  )
}
