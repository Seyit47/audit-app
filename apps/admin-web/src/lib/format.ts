import type { Locale } from './i18n'

const tag = (l: Locale) => (l === 'ru' ? 'ru-RU' : 'en-US')

/** "Today, 10:42" / "2 min ago" / "12 days ago" (31:2307 LAST ACTIVITY). */
export function lastActivity (iso: string | null, locale: Locale, now = new Date()): string {
  if (iso == null) return '—'
  const at = new Date(iso)
  const mins = Math.round((now.getTime() - at.getTime()) / 60_000)
  const rel = new Intl.RelativeTimeFormat(tag(locale), { numeric: 'auto' })
  if (mins < 1) return locale === 'ru' ? 'Только что' : 'Just now'
  if (mins < 60) return rel.format(-mins, 'minute')
  const time = new Intl.DateTimeFormat(tag(locale), { hour: '2-digit', minute: '2-digit', hour12: false }).format(at)
  if (at.toDateString() === now.toDateString()) return `${locale === 'ru' ? 'Сегодня' : 'Today'}, ${time}`
  const days = Math.round((startOfDay(now) - startOfDay(at)) / 86_400_000)
  if (days === 1) return `${locale === 'ru' ? 'Вчера' : 'Yesterday'}, ${time}`
  return rel.format(-days, 'day')
}

const startOfDay = (d: Date) => new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime()

/** "+993 65 124582" → "65 124582" as in 31:2307. */
export const shortPhone = (phone: string) => phone.replace(/^\+993\s?/, '').replace(/^(\d{2})(\d+)$/, '$1 $2')

export const number = (n: number, locale: Locale) => new Intl.NumberFormat(tag(locale)).format(n)

/** YYYY-MM-DD in the browser's local time. */
export const isoDay = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
