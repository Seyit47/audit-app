'use client'

import { useEffect, type ReactNode } from 'react'
import { FigmaIcon } from './FigmaIcon'

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

export function Dialog ({ open, onClose, title, badge, subtitle, footer, children, width = 879, closeLabel, variant = 'edit' }: {
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
}) {
  const v = variants[variant]
  useEffect(() => {
    if (!open) return
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose() }
    document.addEventListener('keydown', esc)
    const overflow = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    return () => { document.removeEventListener('keydown', esc); document.body.style.overflow = overflow }
  }, [open, onClose])

  if (!open) return null
  return (
    <div className='fixed inset-0 z-50 flex items-center justify-center bg-black/20 p-6' onMouseDown={(e) => { if (e.target === e.currentTarget) onClose() }}>
      <div
        role='dialog' aria-modal='true'
        className={`flex max-h-full flex-col overflow-hidden ${v.card}`}
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
          <button type='button' aria-label={closeLabel} onClick={onClose} className='flex size-9 shrink-0 items-center justify-center rounded-lg hover:bg-grey-3'>
            <FigmaIcon name='dialog-close' width={20} height={20} />
          </button>
        </header>
        <div className={`flex min-h-0 flex-1 flex-col overflow-y-auto ${v.body}`}>{children}</div>
        {footer != null && (
          <footer className={`flex shrink-0 items-center gap-3 ${v.footer}`}>{footer}</footer>
        )}
      </div>
    </div>
  )
}
