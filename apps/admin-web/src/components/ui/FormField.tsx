import type { InputHTMLAttributes, ReactNode, SelectHTMLAttributes } from 'react'
import { FigmaIcon } from './FigmaIcon'

/** Label, control and hint of the 162:20071 form ("Название торговой точки *"). */
export function FormField ({ label, required, hint, action, error, htmlFor, children, className = '', variant = 'edit' }: {
  label: ReactNode
  required?: boolean
  hint?: ReactNode
  /** Right-aligned control next to the label ("Указать на интерактивной карте", "Поддерживается до 4 номеров"). */
  action?: ReactNode
  error?: string
  htmlFor?: string
  children: ReactNode
  className?: string
  /** edit: 162:20071; form: 495:3932 (slate label, 6 px gap). */
  variant?: 'edit' | 'form'
}) {
  return (
    <div data-invalid={error != null || undefined} className={`flex min-w-0 flex-col ${variant === 'form' ? 'gap-1.5' : 'gap-1'} ${className}`}>
      <div className='flex items-center justify-between gap-4'>
        <label htmlFor={htmlFor} className={`text-xs font-semibold leading-4 ${variant === 'form' ? 'text-slate-700' : 'text-default-black'}`}>
          {label}{required === true && <span className='text-error'> *</span>}
        </label>
        {action}
      </div>
      {children}
      {error != null
        ? <p role='alert' className='text-[11px] leading-[16.5px] text-error'>{error}</p>
        : hint != null && <p className='text-[11px] leading-[16.5px] text-off-white'>{hint}</p>}
    </div>
  )
}

const control = 'w-full rounded-lg border border-border bg-pure-white text-sm leading-5 text-black placeholder:text-off-white hover:border-slate-400 focus:border-accent focus:outline-none focus:ring-2 focus:ring-accent/20 disabled:cursor-not-allowed disabled:border-border disabled:bg-slate-50 disabled:text-off-white read-only:bg-slate-50 aria-invalid:border-error aria-invalid:ring-error/20 user-invalid:border-error user-invalid:ring-2 user-invalid:ring-error/20'

const formControl = 'w-full rounded-xl border border-border bg-pure-white text-xs leading-4 text-slate-800 shadow-[0px_1px_2px_rgba(0,0,0,0.05)] placeholder:text-off-white hover:border-slate-400 focus:border-accent focus:outline-none focus:ring-2 focus:ring-accent/20 disabled:cursor-not-allowed disabled:border-border disabled:bg-slate-50 disabled:text-off-white read-only:bg-slate-50 aria-invalid:border-error aria-invalid:ring-error/20 user-invalid:border-error user-invalid:ring-2 user-invalid:ring-error/20'

/** 44 px text input (162:20743); `form` is the 38 px input of 495:3932 with optional icon and suffix. */
export function TextInput ({ className = '', variant = 'edit', icon, suffix, ...props }: InputHTMLAttributes<HTMLInputElement> & { variant?: 'edit' | 'form', icon?: ReactNode, suffix?: ReactNode }) {
  if (variant === 'edit') return <input {...props} className={`h-11 px-3.5 font-medium ${control} ${className}`} />
  return (
    <div className='relative'>
      {icon != null && <span className='pointer-events-none absolute left-3.5 top-1/2 flex -translate-y-1/2'>{icon}</span>}
      <input {...props} className={`h-[38px] ${icon != null ? 'pl-9' : 'pl-3.5'} ${suffix != null ? 'pr-24' : 'pr-3.5'} ${formControl} ${className}`} />
      {suffix != null && <span className='pointer-events-none absolute right-3.5 top-1/2 -translate-y-1/2 text-xs leading-4 text-off-white'>{suffix}</span>}
    </div>
  )
}

/** Multi-line field of 495:3932 ("Примечания / График маршрута"). */
export function TextArea ({ className = '', ...props }: React.TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return <textarea {...props} className={`min-h-[50px] resize-y px-3.5 pb-6 pt-2 ${formControl} ${className}`} />
}

/** 42 px select with the Figma chevron (162:20761); `form` is the 38 px select of 495:3932. */
export function SelectInput ({ className = '', children, variant = 'edit', icon, ...props }: SelectHTMLAttributes<HTMLSelectElement> & { variant?: 'edit' | 'form', icon?: ReactNode }) {
  if (variant === 'edit') {
    return (
      <div className='relative'>
        <select {...props} className={`h-[42px] cursor-pointer appearance-none pl-3.5 pr-10 ${control} ${className}`}>{children}</select>
        <FigmaIcon name='select-chevron' width={16} height={16} className='pointer-events-none absolute right-3 top-1/2 -translate-y-1/2' />
      </div>
    )
  }
  return (
    <div className='relative'>
      {icon != null && <span className='pointer-events-none absolute left-3.5 top-1/2 flex -translate-y-1/2'>{icon}</span>}
      <select {...props} className={`h-[38px] cursor-pointer appearance-none ${icon != null ? 'pl-9' : 'pl-3.5'} pr-10 text-sm leading-5 ${formControl} ${className}`}>{children}</select>
      <FigmaIcon name='select-chevron-lg' width={21} height={21} className='pointer-events-none absolute right-2.5 top-1/2 -translate-y-1/2' />
    </div>
  )
}

/** "Статус активности сотрудника" switch of 495:3932 (495:4881). */
export function StatusSwitch<T extends string> ({ options, value, onChange }: { options: Array<{ value: T, label: string }>, value: T, onChange: (v: T) => void }) {
  return (
    <div role='radiogroup' className='flex h-[38px] items-center gap-1 rounded-xl bg-grey-3 p-1'>
      {options.map((o, i) => {
        const on = o.value === value
        return (
          <button
            key={o.value} type='button' role='radio' aria-checked={on} onClick={() => { if (!on) onChange(o.value) }} data-ripple={!on || undefined}
            className={`flex h-[30px] flex-1 items-center justify-center gap-1.5 rounded-lg text-xs leading-4 ${on ? 'cursor-default bg-pure-white font-semibold shadow-[0px_1px_2px_rgba(0,0,0,0.05)]' : 'font-medium text-default-black'} ${on && i === 0 ? 'text-success' : on ? 'text-ink' : ''}`}
          >
            {on && i === 0 && <span className='size-2 rounded-full bg-light-green' />}
            {o.label}
          </button>
        )
      })}
    </div>
  )
}
