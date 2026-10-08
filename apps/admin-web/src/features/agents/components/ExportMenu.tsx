'use client'

import { useRef, useState } from 'react'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { usePopup } from '@/lib/use-popup'

/** "Экспорт отчёта (PDF/XLS)" of 122:9104 with its two formats. */
export function ExportMenu ({ label, items }: { label: string, items: Array<{ label: string, href: string }> }) {
  const [open, setOpen] = useState(false)
  const ref = useRef<HTMLDivElement>(null)
  usePopup(open, () => setOpen(false), [ref])
  return (
    <div ref={ref} className='relative shrink-0'>
      <button
        data-ripple type='button' aria-haspopup='menu' aria-expanded={open} onClick={() => setOpen(!open)}
        className='flex items-center gap-2 rounded-lg bg-secondary-bg px-4 py-2 text-xs font-semibold leading-4 text-ink shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'
      >
        <FigmaIcon name='export-download' width={12} height={12} />{label}
      </button>
      {open && (
        <div role='menu' className='anim-menu-in origin-top-right absolute right-0 top-full z-40 mt-1 flex w-full flex-col overflow-hidden rounded-lg bg-pure-white py-1 shadow-[0px_4px_6px_-4px_rgba(0,0,0,0.1),0px_10px_15px_-3px_rgba(0,0,0,0.1)]'>
          {/* Plain links: an export starts a server job and must not be prefetched. */}
          {items.map((i) => <a key={i.href} role='menuitem' data-ripple href={i.href} onClick={() => setOpen(false)} className='mx-1 rounded-md px-3 py-2 text-xs font-medium leading-4 text-ink'>{i.label}</a>)}
        </div>
      )}
    </div>
  )
}
