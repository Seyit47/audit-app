import { notFound } from 'next/navigation'
import { AutoRefresh } from '@/components/ui/AutoRefresh'
import { Card } from '@/components/ui/Card'
import { getAgentDetails, getAgentVisits, getTimeline, getTrack } from '@/features/agents/api'
import { AgentHeader } from '@/features/agents/components/AgentHeader'
import { AgentKpis } from '@/features/agents/components/AgentKpis'
import { AgentVisitHistory } from '@/features/agents/components/AgentVisitHistory'
import { PeriodFilter } from '@/features/agents/components/AgentsToolbar'
import { PhotoReports } from '@/features/agents/components/PhotoReports'
import { RouteMap } from '@/features/agents/components/RouteMap'
import { hhmm, RouteTimeline } from '@/features/agents/components/RouteTimeline'
import { agentsCopy } from '@/features/agents/copy'
import type { GalleryPage } from '@/features/photos/types'
import { api, ApiError } from '@/lib/api'
import { isoDay } from '@/lib/format'
import { sub } from '@/lib/i18n'
import { getLocale } from '@/lib/locale'

type Search = Record<string, string | undefined>

/** Salesman details of 122:7981. The route, timeline and map show the last day of the period. */
export default async function SalesmanDetailsPage ({ params, searchParams }: PageProps<'/salesmen/[id]'>) {
  const { id } = await params
  const sp = (await searchParams) as Search
  const locale = await getLocale()
  const copy = agentsCopy[locale]
  const d = copy.details
  const day = sp.to ?? sp.from

  let agent
  try {
    agent = await getAgentDetails(id, sp.from, sp.to)
  } catch (err) {
    if (err instanceof ApiError && (err.status === 404 || err.status === 400)) notFound()
    throw err
  }
  const [stops, track, visits, photos] = await Promise.all([
    getTimeline(id, day),
    getTrack(id, day),
    getAgentVisits(id, sp.cursor),
    api<GalleryPage>('/v1/photos', { query: { agentId: id, from: sp.from, limit: 5 } })
  ])

  const keep = (extra: Search) => new URLSearchParams(Object.entries({ from: sp.from, to: sp.to, ...extra }).filter((e): e is [string, string] => e[1] != null)).toString()
  const p = agent.position
  const live = p != null && agent.online
    ? [d.hereNow, p.speedKmh != null ? sub(d.speed, Math.round(p.speedKmh)) : null, p.batteryPct != null ? sub(d.battery, p.batteryPct) : null].filter(Boolean).join(' · ')
    : null
  const checkpointLabel = Object.fromEntries(track.checkpoints.map((c) => [c.id, `${c.name} (${hhmm(c.at, locale)})`]))

  return (
    <div className='flex flex-col gap-2.5 p-4'>
      <AutoRefresh seconds={30} />
      <AgentHeader
        agent={agent} copy={copy} locale={locale}
        exportHref={(type) => `/export?${new URLSearchParams({ type, agentId: id, back: `/salesmen/${id}`, ...(sp.from != null ? { from: sp.from } : {}), ...(sp.to != null ? { to: sp.to } : {}) }).toString()}`}
      />
      <Card className='flex flex-wrap items-center gap-3 p-4'>
        <PeriodFilter copy={copy} />
      </Card>
      <AgentKpis
        allTimeAudits={visits.totals.completed} assignedShops={agent.kpis.assignedShops}
        visitedShops={agent.kpis.visitedShops} photos={agent.kpis.photos} copy={copy} locale={locale}
      />
      <div className='flex items-start gap-6 px-8 pb-12 pt-5'>
        <div className='flex min-w-0 flex-1 flex-col gap-6'>
          <RouteMap
            track={track} checkpointLabel={checkpointLabel} live={live}
            labels={{ route: d.route, recenter: d.recenter, fullscreen: d.fullscreen, zoomIn: d.zoomIn, zoomOut: d.zoomOut }}
          />
          <PhotoReports photos={photos.items} total={agent.kpis.photos} galleryHref={`/pictures?agentId=${id}`} copy={copy} locale={locale} />
        </div>
        <div className='flex min-w-0 flex-1 flex-col gap-3.5'>
          <RouteTimeline stops={stops} day={day ?? isoDay(new Date())} isToday={day == null || day === isoDay(new Date())} copy={copy} locale={locale} />
          <AgentVisitHistory
            visits={visits} copy={copy} locale={locale}
            moreHref={visits.nextCursor != null ? `/salesmen/${id}?${keep({ cursor: visits.nextCursor })}` : null}
          />
        </div>
      </div>
    </div>
  )
}
