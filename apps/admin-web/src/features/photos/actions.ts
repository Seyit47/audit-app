'use server'

import { revalidatePath } from 'next/cache'
import { api } from '@/lib/api'
import type { GalleryPage, GalleryQuery, PhotoDetail } from './types'

/** Next page for infinite scroll. */
export async function loadPhotos (query: GalleryQuery, cursor: string | null, groups = false) {
  return api<GalleryPage>('/v1/photos', { query: { ...query, limit: 24, cursor: cursor ?? undefined, groups: groups || undefined } })
}

export async function loadPhoto (id: string) {
  return api<PhotoDetail>(`/v1/photos/${id}`)
}

export async function photosUploaded () {
  revalidatePath('/pictures')
}
