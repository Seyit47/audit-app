import { AutoRefresh } from '@/components/ui/AutoRefresh'
import { listAgentOptions } from '@/features/shops/api'
import { listRegions } from '@/features/agents/api'
import { AdminMap } from '@/features/map/components/AdminMap'
import { loadShopCard } from '@/features/map/card'
import { mapCopy } from '@/features/map/copy'
import type { AgentPosition, MapShop, MapVisitStatus } from '@/features/map/types'
import { shopsCopy } from '@/features/shops/copy'
import { api } from '@/lib/api'
import { getLocale } from '@/lib/locale'
import { loadMapParams } from '@/features/map/search-params'

const SATELLITE = process.env.SATELLITE_TILES_URL ?? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'

const RECENT_MS = 7 * 86_400_000

/** Status filter (791:2406): `visitState` is today's, so "visited" means visited today. */
function matchesStatus (s: MapShop, status: MapVisitStatus, now: number): boolean {
  if (status === 'visited') return s.visitState === 'VISITED'
  if (status === 'not_visited') return s.visitState !== 'VISITED'
  if (status === 'recent') return s.lastVisitAt != null && now - Date.parse(s.lastVisitAt) <= RECENT_MS
  return true
}

/**
 * Map of 21:2 / 3:2. Filters live in the URL (`agents`, `regions`, `show`, `status`, `ids` from Shops "View on Map",
 * `shop`).
 */
export default async function MapPage ({ searchParams }: PageProps<'/map'>) {
  const locale = await getLocale()
  const copy = mapCopy[locale]
  const p = await loadMapParams(searchParams)
  const filters = { agentIds: p.agents, regionIds: p.regions, show: p.show, status: p.status, ids: p.ids }
  const shopId = p.shop
  const [shops, positions, regions, agents, selected] = await Promise.all([
    api<MapShop[]>('/v1/shops/map', { query: { agentIds: filters.agentIds, regionIds: filters.regionIds, ids: filters.ids } }),
    api<AgentPosition[]>('/v1/agents/positions'),
    listRegions(),
    listAgentOptions(),
    // Only for a link that opens with a shop selected; later selections load on the client.
    shopId != null ? loadShopCard(shopId) : Promise.resolve(null)
  ])
  const d = shopsCopy[locale].details
  const now = new Date().getTime()
  const shownShops = filters.show === 'agents' ? [] : shops.filter((s) => matchesStatus(s, filters.status, now))

  return (
    <div className='h-screen pl-4'>
      {/* Agent positions poll every 30 s in the map itself; the whole page (shop visit colors) every 5 min. */}
      <AutoRefresh seconds={300} />
      <AdminMap
        shops={shownShops} positions={positions} regions={regions} agents={agents.items.filter((a) => a.active)}
        filters={filters} initialCard={selected} copy={copy} locale={locale} satelliteTiles={SATELLITE}
        history={{ title: d.history, updatedAt: d.updatedAt, total: d.total, completed: d.completed, missed: d.missed, duration: d.duration, comment: d.comment, violation: d.violation, missedStatus: d.missedStatus, noVisits: d.noVisits }}
      />
    </div>
  )
}
