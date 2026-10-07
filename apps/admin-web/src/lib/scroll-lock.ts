'use client'

let locks = 0
let saved: { overflow: string, paddingRight: string } | null = null

/**
 * Locks page scroll for a modal: hides the scrollbar and pads the page by its width, so the backdrop
 * covers the whole viewport and nothing behind it moves. Nested locks are counted.
 */
export function lockScroll (): () => void {
  const html = document.documentElement
  if (locks++ === 0) {
    const scrollbar = window.innerWidth - html.clientWidth
    saved = { overflow: html.style.overflow, paddingRight: document.body.style.paddingRight }
    html.style.overflow = 'hidden'
    if (scrollbar > 0) document.body.style.paddingRight = `${scrollbar}px`
  }
  return () => {
    if (--locks > 0 || saved == null) return
    html.style.overflow = saved.overflow
    document.body.style.paddingRight = saved.paddingRight
    saved = null
  }
}
