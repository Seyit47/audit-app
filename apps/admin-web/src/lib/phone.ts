// Turkmen numbers, the same rules as the API (apps/api/src/lib/phone.ts): +993 and an 8-digit national
// number; mobile 6X, 71, 72; landlines start 1–5. Accepts +993…, 993…, 8… (domestic) or the bare 8 digits.
const MOBILE = /^(6\d|7[12])\d{6}$/
const ANY = /^[1-7]\d{7}$/

/** `+993XXXXXXXX`, or null when it is not a Turkmen number of the required kind. */
export function tmPhone (input: string, kind: 'mobile' | 'any'): string | null {
  let d = input.replace(/[\s().-]/g, '')
  if (d.startsWith('+993')) d = d.slice(4)
  else if (d.startsWith('993') && d.length === 11) d = d.slice(3)
  else if (d.startsWith('8') && d.length === 9) d = d.slice(1)
  return /^\d{8}$/.test(d) && (kind === 'mobile' ? MOBILE : ANY).test(d) ? `+993${d}` : null
}
