'use client'

import { type CSSProperties, type ReactNode, useRef } from 'react'
import { FigmaIcon } from './FigmaIcon'
import { FloatingScrollbar } from '@/components/ui/FloatingScrollbar'

/**
 * Detail panel beside a grid (Pictures 138:11987, 151:13446): white, 16 px radius and padding,
 * the accent-tinted elevation, a close control in the header row.
 */
export function SidePanel ({ header, onClose, closeLabel, children, className = 'w-[582px]', style, animate = true, scroll = false }: {
  header: ReactNode
  onClose: () => void
  closeLabel: string
  children: ReactNode
  className?: string
  style?: CSSProperties
  /** Off when a parent shell already animated in (content swapped inside it must not slide again). */
  animate?: boolean
  /** The panel scrolls inside itself (max-height set by the caller), with a floating scrollbar. */
  scroll?: boolean
}) {
  const box = useRef<HTMLElement>(null)
  return (
    <aside ref={box} style={style} className={`${animate ? 'anim-panel-right' : ''} ${scroll ? 'scrollbar-none overflow-y-auto' : ''} flex shrink-0 flex-col gap-4 self-start overflow-clip rounded-2xl bg-pure-white p-4 shadow-[0px_1px_2px_rgba(0,0,0,0.05),0px_4px_16px_-2px_rgba(37,99,235,0.2)] ${className}`}>
      <div className='flex items-center justify-between gap-6'>
        <div className='min-w-0 flex-1'>{header}</div>
        <button data-ripple type='button' aria-label={closeLabel} onClick={onClose} className='-m-2 flex size-10 shrink-0 items-center justify-center rounded-full'>
          <FigmaIcon name='panel-close' width={24} height={24} />
        </button>
      </div>
      {children}
      {scroll && <FloatingScrollbar target={box} />}
    </aside>
  )
}
