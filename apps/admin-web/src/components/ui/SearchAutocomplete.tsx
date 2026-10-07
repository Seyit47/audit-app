'use client'

import { useRouter } from 'next/navigation'
import { useEffect, useId, useRef, useState } from 'react'
import { navigationStarted } from '@/lib/feedback'
import type { SearchHit } from '@/lib/search-actions'
import { Avatar } from './Avatar'
import { Icon } from './Icon'
import { usePopup } from '@/lib/use-popup'

export interface SearchGroup { label: string, hits: SearchHit[] }

const text = {
  en: { empty: 'Nothing found', all: 'Show all results for', searching: 'Searching…' },
  ru: { empty: 'Ничего не найдено', all: 'Показать все результаты для', searching: 'Поиск…' }
}

function Highlight ({ value, term }: { value: string, term: string }) {
  const i = value.toLowerCase().indexOf(term.toLowerCase())
  if (term === '' || i < 0) return <>{value}</>
  return <>{value.slice(0, i)}<mark className='rounded-sm bg-accent/15 text-inherit'>{value.slice(i, i + term.length)}</mark>{value.slice(i + term.length)}</>
}

/**
 * Search input of 30:574 / 3:853 with a debounced results popup below it. `load` returns grouped hits;
 * ↑/↓ move, Enter opens the highlighted hit (or submits the term), Esc closes.
 */
export function SearchAutocomplete ({ placeholder, defaultValue = '', load, onSubmit, onPick, onQueryChange, className = 'w-[350px]', inputClassName, icon, delay = 250 }: {
  placeholder: string
  defaultValue?: string
  load: (q: string) => Promise<SearchGroup[]>
  /** Enter without a highlighted hit, or "show all". Omit to hide "show all". */
  onSubmit?: (q: string) => void
  /** Overrides navigating to the hit's href. */
  onPick?: (hit: SearchHit) => void
  /** Every keystroke, for callers that also filter in place (the map). */
  onQueryChange?: (q: string) => void
  className?: string
  inputClassName?: string
  icon?: React.ReactNode
  delay?: number
}) {
  const router = useRouter()
  const id = useId()
  const box = useRef<HTMLDivElement>(null)
  const [q, setQ] = useState(defaultValue)
  const [open, setOpen] = useState(false)
  const [state, setState] = useState<{ term: string, groups: SearchGroup[] } | null>(null)
  const [active, setActive] = useState(-1)
  const loader = useRef(load)
  useEffect(() => { loader.current = load })
  const lang = typeof document !== 'undefined' && document.documentElement.lang === 'en' ? 'en' : 'ru'
  const t = text[lang]

  const term = q.trim()
  const loading = term !== '' && state?.term !== term
  const groups = state?.term === term ? state.groups.filter((g) => g.hits.length > 0) : []
  const flat = groups.flatMap((g) => g.hits)

  useEffect(() => {
    if (term === '') return
    let live = true
    const timer = setTimeout(() => {
      loader.current(term).then((gs) => { if (live) { setState({ term, groups: gs }); setActive(-1) } }, () => { if (live) setState({ term, groups: [] }) })
    }, delay)
    return () => { live = false; clearTimeout(timer) }
  }, [term, delay])

  usePopup(open && q.trim() !== '', () => setOpen(false), [box])

  const pick = (hit: SearchHit) => {
    setOpen(false)
    if (onPick != null) return onPick(hit)
    setQ('')
    navigationStarted()
    router.push(hit.href)
  }
  const submit = () => { setOpen(false); onSubmit?.(term) }

  const onKey = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault(); setOpen(true)
      // -1 is the input itself; the highlight wraps through it.
      const last = flat.length - 1
      setActive((i) => e.key === 'ArrowDown' ? (i >= last ? -1 : i + 1) : (i === -1 ? last : i - 1))
    } else if (e.key === 'Enter') {
      e.preventDefault()
      if (active >= 0 && active < flat.length) pick(flat[active]); else submit()
    } else if (e.key === 'Escape') {
      if (open) { e.preventDefault(); setOpen(false) } else { setQ(''); onQueryChange?.('') }
    }
  }

  const show = open && term !== ''
  let n = -1
  return (
    <div ref={box} role='search' className={`relative ${className}`}>
      {icon ?? <Icon name='search' width={15} height={15} className='pointer-events-none absolute left-[14.5px] top-[12.5px] z-[1] text-muted' />}
      <input
        type='search' value={q} placeholder={placeholder} aria-label={placeholder} autoComplete='off'
        role='combobox' aria-expanded={show} aria-controls={id} aria-autocomplete='list'
        aria-activedescendant={active >= 0 && active < flat.length ? `${id}-${active}` : undefined}
        onChange={(e) => { setQ(e.target.value); onQueryChange?.(e.target.value); setOpen(true) }}
        onFocus={() => setOpen(true)}
        onKeyDown={onKey}
        className={inputClassName ?? 'h-10 w-full rounded-lg bg-secondary-bg pl-10 pr-4 text-sm text-ink placeholder:text-muted hover:bg-line focus:bg-pure-white focus:outline-none focus:ring-2 focus:ring-accent/30'}
      />
      {show && (
        <div id={id} role='listbox' className='anim-menu-in origin-top absolute inset-x-0 top-[calc(100%+6px)] z-40 flex max-h-[420px] min-w-80 flex-col overflow-y-auto rounded-xl border border-border bg-pure-white py-1.5 shadow-[0px_20px_25px_-5px_rgba(0,0,0,0.1),0px_8px_10px_-6px_rgba(0,0,0,0.1)]'>
          {loading && groups.length === 0 && (
            <div className='flex flex-col gap-2 px-3 py-2' aria-label={t.searching}>
              {[0, 1, 2].map((i) => (
                <div key={i} className='flex items-center gap-3'>
                  <span className='skeleton size-9 rounded-lg' />
                  <span className='flex flex-1 flex-col gap-1.5'><span className='skeleton h-3 w-2/3 rounded' /><span className='skeleton h-2.5 w-1/2 rounded' /></span>
                </div>
              ))}
            </div>
          )}
          {!loading && groups.length === 0 && <p className='px-4 py-3 text-xs leading-4 text-muted'>{t.empty}</p>}
          {groups.map((g) => (
            <div key={g.label} role='group' aria-label={g.label} className={`flex flex-col ${loading ? 'opacity-60' : ''}`}>
              {groups.length > 1 && <p className='px-4 pb-1 pt-2 text-[10px] font-semibold uppercase leading-4 tracking-[0.5px] text-subtle'>{g.label}</p>}
              {g.hits.map((h) => {
                const i = ++n
                return (
                  <button
                    key={h.id} id={`${id}-${i}`} data-ripple type='button' role='option' aria-selected={i === active}
                    onMouseEnter={() => setActive(i)} onClick={() => pick(h)}
                    className={`mx-1.5 flex items-center gap-3 rounded-lg px-2.5 py-2 text-left`}
                  >
                    <Avatar name={h.title} size='lg' src={h.image} />
                    <span className='flex min-w-0 flex-col'>
                      <span className='truncate text-sm font-medium leading-5 text-ink'><Highlight value={h.title} term={term} /></span>
                      {h.detail != null && <span className='truncate text-xs leading-4 text-muted'><Highlight value={h.detail} term={term} /></span>}
                    </span>
                  </button>
                )
              })}
            </div>
          ))}
          {onSubmit != null && (
            <button data-ripple type='button' onClick={submit} className='mx-1.5 mt-1 flex items-center gap-2 rounded-lg border-t border-line px-2.5 py-2 text-left text-xs font-semibold leading-4 text-accent'>
              <Icon name='search' width={12} height={12} />{t.all} «{term}»
            </button>
          )}
        </div>
      )}
    </div>
  )
}
