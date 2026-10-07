'use client'

import { usePathname, useRouter, useSearchParams } from 'next/navigation'
import { useCallback, useTransition } from 'react'
import { navigationStarted } from './feedback'

/**
 * Reads and updates list state (filters, sort, page) in the URL so server pages re-render with it.
 * Setting any key other than `page` resets to the first page.
 */
export function useUrlState () {
  const router = useRouter()
  const pathname = usePathname()
  const params = useSearchParams()
  const [pending, startTransition] = useTransition()

  const set = useCallback((patch: Record<string, string | number | null | undefined>) => {
    const next = new URLSearchParams(params.toString())
    for (const [k, v] of Object.entries(patch)) {
      if (v === null || v === undefined || v === '') next.delete(k)
      else next.set(k, String(v))
    }
    if (!('page' in patch)) next.delete('page')
    const qs = next.toString()
    if (qs !== params.toString()) navigationStarted()
    startTransition(() => router.replace(qs === '' ? pathname : `${pathname}?${qs}`, { scroll: false }))
  }, [params, pathname, router])

  return { params, set, pending }
}
