'use client'

import { useRef, useState } from 'react'
import { Checkbox } from './Checkbox'
import { FigmaIcon } from './FigmaIcon'
import { usePopup } from '@/lib/use-popup'
import { FloatingScrollbar } from '@/components/ui/FloatingScrollbar'

export interface MultiOption { value: string, label: string, hint?: string }

/** Multi-select in the style of the 162:20071 select (approved gap A11): a list of checkboxes with search. */
export function MultiSelect ({ id, options, value, onChange, placeholder, searchPlaceholder, summary }: {
  id?: string
  options: MultiOption[]
  value: string[]
  onChange: (value: string[]) => void
  placeholder: string
  searchPlaceholder: string
  summary: (n: number) => string
}) {
  const [open, setOpen] = useState(false)
  const [q, setQ] = useState('')
  const ref = useRef<HTMLDivElement>(null)
  const list = useRef<HTMLUListElement>(null)
  usePopup(open, () => setOpen(false), [ref])
  const chosen = new Set(value)
  const shown = options.filter((o) => `${o.label} ${o.hint ?? ''}`.toLowerCase().includes(q.toLowerCase()))
  const names = options.filter((o) => chosen.has(o.value)).map((o) => o.label)

  return (
    <div ref={ref} className='relative'>
      <button
        id={id} type='button' aria-haspopup='listbox' aria-expanded={open} onClick={() => setOpen(!open)}
        className='flex h-[42px] w-full items-center rounded-lg border border-border bg-pure-white pl-3.5 pr-10 text-left text-sm leading-5 text-black hover:border-slate-400 focus:outline-none focus-visible:border-accent focus-visible:ring-2 focus-visible:ring-accent/20 aria-expanded:border-accent aria-expanded:ring-2 aria-expanded:ring-accent/20 disabled:cursor-not-allowed disabled:bg-slate-50'
      >
        <span className={`truncate ${names.length === 0 ? 'text-off-white' : ''}`}>{names.length === 0 ? placeholder : names.length <= 2 ? names.join(', ') : summary(names.length)}</span>
        <FigmaIcon name='select-chevron' width={16} height={16} className='pointer-events-none absolute right-3 top-1/2 -translate-y-1/2' />
      </button>
      {open && (
        <div className='anim-menu-in origin-top absolute inset-x-0 top-full mt-1 z-40 flex max-h-64 flex-col rounded-lg border border-border bg-pure-white shadow-[0px_20px_25px_-5px_rgba(0,0,0,0.1),0px_8px_10px_-6px_rgba(0,0,0,0.1)]'>
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder={searchPlaceholder} aria-label={searchPlaceholder} className='m-2 h-9 rounded-md border border-border px-3 text-xs hover:border-slate-400 focus:border-accent focus:outline-none focus:ring-2 focus:ring-accent/20' />
          <ul ref={list} role='listbox' aria-multiselectable className='scrollbar-none overflow-y-auto pb-1'>
            <FloatingScrollbar target={list} />
            {shown.map((o) => (
              <li key={o.value} role='option' aria-selected={chosen.has(o.value)}>
                <label className='flex cursor-pointer items-center gap-3 px-3 py-2 text-xs leading-4 text-ink hover:bg-secondary-bg'>
                  <Checkbox checked={chosen.has(o.value)} onChange={() => onChange(chosen.has(o.value) ? value.filter((v) => v !== o.value) : [...value, o.value])} />
                  <span className='min-w-0 flex-1 truncate'>{o.label}</span>
                  {o.hint != null && <span className='font-display text-muted'>{o.hint}</span>}
                </label>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}
