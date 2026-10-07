import type { Image } from '@/features/agents/api'

type Ref = { id: string, name: string, code: string, address: string }
type AgentRef = { id: string, fullName: string, code: string }

export type FeedItem =
  | { type: 'VIOLATION', id: string, at: string, shop: Ref, agent: AgentRef, comment: string, photos: Image[] }
  | { type: 'MISSED_VISIT', id: string, at: string, shop: Ref, agent: AgentRef }

export interface FeedPage { items: FeedItem[], nextCursor: string | null, unreadCount: number }
