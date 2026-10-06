import Link from 'next/link'
import type { ButtonHTMLAttributes, ReactNode } from 'react'

// Page-header buttons of 30:574: "Add Product" (primary) and "Export Catalog" (secondary).
const variants = {
  primary: 'bg-accent px-4 text-white shadow-[0px_4px_6px_-1px_rgba(0,0,0,0.1),0px_2px_4px_-2px_rgba(0,0,0,0.1)]',
  secondary: 'bg-line px-3.5 text-ink drop-shadow-[0px_1px_1px_rgba(0,0,0,0.05)]'
}

type Props = {
  variant?: keyof typeof variants
  icon?: ReactNode
  href?: string
  children: ReactNode
} & ButtonHTMLAttributes<HTMLButtonElement>

export function Button ({ variant = 'primary', icon, href, children, className = '', type = 'button', ...rest }: Props) {
  const cls = `inline-flex items-center gap-2 rounded-lg py-2 text-center text-xs font-semibold leading-4 whitespace-nowrap disabled:opacity-60 ${variants[variant]} ${className}`
  if (href != null) return <Link href={href} className={cls}>{icon}{children}</Link>
  return <button type={type} className={cls} {...rest}>{icon}{children}</button>
}
