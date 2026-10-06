import type { ReactNode } from 'react'

/** "Top Stats & Header Bar" of 30:574: title, optional badge, description and actions. */
export function PageHeader ({ title, badge, description, actions }: { title: ReactNode, badge?: ReactNode, description?: ReactNode, actions?: ReactNode }) {
  return (
    <div className='flex w-full items-center justify-between gap-6'>
      <div className='flex flex-col gap-1'>
        <div className='flex items-center gap-3'>
          <h1 className='text-2xl font-bold leading-8 tracking-[-0.6px] text-ink'>{title}</h1>
          {badge != null && (
            <span className='rounded-full bg-[rgba(99,91,255,0.15)] px-2 py-0.5 text-xs font-semibold leading-4 text-accent'>{badge}</span>
          )}
        </div>
        {description != null && <p className='max-w-[640px] text-sm leading-5 text-muted'>{description}</p>}
      </div>
      {actions != null && <div className='flex shrink-0 items-center gap-3'>{actions}</div>}
    </div>
  )
}
