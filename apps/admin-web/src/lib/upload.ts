import { sha256 } from '@noble/hashes/sha2.js'
import { bytesToHex } from '@noble/hashes/utils.js'
import { completeUpload, createUpload, type CreateUploadInput, type UploadKind } from './upload-actions'

// crypto.subtle and crypto.randomUUID exist only on HTTPS pages; the admin web may run on plain HTTP inside a
// company network (SECURE_COOKIES=false), so hashing and ids use what works on both.
async function sha256Hex (file: Blob): Promise<string> {
  return bytesToHex(sha256(new Uint8Array(await file.arrayBuffer())))
}

/** A random (v4) UUID from crypto.getRandomValues. */
function uuid (): string {
  const b = crypto.getRandomValues(new Uint8Array(16))
  b[6] = (b[6] & 0x0f) | 0x40
  b[8] = (b[8] & 0x3f) | 0x80
  const h = bytesToHex(b)
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-${h.slice(12, 16)}-${h.slice(16, 20)}-${h.slice(20)}`
}

/** Uploads an image straight to storage and returns the photo id to save on the record. */
export async function uploadImage (file: File, kind: UploadKind, opts: { shopId?: string } = {}): Promise<string> {
  const created = await createUpload({
    id: uuid(),
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
