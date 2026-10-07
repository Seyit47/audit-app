'use client'

import { guard } from '@/lib/feedback'
import { usePathname } from 'next/navigation'
import { useCallback, useEffect, useRef, useState, useSyncExternalStore, useTransition } from 'react'
import { createPortal } from 'react-dom'
import { Bone } from '@/components/ui/Skeleton'
import { usePopup } from '@/lib/use-popup'
import { Icon } from '@/components/ui/Icon'
import { SidePanel } from '@/components/ui/SidePanel'
import { VisitHistoryItem } from '@/components/ui/VisitHistoryItem'
import { loadFeed, markFeedSeen } from '@/features/feed/actions'
import type { FeedCopy } from '@/features/feed/copy'
import type { FeedItem } from '@/features/feed/types'
import type { Locale } from '@/lib/i18n'

const POLL_MS = 30_000
const noop = () => () => {}

function when (iso: string, locale: Locale, today: string) {
  const d = new Date(iso)
  const tag = locale === 'ru' ? 'ru-RU' : 'en-US'
  const time = new Intl.DateTimeFormat(tag, { hour: '2-digit', minute: '2-digit', hour12: false }).format(d)
  if (d.toDateString() === new Date().toDateString()) return `${today}, ${time}`
  return `${new Intl.DateTimeFormat(tag, { day: 'numeric', month: 'short' }).format(d)}, ${time}`
}

/**
 * Bell activity feed (approved exception A6): the Figma bell (3:853) with its unread dot, polled every
 * 30 s, and a side panel of violations and missed visits built from the visit history cards.
 */
export function FeedPanel ({ initialUnread, copy, locale }: { initialUnread: number, copy: FeedCopy, locale: Locale }) {
  const [unread, setUnread] = useState(initialUnread)
  const [open, setOpen] = useState(false)
  const [items, setItems] = useState<FeedItem[]>([])
  const [cursor, setCursor] = useState<string | null>(null)
  const [failed, setFailed] = useState(false)
  const [pending, startTransition] = useTransition()
  const mounted = useSyncExternalStore(noop, () => true, () => false)
  const bell = useRef<HTMLButtonElement>(null)
  // Where the panel opens: just below the bell, measured when it opens.
  const [top, setTop] = useState(0)
  // Following a link in the feed closes it.
  const pathname = usePathname()
  const [openedAt, setOpenedAt] = useState(pathname)
  if (open && openedAt !== pathname) { setOpen(false); setOpenedAt(pathname) }

  const panel = useRef<HTMLDivElement>(null)
  usePopup(open, () => setOpen(false), [bell, panel])

  const poll = useCallback(async () => {
    try { setUnread((await loadFeed()).unreadCount) } catch { /* keep the last count */ }
  }, [])
  useEffect(() => {
    const id = setInterval(() => { if (document.visibilityState === 'visible') void poll() }, POLL_MS)
    return () => clearInterval(id)
  }, [poll])

  const show = () => {
    setTop((bell.current?.getBoundingClientRect().bottom ?? 0) + 8)
    setOpen(true); setOpenedAt(pathname)
    startTransition(() => guard(async () => {
      try {
        const page = await loadFeed()
        setItems(page.items); setCursor(page.nextCursor); setFailed(false)
        await markFeedSeen()
        setUnread(0)
      } catch {
        setFailed(true)
      }
    }))
  }
  const more = () => startTransition(() => guard(async () => {
    if (cursor == null) return
    const page = await loadFeed(cursor)
    setItems((xs) => [...xs, ...page.items]); setCursor(page.nextCursor)
  }))

  return (
    <>
      <button ref={bell} data-ripple type='button' aria-label={copy.open} aria-expanded={open} onClick={() => (open ? setOpen(false) : show())} className='relative flex size-9 items-center justify-center rounded-lg text-muted'>
        <Icon name='bell' width={13.333} height={16.667} />
        {unread > 0 && <span className='absolute left-5 top-2 size-2 rounded-full bg-[#ba1a1a]' />}
      </button>
      {/* Portaled: the header's backdrop blur would otherwise contain this fixed panel. */}
      {open && mounted && createPortal(
        <div ref={panel} style={{ top }} className='fixed right-4 z-40'>
          <SidePanel
            scroll className='w-[420px]' style={{ maxHeight: `calc(100vh - ${top + 16}px)` }}
            closeLabel={copy.close} onClose={() => setOpen(false)}
            header={(
              <div className='flex flex-col'>
                <h2 className='text-base font-bold leading-6 text-ink'>{copy.title}</h2>
                <p className='text-xs leading-4 text-muted'>{copy.subtitle}</p>
              </div>
            )}
          >
            <div className='flex flex-col gap-3'>
              {failed && <p className='text-center text-xs text-error'>{copy.error}</p>}
              {!failed && pending && items.length === 0 && [0, 1, 2, 3].map((i) => (
                <div key={i} className='flex flex-col gap-2.5 rounded-xl bg-pure-white p-5 shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
                  <Bone className='h-3 w-24' />
                  <div className='flex items-center gap-3'><Bone className='size-10 rounded-lg' /><div className='flex flex-1 flex-col gap-1.5'><Bone className='h-3.5 w-40' /><Bone className='h-3 w-28' /></div></div>
                </div>
              ))}
              {!failed && !pending && items.length === 0 && <p className='py-6 text-center text-xs text-muted'>{copy.empty}</p>}
              {items.map((it) => it.type === 'VIOLATION'
                ? (
                  <VisitHistoryItem
                    key={`v${it.id}`} status='missed' statusLabel={copy.violation}
                    when={when(it.at, locale, copy.today)} aside=''
                    thumbnailUrl={it.photos[0]?.previewUrl400}
                    title={it.shop.name} titleHref={`/shops/${it.shop.id}`}
                    subtitle={`${it.agent.fullName} · ${it.shop.code}`}
                    comment={it.comment !== '' ? <><span>{copy.comment}</span> <span className='font-normal'>«{it.comment}»</span></> : undefined}
                    photos={it.photos.map((p) => ({ id: p.id, url: p.previewUrl400 }))}
                    photoHref={(p) => `/pictures?photo=${p.id}`}
                  />
                  )
                : (
                  <VisitHistoryItem
                    key={`m${it.id}`} status='missed' statusLabel={copy.missed}
                    when={when(it.at, locale, copy.today)} aside=''
                    title={it.shop.name} titleHref={`/shops/${it.shop.id}`}
                    subtitle={`${it.agent.fullName} · ${it.shop.code}`}
                  />
                  ))}
              {cursor != null && (
                <button data-ripple type='button' onClick={more} disabled={pending} className='self-center rounded-lg bg-dark-accent px-4 py-2 text-xs font-semibold text-ink'>{copy.more}</button>
              )}
            </div>
          </SidePanel>
        </div>,
        document.body
      )}
    </>
  )
}
