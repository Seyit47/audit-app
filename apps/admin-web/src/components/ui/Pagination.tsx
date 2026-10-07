'use client'

import { FigmaIcon } from './FigmaIcon'

/** Table footer of 30:574 (31:3323): "Showing a-b of n noun", page size, page buttons. */
export function Pagination ({ page, size, total, noun, sizes = [10, 25, 50], onPage, onSize, copy }: {
  page: number
  size: number
  total: number
  noun: string
  sizes?: number[]
  onPage: (page: number) => void
  onSize: (size: number) => void
  copy: { showing: string, of: string, show: string, perPage: string, previous: string, next: string }
}) {
  const pages = Math.max(1, Math.ceil(total / size))
  const from = total === 0 ? 0 : (page - 1) * size + 1
  const to = Math.min(page * size, total)

  // Up to 3 pages around the current one, then "…" and the last page (3:407 footer).
  const start = Math.max(1, Math.min(page - 1, pages - 2))
  const shown: Array<number | null> = Array.from({ length: Math.min(3, pages) }, (_, i) => start + i)
  if (shown.at(-1)! < pages - 1) shown.push(null)
  if (shown.at(-1) !== pages && !shown.includes(pages)) shown.push(pages)

  return (
    <div className='flex items-center justify-between bg-pure-white p-3.5'>
      <div className='flex items-center gap-4 text-xs leading-4 text-muted'>
        <p>{copy.showing} <span className='text-ink'>{from}-{to}</span> {copy.of} <span className='text-ink'>{total}</span> {noun}</p>
        <label className='flex items-center gap-1.5'>
          {copy.show}
          <select
            value={size} onChange={(e) => onSize(Number(e.target.value))}
            className='h-7 cursor-pointer appearance-none rounded bg-dark-accent pl-3 pr-6 text-xs font-medium leading-[15px] text-ink hover:bg-line focus:outline-none focus-visible:ring-2 focus-visible:ring-accent/30'
          >
            {sizes.map((s) => <option key={s} value={s}>{s} {copy.perPage}</option>)}
          </select>
        </label>
      </div>
      <nav className='flex items-center gap-1' aria-label='Pagination'>
        <button data-ripple type='button' aria-label={copy.previous} disabled={page <= 1} onClick={() => onPage(page - 1)} className='flex size-7 items-center justify-center rounded disabled:opacity-40'>
          <FigmaIcon name='page-prev' width={4.933} height={8} />
        </button>
        {shown.map((p, i) => p == null
          ? <span key={`gap-${i}`} className='px-1 text-xs leading-4 text-[#c7c4d8]'>…</span>
          : (
            <button
              data-ripple={p !== page || undefined}
              key={p} type='button' aria-current={p === page ? 'page' : undefined} onClick={() => { if (p !== page) onPage(p) }}
              className={`flex h-7 min-w-7 items-center justify-center rounded-lg px-1 text-xs leading-4 ${p === page ? 'cursor-default bg-accent font-semibold text-white drop-shadow-[0px_1px_1px_rgba(0,0,0,0.05)]' : 'font-medium text-muted'}`}
            >
              {p}
            </button>
            ))}
        <button data-ripple type='button' aria-label={copy.next} disabled={page >= pages} onClick={() => onPage(page + 1)} className='flex size-7 items-center justify-center rounded disabled:opacity-40'>
          <FigmaIcon name='page-next' width={4.933} height={8} />
        </button>
      </nav>
    </div>
  )
}
