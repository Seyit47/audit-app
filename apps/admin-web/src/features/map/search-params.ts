import { createLoader } from 'nuqs/server'
import { literal, parseAsUuid, parseAsUuids } from '@/lib/search-params'

/** /map URL params: filters, ids from Shops "View on Map", the selected shop. */
export const mapParams = {
  agents: parseAsUuids.withDefault([]),
  regions: parseAsUuids.withDefault([]),
  ids: parseAsUuids.withDefault([]),
  show: literal(['both', 'agents', 'shops'] as const).withDefault('both'),
  status: literal(['all', 'visited', 'not_visited', 'recent'] as const).withDefault('all'),
  shop: parseAsUuid
}
export const loadMapParams = createLoader(mapParams)
