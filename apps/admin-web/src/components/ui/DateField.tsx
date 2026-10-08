'use client'

import { useRef } from 'react'
import { FigmaIcon } from './FigmaIcon'

/** "Дата от: 📅 24.10.2024" of 31:2307 (117:7943). Value is `YYYY-MM-DD`. */
export function DateField ({ label, value, onChange, min, max }: {
  label: string
  value: string
  onChange: (value: string) => void
  min?: string
  max?: string
}) {
  const input = useRef<HTMLInputElement>(null)
  const shown = value === '' ? '' : value.split('-').reverse().join('.')
  return (
    <label className='relative flex h-8 cursor-pointer items-center gap-2 rounded-lg bg-secondary-bg px-3 py-1.5 hover:bg-line focus-within:ring-2 focus-within:ring-accent/30 has-[:disabled]:cursor-not-allowed has-[:disabled]:opacity-50 has-[:invalid]:ring-2 has-[:invalid]:ring-error/30' onClick={(e) => {
      // One click opens the picker once: without preventDefault the label also forwards the click to the
      // input, which bubbles back here and calls showPicker() a second time (Chrome throws NotAllowedError).
      e.preventDefault()
      try { input.current?.showPicker() } catch { input.current?.focus() }
    }}>
      <span className='text-xs leading-4 text-muted'>{label}</span>
      <span className='flex items-center gap-1.5'>
        <FigmaIcon name='calendar' width={12} height={13.333} />
        <span className='w-24 text-xs font-semibold leading-4 text-ink'>{shown}</span>
      </span>
      <input
        ref={input} type='date' value={value} min={min} max={max} aria-label={label}
        onChange={(e) => onChange(e.target.value)}
        className='pointer-events-none absolute inset-0 opacity-0'
      />
    </label>
  )
}
