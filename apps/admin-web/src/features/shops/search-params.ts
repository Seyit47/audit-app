import { createLoader } from 'nuqs/server'
import { literal, pageParams, parseAsText, parseAsUuid } from '@/lib/search-params'

/** /shops URL params. */
export const shopsParams = {
  ...pageParams,
  q: parseAsText,
  status: literal(['ACTIVE', 'INACTIVE', 'PENDING_REVIEW'] as const),
  regionId: parseAsUuid,
  agentId: parseAsUuid
}
export const loadShopsParams = createLoader(shopsParams)
