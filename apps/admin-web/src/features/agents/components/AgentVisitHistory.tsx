import Link from 'next/link'
import { VisitHistoryItem } from '@/components/ui/VisitHistoryItem'
import { sub, type Locale, formatDate } from '@/lib/i18n'
import type { AgentVisits } from '../api'
import type { AgentsCopy } from '../copy'
import { hhmm } from './RouteTimeline'

function dayTime (iso: string, locale: Locale, today: string) {
  const d = new Date(iso)
  if (d.toDateString() === new Date().toDateString()) return `${today}, ${hhmm(iso, locale)}`
  return `${formatDate(locale, { day: 'numeric', month: 'short' }, d)}, ${hhmm(iso, locale)}`
}

/** "История визитов" of 122:7981: totals and the agent's audits and missed stops, newest first. */
export function AgentVisitHistory ({ visits, moreHref, copy, locale }: { visits: AgentVisits, moreHref: string | null, copy: AgentsCopy, locale: Locale }) {
  const d = copy.details
  return (
    <section className='flex flex-col gap-3.5'>
      <div className='flex items-center justify-between'>
        <h2 className='text-base font-bold leading-6 text-ink'>{d.history}</h2>
        <span className='flex items-center gap-1.5 text-xs leading-4 text-muted'>{d.updatedAt} <span className='font-display text-ink'>{hhmm(new Date().toISOString(), locale)}</span></span>
      </div>
      <div className='flex items-center gap-4 text-[13px] leading-[14px] tracking-[0.22px] text-muted'>
        <span className='font-semibold'>{sub(d.total, visits.totals.all)}</span>
        <span className='flex items-center gap-1 font-medium'><span className='size-2.5 rounded-full bg-success' />{sub(d.completed, visits.totals.completed)}</span>
        <span className='flex items-center gap-1 font-medium'><span className='size-2.5 rounded-full bg-error' />{sub(d.missed, visits.totals.missed)}</span>
      </div>
      {visits.items.length === 0 && <p className='rounded-xl bg-pure-white p-6 text-center text-sm text-muted'>{d.noVisits}</p>}
      {visits.items.map((v) => v.type === 'AUDIT'
        ? (
          <VisitHistoryItem
            key={v.id} status='done' statusLabel={d.done}
            when={`${dayTime(v.startedAt, locale, d.today)} — ${hhmm(v.at, locale)}`}
            aside={sub(d.duration, v.durationMin)}
            thumbnailUrl={v.photos[0]?.previewUrl400}
            title={v.shop.name}
            subtitle={`${v.shop.address} · ${d.code}: ${v.shop.code}`}
            comment={v.comment !== '' ? <><span>{v.hasViolation ? d.violation : d.comment}</span> <span className='font-normal'>«{v.comment}»</span></> : undefined}
            photos={v.photos.map((p) => ({ id: p.id, url: p.previewUrl400 }))}
            morePhotosLabel={(n) => sub(d.thumbsMore, n + (v.photoCount - v.photos.length))}
            photoHref={(ph) => `/pictures?photo=${ph.id}`}
          />
          )
        : (
          <VisitHistoryItem
            key={v.id} status='missed' statusLabel={d.missedStatus}
            when={dayTime(v.at, locale, d.today)} aside={d.declined}
            title={v.shop.name}
            subtitle={`${v.shop.address} · ${d.code}: ${v.shop.code}`}
          />
          ))}
      {moreHref != null && (
        <Link href={moreHref} className='self-center rounded-lg bg-dark-accent px-4 py-2 text-xs font-semibold text-ink'>{d.more}</Link>
      )}
    </section>
  )
}
