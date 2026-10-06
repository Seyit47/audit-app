'use client'

import { Card } from '@/components/ui/Card'
import { DateField } from '@/components/ui/DateField'
import { AppliedFilters, FilterChip } from '@/components/ui/FilterChip'
import { FilterSelect } from '@/components/ui/FilterSelect'
import { SegmentedControl } from '@/components/ui/SegmentedControl'
import { isoDay } from '@/lib/format'
import { useUrlState } from '@/lib/url-state'
import type { Region } from '../api'
import type { AgentsCopy } from '../copy'

type Preset = 'today' | 'yesterday' | 'week'

function presetRange (p: Preset): { from: string, to: string } {
  const now = new Date()
  if (p === 'yesterday') {
    const y = new Date(now); y.setDate(now.getDate() - 1)
    return { from: isoDay(y), to: isoDay(y) }
  }
  if (p === 'week') {
    const monday = new Date(now); monday.setDate(now.getDate() - ((now.getDay() + 6) % 7))
    return { from: isoDay(monday), to: isoDay(now) }
  }
  return { from: isoDay(now), to: isoDay(now) }
}

/** "Search & Filters Toolbar" of 31:2307 (31:2430): dates, presets, status, region, applied chips. */
export function AgentsToolbar ({ copy, regions }: { copy: AgentsCopy, regions: Region[] }) {
  const { params, set } = useUrlState()
  const today = presetRange('today')
  const from = params.get('from') ?? today.from
  const to = params.get('to') ?? params.get('from') ?? today.to
  const preset = (['today', 'yesterday', 'week'] as const).find((p) => { const r = presetRange(p); return r.from === from && r.to === to }) ?? null
  const status = params.get('status') ?? ''
  const regionId = params.get('regionId') ?? ''
  const regionName = regions.find((r) => r.id === regionId)?.name

  return (
    <Card className='flex flex-col gap-3 p-4'>
      <div className='flex flex-wrap items-center gap-3'>
        <DateField label={copy.dateFrom} value={from} max={to} onChange={(v) => set({ from: v, to })} />
        <DateField label={copy.dateTo} value={to} min={from} onChange={(v) => set({ from, to: v })} />
        <SegmentedControl
          options={[{ value: 'today', label: copy.presets.today }, { value: 'yesterday', label: copy.presets.yesterday }, { value: 'week', label: copy.presets.week }]}
          value={preset}
          onChange={(p) => set(presetRange(p))}
        />
        <FilterSelect
          label={copy.status}
          value={status}
          options={[{ value: '', label: copy.allStatus }, ...(['ACTIVE', 'ON_LEAVE', 'INACTIVE'] as const).map((s) => ({ value: s, label: copy.statuses[s] }))]}
          onChange={(v) => set({ status: v })}
        />
        <FilterSelect
          label={copy.region}
          value={regionId}
          options={[{ value: '', label: copy.allRegions }, ...regions.map((r) => ({ value: r.id, label: r.name }))]}
          onChange={(v) => set({ regionId: v })}
        />
      </div>
      {(status !== '' || regionName != null) && (
        <AppliedFilters label={copy.applied}>
          {regionName != null && <FilterChip label={`${copy.region}: ${regionName}`} removeLabel={copy.remove} onRemove={() => set({ regionId: null })} />}
          {status !== '' && <FilterChip label={`${copy.status}: ${copy.statuses[status as keyof AgentsCopy['statuses']]}`} removeLabel={copy.remove} onRemove={() => set({ status: null })} />}
        </AppliedFilters>
      )}
    </Card>
  )
}
