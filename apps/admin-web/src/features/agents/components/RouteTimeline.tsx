import { Timeline, type TimelineState } from '@/components/ui/Timeline'
import { plural, sub, type Locale, formatDate } from '@/lib/i18n'
import type { StopStatus, TimelineStop } from '../api'
import type { AgentsCopy } from '../copy'

const states: Record<StopStatus, TimelineState> = { DONE: 'done', MISSED: 'missed', IN_PROGRESS: 'active', PLANNED: 'planned' }

export const hhmm = (iso: string, locale: Locale) =>
  formatDate(locale, { hour: '2-digit', minute: '2-digit', hour12: false }, new Date(iso))

/** "Today's Route Timeline Sequence" of 122:7981 (122:9841) for one day's route. */
export function RouteTimeline ({ stops, day, isToday, copy, locale }: { stops: TimelineStop[], day: string, isToday: boolean, copy: AgentsCopy, locale: Locale }) {
  const d = copy.details
  const dayLabel = formatDate(locale, { day: 'numeric', month: 'long' }, new Date(`${day}T12:00:00`))
  return (
    <Timeline
      title={isToday ? d.timelineToday : sub(d.timelineDay, dayLabel)}
      count={`${stops.length} ${plural(locale, stops.length, d.checkpoints)}`}
      empty={d.noStops}
      points={stops.map((st) => ({
        id: st.id,
        title: `${hhmm(st.plannedAt, locale)} — ${st.shop.name}`,
        detail: st.audit != null
          ? `${hhmm(st.audit.startedAt, locale)} — ${hhmm(st.audit.finishedAt, locale)} • ${sub(d.photoCount, st.photoCount)}`
          : st.status === 'IN_PROGRESS' ? d.syncing : st.isAuditTask ? d.auditTask : d.plannedVisit,
        state: states[st.status],
        stateLabel: d.stop[st.status]
      }))}
    />
  )
}
