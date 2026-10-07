'use client'

/** "Quick Filter Presets" of 31:2307 (Сегодня / Вчера / Текущая неделя). */
export function SegmentedControl<T extends string> ({ options, value, onChange }: {
  options: Array<{ value: T, label: string }>
  value: T | null
  onChange: (value: T) => void
}) {
  return (
    <div role='group' className='flex h-8 items-center gap-1 rounded-lg bg-secondary-bg p-1'>
      {options.map((o) => (
        <button
          key={o.value} data-ripple type='button' aria-pressed={o.value === value} onClick={() => onChange(o.value)}
          className={`rounded-lg px-2.5 py-1 text-xs font-medium leading-4 whitespace-nowrap transition-colors duration-200 ${o.value === value ? 'bg-accent text-white shadow-[0px_1px_2px_rgba(0,0,0,0.1)]' : 'text-muted'}`}
        >
          {o.label}
        </button>
      ))}
    </div>
  )
}
