'use client'

import { Card } from '@/components/ui/Card'
import { FilterSelect } from '@/components/ui/FilterSelect'
import { SearchAutocomplete } from '@/components/ui/SearchAutocomplete'
import { search } from '@/lib/search-actions'
import { useListParams } from '@/lib/use-list-params'
import { shopsParams } from '../search-params'
import type { Region } from '@/features/agents/api'
import type { ShopsCopy } from '../copy'

/** "Search & Filters Toolbar" of 3:407 (31:3654). */
export function ShopsToolbar ({ copy, regions }: { copy: ShopsCopy, regions: Region[] }) {
  const { values, set } = useListParams(shopsParams)
  return (
    <Card className='relative z-20 flex items-center justify-between gap-4 p-4'>
      <SearchAutocomplete
        key={values.q ?? ''}
        placeholder={copy.search} defaultValue={values.q ?? ''}
        load={async (q) => [{ label: copy.title, hits: (await search(q, ['shops'])).shops ?? [] }]}
        onSubmit={(q) => set({ q: q.trim() || null })}
      />
      <div className='flex items-center gap-3'>
        <FilterSelect
          label={copy.status}
          value={values.status ?? ''}
          options={[{ value: '', label: copy.allStatus }, ...(['ACTIVE', 'INACTIVE', 'PENDING_REVIEW'] as const).map((s) => ({ value: s, label: copy.statuses[s] }))]}
          onChange={(v) => set({ status: (v || null) as typeof values.status })}
        />
        <FilterSelect
          label={copy.region}
          value={values.regionId ?? ''}
          options={[{ value: '', label: copy.allRegions }, ...regions.map((r) => ({ value: r.id, label: r.name }))]}
          onChange={(v) => set({ regionId: v || null })}
        />
      </div>
    </Card>
  )
}
