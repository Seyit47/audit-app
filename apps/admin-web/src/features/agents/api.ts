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

export interface AgentDetails extends Agent {
  online: boolean
  kpis: { audits: number, assignedShops: number, visitedShops: number, photos: number }
}

export type StopStatus = 'PLANNED' | 'IN_PROGRESS' | 'DONE' | 'MISSED'

export interface TimelineStop {
  id: string
  status: StopStatus
  plannedAt: string
  isAuditTask: boolean
  shop: { id: string, name: string, code: string, lat: number, lng: number }
  photoCount: number
  audit: { id: string, startedAt: string, finishedAt: string, durationMin: number } | null
}

export interface AgentTrack {
  points: Array<{ lat: number, lng: number, recordedAt: string, trigger: string }>
  checkpoints: Array<{ id: string, status: StopStatus, lat: number, lng: number, name: string, at: string }>
  current: { lat: number, lng: number, accuracyM: number, recordedAt: string } | null
}

type VisitShop = { id: string, name: string, code: string, address: string }
export type AgentVisit =
  | { type: 'AUDIT', id: string, at: string, startedAt: string, durationMin: number, shop: VisitShop, comment: string, hasViolation: boolean, photoCount: number, photos: Image[] }
  | { type: 'MISSED', id: string, at: string, shop: VisitShop }

export interface AgentVisits { items: AgentVisit[], nextCursor: string | null, totals: { all: number, completed: number, missed: number } }

export const getAgentDetails = (id: string, from?: string, to?: string) => api<AgentDetails>(`/v1/agents/${id}`, { query: { from, to } })
export const getTimeline = (id: string, date?: string) => api<TimelineStop[]>(`/v1/agents/${id}/timeline`, { query: { date } })
export const getTrack = (id: string, date?: string) => api<AgentTrack>(`/v1/agents/${id}/track`, { query: { date } })
export const getAgentVisits = (id: string, cursor?: string) => api<AgentVisits>(`/v1/agents/${id}/visits`, { query: { cursor } })
