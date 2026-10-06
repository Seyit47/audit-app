'use client'

import Link from 'next/link'
import { useEffect, useRef, useState } from 'react'
import { FigmaIcon } from './FigmaIcon'

export interface RowMenuItem {
  label: string
  icon: { name: string, width: number, height: number }
  href?: string
  onSelect?: () => void
  danger?: boolean
  /** Draws the divider above the item ("Delete Shop", 3:1973). */
  separated?: boolean
}

/** Row "more" button and action dropdown of 3:407 (3:1959). */
export function RowMenu ({ items, label = 'Actions' }: { items: RowMenuItem[], label?: string }) {
  const [open, setOpen] = useState(false)
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!open) return
    const close = (e: MouseEvent) => { if (!ref.current?.contains(e.target as Node)) setOpen(false) }
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') setOpen(false) }
    document.addEventListener('mousedown', close)
    document.addEventListener('keydown', esc)
    return () => { document.removeEventListener('mousedown', close); document.removeEventListener('keydown', esc) }
  }, [open])

  return (
    <div ref={ref} className='relative inline-flex'>
      <button type='button' aria-label={label} aria-haspopup='menu' aria-expanded={open} onClick={() => setOpen(!open)} className='rounded-full'>
        <FigmaIcon name='row-more' width={32} height={32} />
      </button>
      {open && (
        <div role='menu' className='absolute right-0 top-9 z-30 flex w-44 flex-col rounded-xl bg-pure-white py-1.5 shadow-[0px_20px_25px_-5px_rgba(0,0,0,0.1),0px_8px_10px_-6px_rgba(0,0,0,0.1)]'>
          {items.map((item) => {
            const cls = `flex w-full items-center gap-2 px-3 text-left text-xs font-medium leading-4 hover:bg-secondary-bg ${item.danger === true ? 'text-danger' : 'text-ink'} ${item.separated === true ? 'mt-1 border-t border-secondary-bg pb-2 pt-3' : 'py-2'}`
            const body = <><FigmaIcon {...item.icon} />{item.label}</>
            return item.href != null
              ? <Link key={item.label} role='menuitem' href={item.href} className={cls} onClick={() => setOpen(false)}>{body}</Link>
              : <button key={item.label} role='menuitem' type='button' className={cls} onClick={() => { setOpen(false); item.onSelect?.() }}>{body}</button>
          })}
        </div>
      )}
    </div>
  )
}
