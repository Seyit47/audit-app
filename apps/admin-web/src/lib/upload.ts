import { completeUpload, createUpload, type CreateUploadInput, type UploadKind } from './upload-actions'

async function sha256Hex (file: Blob): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', await file.arrayBuffer())
  return Array.from(new Uint8Array(digest), (b) => b.toString(16).padStart(2, '0')).join('')
}

/** Uploads an image straight to storage and returns the photo id to save on the record. */
export async function uploadImage (file: File, kind: UploadKind, opts: { shopId?: string } = {}): Promise<string> {
  const created = await createUpload({
    id: crypto.randomUUID(),
    kind,
    mime: file.type as CreateUploadInput['mime'],
    sizeBytes: file.size,
    sha256: await sha256Hex(file),
    takenAt: new Date(file.lastModified || Date.now()).toISOString(),
    shopId: opts.shopId
  })
  if (created.status === 'READY') return created.id

  const put = await fetch(created.uploadUrl!, { method: 'PUT', headers: created.headers, body: file })
  if (!put.ok) throw new Error(`Upload failed (${put.status})`)
  await completeUpload(created.id)
  return created.id
}
