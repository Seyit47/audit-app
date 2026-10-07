import Link from 'next/link'
import type { ButtonHTMLAttributes, ReactNode } from 'react'

// Page-header buttons of 30:574 ("Add Product" primary, "Export Catalog" secondary) and the
// dialog footer buttons of 162:20071 ("Сохранить изменения" primary md, "Отменить" outline md).
const variants = {
  primary: 'bg-accent text-white shadow-[0px_4px_6px_-1px_rgba(0,0,0,0.1),0px_2px_4px_-2px_rgba(0,0,0,0.1)]',
  secondary: 'bg-line px-3.5 text-ink drop-shadow-[0px_1px_1px_rgba(0,0,0,0.05)]',
  outline: 'border border-border bg-pure-white px-4 text-default-black shadow-[0px_1px_2px_rgba(0,0,0,0.05)] hover:border-slate-400',
  danger: 'bg-[#fff0ef] px-4 text-danger shadow-[0px_2px_4px_-2px_rgba(0,0,0,0.1),0px_4px_6px_-1px_rgba(0,0,0,0.1)]'
}
const sizes = {
  sm: 'text-xs font-semibold leading-4',
  md: 'text-sm leading-5'
}
const primaryPadding = { sm: 'px-4', md: 'px-5 font-semibold shadow-[0px_1px_2px_rgba(0,0,0,0.05)]' }

type Props = {
  variant?: keyof typeof variants
  size?: keyof typeof sizes
  icon?: ReactNode
  href?: string
  /** Full prefetch so a dialog opened by URL (`?add=1`, `?edit=…`) appears at once. */
  prefetch?: boolean
  children: ReactNode
} & ButtonHTMLAttributes<HTMLButtonElement>

export function Button ({ variant = 'primary', size = 'sm', icon, href, prefetch, children, className = '', type = 'button', ...rest }: Props) {
  const weight = size === 'md' && variant === 'outline' ? 'font-medium' : ''
  const pad = variant === 'primary' ? primaryPadding[size] : ''
  const cls = `inline-flex items-center justify-center gap-2 rounded-lg py-2 text-center whitespace-nowrap hover:shadow-md active:shadow-none disabled:cursor-not-allowed disabled:opacity-50 disabled:shadow-none aria-disabled:pointer-events-none aria-disabled:opacity-50 ${sizes[size]} ${variants[variant]} ${pad} ${weight} ${className}`
  // Export links start a server job: a plain link, never prefetched.
  if (href?.startsWith('/export')) return <a href={href} data-ripple className={cls}>{icon}{children}</a>
  if (href != null) return <Link href={href} prefetch={prefetch} data-ripple className={cls}>{icon}{children}</Link>
  return <button type={type} data-ripple className={cls} {...rest}>{icon}{children}</button>
}
