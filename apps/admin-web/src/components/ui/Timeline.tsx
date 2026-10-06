import type { ReactNode } from 'react'

export type TimelineState = 'done' | 'missed' | 'active' | 'planned'

export interface TimelinePoint {
  id: string
  /** "09:30 — ТЦ «Ашхабад Сити»" */
  title: string
  /** "10:15 — 10:45 • 12 фото" */
  detail: string
  state: TimelineState
  stateLabel: string
}

// Dot fill and halo per state (122:9841). Figma draws the missed dot like a done one; only its label is red.
const dots: Record<TimelineState, string> = {
  done: 'bg-success shadow-[0_0_0_4px_#ffffff]',
  missed: 'bg-success shadow-[0_0_0_4px_#ffffff]',
  active: 'bg-[#005cba] shadow-[0_0_0_4px_#d7e3ff]',
  planned: 'bg-[#c7c4d8] shadow-[0_0_0_4px_#ffffff]'
}
const labels: Record<TimelineState, string> = {
  done: 'font-bold text-success',
  missed: 'font-bold text-error',
  active: 'font-bold text-[#005cba]',
  planned: 'font-normal text-muted'
}

/** "Today's Route Timeline Sequence" of 122:7981: title, checkpoint count, points on a rail. */
export function Timeline ({ title, count, points, empty }: { title: string, count: ReactNode, points: TimelinePoint[], empty?: ReactNode }) {
  return (
    <section className='flex flex-col gap-2 rounded-2xl bg-pure-white p-4 shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
      <div className='flex items-center justify-between gap-3 border-b border-secondary-bg pb-2'>
        <h2 className='text-sm font-bold leading-4 text-ink'>{title}</h2>
        <span className='text-sm font-semibold leading-[16.5px] text-accent'>{count}</span>
      </div>
      {points.length === 0
        ? <p className='py-6 text-center text-xs text-muted'>{empty}</p>
        : (
          <ol className='relative flex flex-col gap-3 pl-2'>
            <span aria-hidden className='absolute bottom-4 left-[13px] top-2 w-0.5 bg-line' />
            {points.map((p) => {
              const active = p.state === 'active'
              return (
                <li key={p.id} className='relative flex gap-3'>
                  <span className='shrink-0 pt-0.5'><span className={`block size-3 rounded-full ${dots[p.state]}`} /></span>
                  <div className={`flex min-w-0 flex-1 flex-col ${active ? 'rounded-xl bg-[#d7e3ff]/20 p-2' : ''} ${p.state === 'planned' ? 'opacity-70' : ''}`}>
                    <div className='flex items-center justify-between gap-2'>
                      <span className={`truncate text-xs leading-4 text-ink ${active ? 'font-bold' : p.state === 'planned' ? 'font-medium' : 'font-semibold'}`}>{p.title}</span>
                      <span className={`shrink-0 text-[10px] leading-4 ${labels[p.state]}`}>{p.stateLabel}</span>
                    </div>
                    <span className='text-[11px] leading-4 text-muted'>{p.detail}</span>
                  </div>
                </li>
              )
            })}
          </ol>
          )}
    </section>
  )
}
