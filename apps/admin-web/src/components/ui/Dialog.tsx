'use client'

import { type ReactNode, useCallback, useEffect, useRef, useState, useSyncExternalStore } from 'react'
import { createPortal } from 'react-dom'
import { lockScroll } from '@/lib/scroll-lock'
import { FigmaIcon } from './FigmaIcon'
import { FloatingScrollbar } from '@/components/ui/FloatingScrollbar'

/**
 * Centered dialog of 162:20071 (162:20592): header with title, code badge and subtitle,
 * scrollable body, pinned action bar. Closes on Escape and on the backdrop.
 */
// edit: 162:20071 (shop edit). form: 495:3932 / 495:2311 (Add Salesman / Add Product).
const variants = {
  edit: {
    card: 'rounded-2xl bg-pure-white px-px shadow-[0px_25px_50px_-12px_rgba(15,23,42,0.35)] gap-4',
    header: 'border-b border-border px-6 py-5',
    title: 'text-lg font-bold leading-6 text-black',
    subtitle: 'text-xs leading-4 text-default-black',
    body: 'gap-6 p-6',
    footer: 'justify-between border-t border-border px-6 py-4'
  },
  form: {
    card: 'rounded-2xl bg-pure-white shadow-[0px_25px_50px_-12px_rgba(0,0,0,0.25)]',
    header: 'border-b border-grey-3 bg-pure-white px-6 py-5',
    title: 'text-xl font-bold leading-7 tracking-[-0.5px] text-black',
    subtitle: 'text-sm leading-5 text-slate-500',
    body: 'gap-5 px-6 py-5',
    footer: 'justify-end border-t border-grey-3 bg-slate-50 px-6 py-4'
  }
}

const noop = () => () => {}

export function Dialog ({ open, onClose, title, badge, subtitle, footer, children, width = 879, closeLabel, variant = 'edit', animateIn = true }: {
  open: boolean
  onClose: () => void
  title: ReactNode
  badge?: ReactNode
  subtitle?: ReactNode
  footer?: ReactNode
  children: ReactNode
  width?: number
  closeLabel: string
  variant?: keyof typeof variants
  /** Off when the dialog replaces its own loading state, which already played the entrance. */
  animateIn?: boolean
}) {
  const body = useRef<HTMLDivElement>(null)
  const v = variants[variant]
  // shown → leaving (exit animation, clicks pass through) → gone. A dialog driven by the URL (`?add=1`)
  // stays mounted until the server answers the closing navigation, which can take seconds or fail; it
  // must not keep covering the page meanwhile.
  const [phase, setPhase] = useState<'shown' | 'leaving' | 'gone'>('shown')
  const leaving = phase === 'leaving'
  if (!open && phase !== 'shown') setPhase('shown') // closed: the next open starts fresh
  // false during SSR and hydration, true after: the portal needs document.body.
  const mounted = useSyncExternalStore(noop, () => true, () => false)
  // Plays the exit (Material emphasized accelerate) before the caller unmounts the dialog.
  const close = useCallback(() => {
    if (phase !== 'shown') return
    setPhase('leaving')
    window.setTimeout(() => { setPhase('gone'); onClose() }, matchMedia('(prefers-reduced-motion: reduce)').matches ? 0 : 140)
  }, [phase, onClose])
  const active = open && phase !== 'gone'
  useEffect(() => {
    if (!active) return
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') close() }
    document.addEventListener('keydown', esc)
    const unlock = lockScroll()
    return () => { document.removeEventListener('keydown', esc); unlock() }
  }, [active, close])

  if (!active || !mounted) return null
  // Portaled to <body> so the backdrop always covers the whole viewport, whatever the parents do.
  return createPortal(
    <div
      className={`fixed inset-0 z-50 flex items-center justify-center bg-black/20 p-6 ${leaving ? 'anim-fade-out pointer-events-none' : animateIn ? 'anim-fade-in' : ''}`}
      onMouseDown={(e) => { if (e.target === e.currentTarget) close() }}
    >
      <div
        role='dialog' aria-modal='true'
        className={`flex max-h-full flex-col overflow-hidden ${v.card} ${leaving ? 'anim-dialog-out' : animateIn ? 'anim-dialog-in' : ''}`}
        // Footer "Cancel" buttons marked data-dialog-close also play the exit.
        onClickCapture={(e) => {
          if ((e.target as Element).closest('[data-dialog-close]')) { e.preventDefault(); e.stopPropagation(); close() }
        }}
        style={{ width }}
      >
        <header className={`flex shrink-0 items-center justify-between gap-6 ${v.header}`}>
          <div className='flex min-w-0 flex-col gap-0.5'>
            <div className='flex items-center gap-2.5'>
              <h2 className={v.title}>{title}</h2>
              {badge != null && <span className='rounded bg-accent-6 px-2 py-0.5 text-xs font-semibold leading-4 text-accent'>{badge}</span>}
            </div>
            {subtitle != null && <p className={v.subtitle}>{subtitle}</p>}
          </div>
          <button type='button' aria-label={closeLabel} onClick={close} data-ripple className='flex size-9 shrink-0 items-center justify-center rounded-lg text-ink'>
            <FigmaIcon name='dialog-close' width={20} height={20} />
          </button>
        </header>
        <div ref={body} className={`scrollbar-none flex min-h-0 flex-1 flex-col overflow-y-auto ${v.body}`}>{children}<FloatingScrollbar target={body} /></div>
        {footer != null && (
          <footer className={`flex shrink-0 items-center gap-3 ${v.footer}`}>{footer}</footer>
        )}
      </div>
    </div>,
    document.body
  )
}
