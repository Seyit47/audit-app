'use client'

/** 38×20 switch of 47:7387 ("Status: Active"). */
export function Toggle ({ checked, onChange, label, disabled }: { checked: boolean, onChange: (v: boolean) => void, label: string, disabled?: boolean }) {
  return (
    <button
      type='button' role='switch' aria-checked={checked} aria-label={label} disabled={disabled} onClick={() => onChange(!checked)}
      className={`relative h-5 w-[38px] shrink-0 rounded-full transition-colors disabled:opacity-60 ${checked ? 'bg-accent' : 'bg-[#c7c4d8]'}`}
    >
      <span className={`absolute top-0.5 size-4 rounded-full bg-white shadow transition-all ${checked ? 'left-5' : 'left-0.5'}`} />
    </button>
  )
}
