'use client'

import { isServer, QueryClient } from '@tanstack/react-query'

/**
 * Client-side data (dialog form data, photo details, map cards, live positions, the feed) goes through one
 * TanStack Query cache: requests are shared, kept fresh for 30 s by default, refetched when stale, and polled
 * where live. Pages themselves are server-rendered and don't use it.
 */
function makeQueryClient () {
  return new QueryClient({ defaultOptions: { queries: { staleTime: 30_000, retry: 1, refetchOnWindowFocus: false } } })
}

let browserClient: QueryClient | undefined

/** One client in the browser; a fresh one per server render (never shared between requests). */
export function getQueryClient (): QueryClient {
  if (isServer) return makeQueryClient()
  return (browserClient ??= makeQueryClient())
}

/** GET a /data route's JSON; a non-OK answer is an error. */
export async function getJson<T> (url: string): Promise<T> {
  const r = await fetch(url)
  if (!r.ok) throw new Error(`${url} ${r.status}`)
  return await r.json() as T
}
