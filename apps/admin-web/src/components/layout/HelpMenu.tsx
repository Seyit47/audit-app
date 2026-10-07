'use client'

import { usePathname } from 'next/navigation'
import { useEffect, useRef, useState } from 'react'
import { Icon } from '@/components/ui/Icon'
import type { Locale } from '@/lib/i18n'
import { helpCopy, helpKey, type HelpTopic } from './help-copy'

/** Header help button (3:853): a popover listing what the current page lets you do. */
export function HelpMenu ({ label, locale }: { label: string, locale: Locale }) {
  const pathname = usePathname()
  const [openAt, setOpenAt] = useState<string | null>(null)
  const open = openAt === pathname // closes itself when the page changes
  const ref = useRef<HTMLDivElement>(null)
  const copy = helpCopy[locale]
  const topic = (copy.pages as Record<string, HelpTopic>)[helpKey(pathname)]

  useEffect(() => {
    if (!open) return
    const close = (e: MouseEvent) => { if (ref.current?.contains(e.target as Node) !== true) setOpenAt(null) }
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') setOpenAt(null) }
    document.addEventListener('mousedown', close)
    document.addEventListener('keydown', esc)
    return () => { document.removeEventListener('mousedown', close); document.removeEventListener('keydown', esc) }
  }, [open])

  if (topic == null) return null
  return (
    <div ref={ref} className='relative'>
      <button
        data-ripple type='button' aria-label={label} title={label} aria-haspopup='dialog' aria-expanded={open}
        onClick={() => setOpenAt(open ? null : pathname)}
        className='flex size-9 items-center justify-center rounded-lg text-muted'
      >
        <Icon name='help' width={16.667} height={16.667} />
      </button>
      {open && (
        <div role='dialog' aria-label={copy.heading} className='anim-menu-in origin-top-right absolute right-0 top-11 z-40 flex w-[360px] flex-col gap-3 rounded-xl bg-pure-white p-4 shadow-[0px_20px_25px_-5px_rgba(0,0,0,0.1),0px_8px_10px_-6px_rgba(0,0,0,0.1)]'>
          <div className='flex flex-col'>
            <p className='text-[10px] font-semibold uppercase leading-4 tracking-[0.5px] text-subtle'>{copy.heading}</p>
            <h2 className='text-base font-bold leading-6 text-ink'>{topic.title}</h2>
          </div>
          <ul className='flex flex-col gap-2.5'>
            {topic.tips.map((tip) => (
              <li key={tip} className='flex gap-2.5 text-xs leading-[18px] text-ink'>
                <span className='mt-[7px] size-1.5 shrink-0 rounded-full bg-accent' />
                <span>{tip}</span>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}
