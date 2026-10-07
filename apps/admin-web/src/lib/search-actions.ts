'use server'

import { api, type Page } from '@/lib/api'
import type { AgentRow } from '@/features/agents/api'
import type { Product } from '@/features/products/api'
import type { ShopRow } from '@/features/shops/api'

export type SearchScope = 'shops' | 'agents' | 'products'

export interface SearchHit { id: string, title: string, detail: string | null, image: string | null, href: string }
export type SearchResults = Partial<Record<SearchScope, SearchHit[]>>

const size = 5

const loaders: Record<SearchScope, (q: string) => Promise<SearchHit[]>> = {
  shops: async (q) => (await api<Page<ShopRow>>('/v1/shops', { query: { q, size } })).items
    .map((s) => ({ id: s.id, title: s.name, detail: s.address, image: s.facade?.previewUrl400 ?? null, href: `/shops/${s.id}` })),
  agents: async (q) => (await api<Page<AgentRow>>('/v1/agents', { query: { q, size } })).items
    .map((a) => ({ id: a.id, title: a.fullName, detail: `${a.code} · ${a.region.name}`, image: a.photo?.previewUrl400 ?? null, href: `/salesmen/${a.id}` })),
  products: async (q) => (await api<Page<Product>>('/v1/products', { query: { q, size } })).items
    .map((p) => ({ id: p.id, title: p.name, detail: `${p.sku} · ${p.category.name}`, image: p.image?.previewUrl400 ?? null, href: `/products?edit=${p.id}` }))
}

/** Top matches per scope for the search popups; a scope that fails is left out. */
export async function search (q: string, scopes: SearchScope[]): Promise<SearchResults> {
  const term = q.trim().slice(0, 100)
  if (term === '') return {}
  const settled = await Promise.allSettled(scopes.map(async (s) => [s, await loaders[s](term)] as const))
  return Object.fromEntries(settled.flatMap((r) => r.status === 'fulfilled' ? [r.value] : []))
}
