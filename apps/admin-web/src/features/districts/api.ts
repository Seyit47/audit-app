import 'server-only'
import { api } from '@/lib/api'

/**
 * A district card: its shops, the agents working them, and today's visited and overdue shops. The last entry has
 * no id: the shops without a district (from before districts).
 */
export interface District { id: string | null, name: string | null, shops: number, agents: number, visitedToday: number, overdue: number }

export const listDistricts = () => api<District[]>('/v1/districts')

/** Districts that can be chosen (not the "no district" entry). */
export const districtOptions = async () => (await listDistricts()).filter((d): d is District & { id: string, name: string } => d.id != null)
