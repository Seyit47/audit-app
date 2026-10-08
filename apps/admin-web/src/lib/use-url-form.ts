'use client'

import { usePathname, useSearchParams } from 'next/navigation'
import { useEffect, useState } from 'react'
import { loadFormData, peekFormData, type FormKind } from './url-dialog'

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
  const [loaded, setLoaded] = useState<{ key: string, data: T } | null>(null)
  const [failed, setFailed] = useState<string | null>(null)
  // When this opening began: the loading dialog and the form that replaces it share one entrance animation,
  // and every new opening starts a new one.
  const [opened, setOpened] = useState<{ key: string, at: number } | null>(null)
  if (k != null && opened?.key !== k) setOpened({ key: k, at: clock() })
  if (k == null && opened != null) setOpened(null)

  useEffect(() => {
    if (k == null) return
    let live = true
    loadFormData<T>(kind, id).then(
      (data) => { if (live) setLoaded({ key: k, data }) },
      () => { if (live) setFailed(k) }
    )
    return () => { live = false }
  }, [kind, id, k])

  const data = k == null ? null : loaded?.key === k ? loaded.data : (peekFormData<T>(kind, id) ?? null)
  const rest = new URLSearchParams(params)
  rest.delete('add')
  rest.delete('edit')
  const closeHref = rest.size > 0 ? `${pathname}?${rest.toString()}` : pathname
  return { open, id, key: k, data, failed: failed != null && failed === k, closeHref, enterStartedAt: opened?.key === k ? opened.at : undefined }
}
