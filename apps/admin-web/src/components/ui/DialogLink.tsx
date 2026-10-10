'use client'

import type { ComponentProps, ReactNode } from 'react'
import { openUrlDialog, prefetchFormData, type FormKind } from '@/lib/url-dialog'

/**
 * A link that opens a URL dialog (`?add=1`, `?edit=…`) in the browser, with no server render, and starts
 * loading the form's data on hover. A plain link still: new tab and middle click work.
 */
export function DialogLink ({ href, form, className, children, onOpen, onClick, onPointerEnter, onFocus, ...rest }: {
  href: string
  form: { kind: FormKind, id?: string | null }
  className?: string
  children: ReactNode
  /** Runs after opening (e.g. closing the row menu the link sits in). */
  onOpen?: () => void
} & Omit<ComponentProps<'a'>, 'href' | 'className' | 'children'>) {
  const prefetch = () => prefetchFormData(form.kind, form.id ?? null)
  // Extra props (a ref, Radix menu item handlers and attributes) reach the <a>; its handlers run alongside ours.
  return (
    <a
      {...rest}
      href={href} data-ripple className={className}
      onPointerEnter={(e) => { prefetch(); onPointerEnter?.(e) }}
      onFocus={(e) => { prefetch(); onFocus?.(e) }}
      onClick={(e) => { onClick?.(e); openUrlDialog(e, href); onOpen?.() }}
    >
      {children}
    </a>
  )
}
