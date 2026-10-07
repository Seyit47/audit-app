import type { ReactNode } from 'react'
import { FigmaIcon } from './FigmaIcon'

type IconSpec = { name: string, width: number, height: number }

/** KPI tile of 31:2307 (117:7746; alert state 117:7829). */
export function StatCard ({ label, value, unit, icon, footer, footerIcon, footerTone = 'muted', alert = false }: {
  label: ReactNode
  value: ReactNode
  unit?: ReactNode
  icon: IconSpec
  /** Line under the value, e.g. `<b>92.3%</b> (в штате 52)`. */
  footer?: ReactNode
  footerIcon?: IconSpec
  footerTone?: 'muted' | 'success' | 'danger'
  alert?: boolean
}) {
  const tone = { muted: 'text-muted', success: 'text-success', danger: 'text-danger' }[alert ? 'danger' : footerTone]
  return (
    <div className='flex flex-col justify-between overflow-clip rounded-2xl bg-pure-white p-4 shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]'>
      <div className='flex items-center justify-between gap-4'>
        <p className='max-w-[76px] text-xs font-medium leading-4 text-muted'>{label}</p>
        <span className={`flex h-7 min-w-7 shrink-0 items-center justify-center rounded-lg px-[3px] ${alert ? 'bg-alert-bg' : 'bg-secondary-bg'}`}>
          <FigmaIcon {...icon} />
        </span>
      </div>
      <div className='flex flex-col gap-1 pt-2'>
        <p className='flex items-baseline gap-1.5 whitespace-nowrap'>
          <span className={`text-2xl font-bold leading-8 ${alert ? 'text-danger' : 'text-ink'}`}>{value}</span>
          {unit != null && <span className='text-xs font-medium leading-4 text-muted'>{unit}</span>}
        </p>
        {footer != null && (
          <p className={`flex items-center gap-1 text-[11px] font-medium leading-[16.5px] ${tone}`}>
            {footerIcon != null && <FigmaIcon {...footerIcon} />}
            {footer}
          </p>
        )}
      </div>
    </div>
  )
}
