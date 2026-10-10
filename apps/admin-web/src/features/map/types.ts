import type { GalleryPhoto } from '@/features/photos/types'
import type { ShopDetails, Visit } from '@/features/shops/api'

export interface MapShop {
  id: string
  code: string
  name: string
  address: string
  lat: number
  lng: number
  auditRadiusM: number
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

/** Users/Shops (788:2352): what the map shows. */
export type MapShow = 'both' | 'agents' | 'shops'
/** Status (791:2406), day-based: visited today, not visited yet today, visited in the last 7 days. */
export type MapVisitStatus = 'all' | 'visited' | 'not_visited' | 'recent'
export interface MapFilterState { agentIds: string[], regionIds: string[], show: MapShow, status: MapVisitStatus }

export interface ShopCardData {
  shop: ShopDetails
  visits: Visit[]
  totals: { all: number, completed: number, missed: number }
  photos: GalleryPhoto[]
}
