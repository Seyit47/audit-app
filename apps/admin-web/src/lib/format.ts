import { intlTag, pick, formatDate } from '@/lib/i18n'
import type { Locale } from './i18n'

const tag = intlTag

/** "Today, 10:42" / "2 min ago" / "12 days ago" (31:2307 LAST ACTIVITY). */
export function lastActivity (iso: string | null, locale: Locale, now = new Date()): string {
  if (iso == null) return '—'
  const at = new Date(iso)
  const mins = Math.round((now.getTime() - at.getTime()) / 60_000)
  // Browsers have no Turkmen relative times (see intlTag), so Turkmen spells them out: "5 minut öň", "3 gün öň".
  const ago = (n: number, unit: 'minute' | 'day') => locale === 'tk'
    ? `${n} ${unit === 'minute' ? 'minut' : 'gün'} öň`
    : new Intl.RelativeTimeFormat(tag(locale), { numeric: 'auto' }).format(-n, unit)
  if (mins < 1) return pick(locale, { ru: 'Только что', en: 'Just now', tk: 'Ýaňy' })
  if (mins < 60) return ago(mins, 'minute')
  const time = formatDate(locale, { hour: '2-digit', minute: '2-digit', hour12: false }, at)
  if (at.toDateString() === now.toDateString()) return `${pick(locale, { ru: 'Сегодня', en: 'Today', tk: 'Şu gün' })}, ${time}`
  const days = Math.round((startOfDay(now) - startOfDay(at)) / 86_400_000)
  if (days === 1) return `${pick(locale, { ru: 'Вчера', en: 'Yesterday', tk: 'Düýn' })}, ${time}`
  return ago(days, 'day')
}

const startOfDay = (d: Date) => new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime()

/** "+993 65 124582" → "65 124582" as in 31:2307. */
export const shortPhone = (phone: string) => phone.replace(/^\+993\s?/, '').replace(/^(\d{2})(\d+)$/, '$1 $2')

export const number = (n: number, locale: Locale) => new Intl.NumberFormat(tag(locale)).format(n)

/** 92.3 → "92.3%" ("92,3%" in Russian); null → "—". */
export const percent = (n: number | null, locale: Locale) => (n == null ? '—' : `${new Intl.NumberFormat(tag(locale), { maximumFractionDigits: 1 }).format(n)}%`)

/** YYYY-MM-DD in the browser's local time. */
export const isoDay = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`

/** Turkmen numbers as in the frames: "+993 12 94-20-11". Other numbers are returned unchanged. */
export function formatPhone (phone: string): string {
  const d = phone.replace(/\D/g, '')
  const m = /^993(\d{2})(\d{2})(\d{2})(\d{2})$/.exec(d)
  return m == null ? phone : `+993 ${m[1]} ${m[2]}-${m[3]}-${m[4]}`
}
