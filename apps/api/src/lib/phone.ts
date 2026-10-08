import { AppError } from './app-error.js'

// Turkmen numbers: +993 and an 8-digit national number. Mobile (TMCell / Altyn Asyr): 6X, 71, 72;
// landlines: a regional code starting 1–5 (Ashgabat 12).
const MOBILE = /^(6\d|7[12])\d{6}$/
const ANY = /^[1-7]\d{7}$/

/** The 8-digit national number from `+993 65 123456`, `993…`, `8 65 123456` (domestic) or `65 123456`. */
export function tmNationalNumber (input: string): string | null {
  let d = input.replace(/[\s().-]/g, '')
  if (d.startsWith('+993')) d = d.slice(4)
  else if (d.startsWith('993') && d.length === 11) d = d.slice(3)
  else if (d.startsWith('8') && d.length === 9) d = d.slice(1)
  return /^\d{8}$/.test(d) ? d : null
}

/** `+993XXXXXXXX`, or null when it is not a Turkmen number of the required kind. */
export function tmPhone (input: string, kind: 'mobile' | 'any'): string | null {
  const n = tmNationalNumber(input)
  return n != null && (kind === 'mobile' ? MOBILE : ANY).test(n) ? `+993${n}` : null
}

/** Canonical number, or a 400 VALIDATION_FAILED naming the field. */
export function requireTmPhone (input: string, kind: 'mobile' | 'any', field: string): string {
  const phone = tmPhone(input, kind)
  if (phone == null) {
    const expected = kind === 'mobile' ? 'a Turkmen mobile number (+993 6X XXXXXX or 71/72)' : 'a Turkmen phone number (+993 and 8 digits)'
    throw new AppError(400, 'VALIDATION_FAILED', `${field} must be ${expected}`, [{ field: `/${field}`, message: `must be ${expected}` }])
  }
  return phone
}
