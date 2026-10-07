import 'server-only'
import { api, type CursorPage, type Page } from '@/lib/api'
import type { Image, Region } from '@/features/agents/api'

export type ShopStatus = 'PENDING_REVIEW' | 'ACTIVE' | 'INACTIVE'

export interface Shop {
  id: string
  code: string
  name: string
  type: string
  address: string
  addressDetail: string | null
  region: Region | null
  lat: number
  lng: number
  auditRadiusM: number
  ownerName: string | null
  status: ShopStatus
  version: number
  facade: Image | null
  agent: { id: string, fullName: string, code: string, phone: string } | null
  contacts: Array<{ id: string, phone: string, label: string | null, position: number }>
  lastVisitAt: string | null
  nextDueAt: string | null
  createdAt: string
  updatedAt: string
}

export interface ShopRow extends Shop { lastVisit: { at: string, agentName: string } | null }

export interface ShopDetails extends Shop {
  kpis: { totalAudits: number, lastAuditAt: string | null, productsCarried: number, compliancePct: number | null, auditPhotos: number, geotaggedPct: number | null }
}

export type Visit =
  | { type: 'AUDIT', id: string, at: string, startedAt: string, durationMin: number, agent: { id: string, fullName: string }, comment: string, hasViolation: boolean, withinRadius: boolean, photoCount: number, photos: Image[] }
  | { type: 'MISSED', id: string, at: string, agent: { id: string, fullName: string } }

export interface ShopListQuery { page?: number, size?: number, q?: string, status?: ShopStatus, regionId?: string, agentId?: string, sort?: string, dir?: 'asc' | 'desc' }

export const listShops = (query: ShopListQuery) => api<Page<ShopRow>>('/v1/shops', { query: { ...query } })
export const getShop = (id: string) => api<ShopDetails>(`/v1/shops/${id}`)
export const getVisits = (id: string, cursor?: string) =>
  api<CursorPage<Visit> & { totals: { all: number, completed: number, missed: number } }>(`/v1/shops/${id}/visits`, { query: { cursor, limit: 20 } })
export const listAgentOptions = () => api<Page<{ id: string, fullName: string, code: string, active: boolean }>>('/v1/agents', { query: { size: 100, sort: 'fullName' } })
export const getShopProducts = (id: string) => api<{ productIds: string[] }>(`/v1/shops/${id}/products`)
export const listProductOptions = () => api<Page<{ id: string, name: string, sku: string, status: string }>>('/v1/products', { query: { size: 100, status: 'ACTIVE' } })
