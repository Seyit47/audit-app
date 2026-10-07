import type { GalleryPhoto } from '@/features/photos/types'
import type { ShopDetails, Visit } from '@/features/shops/api'

export interface MapShop {
  id: string
  code: string
  name: string
  address: string
  lat: number
  lng: number
  status: 'PENDING_REVIEW' | 'ACTIVE' | 'INACTIVE'
  agentId: string | null
  regionId: string | null
  visitState: string
  lastVisitAt: string | null
  thumbUrl: string | null
}

export interface AgentPosition {
  agentId: string
  fullName: string
  code: string
  regionId: string
  lat: number
  lng: number
  accuracyM: number
  speedKmh: number | null
  batteryPct: number | null
  recordedAt: string
}

export interface MapFilterState { agentIds: string[], regionIds: string[] }

export interface ShopCardData {
  shop: ShopDetails
  visits: Visit[]
  totals: { all: number, completed: number, missed: number }
  photos: GalleryPhoto[]
}
