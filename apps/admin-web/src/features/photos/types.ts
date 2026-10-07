import type { Image } from '@/features/agents/api'

export interface GalleryPhoto extends Image {
  kind: 'AUDIT' | 'FACADE' | 'ADMIN_UPLOAD'
  verified: boolean
  auditId: string | null
  shop: { id: string, name: string, code: string, address: string } | null
  agent: { id: string, fullName: string, code: string, phone: string } | null
}

export interface PhotoDetail extends GalleryPhoto {
  lat: number | null
  lng: number | null
  accuracyM: number | null
  shop: (GalleryPhoto['shop'] & { status: string, lat: number, lng: number, facade: Image | null, phone: string | null, agent: { id: string, fullName: string, phone: string } | null }) | null
  audit: { id: string, comment: string, hasViolation: boolean, startedAt: string, finishedAt: string, durationMin: number, withinRadius: boolean } | null
  related: GalleryPhoto[]
}

export interface GalleryQuery {
  type?: string
  regionId?: string
  verified?: string
  from?: string
  agentId?: string
  shopId?: string
  q?: string
}

export interface GalleryPage { items: GalleryPhoto[], nextCursor: string | null, groups?: Array<{ date: string, count: number }> }
