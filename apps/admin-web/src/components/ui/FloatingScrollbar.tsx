'use client'

import { useEffect, useRef, useState, useSyncExternalStore, type RefObject } from 'react'
import { createPortal } from 'react-dom'

const noop = () => () => {}
const MIN_THUMB = 28
const SHOW_MS = 900

interface Geometry { trackTop: number, trackHeight: number, right: number, thumbTop: number, thumbHeight: number }

/**
 * A thin scrollbar that floats over the content instead of taking width, so content never shifts when a
 * page or panel starts or stops scrolling. The native scrollbar of the target is hidden (`html` in
 * globals.css, `.scrollbar-none` on containers). The thumb shows while scrolling or when the pointer is
 * near the right edge, and can be dragged.
 *
 * `target`: the scroll container; omitted, the page itself.
 */
export function FloatingScrollbar ({ target }: { target?: RefObject<HTMLElement | null> }) {
  const mounted = useSyncExternalStore(noop, () => true, () => false)
  const [geo, setGeo] = useState<Geometry | null>(null)
  const [visible, setVisible] = useState(false)
  const [dragging, setDragging] = useState(false)
  const hide = useRef<ReturnType<typeof setTimeout> | null>(null)

  useEffect(() => {
    const el = target?.current ?? null
    if (target != null && el == null) return
    const metrics = () => el == null
      ? { top: 0, height: window.innerHeight, right: 2, scroll: window.scrollY, size: document.documentElement.scrollHeight, view: window.innerHeight }
      : (() => {
          const r = el.getBoundingClientRect()
          return { top: r.top + 2, height: r.height - 4, right: window.innerWidth - r.right + 2, scroll: el.scrollTop, size: el.scrollHeight, view: el.clientHeight }
        })()
    let frame = 0
    const update = () => {
      cancelAnimationFrame(frame)
      frame = requestAnimationFrame(() => {
        const m = metrics()
        if (m.size <= m.view + 1 || m.height <= 0) { setGeo(null); return }
        const thumbHeight = Math.max(MIN_THUMB, (m.view / m.size) * m.height)
        const thumbTop = m.top + (m.scroll / (m.size - m.view)) * (m.height - thumbHeight)
        setGeo({ trackTop: m.top, trackHeight: m.height, right: m.right, thumbTop, thumbHeight })
      })
    }
    const flash = () => {
      update()
      setVisible(true)
      if (hide.current != null) clearTimeout(hide.current)
      hide.current = setTimeout(() => setVisible(false), SHOW_MS)
    }
    const scroller: HTMLElement | Window = el ?? window
    scroller.addEventListener('scroll', flash, { passive: true })
    window.addEventListener('resize', update)
    // Content growing or shrinking (infinite lists, panels opening) changes the thumb.
    const ro = new ResizeObserver(update)
    ro.observe(el ?? document.body)
    if (el?.firstElementChild != null) ro.observe(el.firstElementChild)
    // Inner containers move with the page.
    if (el != null) window.addEventListener('scroll', update, { passive: true })
    update()
    return () => {
      cancelAnimationFrame(frame)
      scroller.removeEventListener('scroll', flash)
      window.removeEventListener('resize', update)
      if (el != null) window.removeEventListener('scroll', update)
      ro.disconnect()
      if (hide.current != null) clearTimeout(hide.current)
    }
  }, [target])

  if (!mounted || geo == null) return null

  const drag = (e: React.PointerEvent<HTMLDivElement>) => {
    const el = target?.current ?? null
    const startY = e.clientY
    const startScroll = el == null ? window.scrollY : el.scrollTop
    const size = el == null ? document.documentElement.scrollHeight - window.innerHeight : el.scrollHeight - el.clientHeight
    const perPx = size / (geo.trackHeight - geo.thumbHeight)
    e.currentTarget.setPointerCapture(e.pointerId)
    setDragging(true)
    const move = (ev: PointerEvent) => {
      const y = startScroll + (ev.clientY - startY) * perPx
      if (el == null) window.scrollTo({ top: y }); else el.scrollTop = y
    }
    const up = () => { setDragging(false); window.removeEventListener('pointermove', move); window.removeEventListener('pointerup', up) }
    window.addEventListener('pointermove', move)
    window.addEventListener('pointerup', up)
  }

  const shown = visible || dragging
  return createPortal(
    <div
      aria-hidden
      // The hover strip along the right edge: pointing at it reveals the thumb.
      className='group fixed z-[70] w-3'
      style={{ top: geo.trackTop, height: geo.trackHeight, right: geo.right - 2 }}
    >
      <div
        onPointerDown={drag}
        className={`absolute right-[3px] w-1.5 cursor-default rounded-full bg-[#191b25]/35 transition-[opacity,width,background-color] duration-200 hover:w-2 hover:bg-[#191b25]/50 group-hover:opacity-100 ${shown ? 'opacity-100' : 'opacity-0'} ${dragging ? 'w-2 bg-[#191b25]/55' : ''}`}
        style={{ top: geo.thumbTop - geo.trackTop, height: geo.thumbHeight }}
      />
    </div>,
    document.body
  )
}
