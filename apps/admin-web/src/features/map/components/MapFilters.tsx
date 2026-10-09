'use client'

import { useRef, useState } from 'react'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { sub } from '@/lib/i18n'
import type { MapCopy } from '../copy'
import type { MapFilterState, MapShow, MapVisitStatus } from '../types'
import { FloatingScrollbar } from '@/components/ui/FloatingScrollbar'

const shadowXl = 'shadow-[0px_8px_10px_-6px_rgba(0,0,0,0.1),0px_20px_25px_-5px_rgba(0,0,0,0.1)]'

function Check ({ on }: { on: boolean }) {
  return on
    ? <FigmaIcon name='map-checkbox-on' width={13} height={13} />
    : <span className='size-[13px] shrink-0 rounded-[2.5px] border border-[#767676] bg-white' />
}

/** A collapsible single-choice list (788:2352 Users/Shops, 791:2406 Status), styled like the region list. */
function ChoiceSection<T extends string> ({ title, options, value, onChange }: {
  title: string
  options: Array<{ value: T, label: string }>
  value: T
  onChange: (v: T) => void
}) {
  const [open, setOpen] = useState(true)
  return (
    <div className='flex flex-col gap-1.5'>
      <button data-ripple data-disclosure type='button' onClick={() => setOpen((o) => !o)} aria-expanded={open} className='flex h-6 items-center justify-between'>
        <span className='text-xs font-semibold leading-4 text-ink'>{title}</span>
        <span className={`flex size-6 items-center justify-center transition-transform ${open ? '' : '-rotate-90'}`}><FigmaIcon name='map-chevron' width={7} height={3.5} /></span>
      </button>
      {open && (
        <div role='radiogroup' aria-label={title} className='flex flex-col gap-1 rounded-xl bg-secondary-bg p-1.5'>
          {options.map((o) => {
            const on = o.value === value
            return (
              <button data-ripple key={o.value} type='button' role='radio' aria-checked={on} onClick={() => onChange(o.value)} className={`flex ${on ? 'bg-accent/5' : ''} items-center justify-between rounded-lg px-2.5 py-1.5`}>
                <span className={`text-left text-xs leading-4 ${on ? 'font-semibold text-accent' : 'text-muted'}`}>{o.label}</span>
                <Check on={on} />
              </button>
            )
          })}
        </div>
      )}
    </div>
  )
}

/**
 * "Floating / collapsible filter panel" of 3:2 (3:257, 574:3450): what to show (agents / shops), visit status,
 * salesmen and region zones, Apply / Clear.
 */
export function MapFilters ({ agents, regions, value, copy, onApply, onClose }: {
  agents: Array<{ id: string, fullName: string }>
  regions: Array<{ id: string, name: string }>
  value: MapFilterState
  copy: MapCopy
  onApply: (next: MapFilterState) => void
  onClose: () => void
}) {
  const p = copy.panel
  const [agentIds, setAgentIds] = useState(value.agentIds)
  const [regionIds, setRegionIds] = useState(value.regionIds)
  const [show, setShow] = useState<MapShow>(value.show)
  const [status, setStatus] = useState<MapVisitStatus>(value.status)
  const count = agentIds.length + regionIds.length + (show !== 'both' ? 1 : 0) + (status !== 'all' ? 1 : 0)
  const [q, setQ] = useState('')
  const [regionsOpen, setRegionsOpen] = useState(true)
  const body = useRef<HTMLDivElement>(null)
  const matches = q.trim() === ''
    ? []
    : agents.filter((a) => !agentIds.includes(a.id) && a.fullName.toLowerCase().includes(q.trim().toLowerCase())).slice(0, 6)
  const toggleRegion = (id: string) => setRegionIds((ids) => ids.includes(id) ? ids.filter((x) => x !== id) : [...ids, id])

  return (
    <aside className={`anim-menu-in origin-top-right absolute right-[13px] top-[68px] z-20 flex max-h-[calc(100%-84px)] w-80 flex-col overflow-hidden rounded-2xl bg-pure-white ${shadowXl}`}>
      <div className='flex items-center justify-between px-4 py-3.5'>
        <span className='flex items-center gap-2'>
          <FigmaIcon name='map-filters' width={13.5} height={13.5} />
          <span className='text-sm font-bold leading-5 text-ink'>{copy.filters}</span>
          {count > 0 && (
            <span className='flex size-4 items-center justify-center rounded-full bg-accent text-[10px] font-bold leading-4 text-white'>{count}</span>
          )}
        </span>
        <button data-ripple type='button' onClick={onClose} aria-label={p.close} className='flex size-7 items-center justify-center rounded-full'><FigmaIcon name='map-panel-close' width={10} height={10} /></button>
      </div>

      <div ref={body} className='scrollbar-none flex min-h-0 flex-col gap-4 overflow-y-auto px-4 py-3'>
        <FloatingScrollbar target={body} />
        <ChoiceSection<MapShow>
          title={p.show} value={show} onChange={setShow}
          options={[{ value: 'both', label: p.showBoth }, { value: 'agents', label: p.showAgents }, { value: 'shops', label: p.showShops }]}
        />
        <ChoiceSection<MapVisitStatus>
          title={p.status} value={status} onChange={setStatus}
          options={[{ value: 'all', label: p.statusAll }, { value: 'visited', label: p.visited }, { value: 'not_visited', label: p.notVisited }, { value: 'recent', label: p.recent }]}
        />
        <div className='flex flex-col gap-1.5'>
          <div className='flex items-center justify-between'>
            <span className='text-xs font-semibold leading-4 text-ink'>{p.salesman}</span>
            <span className='text-[10px] leading-[15px] text-subtle'>{p.searchable}</span>
          </div>
          <div className='relative'>
            <FigmaIcon name='map-search-small' width={10.5} height={10.5} className='absolute left-[9.75px] top-[9.75px]' />
            <input
              value={q} onChange={(e) => setQ(e.target.value)} placeholder={p.searchAgents} aria-label={p.searchAgents}
              className='h-8 w-full rounded-lg bg-secondary-bg pl-7 pr-3 text-xs leading-[14.5px] text-ink placeholder:text-muted focus:outline-none'
            />
            {matches.length > 0 && (
              <ul className={`absolute inset-x-0 top-full mt-1 z-10 flex flex-col rounded-lg bg-pure-white p-1 ${shadowXl}`}>
                {matches.map((a) => (
                  <li key={a.id}>
                    <button data-ripple type='button' onClick={() => { setAgentIds((ids) => [...ids, a.id]); setQ('') }} className='w-full rounded-md px-2.5 py-1.5 text-left text-xs leading-4 text-muted'>{a.fullName}</button>
                  </li>
                ))}
              </ul>
            )}
          </div>
          {agentIds.length > 0 && (
            <div className='flex flex-wrap gap-2'>
              {agentIds.map((id) => (
                <span key={id} className='flex items-center gap-1.5 rounded-md bg-secondary-bg px-2.5 py-1 text-[11px] font-medium leading-[16.5px] text-muted'>
                  {agents.find((a) => a.id === id)?.fullName ?? id}
                  <button data-ripple type='button' aria-label={p.remove} className='rounded-full p-1' onClick={() => setAgentIds((ids) => ids.filter((x) => x !== id))}><FigmaIcon name='map-chip-x' width={7} height={7} /></button>
                </span>
              ))}
            </div>
          )}
        </div>

        <div className='flex flex-col gap-1.5 border-b border-secondary-bg pb-3'>
          <button data-ripple data-disclosure type='button' onClick={() => setRegionsOpen((o) => !o)} aria-expanded={regionsOpen} className='flex h-6 items-center justify-between'>
            <span className='text-xs font-semibold leading-4 text-ink'>{p.region}</span>
            <span className={`flex size-6 items-center justify-center transition-transform ${regionsOpen ? '' : '-rotate-90'}`}><FigmaIcon name='map-chevron' width={7} height={3.5} /></span>
          </button>
          {regionsOpen && (
            <div className='flex flex-col gap-1 rounded-xl bg-secondary-bg p-1.5'>
              <button data-ripple type='button' onClick={() => setRegionIds([])} className='flex items-center justify-between rounded-lg px-2.5 py-1.5'>
                <span className={`text-xs leading-4 ${regionIds.length === 0 ? 'font-semibold text-accent' : 'text-muted'}`}>{sub(p.allRegions, regions.length)}</span>
                <Check on={regionIds.length === 0} />
              </button>
              {regions.map((r) => {
                const on = regionIds.includes(r.id)
                return (
                  <button data-ripple key={r.id} type='button' onClick={() => toggleRegion(r.id)} aria-pressed={on} className={`flex ${on ? 'bg-accent/5' : ''} items-center justify-between rounded-lg px-2.5 py-1.5`}>
                    <span className={`text-left text-xs leading-4 ${on ? 'font-semibold text-accent' : 'text-muted'}`}>{r.name}</span>
                    <Check on={on} />
                  </button>
                )
              })}
            </div>
          )}
        </div>
      </div>

      <div className='flex items-center gap-2 p-3'>
        <button data-ripple
          type='button' onClick={() => onApply({ agentIds, regionIds, show, status })}
          className='flex h-9 flex-1 items-center justify-center gap-1.5 rounded-lg bg-accent text-xs font-semibold leading-4 text-white shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'
        >
          <FigmaIcon name='map-apply-check' width={10.87} height={8.02} />{p.apply}
        </button>
        <button data-ripple type='button' onClick={() => { setAgentIds([]); setRegionIds([]); setShow('both'); setStatus('all'); onApply({ agentIds: [], regionIds: [], show: 'both', status: 'all' }) }} className='h-9 rounded-lg bg-secondary-bg px-3 text-xs font-semibold leading-4 text-ink'>{p.clear}</button>
      </div>
    </aside>
  )
}
