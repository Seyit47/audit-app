'use client'

import { useLayoutEffect, useRef, type RefObject } from 'react'

/**
 * FLIP for a reflowing grid: call `capture()` right before the state change that reflows it; when
 * `trigger` changes, every `[data-flip]` child glides from its old place to the new one instead of jumping.
 */
export function useFlip (container: RefObject<HTMLElement | null>, trigger: unknown) {
  const before = useRef<Map<string, DOMRect> | null>(null)

  const capture = () => {
    const map = new Map<string, DOMRect>()
    container.current?.querySelectorAll<HTMLElement>('[data-flip]').forEach((el) => map.set(el.dataset.flip!, el.getBoundingClientRect()))
    before.current = map
  }

  useLayoutEffect(() => {
    const old = before.current
    before.current = null
    if (old == null || container.current == null || window.matchMedia('(prefers-reduced-motion: reduce)').matches) return
    container.current.querySelectorAll<HTMLElement>('[data-flip]').forEach((el) => {
      const was = old.get(el.dataset.flip!)
      if (was == null) return
      const now = el.getBoundingClientRect()
      const dx = was.left - now.left
      const dy = was.top - now.top
      const sx = was.width / now.width
      const sy = was.height / now.height
      if (Math.abs(dx) < 1 && Math.abs(dy) < 1 && Math.abs(sx - 1) < 0.01) return
      el.animate(
        [{ transformOrigin: 'top left', transform: `translate(${dx}px, ${dy}px) scale(${sx}, ${sy})` }, { transformOrigin: 'top left', transform: 'none' }],
        { duration: 380, easing: 'cubic-bezier(0.2, 0, 0, 1)' }
      )
    })
  }, [trigger, container])

  return capture
}
