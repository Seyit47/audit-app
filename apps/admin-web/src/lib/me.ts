import 'server-only'
import { cache } from 'react'
import { api } from './api'

export interface Me {
  user: { id: string, role: 'ADMIN' | 'AGENT', email: string | null }
  config: { companyName: string, logo: { url: string, previewUrl400: string | null } | null }
}

/** The signed-in user and company config, fetched once per request. */
export const getMe = cache(() => api<Me>('/v1/me'))
