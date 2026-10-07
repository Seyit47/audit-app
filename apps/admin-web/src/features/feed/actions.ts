'use server'

import { api } from '@/lib/api'
import type { FeedPage } from './types'

export async function loadFeed (cursor?: string): Promise<FeedPage> {
  return api<FeedPage>('/v1/feed', { query: { cursor } })
}

export async function markFeedSeen (): Promise<void> {
  await api('/v1/feed/seen', { method: 'POST' })
}
