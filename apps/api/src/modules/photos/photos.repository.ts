import type { PrismaClient } from '../../lib/prisma.js'
import type { PhotoKind } from '../../generated/prisma/client.js'

export interface NewPhoto {
  id: string, kind: PhotoKind, uploadedById: string, storageKey: string, mime: string, sizeBytes: number,
  sha256: string, takenAt: Date, lat?: number | null, lng?: number | null, accuracyM?: number | null, shopId?: string | null
}

export class PhotosRepository {
  private readonly prisma: PrismaClient
  constructor (prisma: PrismaClient) { this.prisma = prisma }

  findById (id: string) {
    return this.prisma.photo.findUnique({ where: { id } })
  }

  create (p: NewPhoto) {
    return this.prisma.photo.create({ data: { ...p, status: 'PENDING_UPLOAD' } })
  }

  markReady (id: string) {
    return this.prisma.photo.update({ where: { id }, data: { status: 'READY' } })
  }

  setPreviews (id: string, previewKeys: Record<string, string>, width: number, height: number) {
    return this.prisma.photo.update({ where: { id }, data: { previewKeys, width, height } })
  }
}
