'use client'

import type { UseFormRegisterReturn } from 'react-hook-form'
import { z } from 'zod'
import { phoneInputProps, tmPhone } from './phone'

/**
 * Forms use react-hook-form with a zod schema per form and `mode: 'onChange'`: a field reports its error once the
 * user has changed it, and every field on Save. These helpers keep the schemas short.
 */

/** A required text field (trimmed). */
export const required = (message: string) => z.string().trim().min(1, message)

/** A Turkmen phone, sent in the stored form +993XXXXXXXX; `optional` allows an empty field (→ null). */
export function phone (kind: 'mobile' | 'any', messages: { required: string, invalid: string }, optional = false) {
  return z.string().trim()
    .refine((v) => (optional && v === '') || v !== '', messages.required)
    .refine((v) => v === '' || tmPhone(v, kind) != null, messages.invalid)
    .transform((v) => (v === '' ? null : tmPhone(v, kind)!))
}

/** A whole number typed in a text or number input, within [min, max]. */
export const int = (min: number, max: number, message: string) =>
  z.string().trim().refine((v) => /^\d+$/.test(v) && Number(v) >= min && Number(v) <= max, message).transform(Number)

/**
 * A cross-field rule (audit plan ≤ visit plan, password confirmation) that runs whenever the fields it reads are
 * valid on their own: zod skips object rules while any other field has an error, which would hide it.
 */
export function whenValid<T extends z.ZodObject> (_schema: T, keys: Array<keyof T['shape'] & string>) {
  return { when: (payload: z.core.ParsePayload) => !payload.issues.some((i) => keys.includes(i.path?.[0] as never)) }
}

/** register() for a phone input: formats as `+993 65 123456` while typing, then hands the value to the form. */
export function phoneField (field: UseFormRegisterReturn) {
  const format = phoneInputProps()
  return {
    ...format,
    ...field,
    onChange: async (e: React.ChangeEvent<HTMLInputElement>) => {
      format.onChange(e)
      await field.onChange(e)
    }
  }
}
