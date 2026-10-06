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

  // Up to 5 page buttons around the current page.
  const start = Math.max(1, Math.min(page - 2, pages - 4))
  const shown = Array.from({ length: Math.min(5, pages) }, (_, i) => start + i)

  return (
    <div className='flex items-center justify-between bg-pure-white p-3.5'>
      <div className='flex items-center gap-4 text-xs leading-4 text-muted'>
        <p>{copy.showing} <span className='text-ink'>{from}-{to}</span> {copy.of} <span className='text-ink'>{total}</span> {noun}</p>
        <label className='flex items-center gap-1.5'>
          {copy.show}
          <select
            value={size} onChange={(e) => onSize(Number(e.target.value))}
            className='h-7 cursor-pointer appearance-none rounded bg-dark-accent pl-3 pr-6 text-xs font-medium leading-[15px] text-ink focus:outline-none'
          >
            {sizes.map((s) => <option key={s} value={s}>{s} {copy.perPage}</option>)}
          </select>
        </label>
      </div>
      <nav className='flex items-center gap-1' aria-label='Pagination'>
        <button type='button' aria-label={copy.previous} disabled={page <= 1} onClick={() => onPage(page - 1)} className='flex size-7 items-center justify-center rounded disabled:opacity-40'>
          <FigmaIcon name='page-prev' width={4.933} height={8} />
        </button>
        {shown.map((p) => (
          <button
            key={p} type='button' aria-current={p === page ? 'page' : undefined} onClick={() => onPage(p)}
            className={`flex size-7 items-center justify-center rounded text-xs leading-4 ${p === page ? 'bg-accent font-semibold text-white drop-shadow-[0px_1px_1px_rgba(0,0,0,0.05)]' : 'font-medium text-ink'}`}
          >
            {p}
          </button>
        ))}
        <button type='button' aria-label={copy.next} disabled={page >= pages} onClick={() => onPage(page + 1)} className='flex size-7 items-center justify-center rounded disabled:opacity-40'>
          <FigmaIcon name='page-next' width={4.933} height={8} />
        </button>
      </nav>
    </div>
  )
}
