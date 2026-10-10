'use client'

import { Card } from '@/components/ui/Card'
import { DateField } from '@/components/ui/DateField'
import { AppliedFilters, FilterChip } from '@/components/ui/FilterChip'
import { FilterSelect } from '@/components/ui/FilterSelect'
import { SegmentedControl } from '@/components/ui/SegmentedControl'
import { isoDay } from '@/lib/format'
import { useListParams } from '@/lib/use-list-params'
import { agentsParams, periodParams } from '../search-params'
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

/** Дата от / Дата до and the Сегодня / Вчера / Текущая неделя presets (31:2430, 122:8163), in the URL. */
export function PeriodFilter ({ copy }: { copy: AgentsCopy }) {
  const { values, set } = useListParams(periodParams)
  const today = presetRange('today')
  const from = values.from ?? today.from
  const to = values.to ?? values.from ?? today.to
  const preset = (['today', 'yesterday', 'week'] as const).find((p) => { const r = presetRange(p); return r.from === from && r.to === to }) ?? null
  return (
    <>
      <DateField label={copy.dateFrom} value={from} max={to} onChange={(v) => set({ from: v, to })} />
      <DateField label={copy.dateTo} value={to} min={from} onChange={(v) => set({ from, to: v })} />
      <SegmentedControl
        options={[{ value: 'today', label: copy.presets.today }, { value: 'yesterday', label: copy.presets.yesterday }, { value: 'week', label: copy.presets.week }]}
        value={preset}
        onChange={(p) => set(presetRange(p))}
      />
    </>
  )
}

/** "Search & Filters Toolbar" of 31:2307 (31:2430): dates, presets, status, region, applied chips. */
export function AgentsToolbar ({ copy, regions }: { copy: AgentsCopy, regions: Region[] }) {
  const { values, set } = useListParams(agentsParams)
  const status = values.status ?? ''
  const regionId = values.regionId ?? ''
  const regionName = regions.find((r) => r.id === regionId)?.name

  return (
    <Card className='flex flex-col gap-3 p-4'>
      <div className='flex flex-wrap items-center gap-3'>
        <PeriodFilter copy={copy} />
        <FilterSelect
          label={copy.status}
          value={status}
          options={[{ value: '', label: copy.allStatus }, ...(['ACTIVE', 'ON_LEAVE', 'INACTIVE'] as const).map((s) => ({ value: s, label: copy.statuses[s] }))]}
          onChange={(v) => set({ status: (v || null) as typeof values.status })}
        />
        <FilterSelect
          label={copy.region}
          value={regionId}
          options={[{ value: '', label: copy.allRegions }, ...regions.map((r) => ({ value: r.id, label: r.name }))]}
          onChange={(v) => set({ regionId: v || null })}
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
