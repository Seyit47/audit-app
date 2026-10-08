import { NextResponse } from 'next/server'
import { getAgent, listRegions } from '@/features/agents/api'
import { getProduct, listCategories } from '@/features/products/api'
import { getShop, getShopProducts, listAgentOptions, listProductOptions } from '@/features/shops/api'
import { api, ApiError } from '@/lib/api'
import { uuid } from '@/lib/params'

/** What a URL dialog's form needs (`?id=` when editing), fetched by the browser when the dialog opens. */
export async function GET (request: Request, ctx: RouteContext<'/data/forms/[kind]'>) {
  const { kind } = await ctx.params
  const raw = new URL(request.url).searchParams.get('id')
  const id = raw == null ? null : uuid(raw)
  if (raw != null && id == null) return NextResponse.json(null, { status: 404 })
  try {
    const body = kind === 'shop'
      ? await Promise.all([
        id == null ? null : getShop(id),
        listAgentOptions().then((p) => p.items.filter((a) => a.active)),
        listProductOptions().then((p) => p.items),
        id == null ? [] : getShopProducts(id).then((c) => c.productIds)
      ]).then(([shop, agents, products, productIds]) => ({ shop, agents, products, productIds }))
      : kind === 'product'
        ? await Promise.all([id == null ? null : getProduct(id), listCategories()]).then(([product, categories]) => ({ product, categories }))
        : kind === 'agent'
          ? await Promise.all([
            id == null ? null : getAgent(id),
            listRegions(),
            id == null ? api<{ code: string }>('/v1/agents/next-code').then((n) => n.code) : ''
          ]).then(([agent, regions, nextCode]) => ({ agent, regions, nextCode }))
          : null
    if (body == null) return NextResponse.json(null, { status: 404 })
    return NextResponse.json(body, { headers: { 'cache-control': 'private, no-store' } })
  } catch (err) {
    return NextResponse.json(null, { status: err instanceof ApiError ? err.status : 502 })
  }
}
