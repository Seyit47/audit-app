'use client'

import { Card } from '@/components/ui/Card'
import { FilterSelect } from '@/components/ui/FilterSelect'
import { SearchAutocomplete } from '@/components/ui/SearchAutocomplete'
import { search } from '@/lib/search-actions'
import { useUrlState } from '@/lib/url-state'
import type { ProductsCopy } from '../copy'

/** "Search & Filters Toolbar" of 30:574 (30:730). */
export function ProductsToolbar ({ copy }: { copy: ProductsCopy }) {
  const { params, set } = useUrlState()
  return (
    <Card className='relative z-20 flex items-center justify-between gap-4 p-4'>
      <SearchAutocomplete
        key={params.get('q') ?? ''}
        placeholder={copy.search} defaultValue={params.get('q') ?? ''}
        load={async (q) => [{ label: copy.title, hits: (await search(q, ['products'])).products ?? [] }]}
        onSubmit={(q) => set({ q })}
      />
      <FilterSelect
        label={copy.status} value={params.get('status') ?? ''}
        options={[{ value: '', label: copy.allStatus }, ...(['ACTIVE', 'DRAFT', 'INACTIVE'] as const).map((s) => ({ value: s, label: copy.statuses[s] }))]}
        onChange={(v) => set({ status: v })}
      />
    </Card>
  )
}
