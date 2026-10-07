'use client'

import Link from 'next/link'
import { useEffect, useRef, useState } from 'react'
import { createPortal } from 'react-dom'
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
  // Fixed position of the open menu; it is portaled so table clipping and row layers can't hide it.
  const [at, setAt] = useState<{ top?: number, bottom?: number, right: number } | null>(null)
  const open = at != null
  const ref = useRef<HTMLDivElement>(null)
  const menu = useRef<HTMLDivElement>(null)

  const toggle = () => {
    if (open || ref.current == null) return setAt(null)
    const r = ref.current.getBoundingClientRect()
    const height = items.length * 32 + 24
    const right = window.innerWidth - r.right
    // Opens upward when the row is too close to the bottom of the window.
    setAt(window.innerHeight - r.bottom < height + 8 ? { bottom: window.innerHeight - r.top + 4, right } : { top: r.bottom + 4, right })
  }

  useEffect(() => {
    if (!open) return
    const close = (e: MouseEvent) => { if (!ref.current?.contains(e.target as Node) && !menu.current?.contains(e.target as Node)) setAt(null) }
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') setAt(null) }
    const away = () => setAt(null)
    document.addEventListener('mousedown', close)
    document.addEventListener('keydown', esc)
    window.addEventListener('scroll', away, true)
    window.addEventListener('resize', away)
    return () => {
      document.removeEventListener('mousedown', close); document.removeEventListener('keydown', esc)
      window.removeEventListener('scroll', away, true); window.removeEventListener('resize', away)
    }
  }, [open])

  return (
    <div ref={ref} className='relative inline-flex'>
      <button type='button' aria-label={label} aria-haspopup='menu' aria-expanded={open} onClick={toggle} data-ripple className='rounded-full text-ink'>
        <FigmaIcon name='row-more' width={32} height={32} />
      </button>
      {at != null && createPortal(
        <div ref={menu} role='menu' style={at} className={`anim-menu-in fixed z-40 flex ${at.bottom != null ? 'origin-bottom-right' : 'origin-top-right'} w-44 flex-col rounded-xl bg-pure-white py-1.5 shadow-[0px_20px_25px_-5px_rgba(0,0,0,0.1),0px_8px_10px_-6px_rgba(0,0,0,0.1)]`}>
          {items.map((item) => {
            const cls = `relative flex w-full items-center gap-2 px-3 text-left text-xs font-medium leading-4 hover:bg-secondary-bg ${item.danger === true ? 'text-danger' : 'text-ink'} ${item.separated === true ? 'mt-1 border-t border-secondary-bg pb-2 pt-3' : 'py-2'}`
            const body = <><FigmaIcon {...item.icon} />{item.label}</>
            return item.href != null
              ? <Link key={item.label} role='menuitem' data-ripple href={item.href} className={cls} onClick={() => setAt(null)}>{body}</Link>
              : <button key={item.label} role='menuitem' data-ripple type='button' className={cls} onClick={() => { setAt(null); item.onSelect?.() }}>{body}</button>
          })}
        </div>,
        document.body
      )}
    </div>
  )
}
