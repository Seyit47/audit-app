import 'server-only'
import { api, type Page } from '@/lib/api'

export interface Image { id: string, url: string, previewUrl400: string, previewUrl1200: string, width: number | null, height: number | null, takenAt: string }
export interface Region { id: string, name: string }
export type WorkStatus = 'ACTIVE' | 'ON_LEAVE'

export interface AgentRow {
  id: string
  code: string
  fullName: string
  phone: string
  photo: Image | null
  region: Region
  locations: number
  visits: number
  photos: number
  lastActivityAt: string | null
  workStatus: WorkStatus
  active: boolean
  onRoute: boolean
  needsContact: boolean
  topPerformer: boolean
}

export interface Agent {
  id: string
  code: string
  fullName: string
  phone: string
  whatsappPhone: string | null
  photo: Image | null
  region: Region
  routeNotes: string | null
  dailyVisitPlan: number
  dailyAuditPlan: number
  workStatus: WorkStatus
  active: boolean
  version: number
  device: { model: string | null, imeiLabel: string | null, boundAt: string | null } | null
  position: { lat: number, lng: number, accuracyM: number, speedKmh: number | null, batteryPct: number | null, recordedAt: string } | null
}

export interface AgentListQuery {
  page?: number
  size?: number
  q?: string
  status?: 'ACTIVE' | 'ON_LEAVE' | 'INACTIVE'
  regionId?: string
  from?: string
  to?: string
  sort?: string
  dir?: 'asc' | 'desc'
}

export const listAgents = (query: AgentListQuery) => api<Page<AgentRow>>('/v1/agents', { query: { ...query } })
export const getAgent = (id: string) => api<Agent>(`/v1/agents/${id}`)
export const listRegions = () => api<Region[]>('/v1/regions')

export interface AgentsSummary {
  totalStaff: number
  activeStaff: number
  activePct: number | null
  onRoute: number
  onRoutePct: number | null
  audits: number
  auditsVsPlanPct: number | null
  shopsVisited: number
  shopsPlanned: number
  shopsRemaining: number
  photos: number
  photosVerifiedPct: number | null
  inactiveStaff: number
  needsContact: number
  noSignalMinutes: number
}

export const getAgentsSummary = (from?: string, to?: string) => api<AgentsSummary>('/v1/agents/summary', { query: { from, to } })
