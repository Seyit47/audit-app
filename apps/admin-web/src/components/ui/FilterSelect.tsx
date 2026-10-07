'use client'

import { FigmaIcon } from './FigmaIcon'

export interface FilterOption { value: string, label: string }

/** "Options" filter of 30:574 ("Status: All status"). Shows `label: option`. */
export function FilterSelect ({ label, value, options, onChange, name, size = 'sm' }: {
  label: string
  value: string
  options: FilterOption[]
  onChange?: (value: string) => void
  name?: string
  /** sm: 32 px (30:574); lg: 40 px (138:12085). */
  size?: 'sm' | 'lg'
}) {
  return (
    <label className='relative inline-flex items-center rounded-lg bg-secondary-bg'>
      <select
        name={name} value={value} aria-label={label}
        onChange={(e) => onChange?.(e.target.value)}
        className={`cursor-pointer appearance-none bg-transparent pl-3 pr-8 text-xs font-medium leading-4 text-ink focus:outline-none ${size === 'lg' ? 'h-10 min-w-40' : 'py-2'}`}
      >
        {options.map((o) => <option key={o.value} value={o.value}>{`${label}: ${o.label}`}</option>)}
      </select>
      <FigmaIcon name='chevron-down' width={8} height={4.933} className='pointer-events-none absolute right-3' />
    </label>
  )
}
