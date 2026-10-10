'use client'

import { useQueryStates, type ParserMap, type Values } from 'nuqs'
import { useTransition } from 'react'
import { navigationStarted } from './feedback'

/**
 * A page's URL params (filters, sort, page), typed by its nuqs parsers. Setting them re-renders the server page
 * (shallow: false) without a history entry; changing anything but `page` goes back to the first page.
 */
export function useListParams<P extends ParserMap> (parsers: P) {
  const [pending, startTransition] = useTransition()
  const [values, setValues] = useQueryStates(parsers, { shallow: false, scroll: false, history: 'replace', startTransition })

  const set = (patch: Partial<{ [K in keyof P]: Values<P>[K] | null }>) => {
    const next = 'page' in parsers && !('page' in patch) ? { ...patch, page: null } : patch
    const changed = Object.entries(patch).some(([k, v]) => JSON.stringify(v ?? null) !== JSON.stringify(values[k as keyof P] ?? null))
    if (!changed) return
    navigationStarted()
    void setValues(next as never)
  }

  return { values, set, pending }
}
