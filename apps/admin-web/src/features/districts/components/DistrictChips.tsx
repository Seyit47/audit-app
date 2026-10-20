'use client'

import { useListParams } from '@/lib/use-list-params'
import { shopsParams } from '@/features/shops/search-params'
import type { District } from '../api'
import type { DistrictsCopy } from '../copy'

/** District chips over the shops table: all, each district with its shop count, then the shops without one. */
export function DistrictChips ({ districts, copy }: { districts: District[], copy: DistrictsCopy }) {
  const { values, set } = useListParams(shopsParams)
  const total = districts.reduce((n, d) => n + d.shops, 0)
  const chips: Array<{ key: string | null, label: string, shops: number }> = [
    { key: null, label: copy.all, shops: total },
    ...districts.map((d) => ({ key: d.id ?? 'none', label: d.name ?? copy.none, shops: d.shops }))
  ]
  return (
    <div role='tablist' aria-label={copy.title} className='flex flex-wrap gap-2'>
      {chips.map((c) => {
        const on = (values.districtId ?? null) === c.key
        return (
          <button
            key={c.key ?? 'all'}
            type='button'
            role='tab'
            aria-selected={on}
            data-ripple
            onClick={() => set({ districtId: c.key, page: null })}
            className={`flex h-8 items-center gap-2 rounded-full border px-3.5 text-sm leading-5 transition-colors ${
              on ? 'border-accent bg-accent font-semibold text-white' : 'border-border bg-pure-white text-ink hover:border-accent hover:text-accent'
            }`}
          >
            {c.label}
            <span className={`rounded-full px-1.5 text-xs font-semibold leading-5 ${on ? 'bg-white/20 text-white' : 'bg-secondary-bg text-muted'}`}>{c.shops}</span>
          </button>
        )
      })}
    </div>
  )
}
