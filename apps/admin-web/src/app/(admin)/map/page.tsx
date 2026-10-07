import { AutoRefresh } from '@/components/ui/AutoRefresh'
import { listAgentOptions } from '@/features/shops/api'
import { listRegions } from '@/features/agents/api'
import { AdminMap } from '@/features/map/components/AdminMap'
import { loadShopCard } from '@/features/map/card'
import { mapCopy } from '@/features/map/copy'
import type { AgentPosition, MapShop } from '@/features/map/types'
import { shopsCopy } from '@/features/shops/copy'
import { api } from '@/lib/api'
import { getLocale } from '@/lib/locale'
import { uuid, uuids } from '@/lib/params'

type Search = Record<string, string | undefined>

const SATELLITE = process.env.SATELLITE_TILES_URL ?? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'

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
    // Only for a link that opens with a shop selected; later selections load on the client.
    shopId != null ? loadShopCard(shopId) : Promise.resolve(null)
  ])
  const d = shopsCopy[locale].details
  const shown = filters.agentIds.length > 0 ? positions.filter((p) => filters.agentIds.includes(p.agentId)) : positions

  return (
    <div className='h-screen pl-4'>
      <AutoRefresh seconds={30} />
      <AdminMap
        shops={shops} positions={shown} regions={regions} agents={agents.items.filter((a) => a.active)}
        filters={filters} initialCard={selected} copy={copy} locale={locale} satelliteTiles={SATELLITE}
        history={{ title: d.history, updatedAt: d.updatedAt, total: d.total, completed: d.completed, missed: d.missed, duration: d.duration, comment: d.comment, violation: d.violation, missedStatus: d.missedStatus, noVisits: d.noVisits }}
      />
    </div>
  )
}
