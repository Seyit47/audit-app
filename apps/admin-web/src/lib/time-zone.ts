/**
 * Every date on the admin web is shown in the company's time zone (Settings → time zone, sent by /v1/me),
 * not the zone of the machine rendering it: the server may run in UTC (Vercel) and an admin's laptop may be
 * set to anything. The admin layout sets it once per request on the server and once on the client.
 */
let current = 'Asia/Ashgabat'

export const displayTimeZone = () => current

export function setDisplayTimeZone (tz: string | undefined) {
  if (tz != null && tz !== '') current = tz
}

const dayFormat = (tz: string) => new Intl.DateTimeFormat('en-CA', { timeZone: tz, year: 'numeric', month: '2-digit', day: '2-digit' })

/** `YYYY-MM-DD` of an instant in the company time zone (today by default). */
export const isoDay = (d: Date = new Date(), tz = current) => dayFormat(tz).format(d)

/** Whether an instant falls on the company's "today". */
export const isToday = (d: Date | string, now = new Date()) => isoDay(new Date(d)) === isoDay(now)

/** Calendar days from `a` to `b` in the company time zone (positive when `b` is later). */
export const daysBetween = (a: Date, b: Date) => Math.round((Date.parse(`${isoDay(b)}T00:00:00Z`) - Date.parse(`${isoDay(a)}T00:00:00Z`)) / 86_400_000)

/** `YYYY-MM-DD` moved by `n` days. */
export function shiftDay (day: string, n: number): string {
  const d = new Date(`${day}T00:00:00Z`)
  d.setUTCDate(d.getUTCDate() + n)
  return d.toISOString().slice(0, 10)
}

/** Monday (0) … Sunday (6) of a `YYYY-MM-DD`. */
export const weekdayOf = (day: string) => (new Date(`${day}T00:00:00Z`).getUTCDay() + 6) % 7

/** The instant a company-local calendar day starts (as the API computes it). */
export function startOfDay (day: string, tz = current): Date {
  const guess = new Date(`${day}T00:00:00Z`)
  const parts = new Intl.DateTimeFormat('en-CA', { timeZone: tz, year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit', hourCycle: 'h23' }).formatToParts(guess)
  const get = (t: string) => parts.find((p) => p.type === t)!.value
  const asUtc = Date.parse(`${get('year')}-${get('month')}-${get('day')}T${get('hour')}:${get('minute')}:${get('second')}Z`)
  return new Date(guess.getTime() - (asUtc - guess.getTime()))
}
