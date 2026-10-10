import { z } from 'zod'
import { phone, required } from '@/lib/form'
import type { ShopFormCopy } from './copy'

/** Add / edit shop (162:20071). Contacts are Turkmen mobile or landline numbers; empty rows are dropped. */
export function shopSchema (copy: ShopFormCopy) {
  return z.object({
    name: required(copy.errors.field),
    address: required(copy.errors.field),
    agentId: z.string().transform((v) => v || null),
    point: z.object({ lat: z.number(), lng: z.number() }).nullable().refine((v) => v != null, copy.errors.location),
    productIds: z.array(z.string()),
    facadePhotoId: z.string().nullable(),
    phones: z.array(z.object({
      phone: phone('any', { required: copy.errors.field, invalid: copy.errors.phoneShort }, true),
      label: z.string().trim().transform((v) => v || null)
    }))
  })
}
export type ShopValues = z.input<ReturnType<typeof shopSchema>>
