import type { Storage } from '../../plugins/storage.js'

export interface PhotoRow {
  id: string, storageKey: string, previewKeys: unknown, width: number | null, height: number | null, takenAt: Date
}
export interface PhotoView {
  id: string, url: string, previewUrl400: string, previewUrl1200: string, width: number | null, height: number | null, takenAt: string
}

/** Serializes a photo with short-lived presigned URLs; falls back to the original until previews exist. */
export async function photoView (storage: Storage, p: PhotoRow): Promise<PhotoView> {
  const previews = (p.previewKeys ?? {}) as Record<string, string>
  const url = await storage.presignGet(p.storageKey)
  return {
    id: p.id,
    url,
    previewUrl400: previews['400'] ? await storage.presignGet(previews['400']) : url,
    previewUrl1200: previews['1200'] ? await storage.presignGet(previews['1200']) : url,
    width: p.width,
    height: p.height,
    takenAt: p.takenAt.toISOString()
  }
}
