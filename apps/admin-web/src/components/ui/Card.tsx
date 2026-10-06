import type { ReactNode } from 'react'

/** White rounded surface of the admin frames ("Search & Filters Toolbar", 30:730). */
export function Card ({ children, className = '' }: { children: ReactNode, className?: string }) {
  return <div className={`rounded-xl bg-pure-white drop-shadow-[0px_1px_1px_rgba(0,0,0,0.05)] ${className}`}>{children}</div>
}
