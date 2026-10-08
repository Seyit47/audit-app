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

const PREFIX = '+993 '

/** National digits typed so far, and how many leading digits were dialling prefixes (993, or the domestic 8). */
function national (text: string): [string, number] {
  const all = text.replace(/\D/g, '')
  let d = all
  for (;;) {
    if (d.startsWith('993')) d = d.slice(3)
    else if (d.startsWith('8')) d = d.slice(1)
    else break
  }
  return [d, all.length - d.length]
}

const format = (n: string) => n === '' ? '' : n.length <= 2 ? PREFIX + n : `${PREFIX}${n.slice(0, 2)} ${n.slice(2)}`

/** How a stored phone is shown in an input: `+993 65 123456`; anything else stays as it is. */
export function displayPhone (stored: string | null | undefined): string {
  if (stored == null) return ''
  return tmPhone(stored, 'any') == null ? stored : format(national(stored)[0])
}

/**
 * One edit of a phone input (same as the mobile TmPhoneFormatter): shows `+993 65 123456`, stops at the
 * 8th digit, and backspace steps over the spaces and the fixed `+993 `.
 */
export function formatPhoneEdit (before: string, text: string, cursor: number): { text: string, cursor: number } {
  const [oldNational] = national(before)
  const [typed, stripped] = national(text)
  let n = typed
  let at = Math.min(Math.max(text.slice(0, cursor).replace(/\D/g, '').length - stripped, 0), n.length)
  const deleting = text.length < before.length
  if (deleting && before.startsWith(PREFIX) && cursor < PREFIX.length && /\d/.test(text)) {
    n = oldNational
    at = 0
  } else if (deleting && n === oldNational && at > 0) {
    n = n.slice(0, at - 1) + n.slice(at)
    at--
  }
  if (n.length > 8) {
    if (oldNational.length >= 8) return { text: before, cursor: Math.max(cursor - (text.length - before.length), 0) }
    n = n.slice(0, 8)
    at = Math.min(at, 8)
  }
  const out = format(n)
  return { text: out, cursor: n === '' ? 0 : Math.min(PREFIX.length + at + (at > 2 ? 1 : 0), out.length) }
}

/** Props for a phone `<input>` (controlled or not): formats as you type; [onValue] gets the shown text. */
export function phoneInputProps (onValue?: (value: string) => void) {
  return {
    type: 'tel',
    inputMode: 'tel' as const,
    maxLength: 32,
    onFocus: (e: { currentTarget: HTMLInputElement }) => { e.currentTarget.dataset.prev = e.currentTarget.value },
    onChange: (e: { currentTarget: HTMLInputElement }) => {
      const el = e.currentTarget
      const next = formatPhoneEdit(el.dataset.prev ?? '', el.value, el.selectionStart ?? el.value.length)
      el.value = next.text
      el.setSelectionRange(next.cursor, next.cursor)
      el.dataset.prev = next.text
      onValue?.(next.text)
    }
  }
}
