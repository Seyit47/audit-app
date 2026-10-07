'use client'

import { useRouter } from 'next/navigation'
import { SearchAutocomplete } from '@/components/ui/SearchAutocomplete'
import { navigationStarted } from '@/lib/feedback'
import { search } from '@/lib/search-actions'
import type { LayoutCopy } from './copy'

/** Header search of 3:853: shops, salesmen and products as you type; Enter lists matching shops. */
export function GlobalSearch ({ copy }: { copy: LayoutCopy }) {
  const router = useRouter()
  return (
    <SearchAutocomplete
      placeholder={copy.searchPlaceholder}
      load={async (q) => {
        const r = await search(q, ['shops', 'agents', 'products'])
        return [
          { label: copy.nav.shops, hits: r.shops ?? [] },
          { label: copy.nav.salesmen, hits: r.agents ?? [] },
          { label: copy.nav.products, hits: r.products ?? [] }
        ]
      }}
      onSubmit={(q) => { navigationStarted(); router.push(`/shops?${new URLSearchParams({ q }).toString()}`) }}
    />
  )
}
