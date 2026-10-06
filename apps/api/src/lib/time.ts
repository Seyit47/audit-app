/** Company-local calendar date (YYYY-MM-DD) for an instant. */
export function localDate (at: Date, timezone: string): string {
  return new Intl.DateTimeFormat('en-CA', { timeZone: timezone, year: 'numeric', month: '2-digit', day: '2-digit' }).format(at)
}

/** Minutes since local midnight for an instant. */
export function localMinutes (at: Date, timezone: string): number {
  const parts = new Intl.DateTimeFormat('en-GB', { timeZone: timezone, hour: '2-digit', minute: '2-digit', hourCycle: 'h23' }).formatToParts(at)
  const get = (t: string) => Number(parts.find((p) => p.type === t)?.value ?? 0)
  return get('hour') * 60 + get('minute')
}

const toMinutes = (hhmm: string): number => { const [h, m] = hhmm.split(':').map(Number); return h! * 60 + m! }

/** Whether an instant falls inside working hours (inclusive start, exclusive end). */
export function isWithinWorkingHours (at: Date, s: { workStart: string, workEnd: string, timezone: string }): boolean {
  const m = localMinutes(at, s.timezone)
  return m >= toMinutes(s.workStart) && m < toMinutes(s.workEnd)
}

/** The instant a company-local calendar date (YYYY-MM-DD) starts. */
export function startOfLocalDay (date: string, timezone: string): Date {
  const guess = new Date(`${date}T00:00:00Z`)
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone: timezone, year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit', hourCycle: 'h23'
  }).formatToParts(guess)
  const get = (t: string) => parts.find((p) => p.type === t)!.value
  const asUtc = Date.parse(`${get('year')}-${get('month')}-${get('day')}T${get('hour')}:${get('minute')}:${get('second')}Z`)
  return new Date(guess.getTime() - (asUtc - guess.getTime()))
}
