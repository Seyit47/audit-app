'use client'

// URL-driven dialogs (`?add=1`, `?edit=<id>`) open in the browser: the URL changes with the history API
// (Next keeps useSearchParams in sync, no server render) and the form's data comes from /data/forms/<kind>,
// cached briefly (TanStack Query) and prefetched on hover, so a slow server never delays the dialog appearing.

import { queryOptions } from '@tanstack/react-query'
import { getJson, getQueryClient } from './query'

export type FormKind = 'shop' | 'product' | 'agent'

/** The query for a form's data (/data/forms/<kind>), in the shared cache for 30 s. */
export const formQuery = <T>(kind: FormKind, id: string | null) => queryOptions({
  queryKey: ['form', kind, id ?? 'new'],
  queryFn: () => getJson<T>(`/data/forms/${kind}${id == null ? '' : `?id=${encodeURIComponent(id)}`}`)
})

/** Hover/focus on a link that opens a form: start loading its data. */
export function prefetchFormData (kind: FormKind, id: string | null) {
  void getQueryClient().prefetchQuery(formQuery(kind, id))
}

/** After a save the cached form data is stale. */
export function forgetFormData () {
  void getQueryClient().invalidateQueries({ queryKey: ['form'] })
}

// The element that opened the current URL dialog: focus returns there when it closes. The dialog itself can't
// know it, since its loading placeholder and then the form mount in turn.
let opener: HTMLElement | null = null

/** Opens a URL dialog without a server render; modified clicks (new tab) keep the link's default. */
export function openUrlDialog (e: React.MouseEvent<HTMLAnchorElement>, href: string) {
  if (e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return
  e.preventDefault()
  // A link in a menu goes away with the menu; its trigger takes the focus back instead.
  const trigger = e.currentTarget.closest<HTMLElement>('[role=menu]')?.id
  opener = (trigger != null ? document.querySelector<HTMLElement>(`[aria-controls="${trigger}"]`) : null) ?? e.currentTarget
  window.history.pushState(null, '', href)
}

/** The element to focus when a URL dialog closes (if it is still on the page). */
export function takeOpener (): HTMLElement | null {
  const el = opener
  opener = null
  return el?.isConnected === true ? el : null
}
