import sharp from 'sharp'
import type { FastifyInstance } from 'fastify'
import { PREVIEWS_QUEUE } from '../modules/photos/uploads.service.js'

const SIZES = [400, 1200] as const

/** Generates 400/1200 px WebP previews. The original object is never modified (Constitution VII). */
export async function generatePreviews (app: FastifyInstance, photoId: string): Promise<void> {
  const repo = app.services.repositories.photos
  const photo = await repo.findById(photoId)
  if (!photo || photo.status !== 'READY' || photo.previewKeys) return
  const original = await app.storage.getObject(photo.storageKey)
  const meta = await sharp(original).metadata()
  const keys: Record<string, string> = {}
  for (const size of SIZES) {
    const key = `previews/${photo.id}-${size}.webp`
    const buf = await sharp(original).rotate().resize({ width: size, height: size, fit: 'inside', withoutEnlargement: true }).webp({ quality: 80 }).toBuffer()
    await app.storage.putObject(key, buf, 'image/webp')
    keys[String(size)] = key
  }
  await repo.setPreviews(photo.id, keys, meta.width ?? 0, meta.height ?? 0)
}

export async function registerPreviewWorker (app: FastifyInstance): Promise<void> {
  await app.jobs.work<{ photoId: string }>(PREVIEWS_QUEUE, async ({ photoId }) => generatePreviews(app, photoId))
}
