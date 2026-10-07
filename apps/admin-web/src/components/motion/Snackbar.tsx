'use client'

import { useEffect, useState } from 'react'
import type { ToastTone } from '@/lib/feedback'

interface Item { id: number, message: string, tone: ToastTone, leaving: boolean }

/** Material snackbars, bottom left: confirm actions ("Saved", "Deleted") and report failures. */
export function Snackbar () {
  const [items, setItems] = useState<Item[]>([])
  useEffect(() => {
    let seq = 0
    const add = (e: Event) => {
      const { message, tone } = (e as CustomEvent<{ message: string, tone: ToastTone }>).detail
      const id = ++seq
      setItems((xs) => [...xs.slice(-2), { id, message, tone, leaving: false }])
      window.setTimeout(() => setItems((xs) => xs.map((x) => (x.id === id ? { ...x, leaving: true } : x))), 3800)
      window.setTimeout(() => setItems((xs) => xs.filter((x) => x.id !== id)), 4000)
    }
    window.addEventListener('app:toast', add)
    return () => window.removeEventListener('app:toast', add)
  }, [])
  return (
    <div role='status' aria-live='polite' className='pointer-events-none fixed bottom-6 left-1/2 z-[90] flex -translate-x-1/2 flex-col items-center gap-2'>
      {items.map((t) => (
        <div
          key={t.id}
          className={`pointer-events-auto flex min-w-[288px] max-w-[560px] items-center gap-3 rounded-lg px-4 py-3 text-sm leading-5 text-[#f0effe] shadow-[0px_6px_16px_rgba(15,23,42,0.24)] ${t.tone === 'error' ? 'bg-[#93000a]' : 'bg-[#2e303b]'} ${t.leaving ? 'anim-fade-out' : 'anim-snackbar-in'}`}
        >
          {t.tone === 'success' && <span className='size-2 shrink-0 rounded-full bg-[#72f8df]' />}
          {t.message}
        </div>
      ))}
    </div>
  )
}
