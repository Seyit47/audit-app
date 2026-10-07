'use client'

import { useEffect } from 'react'

/**
 * Material ripple for every element marked `data-ripple`: one delegated listener draws a wave from
 * the pointer (or the center for keyboard presses).
 */
export function RippleRoot () {
  useEffect(() => {
    const spawn = (host: HTMLElement, x: number, y: number) => {
      if (host.matches(':disabled,[aria-disabled="true"]')) return
      const r = host.getBoundingClientRect()
      const size = Math.hypot(Math.max(x - r.left, r.right - x), Math.max(y - r.top, r.bottom - y)) * 2
      const wave = document.createElement('span')
      wave.className = 'ripple-wave'
      wave.style.width = wave.style.height = `${size}px`
      wave.style.left = `${x - r.left - size / 2}px`
      wave.style.top = `${y - r.top - size / 2}px`
      host.appendChild(wave)
      wave.addEventListener('animationend', () => wave.remove(), { once: true })
    }
    const down = (e: PointerEvent) => {
      if (e.button !== 0) return
      const host = (e.target as Element | null)?.closest<HTMLElement>('[data-ripple]')
      if (host) spawn(host, e.clientX, e.clientY)
    }
    const key = (e: KeyboardEvent) => {
      if (e.key !== 'Enter' && e.key !== ' ') return
      const host = (e.target as Element | null)?.closest<HTMLElement>('[data-ripple]')
      if (!host) return
      const r = host.getBoundingClientRect()
      spawn(host, r.left + r.width / 2, r.top + r.height / 2)
    }
    document.addEventListener('pointerdown', down, { passive: true })
    document.addEventListener('keydown', key)
    return () => { document.removeEventListener('pointerdown', down); document.removeEventListener('keydown', key) }
  }, [])
  return null
}
