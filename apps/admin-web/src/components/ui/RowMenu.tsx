'use client'

import Link from 'next/link'
import { Fragment, useEffect, useLayoutEffect, useRef, useState } from 'react'
import { createPortal } from 'react-dom'
import { FigmaIcon } from './FigmaIcon'
import { usePopup } from '@/lib/use-popup'

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
  const [at, setAt] = useState<{ top?: number, bottom?: number, right: number, anchorTop: number } | null>(null)
  const open = at != null
  const ref = useRef<HTMLDivElement>(null)
  const menu = useRef<HTMLDivElement>(null)

  const toggle = () => {
    if (open || ref.current == null) return setAt(null)
    const r = ref.current.getBoundingClientRect()
    setAt({ top: r.bottom + 4, right: window.innerWidth - r.right, anchorTop: r.top })
  }

  // Measured before paint: a menu that would run past the bottom of the window opens upward instead.
  useLayoutEffect(() => {
    if (at?.top == null || menu.current == null) return
    if (at.top + menu.current.offsetHeight > window.innerHeight - 8) {
      setAt({ bottom: window.innerHeight - at.anchorTop + 4, right: at.right, anchorTop: at.anchorTop })
    }
  }, [at])

  usePopup(open, () => setAt(null), [ref, menu])
  // A fixed menu would drift from its row: scrolling or resizing closes it.
  useEffect(() => {
    if (!open) return
    const away = () => setAt(null)
    window.addEventListener('scroll', away, true)
    window.addEventListener('resize', away)
    return () => { window.removeEventListener('scroll', away, true); window.removeEventListener('resize', away) }
  }, [open])

  return (
    <div ref={ref} className='relative inline-flex'>
      <button type='button' aria-label={label} aria-haspopup='menu' aria-expanded={open} onClick={toggle} data-ripple className='rounded-full text-ink'>
        <FigmaIcon name='row-more' width={32} height={32} />
      </button>
      {at != null && createPortal(
        <div ref={menu} role='menu' style={{ top: at.top, bottom: at.bottom, right: at.right }} className={`anim-menu-in fixed z-40 flex ${at.bottom != null ? 'origin-bottom-right' : 'origin-top-right'} w-44 flex-col rounded-xl bg-pure-white py-1.5 shadow-[0px_20px_25px_-5px_rgba(0,0,0,0.1),0px_8px_10px_-6px_rgba(0,0,0,0.1)]`}>
          {items.map((item) => {
            const cls = `relative mx-1.5 flex items-center gap-2 rounded-lg px-2.5 py-2 text-left text-xs font-medium leading-4 ${item.danger === true ? 'text-danger' : 'text-ink'}`
            // Icons differ in width; a fixed centered slot keeps the labels aligned.
            const body = <><span className='flex w-4 shrink-0 justify-center'><FigmaIcon {...item.icon} /></span>{item.label}</>
            const entry = item.href != null
              ? <Link role='menuitem' data-ripple href={item.href} prefetch className={cls} onClick={() => setAt(null)}>{body}</Link>
              : <button role='menuitem' data-ripple type='button' className={cls} onClick={() => { setAt(null); item.onSelect?.() }}>{body}</button>
            // "Delete Shop" (3:1973) sits under a divider.
            return <Fragment key={item.label}>{item.separated === true && <hr role='separator' className='my-1 border-secondary-bg' />}{entry}</Fragment>
          })}
        </div>,
        document.body
      )}
    </div>
  )
}
