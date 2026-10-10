import { createLoader } from 'nuqs/server'
import { literal, pageParams, parseAsDay, parseAsText, parseAsUuid } from '@/lib/search-params'

/** The salesman period (Дата от / Дата до and presets), on /salesmen and a salesman's page. */
export const periodParams = {
  from: parseAsDay,
  to: parseAsDay,
  // Present so a period change also returns the list to its first page.
  page: pageParams.page
}

/** /salesmen URL params. */
export const agentsParams = {
  ...pageParams,
  ...periodParams,
  q: parseAsText,
  status: literal(['ACTIVE', 'ON_LEAVE', 'INACTIVE'] as const),
  regionId: parseAsUuid,
  sort: literal(['fullName', 'code', 'locations', 'visits', 'photos', 'lastActivityAt'] as const).withDefault('code'),
  dir: literal(['asc', 'desc'] as const).withDefault('asc')
}
export const loadAgentsParams = createLoader(agentsParams)
export const loadPeriodParams = createLoader(periodParams)
