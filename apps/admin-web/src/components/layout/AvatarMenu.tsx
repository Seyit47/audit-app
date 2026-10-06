'use client'

import { useEffect, useRef, useState } from 'react'
import { Icon } from '@/components/ui/Icon'
import { signOut } from '@/features/auth/actions'
import { layoutCopy as copy } from './copy'

export function AvatarMenu () {
  const [open, setOpen] = useState(false)
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!open) return
    const close = (e: MouseEvent) => { if (!ref.current?.contains(e.target as Node)) setOpen(false) }
    document.addEventListener('mousedown', close)
    return () => document.removeEventListener('mousedown', close)
  }, [open])

  return (
    <div ref={ref} className='relative'>
      <button
        type='button' aria-label={copy.account} aria-expanded={open} onClick={() => setOpen(!open)}
        className='flex size-8 items-center justify-center rounded-full bg-accent text-white'
      >
        <Icon name='avatar' width={12} height={12} />
      </button>
      {open && (
        // Styled after the row action dropdown of 3:407 (3:1959).
        <form action={signOut} className='absolute right-0 top-10 z-20 w-44 rounded-lg bg-pure-white py-1.5 shadow-[0px_10px_15px_-3px_rgba(0,0,0,0.1),0px_4px_6px_-4px_rgba(0,0,0,0.1)]'>
          <button type='submit' className='flex h-9 w-full items-center px-3 text-left text-sm text-error hover:bg-grey-3'>
            {copy.signOut}
          </button>
        </form>
      )}
    </div>
  )
}
