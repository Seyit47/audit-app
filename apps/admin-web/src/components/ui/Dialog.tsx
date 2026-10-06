'use client'

import { useEffect, type ReactNode } from 'react'
import { FigmaIcon } from './FigmaIcon'

/**
 * Centered dialog of 162:20071 (162:20592): header with title, code badge and subtitle,
 * scrollable body, pinned action bar. Closes on Escape and on the backdrop.
 */
export function Dialog ({ open, onClose, title, badge, subtitle, footer, children, width = 879, closeLabel }: {
  open: boolean
  onClose: () => void
  title: ReactNode
  badge?: ReactNode
  subtitle?: ReactNode
  footer?: ReactNode
  children: ReactNode
  width?: number
  closeLabel: string
}) {
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
        className='flex max-h-full flex-col gap-4 overflow-hidden rounded-2xl bg-pure-white px-px shadow-[0px_25px_50px_-12px_rgba(15,23,42,0.35)]'
        style={{ width }}
      >
        <header className='flex shrink-0 items-center justify-between gap-6 border-b border-border px-6 py-5'>
          <div className='flex min-w-0 flex-col gap-0.5'>
            <div className='flex items-center gap-2.5'>
              <h2 className='text-lg font-bold leading-6 text-black'>{title}</h2>
              {badge != null && <span className='rounded bg-accent-6 px-2 py-0.5 text-xs font-semibold leading-4 text-accent'>{badge}</span>}
            </div>
            {subtitle != null && <p className='text-xs leading-4 text-default-black'>{subtitle}</p>}
          </div>
          <button type='button' aria-label={closeLabel} onClick={onClose} className='flex size-9 shrink-0 items-center justify-center rounded-lg hover:bg-grey-3'>
            <FigmaIcon name='dialog-close' width={20} height={20} />
          </button>
        </header>
        <div className='flex min-h-0 flex-1 flex-col gap-6 overflow-y-auto p-6'>{children}</div>
        {footer != null && (
          <footer className='flex shrink-0 items-center justify-between gap-6 border-t border-border px-6 py-4'>{footer}</footer>
        )}
      </div>
    </div>
  )
}
