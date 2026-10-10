'use client'

import { Card } from '@/components/ui/Card'
import { FilterSelect } from '@/components/ui/FilterSelect'
import { SearchAutocomplete } from '@/components/ui/SearchAutocomplete'
import { search } from '@/lib/search-actions'
import { useListParams } from '@/lib/use-list-params'
import { productsParams } from '../search-params'
import type { ProductsCopy } from '../copy'

/** "Search & Filters Toolbar" of 30:574 (30:730). */
export function ProductsToolbar ({ copy }: { copy: ProductsCopy }) {
  const { values, set } = useListParams(productsParams)
  return (
    <Card className='relative z-20 flex items-center justify-between gap-4 p-4'>
      <SearchAutocomplete
        key={values.q ?? ''}
        placeholder={copy.search} defaultValue={values.q ?? ''}
        load={async (q) => [{ label: copy.title, hits: (await search(q, ['products'])).products ?? [] }]}
        onSubmit={(q) => set({ q: q.trim() || null })}
      />
      <FilterSelect
        label={copy.status} value={values.status ?? ''}
        options={[{ value: '', label: copy.allStatus }, ...(['ACTIVE', 'DRAFT', 'INACTIVE'] as const).map((s) => ({ value: s, label: copy.statuses[s] }))]}
        onChange={(v) => set({ status: (v || null) as typeof values.status })}
      />
    </Card>
  )
}
