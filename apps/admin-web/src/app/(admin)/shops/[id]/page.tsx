import Link from 'next/link'
import { notFound } from 'next/navigation'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { VisitHistoryItem } from '@/components/ui/VisitHistoryItem'
import { getShop, getVisits } from '@/features/shops/api'
import { ShopFormHost } from '@/features/shops/components/ShopFormHost'
import { ShopHeader } from '@/features/shops/components/ShopHeader'
import { ShopMiniMap } from '@/features/shops/components/ShopMiniMap'
import { shopFormCopy, shopsCopy } from '@/features/shops/copy'
import { ApiError } from '@/lib/api'
import { sub, type Locale } from '@/lib/i18n'
import { getLocale } from '@/lib/locale'
import { uuid } from '@/lib/params'

const tag = (l: Locale) => (l === 'ru' ? 'ru-RU' : 'en-US')

function dayTime (iso: string, l: Locale, today: string, withDate = true) {
  const d = new Date(iso)
  const time = new Intl.DateTimeFormat(tag(l), { hour: '2-digit', minute: '2-digit', hour12: false }).format(d)
  if (!withDate) return time
  if (d.toDateString() === new Date().toDateString()) return `${today}, ${time}`
  return `${new Intl.DateTimeFormat(tag(l), { day: 'numeric', month: 'short' }).format(d)}, ${time}`
}

function Kpi ({ icon, iconBg, label, value, unit, foot, footIcon, footTone = 'text-success' }: {
  icon: [string, number, number], iconBg: string, label: string, value: string | number, unit?: string, foot: string, footIcon: [string, number, number], footTone?: string
}) {
  return (
    <div className='flex flex-1 flex-col justify-between rounded-xl bg-pure-white p-3 shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
      <div className='flex flex-col gap-2'>
        <span className={`flex size-8 items-center justify-center rounded-lg ${iconBg}`}><FigmaIcon name={icon[0]} width={icon[1]} height={icon[2]} /></span>
        <span className='text-xs font-semibold uppercase leading-4 tracking-[0.6px] text-muted'>{label}</span>
      </div>
      <div className='flex flex-col gap-1 pt-4'>
        <p className='flex items-baseline gap-3'>
          <span className='text-3xl font-bold leading-9 tracking-[-0.75px] text-ink'>{value}</span>
          {unit != null && <span className='text-sm leading-5 tracking-[-0.75px] text-muted'>{unit}</span>}
        </p>
        <p className={`flex items-center gap-1.5 text-xs font-medium leading-4 ${footTone}`}><FigmaIcon name={footIcon[0]} width={footIcon[1]} height={footIcon[2]} />{foot}</p>
      </div>
    </div>
  )
}

export default async function ShopDetailsPage ({ params, searchParams }: PageProps<'/shops/[id]'>) {
  const { id } = await params
  const sp = (await searchParams) as Record<string, string | undefined>
  const locale = await getLocale()
  const copy = shopsCopy[locale]
  const d = copy.details
  if (uuid(id) == null) notFound()
  let shop
  try {
    shop = await getShop(id)
  } catch (err) {
    if (err instanceof ApiError && (err.status === 404 || err.status === 400)) notFound()
    throw err
  }
  const visits = await getVisits(id, sp.cursor)
  const k = shop.kpis

  return (
    <div className='flex flex-col gap-4 p-4'>
      <nav className='flex items-center gap-2 text-xs leading-4'>
        <Link href='/shops' className='font-medium text-muted'>{d.breadcrumb}</Link>
        <FigmaIcon name='breadcrumb-chevron' width={4.32} height={7} />
        <span className='font-semibold text-ink'>{shop.name} ({shop.code})</span>
      </nav>
      <ShopHeader shop={shop} copy={copy} />

      <div className='flex items-start gap-4'>
        <div className='flex min-w-0 flex-1 flex-col gap-4'>
          <div className='flex h-[152px] gap-4'>
            <Kpi icon={['kpi-audits', 12, 16]} iconBg='bg-[#005cba]/10' label={d.totalAudits} value={k.totalAudits}
              foot={k.lastAuditAt != null ? dayTime(k.lastAuditAt, locale, copy.today) : d.noAudits} footIcon={['kpi-clock', 12.5, 12.5]} footTone='text-muted' />
            <Kpi icon={['kpi-products', 14.25, 15]} iconBg='bg-[#e2dfff]' label={d.productsCarried} value={k.productsCarried} unit={d.skus}
              foot={k.compliancePct != null ? sub(d.compliance, k.compliancePct) : '—'} footIcon={['kpi-check', 12.5, 12.5]} />
            <Kpi icon={['kpi-photos', 15, 13.5]} iconBg='bg-[#d7e3ff]' label={d.auditPhotos} value={k.auditPhotos}
              foot={k.geotaggedPct != null ? sub(d.geotagged, k.geotaggedPct) : '—'} footIcon={['kpi-verified', 13.75, 13.125]} />
          </div>
          <section className='flex h-[352px] flex-col gap-[18px] rounded-xl bg-pure-white p-6 shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
            <h2 className='flex items-center gap-2 text-base font-bold leading-6 text-ink'><FigmaIcon name='geo-target' width={16.62} height={16.58} />{d.geo}</h2>
            <div className='relative min-h-0 flex-1 overflow-hidden rounded-lg bg-dark-accent'>
              <ShopMiniMap lat={shop.lat} lng={shop.lng} name={shop.name} />
              <div className='absolute inset-x-2 bottom-2 flex items-center justify-between rounded bg-white/90 p-2 text-xs leading-4 backdrop-blur-[12px]'>
                <span className='font-medium text-ink'>{shop.region?.name ?? d.noRegion}</span>
                <span className='font-semibold text-success'>{d.gpsValid}</span>
              </div>
            </div>
          </section>
        </div>

        <section className='flex min-w-0 flex-1 flex-col gap-3.5'>
          <div className='flex items-center justify-between'>
            <h2 className='text-base font-bold leading-6 text-ink'>{d.history}</h2>
            <span className='flex items-center gap-1.5 text-xs leading-4 text-muted'>{d.updatedAt} <span className='font-display text-ink'>{dayTime(new Date().toISOString(), locale, '', false)}</span></span>
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
                when={`${dayTime(v.startedAt, locale, copy.today)} — ${dayTime(v.at, locale, '', false)}`}
                aside={sub(d.duration, v.durationMin)}
                thumbnailUrl={v.photos[0]?.previewUrl400 ?? shop.facade?.previewUrl400}
                title={v.agent.fullName}
                subtitle={`${shop.address} · ${d.code}: ${shop.code}`}
                comment={<><span>{v.hasViolation ? d.violation : d.comment}</span> <span className='font-normal'>«{v.comment}»</span></>}
                photos={v.photos.map((p) => ({ id: p.id, url: p.previewUrl400 }))}
                morePhotosLabel={(n) => sub(d.morePhotos, n + (v.photoCount - v.photos.length))}
                photoHref={(ph) => `/pictures?photo=${ph.id}`}
              />
              )
            : (
              <VisitHistoryItem
                key={v.id} status='missed' statusLabel={d.missedStatus}
                when={dayTime(v.at, locale, copy.today)} aside={d.declined}
                thumbnailUrl={shop.facade?.previewUrl400}
                title={v.agent.fullName}
                subtitle={`${shop.address} · ${d.code}: ${shop.code}`}
              />
              ))}
          {visits.nextCursor != null && (
            <Link href={`/shops/${id}?cursor=${encodeURIComponent(visits.nextCursor)}`} className='self-center rounded-lg bg-dark-accent px-4 py-2 text-xs font-semibold text-ink'>{d.more}</Link>
          )}
        </section>
      </div>
      {/* ?edit=1 opens in the browser, its data fetched on demand (no server render). */}
      <ShopFormHost copy={shopFormCopy[locale]} shopId={id} />
    </div>
  )
}
