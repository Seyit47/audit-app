import { createHash } from 'node:crypto'
import type { Storage } from '../../plugins/storage.js'
import type { Jobs } from '../../plugins/jobs.js'
import type { AuthUser } from '../../plugins/auth.js'
import { AppError, notFound } from '../../lib/app-error.js'
import type { PhotosRepository } from './photos.repository.js'
import type { CreateUploadBody } from './photos.schema.js'

const MB = 1024 * 1024
const AGENT_KINDS = new Set(['AUDIT', 'FACADE'])
const ADMIN_KINDS = new Set(['FACADE', 'PRODUCT', 'AVATAR', 'LOGO', 'ADMIN_UPLOAD'])
const EXT: Record<string, string> = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp' }
export const PREVIEWS_QUEUE = 'photo-previews'

const invalid = (message: string) => new AppError(400, 'VALIDATION_FAILED', message)

/** Direct-to-storage uploads: presign, then verify and mark READY (research R-06). */
export class UploadsService {
  private readonly photos: PhotosRepository
  private readonly storage: Storage
  private readonly jobs: Jobs
  constructor (photos: PhotosRepository, storage: Storage, jobs: Jobs) {
    this.photos = photos
    this.storage = storage
    this.jobs = jobs
  }

  async create (user: AuthUser, body: CreateUploadBody) {
    const allowed = user.role === 'AGENT' ? AGENT_KINDS : ADMIN_KINDS
    if (!allowed.has(body.kind)) throw new AppError(403, 'FORBIDDEN', `Upload kind ${body.kind} not allowed`)
    if (body.kind === 'PRODUCT') {
      if (body.mime === 'image/webp') throw invalid('Product images must be PNG or JPG')
      if (body.sizeBytes > 5 * MB) throw invalid('Product images must be at most 5 MB')
    } else if (body.sizeBytes > 10 * MB) {
      throw invalid('Images must be at most 10 MB')
    }
    if (body.kind === 'ADMIN_UPLOAD' && !body.shopId) throw invalid('shopId is required for ADMIN_UPLOAD')
    if (user.deactivatedAt != null && new Date(body.takenAt) >= user.deactivatedAt) {
      throw new AppError(401, 'UNAUTHENTICATED', 'Account deactivated')
    }

    const existing = await this.photos.findById(body.id)
    if (existing && existing.uploadedById !== user.id) throw notFound('Upload')
    const photo = existing ?? await this.photos.create({
      id: body.id,
      kind: body.kind,
      uploadedById: user.id,
      storageKey: `${body.kind.toLowerCase()}/${body.id}.${EXT[body.mime]}`,
      mime: body.mime,
      sizeBytes: body.sizeBytes,
      sha256: body.sha256,
      takenAt: new Date(body.takenAt),
      lat: body.lat ?? null,
      lng: body.lng ?? null,
      accuracyM: body.accuracyM ?? null,
      shopId: body.shopId ?? null
    })
    if (photo.status === 'READY') return { id: photo.id, status: photo.status }
    const put = await this.storage.presignPut(photo.storageKey, photo.mime, photo.sizeBytes)
    return { id: photo.id, status: photo.status, uploadUrl: put.url, headers: put.headers, expiresAt: put.expiresAt }
  }

  async complete (user: AuthUser, id: string) {
    const photo = await this.photos.findById(id)
    if (!photo || photo.uploadedById !== user.id) throw notFound('Upload')
    if (photo.status === 'READY') return { id, status: photo.status }
    const head = await this.storage.head(photo.storageKey)
    if (!head) throw invalid('File has not been uploaded')
    if (head.sizeBytes !== photo.sizeBytes) throw invalid('Uploaded size does not match')
    const hash = createHash('sha256').update(await this.storage.getObject(photo.storageKey)).digest('hex')
    if (hash !== photo.sha256) throw invalid('Uploaded file checksum does not match')
    await this.photos.markReady(id)
    await this.jobs.send(PREVIEWS_QUEUE, { photoId: id })
    return { id, status: 'READY' as const }
  }
}
