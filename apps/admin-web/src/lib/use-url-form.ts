'use client'

import { usePathname, useSearchParams } from 'next/navigation'
import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { formQuery, type FormKind } from './url-dialog'

/**
 * State of a URL-driven form dialog: open while the URL has `?add` or `?edit`, the record being edited
 * (`?edit=<id>`, or `fixedId` on a details page), its data from /data/forms/<kind> (synchronous when
 * prefetched), and the URL to return to on close.
 */
const clock = () => performance.now()

export function useUrlForm<T> (kind: FormKind, fixedId?: string) {
  const params = useSearchParams()
  const pathname = usePathname()
  const open = params.has('add') || params.has('edit')
  const id = !open || params.has('add') ? null : (fixedId ?? params.get('edit'))
  const k = open ? `${id ?? 'new'}` : null
  // When this opening began: the loading dialog and the form that replaces it share one entrance animation,
  // and every new opening starts a new one.
  const [opened, setOpened] = useState<{ key: string, at: number } | null>(null)
  if (k != null && opened?.key !== k) setOpened({ key: k, at: clock() })
  if (k == null && opened != null) setOpened(null)

  // Prefetched on hover, the data is usually already in the cache and the form shows at once.
  const query = useQuery({ ...formQuery<T>(kind, id), enabled: k != null })
  const data = k == null ? null : query.data ?? null
  const rest = new URLSearchParams(params)
  rest.delete('add')
  rest.delete('edit')
  const closeHref = rest.size > 0 ? `${pathname}?${rest.toString()}` : pathname
  return { open, id, key: k, data, failed: k != null && query.isError, closeHref, enterStartedAt: opened?.key === k ? opened.at : undefined }
}
