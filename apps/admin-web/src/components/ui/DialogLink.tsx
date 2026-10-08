'use client'

import type { ReactNode } from 'react'
import { openUrlDialog, prefetchFormData, type FormKind } from '@/lib/url-dialog'

/**
 * A link that opens a URL dialog (`?add=1`, `?edit=…`) in the browser, with no server render, and starts
 * loading the form's data on hover. A plain link still: new tab and middle click work.
 */
export function DialogLink ({ href, form, className, children, onOpen, role }: {
  href: string
  form: { kind: FormKind, id?: string | null }
  className?: string
  children: ReactNode
  /** Runs after opening (e.g. closing the row menu the link sits in). */
  onOpen?: () => void
  role?: string
}) {
  const prefetch = () => prefetchFormData(form.kind, form.id ?? null)
  return (
    <a
      href={href} role={role} data-ripple className={className}
      onPointerEnter={prefetch} onFocus={prefetch}
      onClick={(e) => { openUrlDialog(e, href); onOpen?.() }}
    >
      {children}
    </a>
  )
}
