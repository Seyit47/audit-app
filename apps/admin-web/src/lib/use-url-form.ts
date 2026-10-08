'use client'

import { usePathname, useSearchParams } from 'next/navigation'
import { useEffect, useState } from 'react'
import { loadFormData, peekFormData, type FormKind } from './url-dialog'

/**
 * State of a URL-driven form dialog: open while the URL has `?add` or `?edit`, the record being edited
 * (`?edit=<id>`, or `fixedId` on a details page), its data from /data/forms/<kind> (synchronous when
 * prefetched), and the URL to return to on close.
 */
export function useUrlForm<T> (kind: FormKind, fixedId?: string) {
  const params = useSearchParams()
  const pathname = usePathname()
  const open = params.has('add') || params.has('edit')
  const id = !open || params.has('add') ? null : (fixedId ?? params.get('edit'))
  const k = open ? `${id ?? 'new'}` : null
  const [loaded, setLoaded] = useState<{ key: string, data: T } | null>(null)
  const [failed, setFailed] = useState<string | null>(null)
  // The loading dialog plays the entrance; the form that replaces it then appears without animating again.
  const [skeletonFor, setSkeletonFor] = useState<string | null>(null)

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
  if (k != null && data == null && skeletonFor !== k) setSkeletonFor(k)
  const rest = new URLSearchParams(params)
  rest.delete('add')
  rest.delete('edit')
  const closeHref = rest.size > 0 ? `${pathname}?${rest.toString()}` : pathname
  return { open, id, key: k, data, failed: failed != null && failed === k, closeHref, animateIn: skeletonFor !== k }
}
