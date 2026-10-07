'use client'

import { Card } from '@/components/ui/Card'
import { FilterSelect } from '@/components/ui/FilterSelect'
import { SearchField } from '@/components/ui/SearchField'
import { useUrlState } from '@/lib/url-state'
import type { ProductsCopy } from '../copy'

/** "Search & Filters Toolbar" of 30:574 (30:730). */
export function ProductsToolbar ({ copy }: { copy: ProductsCopy }) {
  const { params, set } = useUrlState()
  return (
    <Card className='flex items-center justify-between gap-4 p-4'>
      <form role='search' onSubmit={(e) => { e.preventDefault(); set({ q: String(new FormData(e.currentTarget).get('q') ?? '') }) }}>
        <SearchField placeholder={copy.search} defaultValue={params.get('q') ?? ''} />
      </form>
      <FilterSelect
        label={copy.status} value={params.get('status') ?? ''}
        options={[{ value: '', label: copy.allStatus }, ...(['ACTIVE', 'DRAFT', 'INACTIVE'] as const).map((s) => ({ value: s, label: copy.statuses[s] }))]}
        onChange={(v) => set({ status: v })}
      />
    </Card>
  )
}
