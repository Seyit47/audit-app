'use client'

import { Card } from '@/components/ui/Card'
import { useListParams } from '@/lib/use-list-params'
import { shopsParams } from '@/features/shops/search-params'
import type { District } from '../api'
import type { DistrictsCopy } from '../copy'

/** The shops list starts with districts: all, each with its shop count, then the shops without one. */
export function DistrictsPanel ({ districts, copy }: { districts: District[], copy: DistrictsCopy }) {
  const { values, set } = useListParams(shopsParams)
  const total = districts.reduce((n, d) => n + d.shops, 0)
  const rows: Array<{ key: string | null, label: string, shops: number }> = [
    { key: null, label: copy.all, shops: total },
    ...districts.map((d) => ({ key: d.id ?? 'none', label: d.name ?? copy.none, shops: d.shops }))
  ]
  return (
    <Card className='flex w-60 shrink-0 flex-col gap-1 self-start p-3'>
      <h2 className='px-2 pb-1 text-xs font-semibold uppercase leading-4 tracking-[0.6px] text-muted'>{copy.title}</h2>
      {rows.map((r) => {
        const on = (values.districtId ?? null) === r.key
        return (
          <button
            key={r.key ?? 'all'}
            type='button'
            aria-pressed={on}
            onClick={() => set({ districtId: r.key, page: null })}
            className={`flex items-center justify-between gap-2 rounded-lg px-2 py-1.5 text-left text-sm leading-5 ${on ? 'bg-dark-accent font-semibold text-accent' : 'text-ink hover:bg-dark-accent'}`}
          >
            <span className='truncate'>{r.label}</span>
            <span className='shrink-0 text-xs text-muted'>{r.shops}</span>
          </button>
        )
      })}
    </Card>
  )
}
