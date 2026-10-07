import Link from 'next/link'
import type { ReactNode } from 'react'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { hhmm } from '@/features/agents/components/RouteTimeline'
import type { GalleryPhoto } from '@/features/photos/types'
import type { ShopDetails, Visit } from '@/features/shops/api'
import { formatPhone } from '@/lib/format'
import { sub, type Locale } from '@/lib/i18n'
import type { MapCopy } from '../copy'

const shadowXl = 'shadow-[0px_8px_10px_-6px_rgba(0,0,0,0.1),0px_20px_25px_-5px_rgba(0,0,0,0.1)]'

function Info ({ label, children }: { label: string, children: ReactNode }) {
  return (
    <div className='flex flex-col'>
      <span className='text-[10px] leading-4 text-subtle'>{label}</span>
      <div className='text-xs font-semibold leading-4 text-ink'>{children}</div>
    </div>
  )
}

function dayTime (iso: string, locale: Locale) {
  const d = new Date(iso)
  const day = d.toDateString() === new Date().toDateString()
    ? (locale === 'ru' ? 'Сегодня' : 'Today')
    : new Intl.DateTimeFormat(locale === 'ru' ? 'ru-RU' : 'en-US', { day: 'numeric', month: 'short' }).format(d)
  return `${day}, ${hhmm(iso, locale)}`
}

/** "Right-side location drawer" of 3:2 (3:125): the selected shop with photos and recent visits. */
export function ShopCard ({ shop, visits, totals, photos, closeHref, copy, history, locale }: {
  shop: ShopDetails
  visits: Visit[]
  totals: { all: number, completed: number, missed: number }
  photos: GalleryPhoto[]
  closeHref: string
  copy: MapCopy
  /** Visit history labels shared with the shop details page. */
  history: { title: string, updatedAt: string, total: string, completed: string, missed: string, duration: string, comment: string, violation: string, missedStatus: string, noVisits: string }
  locale: Locale
}) {
  const c = copy.card
  const status = shop.status === 'ACTIVE'
    ? <span className='flex items-center gap-1 rounded bg-[#72f8df] px-2 py-0.5 text-[10px] font-bold leading-[15px] text-[#00201b]'><FigmaIcon name='map-verified' width={11} height={10.5} />{c.verified}</span>
    : <span className='rounded bg-inactive-bg px-2 py-0.5 text-[10px] font-bold leading-[15px] text-muted'>{shop.status === 'PENDING_REVIEW' ? c.pending : c.inactive}</span>
  const phones = shop.contacts.length > 0 ? shop.contacts.map((x) => x.phone) : []
  const tiles = photos.slice(0, 5)
  const more = shop.kpis.auditPhotos > 5 ? shop.kpis.auditPhotos - 4 : 0

  return (
    <aside className={`absolute bottom-2 left-4 top-[68px] z-20 flex w-96 flex-col overflow-hidden rounded-2xl bg-pure-white ${shadowXl}`}>
      <div className='flex items-start justify-between gap-4 p-4'>
        <div className='flex min-w-0 flex-col gap-[3px]'>
          <div className='flex items-center gap-2'>
            <span className='rounded bg-[#d7e3ff] px-2 py-0.5 text-[10px] font-bold uppercase leading-[15px] tracking-[0.5px] text-[#001b3f]'>{c.types[shop.type as keyof typeof c.types] ?? shop.type}</span>
            {status}
          </div>
          <Link href={`/shops/${shop.id}`} title={c.details} className='truncate text-lg font-bold leading-[22.5px] text-ink hover:text-accent'>{shop.name}</Link>
          <p className='pt-px text-xs font-medium leading-4 text-muted'>{shop.address}</p>
        </div>
        <Link href={closeHref} aria-label={c.close} className='flex size-7 shrink-0 items-center justify-center'><FigmaIcon name='map-card-close' width={10} height={10} /></Link>
      </div>

      <div className='flex min-h-0 flex-1 flex-col gap-4 overflow-y-auto px-4 py-2'>
        <div className='flex flex-col gap-1.5 rounded-xl bg-secondary-bg p-3'>
          <Info label={c.region}>{shop.region?.name ?? c.none}</Info>
          <Info label={c.address}><span className='font-medium'>{shop.address}{shop.addressDetail != null ? `, ${shop.addressDetail}` : ''}</span></Info>
          <Info label={c.lastAudit}>{shop.kpis.lastAuditAt != null ? new Intl.DateTimeFormat(locale === 'ru' ? 'ru-RU' : 'en-GB', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false }).format(new Date(shop.kpis.lastAuditAt)) : c.none}</Info>
          <Info label={c.agent}>
            {shop.agent != null
              ? <Link href={`/salesmen/${shop.agent.id}`} className='flex items-center gap-1 text-accent'><FigmaIcon name='map-agent' width={8.67} height={8.67} />{shop.agent.fullName}</Link>
              : c.unassigned}
          </Info>
          <Info label={c.audits}>{shop.kpis.totalAudits}</Info>
          <Info label={c.phones}>
            {phones.length === 0
              ? c.none
              : (
                <span className='flex flex-wrap gap-x-3 gap-y-2 pt-0.5'>
                  {phones.map((ph) => <a key={ph} href={`tel:${ph}`} className='flex items-center gap-1 text-accent'><FigmaIcon name='map-phone' width={9.84} height={9.83} />{formatPhone(ph)}</a>)}
                </span>
                )}
          </Info>
          <div className='flex flex-col gap-2 pt-3'>
            <div className='flex items-center justify-between'>
              <span className='flex items-center gap-1.5 text-xs font-semibold leading-4 text-ink'><FigmaIcon name='map-camera' width={13.33} height={12} />{c.photos}</span>
              <Link href={`/pictures?shopId=${shop.id}`} className='text-[11px] font-semibold leading-[16.5px] text-accent'>{c.openGallery}</Link>
            </div>
            {tiles.length > 0 && (
              <div className='grid grid-cols-5 gap-2'>
                {tiles.map((p, i) => {
                  const last = i === 4 && more > 0
                  return (
                    <Link key={p.id} href={last ? `/pictures?shopId=${shop.id}` : `/pictures?photo=${p.id}`} className='relative aspect-square overflow-hidden rounded-lg bg-dark-accent shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
                      {/* eslint-disable-next-line @next/next/no-img-element -- presigned preview URL */}
                      <img src={p.previewUrl400} alt='' loading='lazy' className='absolute inset-0 size-full object-cover' />
                      {last && <span className='absolute inset-0 flex items-center justify-center bg-black/40 text-[11px] font-semibold leading-[16.5px] text-white'>{sub(c.morePhotos, more)}</span>}
                    </Link>
                  )
                })}
              </div>
            )}
          </div>
        </div>

        <section className='flex flex-col gap-3'>
          <div className='flex flex-col gap-3 border-b border-secondary-bg pb-3'>
            <div className='flex items-center justify-between'>
              <h2 className='text-base font-bold leading-6 text-ink'>{history.title}</h2>
              <span className='flex items-center gap-1.5 text-xs leading-4 text-muted'>{history.updatedAt} <span className='font-display text-ink'>{hhmm(new Date().toISOString(), locale)}</span></span>
            </div>
            <div className='flex items-center gap-4 text-[11px] leading-[14px] text-muted'>
              <span className='font-semibold'>{sub(history.total, totals.all)}</span>
              <span className='flex items-center gap-1 font-medium tracking-[0.22px]'><span className='size-2.5 rounded-full bg-success' />{sub(history.completed, totals.completed)}</span>
              <span className='flex items-center gap-1 font-medium tracking-[0.22px]'><span className='size-2.5 rounded-full bg-[#ce3437]' />{sub(history.missed, totals.missed)}</span>
            </div>
          </div>
          {visits.length === 0 && <p className='py-4 text-center text-xs text-muted'>{history.noVisits}</p>}
          {visits.map((v) => (
            <article key={v.id} className='flex flex-col gap-2 border-b border-secondary-bg pb-3 last:border-b-0'>
              <div className='flex items-center justify-between gap-1'>
                <span className='font-display text-[11px] font-medium leading-4 text-ink'>
                  {v.type === 'AUDIT' ? `${dayTime(v.startedAt, locale)} — ${hhmm(v.at, locale)}` : dayTime(v.at, locale)}
                </span>
                {v.type === 'AUDIT'
                  ? <span className='text-[11px] leading-[16.5px] text-subtle'>{sub(history.duration, v.durationMin)}</span>
                  : <span className='text-[11px] font-semibold leading-[16.5px] text-error'>{history.missedStatus}</span>}
              </div>
              {v.type === 'AUDIT' && v.comment !== '' && (
                <p className='rounded-lg bg-secondary-bg/60 px-3 py-2 text-xs font-bold leading-[19.5px] text-ink'>
                  {v.hasViolation ? history.violation : history.comment} <span className='font-normal'>«{v.comment}»</span>
                </p>
              )}
              {v.type === 'AUDIT' && v.photos.length > 0 && (
                <div className='flex gap-1.5'>
                  {v.photos.slice(0, 5).map((p) => (
                    <Link key={p.id} href={`/pictures?photo=${p.id}`} className='size-[50px] shrink-0 overflow-hidden rounded-lg bg-dark-accent'>
                      {/* eslint-disable-next-line @next/next/no-img-element -- presigned preview URL */}
                      <img src={p.previewUrl400} alt='' loading='lazy' className='size-full object-cover' />
                    </Link>
                  ))}
                </div>
              )}
            </article>
          ))}
        </section>
      </div>
    </aside>
  )
}
