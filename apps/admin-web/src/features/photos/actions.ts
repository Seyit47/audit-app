'use server'

import { api } from '@/lib/api'
import type { GalleryPage, GalleryQuery } from './types'

/** Next page for infinite scroll (audit photos only, like the first page). */
export async function loadPhotos (query: GalleryQuery, cursor: string | null, groups = false) {
  return api<GalleryPage>('/v1/photos', { query: { ...query, type: 'AUDIT', limit: 24, cursor: cursor ?? undefined, groups: groups || undefined } })
}
