import { listRegions } from '@/features/agents/api'
import { getShopProducts, listProductOptions, listAgentOptions, listShops, getShop, type ShopListQuery } from '@/features/shops/api'
import { ShopEditDialog } from '@/features/shops/components/ShopEditDialog'
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
  const editId = uuid(sp.edit)
  const dialog = sp.add != null || editId != null
  const [page, regions, agents, editing, products, carried] = await Promise.all([
    listShops(query),
    listRegions(),
    listAgentOptions(),
    editId != null ? getShop(editId).catch(() => null) : Promise.resolve(null),
    dialog ? listProductOptions() : Promise.resolve(null),
    editId != null ? getShopProducts(editId).catch(() => ({ productIds: [] })) : Promise.resolve({ productIds: [] })
  ])
  const keep = (omit: string[]) => new URLSearchParams(Object.entries(sp).filter((e): e is [string, string] => e[1] != null && !omit.includes(e[0])))
  const exportHref = `/export?${new URLSearchParams({ type: 'SHOPS_XLSX', back: '/shops', ...Object.fromEntries(keep(['page', 'size', 'add', 'edit', 'exportFailed'])) }).toString()}`
  const activeAgents = agents.items.filter((a) => a.active)

  return (
    <div className='flex flex-col gap-2.5 p-4'>
      <ShopsView page={page} copy={copy} locale={locale} agents={activeAgents} exportHref={exportHref}>
        {sp.exportFailed != null && <p role='alert' className='text-sm text-error'>{copy.exportFailed}</p>}
        <ShopsToolbar copy={copy} regions={regions} />
      </ShopsView>
      {(sp.add != null || editing != null) && (
        <ShopEditDialog key={editing?.id ?? 'new'} shop={editing} agents={activeAgents} products={products?.items ?? []} productIds={carried.productIds} copy={shopFormCopy[locale]} closeHref={`/shops?${keep(['add', 'edit']).toString()}`} />
      )}
    </div>
  )
}
