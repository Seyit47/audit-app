'use server'

import { api } from './api'

export type UploadKind = 'FACADE' | 'PRODUCT' | 'AVATAR' | 'LOGO' | 'ADMIN_UPLOAD'

export interface CreateUploadInput {
  id: string
  kind: UploadKind
  mime: 'image/jpeg' | 'image/png' | 'image/webp'
  sizeBytes: number
  sha256: string
  takenAt: string
  shopId?: string
}

export interface CreatedUpload { id: string, status: 'PENDING_UPLOAD' | 'READY', uploadUrl?: string, headers?: Record<string, string> }

export async function createUpload (input: CreateUploadInput): Promise<CreatedUpload> {
  return api<CreatedUpload>('/v1/uploads', { method: 'POST', body: input })
}

export async function completeUpload (id: string): Promise<void> {
  await api(`/v1/uploads/${id}/complete`, { method: 'POST' })
}
