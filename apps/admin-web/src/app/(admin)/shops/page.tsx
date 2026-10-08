import { listRegions } from '@/features/agents/api'
import { listAgentOptions, listShops, type ShopListQuery } from '@/features/shops/api'
import { ShopFormHost } from '@/features/shops/components/ShopFormHost'
import { ShopsToolbar } from '@/features/shops/components/ShopsToolbar'
import { ShopsView } from '@/features/shops/components/ShopsView'
import { shopFormCopy, shopsCopy } from '@/features/shops/copy'
import { getLocale } from '@/lib/locale'
import { int, oneOf, text, uuid } from '@/lib/params'

type Search = Record<string, string | undefined>

export default async function ShopsPage ({ searchParams }: PageProps<'/shops'>) {
  const sp = (await searchParams) as Search
  const locale = await getLocale()
  const copy = shopsCopy[locale]
  const query: ShopListQuery = {
    page: int(sp.page, 1),
    size: int(sp.size, 10, 1, 100),
    q: text(sp.q),
    status: oneOf(sp.status, ['ACTIVE', 'INACTIVE', 'PENDING_REVIEW'] as const),
    regionId: uuid(sp.regionId),
    agentId: uuid(sp.agentId)
  }
  const [page, regions, agents] = await Promise.all([listShops(query), listRegions(), listAgentOptions()])
  const keep = (omit: string[]) => new URLSearchParams(Object.entries(sp).filter((e): e is [string, string] => e[1] != null && !omit.includes(e[0])))
  const exportHref = `/export?${new URLSearchParams({ type: 'SHOPS_XLSX', back: '/shops', ...Object.fromEntries(keep(['page', 'size', 'add', 'edit', 'exportFailed'])) }).toString()}`
  const activeAgents = agents.items.filter((a) => a.active)

  return (
    <div className='flex flex-col gap-2.5 p-4'>
      <ShopsView page={page} copy={copy} locale={locale} agents={activeAgents} exportHref={exportHref}>
        {sp.exportFailed != null && <p role='alert' className='text-sm text-error'>{copy.exportFailed}</p>}
        <ShopsToolbar copy={copy} regions={regions} />
      </ShopsView>
      {/* Opens from ?add=1 in the browser, its data fetched on demand (no server render). */}
      <ShopFormHost copy={shopFormCopy[locale]} />
    </div>
  )
}
