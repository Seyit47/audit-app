import { StatCard } from '@/components/ui/StatCard'
import { number, percent } from '@/lib/format'
import { plural, sub, type Locale } from '@/lib/i18n'
import type { AgentsSummary as Summary } from '../api'
import type { AgentsCopy } from '../copy'

/** "Summary KPI Section" of 31:2307 (117:7745): six metric tiles for the selected period. */
export function AgentsSummary ({ summary: s, copy, locale }: { summary: Summary, copy: AgentsCopy, locale: Locale }) {
  const k = copy.kpis
  const n = (v: number) => number(v, locale)
  return (
    <div className='grid grid-cols-6 items-start gap-3.5'>
      <StatCard
        label={k.total} value={n(s.activeStaff)} unit={plural(locale, s.activeStaff, k.people)}
        icon={{ name: 'stat-team', width: 17, height: 8.5 }}
        footer={<><b className='font-semibold'>{percent(s.activePct, locale)}</b> {sub(k.onStaff, s.totalStaff)}</>}
      />
      <StatCard
        label={k.onRoute} value={n(s.onRoute)} unit={plural(locale, s.onRoute, k.active)}
        icon={{ name: 'stat-route', width: 9.21, height: 15.23 }}
        footer={s.onRoutePct != null ? `${percent(s.onRoutePct, locale)} ${k.ofPool}` : null}
        footerIcon={{ name: 'stat-trend-up', width: 9.33, height: 9.33 }} footerTone='success'
      />
      <StatCard
        label={k.audits} value={n(s.audits)} unit={plural(locale, s.audits, k.checklists)}
        icon={{ name: 'stat-checklist', width: 14.17, height: 12.75 }}
        footer={s.auditsVsPlanPct != null ? `${s.auditsVsPlanPct > 0 ? '+' : ''}${s.auditsVsPlanPct}% ${k.vsPlan}` : null}
        footerTone={s.auditsVsPlanPct != null && s.auditsVsPlanPct < 0 ? 'danger' : 'success'}
      />
      <StatCard
        label={k.shops} value={n(s.shopsVisited)} unit={`/ ${n(s.shopsPlanned)} ${k.outlets}`}
        icon={{ name: 'stat-shop', width: 12.75, height: 11.33 }}
        footer={sub(k.remaining, `${n(s.shopsRemaining)} ${plural(locale, s.shopsRemaining, k.stops)}`)}
      />
      <StatCard
        label={k.photos} value={n(s.photos)} unit={plural(locale, s.photos, k.frames)}
        icon={{ name: 'stat-photo', width: 14.17, height: 14.17 }}
        footer={s.photosVerifiedPct != null ? `${percent(s.photosVerifiedPct, locale)} ${k.valid}` : null}
        footerIcon={{ name: 'kpi-verified', width: 11.92, height: 11.38 }} footerTone='success'
      />
      <StatCard
        label={k.inactive} value={n(s.needsContact)} unit={plural(locale, s.needsContact, k.people)}
        icon={{ name: 'stat-alert', width: 15.58, height: 13.46 }}
        footer={sub(k.needContact, s.noSignalMinutes)} alert={s.needsContact > 0}
      />
    </div>
  )
}
