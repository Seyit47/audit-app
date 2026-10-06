import type { InputHTMLAttributes, ReactNode, SelectHTMLAttributes } from 'react'
import { FigmaIcon } from './FigmaIcon'

/** Label, control and hint of the 162:20071 form ("Название торговой точки *"). */
export function FormField ({ label, required, hint, action, error, htmlFor, children, className = '' }: {
  label: ReactNode
  required?: boolean
  hint?: ReactNode
  /** Right-aligned control next to the label ("Указать на интерактивной карте", "Поддерживается до 4 номеров"). */
  action?: ReactNode
  error?: string
  htmlFor?: string
  children: ReactNode
  className?: string
}) {
  return (
    <div className={`flex min-w-0 flex-col gap-1 ${className}`}>
      <div className='flex items-center justify-between gap-4'>
        <label htmlFor={htmlFor} className='text-xs font-semibold leading-4 text-default-black'>
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

const control = 'w-full rounded-lg border border-border bg-pure-white text-sm leading-5 text-black placeholder:text-off-white focus:border-accent focus:outline-none focus:ring-2 focus:ring-accent/20 aria-invalid:border-error'

/** 44 px text input (162:20743). */
export function TextInput ({ className = '', ...props }: InputHTMLAttributes<HTMLInputElement>) {
  return <input {...props} className={`h-11 px-3.5 font-medium ${control} ${className}`} />
}

/** 42 px select with the Figma chevron (162:20761). */
export function SelectInput ({ className = '', children, ...props }: SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <div className='relative'>
      <select {...props} className={`h-[42px] cursor-pointer appearance-none pl-3.5 pr-10 ${control} ${className}`}>{children}</select>
      <FigmaIcon name='select-chevron' width={16} height={16} className='pointer-events-none absolute right-3 top-1/2 -translate-y-1/2' />
    </div>
  )
}
