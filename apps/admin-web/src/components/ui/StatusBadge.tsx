import type { ReactNode } from 'react'

// Status pills: Active (3:407 49:9880), Pending Review (3:407 181:22643), Inactive (31:2307 31:3029).
const tones = {
  success: 'gap-1 bg-success-bg px-2 text-[11px] font-medium text-success',
  pending: 'gap-1.5 bg-pending-bg px-2.5 text-xs font-semibold text-accent',
  inactive: 'gap-1.5 bg-inactive-bg px-2 text-[11px] font-medium text-muted'
}
const dots = { success: 'bg-success', pending: 'bg-accent', inactive: 'bg-subtle' }

export function StatusBadge ({ tone, children }: { tone: keyof typeof tones, children: ReactNode }) {
  return (
    <span className={`inline-flex items-center rounded-full py-0.5 leading-4 whitespace-nowrap ${tones[tone]}`}>
      <span className={`size-1.5 shrink-0 rounded-full ${dots[tone]}`} />
      {children}
    </span>
  )
}
