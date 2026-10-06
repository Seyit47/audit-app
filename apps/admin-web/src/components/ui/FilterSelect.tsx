'use client'

import { FigmaIcon } from './FigmaIcon'

export interface FilterOption { value: string, label: string }

/** "Options" filter of 30:574 ("Status: All status"). Shows `label: option`. */
export function FilterSelect ({ label, value, options, onChange, name }: {
  label: string
  value: string
  options: FilterOption[]
  onChange?: (value: string) => void
  name?: string
}) {
  return (
    <label className='relative inline-flex items-center rounded-lg bg-secondary-bg'>
      <select
        name={name} value={value} aria-label={label}
        onChange={(e) => onChange?.(e.target.value)}
        className='cursor-pointer appearance-none bg-transparent py-2 pl-3 pr-8 text-xs font-medium leading-4 text-ink focus:outline-none'
      >
        {options.map((o) => <option key={o.value} value={o.value}>{`${label}: ${o.label}`}</option>)}
      </select>
      <FigmaIcon name='chevron-down' width={8} height={4.933} className='pointer-events-none absolute right-3' />
    </label>
  )
}
