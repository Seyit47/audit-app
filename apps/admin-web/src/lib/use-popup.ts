'use client'

import { useEffect, useId, useRef, type RefObject } from 'react'

const OPENED = 'app:popup-open'

/**
 * Shared popup behaviour: while `open`, a press outside every element in `inside` or Esc calls `close`,
 * and opening any other popup closes this one, so only one menu or panel is ever open.
 */
export function usePopup (open: boolean, close: () => void, inside: Array<RefObject<HTMLElement | null>>) {
  const id = useId()
  const latest = useRef({ close, inside })
  useEffect(() => { latest.current = { close, inside } })

  useEffect(() => {
    if (!open) return
    window.dispatchEvent(new CustomEvent(OPENED, { detail: id }))
    const outside = (e: PointerEvent) => {
      const t = e.target as Node
      if (!latest.current.inside.some((r) => r.current?.contains(t) === true)) latest.current.close()
    }
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') latest.current.close() }
    const other = (e: Event) => { if ((e as CustomEvent<string>).detail !== id) latest.current.close() }
    document.addEventListener('pointerdown', outside)
    document.addEventListener('keydown', esc)
    window.addEventListener(OPENED, other)
    return () => {
      document.removeEventListener('pointerdown', outside)
      document.removeEventListener('keydown', esc)
      window.removeEventListener(OPENED, other)
    }
  }, [open, id])
}
