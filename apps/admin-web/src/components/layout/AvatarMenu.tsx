'use client'

import { useEffect, useRef, useState, useTransition } from 'react'
import { Icon } from '@/components/ui/Icon'
import { SegmentedControl } from '@/components/ui/SegmentedControl'
import { signOut } from '@/features/auth/actions'
import { setLocale } from '@/features/locale/actions'
import type { Locale } from '@/lib/i18n'
import type { LayoutCopy } from './copy'

/** Header avatar menu: RU/EN switch (gap A12) and sign out. Styled after the row dropdown of 3:407 (3:1959). */
export function AvatarMenu ({ copy, locale }: { copy: LayoutCopy, locale: Locale }) {
  const [open, setOpen] = useState(false)
  const [pending, startTransition] = useTransition()
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!open) return
    const close = (e: MouseEvent) => { if (!ref.current?.contains(e.target as Node)) setOpen(false) }
    document.addEventListener('mousedown', close)
    return () => document.removeEventListener('mousedown', close)
  }, [open])

  return (
    <div ref={ref} className='relative'>
      <button data-ripple
        type='button' aria-label={copy.account} aria-expanded={open} onClick={() => setOpen(!open)}
        className='flex size-8 items-center justify-center rounded-full bg-accent text-white'
      >
        <Icon name='avatar' width={12} height={12} />
      </button>
      {open && (
        <div className='anim-menu-in origin-top-right absolute right-0 top-10 z-20 flex w-44 flex-col rounded-xl bg-pure-white py-1.5 shadow-[0px_20px_25px_-5px_rgba(0,0,0,0.1),0px_8px_10px_-6px_rgba(0,0,0,0.1)]'>
          <div className={`flex items-center justify-between gap-2 px-3 py-2 ${pending ? 'opacity-60' : ''}`}>
            <span className='text-xs font-medium leading-4 text-ink'>{copy.language}</span>
            <SegmentedControl
              options={[{ value: 'ru', label: 'RU' }, { value: 'en', label: 'EN' }]}
              value={locale}
              onChange={(next) => startTransition(() => setLocale(next))}
            />
          </div>
          <form action={signOut} className='border-t border-secondary-bg pt-1'>
            <button data-ripple type='submit' className='flex h-9 w-full items-center px-3 text-left text-xs font-medium leading-4 text-danger hover:bg-secondary-bg'>
              {copy.signOut}
            </button>
          </form>
        </div>
      )}
    </div>
  )
}
