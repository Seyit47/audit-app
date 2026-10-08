'use client'

// URL-driven dialogs (`?add=1`, `?edit=<id>`) open in the browser: the URL changes with the history API
// (Next keeps useSearchParams in sync, no server render) and the form's data comes from /data/forms/<kind>,
// cached briefly and prefetched on hover, so a slow server never delays the dialog appearing.

export type FormKind = 'shop' | 'product' | 'agent'

const TTL_MS = 30_000
const cache = new Map<string, { at: number, data: Promise<unknown>, value?: unknown }>()

const key = (kind: FormKind, id: string | null) => `${kind}:${id ?? 'new'}`

export function loadFormData<T> (kind: FormKind, id: string | null): Promise<T> {
  const k = key(kind, id)
  const hit = cache.get(k)
  if (hit != null && performance.now() - hit.at < TTL_MS) return hit.data as Promise<T>
  const data = fetch(`/data/forms/${kind}${id == null ? '' : `?id=${encodeURIComponent(id)}`}`)
    .then(async (r) => { if (!r.ok) throw new Error(`form data ${r.status}`); return await r.json() as T })
  const entry: { at: number, data: Promise<unknown>, value?: unknown } = { at: performance.now(), data }
  data.then((v) => { entry.value = v }, () => cache.delete(k))
  cache.set(k, entry)
  return data
}

/** Data already loaded (e.g. prefetched on hover), available synchronously so the form shows at once. */
export function peekFormData<T> (kind: FormKind, id: string | null): T | undefined {
  const hit = cache.get(key(kind, id))
  return hit != null && performance.now() - hit.at < TTL_MS ? hit.value as T | undefined : undefined
}

/** Hover/focus on a link that opens a form: start loading its data. */
export function prefetchFormData (kind: FormKind, id: string | null) {
  loadFormData(kind, id).catch(() => {})
}

/** After a save the cached form data is stale. */
export function forgetFormData () {
  cache.clear()
}

/** Opens a URL dialog without a server render; modified clicks (new tab) keep the link's default. */
export function openUrlDialog (e: React.MouseEvent<HTMLAnchorElement>, href: string) {
  if (e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return
  e.preventDefault()
  window.history.pushState(null, '', href)
}
