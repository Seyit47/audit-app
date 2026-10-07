'use client'

import { usePathname, useSearchParams } from 'next/navigation'
import { useEffect, useRef, useState } from 'react'

/**
 * Indeterminate top progress bar (Material linear progress) for navigations, URL filter changes
 * and server actions. Appears after 100 ms so instant responses don't flash it.
 */
export function NavigationProgress () {
  const pathname = usePathname()
  const search = useSearchParams()
  const [visible, setVisible] = useState(false)
  const navigating = useRef(false)
  const busy = useRef(0)
  const timers = useRef<{ show?: number, safety?: number }>({})

  useEffect(() => {
    const update = () => {
      const active = navigating.current || busy.current > 0
      window.clearTimeout(timers.current.show)
      if (active) timers.current.show = window.setTimeout(() => setVisible(true), 100)
      else setVisible(false)
    }
    const start = () => {
      navigating.current = true
      window.clearTimeout(timers.current.safety)
      timers.current.safety = window.setTimeout(() => { navigating.current = false; update() }, 10_000)
      update()
    }
    const click = (e: MouseEvent) => {
      if (e.defaultPrevented || e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return
      const a = (e.target as Element | null)?.closest('a')
      if (!a || a.target === '_blank' || a.hasAttribute('download')) return
      const url = new URL(a.href, location.href)
      if (url.origin !== location.origin || url.pathname.startsWith('/export')) return
      if (url.pathname + url.search === location.pathname + location.search) return
      start()
    }
    const busyStart = () => { busy.current++; update() }
    const busyEnd = () => { busy.current = Math.max(0, busy.current - 1); update() }
    document.addEventListener('click', click, true)
    window.addEventListener('app:navigate', start)
    window.addEventListener('app:busy-start', busyStart)
    window.addEventListener('app:busy-end', busyEnd)
    const done = () => { navigating.current = false; update() }
    window.addEventListener('app:navigated', done)
    return () => {
      document.removeEventListener('click', click, true)
      window.removeEventListener('app:navigate', start)
      window.removeEventListener('app:busy-start', busyStart)
      window.removeEventListener('app:busy-end', busyEnd)
      window.removeEventListener('app:navigated', done)
    }
  }, [])

  // The new URL has rendered: the navigation is over.
  useEffect(() => { window.dispatchEvent(new Event('app:navigated')) }, [pathname, search])

  return (
    <div aria-hidden className={`pointer-events-none fixed inset-x-0 top-0 z-[100] h-[3px] overflow-hidden transition-opacity duration-200 ${visible ? 'opacity-100' : 'opacity-0'}`}>
      <div className='h-full w-full origin-left bg-accent/20'>
        <div className='h-full w-full origin-left bg-accent' style={{ animation: visible ? 'progress 1.2s var(--ease-standard) infinite' : 'none' }} />
      </div>
    </div>
  )
}
