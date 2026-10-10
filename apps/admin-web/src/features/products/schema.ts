import { z } from 'zod'
import { required } from '@/lib/form'
import type { ProductsCopy } from './copy'

type FormCopy = ProductsCopy['form']

/** A stock count: empty (keeps 0) or a whole number ≥ 0. */
const count = (message: string) => z.string().trim().refine((v) => v === '' || /^\d+$/.test(v), message).transform((v) => (v === '' ? 0 : Number(v)))

/** Add / edit product (495:2311). */
export function productSchema (f: FormCopy) {
  return z.object({
    name: required(f.errors.field),
    sku: required(f.errors.field),
    categoryId: required(f.errors.field),
    brand: z.string().trim().transform((v) => v || null),
    description: z.string().trim().transform((v) => v || null),
    retailPrice: required(f.errors.field).regex(/^\d+([.,]\d{1,2})?$/, f.errors.price).transform((v) => Number(v.replace(',', '.'))),
    status: z.enum(['ACTIVE', 'DRAFT', 'INACTIVE']),
    stockTracked: z.boolean(),
    stockQty: count(f.errors.count),
    minStockAlert: count(f.errors.count)
  })
}
export type ProductValues = z.input<ReturnType<typeof productSchema>>
