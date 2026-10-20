import { listDistricts } from '@/features/districts/api'
import { DistrictChips } from '@/features/districts/components/DistrictChips'
import { districtsCopy } from '@/features/districts/copy'
import { listAgentOptions, listShops, type ShopListQuery } from '@/features/shops/api'
import { ShopFormHost } from '@/features/shops/components/ShopFormHost'
import { ShopsToolbar } from '@/features/shops/components/ShopsToolbar'
import { ShopsView } from '@/features/shops/components/ShopsView'
import { shopFormCopy, shopsCopy } from '@/features/shops/copy'
import { getLocale } from '@/lib/locale'
import { loadShopsParams } from '@/features/shops/search-params'

type Search = Record<string, string | undefined>

export default async function ShopsPage ({ searchParams }: PageProps<'/shops'>) {
  const sp = (await searchParams) as Search
  const locale = await getLocale()
  const copy = shopsCopy[locale]
  const p = await loadShopsParams(searchParams)
  const query: ShopListQuery = { page: p.page, size: p.size, q: p.q ?? undefined, status: p.status ?? undefined, districtId: p.districtId ?? undefined, agentId: p.agentId ?? undefined }
  const [page, districts, agents] = await Promise.all([listShops(query), listDistricts(), listAgentOptions()])
  const keep = (omit: string[]) => new URLSearchParams(Object.entries(sp).filter((e): e is [string, string] => e[1] != null && !omit.includes(e[0])))
  const exportHref = `/export?${new URLSearchParams({ type: 'SHOPS_XLSX', back: '/shops', ...Object.fromEntries(keep(['page', 'size', 'add', 'edit', 'exportFailed'])) }).toString()}`
  const activeAgents = agents.items.filter((a) => a.active)

  return (
    <div className='flex flex-col gap-2.5 p-4'>
      <ShopsView page={page} copy={copy} locale={locale} agents={activeAgents}
        districts={districts.flatMap((d) => d.id == null || d.name == null ? [] : [{ id: d.id, name: d.name }])} exportHref={exportHref}>
        {sp.exportFailed != null && <p role='alert' className='text-sm text-error'>{copy.exportFailed}</p>}
        {/* Districts first: a chip lists its shops. */}
        <DistrictChips districts={districts} copy={districtsCopy[locale]} />
        <ShopsToolbar copy={copy} />
      </ShopsView>
      {/* Opens from ?add=1 in the browser, its data fetched on demand (no server render). */}
      <ShopFormHost copy={shopFormCopy[locale]} />
    </div>
  )
}
