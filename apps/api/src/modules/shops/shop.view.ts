import type { Storage } from '../../plugins/storage.js'
import type { PhotosRepository } from '../photos/photos.repository.js'
import { photoView, type PhotoView } from '../photos/photo.view.js'
import type { ShopRow } from './shops.repository.js'

export async function facadeView (photos: PhotosRepository, storage: Storage, id: string | null): Promise<PhotoView | null> {
  if (id == null) return null
  const p = await photos.findById(id)
  return p?.status === 'READY' ? photoView(storage, p) : null
}

/** Shop as the screens use it (3:407, 47:7387, 83:17057, 246:23300). */
export async function shopView (s: ShopRow, photos: PhotosRepository, storage: Storage) {
  return {
    id: s.id,
    code: s.code,
    name: s.name,
    type: s.type,
    address: s.address,
    addressDetail: s.addressDetail,
    region: s.region == null ? null : { id: s.region.id, name: s.region.name },
    lat: s.lat,
    lng: s.lng,
    auditRadiusM: s.auditRadiusM,
    ownerName: s.ownerName,
    status: s.status,
    version: s.version,
    facade: await facadeView(photos, storage, s.facadePhotoId),
    agent: s.assignedAgent == null ? null : { id: s.assignedAgent.userId, fullName: s.assignedAgent.fullName, code: s.assignedAgent.code, phone: s.assignedAgent.phone },
    contacts: s.contacts.map((c) => ({ id: c.id, phone: c.phone, label: c.label, position: c.position })),
    lastVisitAt: s.lastVisitAt?.toISOString() ?? null,
    nextDueAt: s.nextDueAt?.toISOString() ?? null,
    createdAt: s.createdAt.toISOString(),
    updatedAt: s.updatedAt.toISOString()
  }
}
