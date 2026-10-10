import { createLoader } from 'nuqs/server'
import { literal, pageParams, parseAsText } from '@/lib/search-params'

/** /products URL params. */
export const productsParams = {
  ...pageParams,
  q: parseAsText,
  status: literal(['ACTIVE', 'DRAFT', 'INACTIVE'] as const)
}
export const loadProductsParams = createLoader(productsParams)
