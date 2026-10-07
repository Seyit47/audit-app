import { FigmaIcon } from './FigmaIcon'

/** Applied-filter tag of 31:2307 ("Region: Region 2 ×", 31:2459). */
export function FilterChip ({ label, onRemove, removeLabel }: { label: string, onRemove: () => void, removeLabel: string }) {
  return (
    <span className='anim-menu-in inline-flex items-center gap-1.5 rounded-md bg-dark-accent px-2.5 py-1 text-xs font-medium leading-4 text-ink'>
      {label}
      <button type='button' aria-label={`${removeLabel}: ${label}`} onClick={onRemove} data-ripple className='flex rounded-full p-0.5 text-ink'>
        <FigmaIcon name='chip-remove' width={8.167} height={8.167} />
      </button>
    </span>
  )
}

/** "APPLIED:" row of 31:2307 (31:2456). */
export function AppliedFilters ({ label, children }: { label: string, children: React.ReactNode }) {
  return (
    <div className='flex w-full flex-wrap items-center gap-2 border-t border-dark-accent pt-[9px]'>
      <span className='text-[11px] font-semibold uppercase leading-[16.5px] tracking-[0.55px] text-muted'>{label}</span>
      {children}
    </div>
  )
}
