'use client'

import { useCallback, useEffect, useRef, useState, useTransition } from 'react'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { FilterSelect } from '@/components/ui/FilterSelect'
import { PhotoTile, VerifiedTag } from '@/components/ui/PhotoTile'
import { SegmentedControl } from '@/components/ui/SegmentedControl'
import { SidePanel } from '@/components/ui/SidePanel'
import { formatPhone } from '@/lib/format'
import type { Locale } from '@/lib/i18n'
import { useUrlState } from '@/lib/url-state'
import { loadPhoto, loadPhotos } from '../actions'
import type { PhotosCopy } from '../copy'
import type { GalleryPage, GalleryPhoto, GalleryQuery, PhotoDetail } from '../types'
import { UploadPhotosDialog } from './UploadPhotosDialog'

const tag = (l: Locale) => (l === 'ru' ? 'ru-RU' : 'en-GB')
const sub = (s: string, n: number | string) => s.replace('{n}', String(n))

function stamp (iso: string, l: Locale) {
  return new Intl.DateTimeFormat(tag(l), { day: '2-digit', month: '2-digit', year: 'numeric' }).format(new Date(iso))
}

/** Pictures of 53:1375 (grid) and 138:11987 (detail panel). */
export function PhotosView ({ first, query, summary, regions, shops, copy, locale }: {
  first: GalleryPage
  query: GalleryQuery
  summary: { total: number, today: number }
  regions: Array<{ id: string, name: string }>
  shops: Array<{ id: string, name: string, code: string }>
  copy: PhotosCopy
  locale: Locale
}) {
  const { params, set } = useUrlState()
  const [items, setItems] = useState<GalleryPhoto[]>(first.items)
  const [cursor, setCursor] = useState<string | null>(first.nextCursor)
  const groups = first.groups ?? []
  const [loading, startLoading] = useTransition()
  const [detail, setDetail] = useState<PhotoDetail | null>(null)
  const [showFilters, setShowFilters] = useState(true)
  const [uploading, setUploading] = useState(false)
  const mode = (params.get('mode') ?? 'grid') as 'grid' | 'byDate'
  const sentinel = useRef<HTMLDivElement>(null)

  const more = useCallback(() => {
    if (cursor == null || loading) return
    startLoading(async () => {
      const page = await loadPhotos(query, cursor)
      setItems((xs) => [...xs, ...page.items])
      setCursor(page.nextCursor)
    })
  }, [cursor, loading, query])

  useEffect(() => {
    const el = sentinel.current
    if (el == null) return
    const io = new IntersectionObserver((entries) => { if (entries.some((e) => e.isIntersecting)) more() }, { rootMargin: '400px' })
    io.observe(el)
    return () => io.disconnect()
  }, [more])

  const open = (p: GalleryPhoto) => startLoading(async () => setDetail(await loadPhoto(p.id)))
  const activeFilters = ['type', 'regionId', 'verified', 'date'].filter((k) => params.get(k) != null).length

  const tile = (p: GalleryPhoto, size = 'h-[170px] w-full') => (
    <PhotoTile
      key={p.id} src={p.previewUrl400} alt={p.shop?.name ?? ''} className={size}
      verifiedLabel={p.verified ? copy.verified : null}
      title={p.agent?.fullName ?? p.shop?.name} address={p.shop?.address} date={stamp(p.takenAt, locale)}
      active={detail?.id === p.id} onSelect={() => open(p)}
    />
  )

  const grid = (list: GalleryPhoto[]) => (
    <div className={`grid gap-2.5 ${detail != null ? 'grid-cols-2' : 'grid-cols-4'}`}>{list.map((p) => tile(p))}</div>
  )

  const byDay = new Map<string, GalleryPhoto[]>()
  for (const p of items) { const d = p.takenAt.slice(0, 10); byDay.set(d, [...(byDay.get(d) ?? []), p]) }

  return (
    <>
      <div className='flex items-center justify-between gap-4'>
        <div className='flex flex-col gap-1'>
          <h1 className='text-3xl font-bold leading-9 tracking-[-0.75px] text-ink'>{copy.title}</h1>
          <p className='max-w-[460px] text-sm leading-5 text-muted'>{copy.description}</p>
        </div>
        <div className='flex items-center gap-3'>
          <span className='flex h-8 items-center gap-2.5 rounded-lg bg-secondary-bg px-3.5 shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
            <FigmaIcon name='photos-counter' width={15} height={15} />
            <span className='text-xs font-bold leading-4 text-ink'>{sub(copy.total, summary.total.toLocaleString(tag(locale)))}</span>
            <span className='text-xs leading-4 text-muted/30'>|</span>
            <span className='flex items-center gap-1 text-xs font-semibold leading-4 text-success'><span className='size-1.5 rounded-full bg-success' />{sub(copy.today, summary.today)}</span>
          </span>
          <SegmentedControl options={[{ value: 'grid', label: copy.modes.grid }, { value: 'byDate', label: copy.modes.byDate }]} value={mode} onChange={(m) => set({ mode: m === 'grid' ? null : m })} />
          <button type='button' onClick={() => setShowFilters(!showFilters)} aria-expanded={showFilters} className='flex h-10 items-center gap-2 rounded-lg bg-pure-white px-3 text-xs font-semibold leading-4 text-ink shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
            <FigmaIcon name='filters' width={13.5} height={13.5} />{copy.filters}
            {activeFilters > 0 && <span className='flex size-4 items-center justify-center rounded-full bg-accent text-[10px] font-bold text-white'>{activeFilters}</span>}
          </button>
          <button type='button' onClick={() => setUploading(true)} className='flex h-10 items-center gap-2 rounded-lg bg-accent px-4 text-sm font-medium leading-5 text-white shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
            <FigmaIcon name='upload-photo' width={16.5} height={15} />{copy.upload}
          </button>
        </div>
      </div>

      {showFilters && (
        <div className='flex flex-wrap items-center gap-3'>
          <FilterSelect size='lg' label={copy.type} value={params.get('type') ?? ''} onChange={(v) => set({ type: v })}
            options={[{ value: '', label: copy.allTypes }, ...(['AUDIT', 'FACADE', 'ADMIN_UPLOAD'] as const).map((t) => ({ value: t, label: copy.types[t] }))]} />
          <FilterSelect size='lg' label={copy.location} value={params.get('regionId') ?? ''} onChange={(v) => set({ regionId: v })}
            options={[{ value: '', label: copy.allLocations }, ...regions.map((r) => ({ value: r.id, label: r.name }))]} />
          <FilterSelect size='lg' label={copy.status} value={params.get('verified') ?? ''} onChange={(v) => set({ verified: v })}
            options={[{ value: '', label: copy.allStatus }, { value: 'true', label: copy.statuses.true }, { value: 'false', label: copy.statuses.false }]} />
          <FilterSelect size='lg' label={copy.date} value={params.get('date') ?? '7'} onChange={(v) => set({ date: v === '7' ? null : v })}
            options={(['today', '7', '30', 'all'] as const).map((d) => ({ value: d, label: copy.dates[d] }))} />
        </div>
      )}

      <div className='flex items-start gap-2.5'>
        <div className='min-w-0 flex-1'>
          {items.length === 0 && <p className='rounded-xl bg-pure-white p-10 text-center text-sm text-muted'>{copy.empty}</p>}
          {mode === 'grid'
            ? grid(items)
            : [...byDay.entries()].map(([day, list]) => (
              <section key={day} className='mb-4 flex flex-col gap-2.5'>
                <h2 className='flex items-baseline gap-2 text-sm font-bold leading-5 text-ink'>
                  {new Intl.DateTimeFormat(tag(locale), { day: 'numeric', month: 'long', year: 'numeric' }).format(new Date(day))}
                  <span className='font-display text-xs font-normal text-muted'>{groups.find((g) => g.date === day)?.count ?? list.length}</span>
                </h2>
                {grid(list)}
              </section>
            ))}
          <div ref={sentinel} className='h-8 pt-2 text-center text-xs text-muted'>{loading && cursor != null ? copy.loading : ''}</div>
        </div>
        {detail != null && <Detail detail={detail} copy={copy} locale={locale} onClose={() => setDetail(null)} onOpen={open} />}
      </div>

      {uploading && <UploadPhotosDialog shops={shops} copy={copy} onClose={() => setUploading(false)} />}
    </>
  )
}

function Detail ({ detail: d, copy, locale, onClose, onOpen }: { detail: PhotoDetail, copy: PhotosCopy, locale: Locale, onClose: () => void, onOpen: (p: GalleryPhoto) => void }) {
  const time = (iso: string) => new Intl.DateTimeFormat(tag(locale), { hour: '2-digit', minute: '2-digit', hour12: false }).format(new Date(iso))
  const day = (iso: string) => new Date(iso).toDateString() === new Date().toDateString()
    ? copy.today2
    : new Intl.DateTimeFormat(tag(locale), { day: 'numeric', month: 'short' }).format(new Date(iso))
  return (
    <SidePanel
      closeLabel={copy.close}
      onClose={onClose}
      className='sticky top-20 w-[582px]'
      header={d.shop == null
        ? <span className='text-2xl font-bold text-ink'>{d.agent?.fullName}</span>
        : (
          <div className='flex items-center gap-5'>
            <span className='size-[72px] shrink-0 overflow-hidden rounded-xl bg-[#e2dfff] shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
              {/* eslint-disable-next-line @next/next/no-img-element -- presigned URL */}
              {d.shop.facade != null && <img src={d.shop.facade.previewUrl400} alt='' className='size-full object-cover' />}
            </span>
            <div className='flex min-w-0 flex-col gap-1'>
              <div className='flex items-center gap-3'>
                <span className='truncate text-2xl font-bold leading-8 tracking-[-0.6px] text-ink'>{d.shop.name}</span>
                <span className='rounded bg-dark-accent px-2.5 py-0.5 text-xs font-semibold leading-4 text-muted'>{d.shop.code}</span>
                {d.shop.status === 'ACTIVE' && <span className='flex items-center gap-1.5 rounded-full bg-success-10 px-2.5 py-0.5 text-xs font-medium leading-4 text-success'><span className='size-1.5 rounded-full bg-success' />{copy.statusActive}</span>}
              </div>
              <span className='flex items-center gap-1.5 text-xs font-medium leading-4 text-muted'><FigmaIcon name='pin-accent-small' width={10.67} height={13.33} />{d.shop.address}</span>
              {d.shop.agent != null && <span className='flex items-center gap-1.5 text-xs font-medium leading-4 text-muted'><FigmaIcon name='assigned-agent' width={13.33} height={13.33} />{copy.assigned} {d.shop.agent.fullName} · {formatPhone(d.shop.agent.phone)}</span>}
            </div>
          </div>
          )}
    >
      <div className='relative h-[350px] overflow-hidden rounded-xl bg-dark-accent shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
        {/* eslint-disable-next-line @next/next/no-img-element -- presigned URL */}
        <img src={d.previewUrl1200} alt='' className='size-full object-cover' />
        {d.verified && <VerifiedTag label={copy.verified} />}
      </div>
      <div className='flex flex-col gap-2'>
        {d.audit != null && (
          <>
            <div className='flex items-center justify-between'>
              <span className='font-display text-xs leading-4 text-ink'>{day(d.audit.startedAt)}, {time(d.audit.startedAt)} — {time(d.audit.finishedAt)}</span>
              <span className='text-[11px] leading-[16.5px] text-subtle'>{sub(copy.duration, d.audit.durationMin)}</span>
            </div>
            <p className='rounded-lg bg-secondary-bg/60 px-3 pb-3 pt-4 text-xs font-bold leading-[19.5px] text-ink'>
              {d.audit.hasViolation ? copy.violation : copy.agentComment} <span className='font-normal'>«{d.audit.comment}»</span>
            </p>
          </>
        )}
        {d.related.length > 0 && (
          <div className='flex flex-col gap-3 pt-3'>
            <span className='text-sm font-bold leading-4 text-ink'>{sub(copy.related, d.related.length + 1)}</span>
            <div className='flex gap-1.5 overflow-x-auto'>
              {[d, ...d.related].map((p) => (
                <button key={p.id} type='button' onClick={() => onOpen(p)} className={`size-20 shrink-0 overflow-hidden rounded-lg bg-dark-accent ${p.id === d.id ? 'border border-accent shadow-[0px_1px_4px_rgba(0,0,0,0.05)]' : ''}`}>
                  {/* eslint-disable-next-line @next/next/no-img-element -- presigned URL */}
                  <img src={p.previewUrl400} alt='' className='size-full object-cover' />
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    </SidePanel>
  )
}
