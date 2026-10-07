'use client'

/** 38×20 switch of 47:7387 ("Status: Active"). */
export function Toggle ({ checked, onChange, label, disabled }: { checked: boolean, onChange: (v: boolean) => void, label: string, disabled?: boolean }) {
  return (
    <button
      type='button' role='switch' aria-checked={checked} aria-label={label} disabled={disabled} onClick={() => onChange(!checked)}
      className={`relative h-5 w-[38px] shrink-0 rounded-full hover:shadow-[0_0_0_6px_rgba(73,62,229,0.08)] active:shadow-[0_0_0_6px_rgba(73,62,229,0.14)] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent disabled:cursor-not-allowed disabled:opacity-50 disabled:shadow-none ${checked ? 'bg-accent' : 'bg-[#c7c4d8]'}`}
    >
      <span className={`absolute top-0.5 size-4 rounded-full bg-white shadow transition-all duration-200 ease-[var(--ease-standard)] ${checked ? 'left-5' : 'left-0.5'}`} />
    </button>
  )
}
