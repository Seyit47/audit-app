import { createLoader } from 'nuqs/server'
import { literal, parseAsText, parseAsUuid } from '@/lib/search-params'

/** /pictures URL params. */
export const picturesParams = {
  regionId: parseAsUuid,
  verified: literal(['true', 'false'] as const),
  date: literal(['today', '7', '30', 'all'] as const).withDefault('7'),
  shopId: parseAsUuid,
  agentId: parseAsUuid,
  q: parseAsText,
  mode: literal(['grid', 'byDate'] as const).withDefault('grid'),
  photo: parseAsUuid
}
export const loadPicturesParams = createLoader(picturesParams)
