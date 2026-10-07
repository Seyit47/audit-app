import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { number } from '@/lib/format'
import { plural, sub, type Locale } from '@/lib/i18n'
import type { AgentsCopy } from '../copy'

function Kpi ({ label, value, unit, icon, iconBg }: { label: string, value: string, unit: string, icon: [string, number, number], iconBg: string }) {
  return (
    <div className='flex flex-1 items-start justify-between gap-4 rounded-xl bg-pure-white p-5 shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
      <div className='flex min-w-0 flex-col gap-2'>
        <span className='text-xs font-medium leading-4 text-muted'>{label}</span>
        <p className='flex items-baseline gap-2'>
          <span className='text-3xl font-bold leading-9 tracking-[-0.75px] text-ink'>{value}</span>
          <span className='text-xs font-medium leading-4 text-subtle'>{unit}</span>
        </p>
      </div>
      <span className={`flex h-10 min-w-10 shrink-0 items-center justify-center rounded-lg px-2 ${iconBg}`}>
        <FigmaIcon name={icon[0]} width={icon[1]} height={icon[2]} />
      </span>
    </div>
  )
}

/** "(4 карточки)" of 122:7981 (122:9215). All-time audits come from the visit totals. */
export function AgentKpis ({ allTimeAudits, assignedShops, visitedShops, photos, copy, locale }: {
  allTimeAudits: number
  assignedShops: number
  visitedShops: number
  photos: number
  copy: AgentsCopy
  locale: Locale
}) {
  const d = copy.details
  const n = (v: number) => number(v, locale)
  return (
    <div className='flex gap-4 py-2'>
      <Kpi label={d.audits} value={n(allTimeAudits)} unit={plural(locale, allTimeAudits, d.checklists)} icon={['agent-kpi-audits', 16.5, 18.33]} iconBg='bg-secondary-bg' />
      <Kpi label={d.assigned} value={n(assignedShops)} unit={plural(locale, assignedShops, d.outlets)} icon={['agent-kpi-shops', 18.42, 16.5]} iconBg='bg-[#d7e3ff]' />
      <Kpi label={d.visited} value={n(visitedShops)} unit={sub(plural(locale, assignedShops, d.ofShops), n(assignedShops))} icon={['agent-kpi-visited', 11.92, 19.71]} iconBg='bg-success-10' />
      <Kpi label={d.photos} value={n(photos)} unit={plural(locale, photos, d.frames)} icon={['photos-counter', 18.33, 18.33]} iconBg='bg-[#e2dfff]' />
    </div>
  )
}
