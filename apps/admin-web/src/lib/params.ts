// URL search params are user input: anything the API would reject falls back to "not set",
// so a hand-edited or stale link shows the default view instead of an error page.

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export const uuid = (v: string | undefined) => (v != null && UUID.test(v) ? v : undefined)

export const uuids = (v: string | undefined) => (v ?? '').split(',').filter((x) => UUID.test(x))

export function int (v: string | undefined, fallback: number, min = 1, max = Number.MAX_SAFE_INTEGER) {
  const n = Number(v)
  return v != null && Number.isInteger(n) && n >= min && n <= max ? n : fallback
}

export function oneOf<T extends string> (v: string | undefined, allowed: readonly T[]): T | undefined {
  return allowed.includes(v as T) ? v as T : undefined
}

export const bool = (v: string | undefined) => (v === 'true' || v === 'false' ? v : undefined)

/** `YYYY-MM-DD` that is a real calendar day. */
export function day (v: string | undefined) {
  if (v == null || !/^\d{4}-\d{2}-\d{2}$/.test(v)) return undefined
  const d = new Date(`${v}T00:00:00Z`)
  return !Number.isNaN(d.getTime()) && d.toISOString().startsWith(v) ? v : undefined
}

/** A valid day range; a reversed range is swapped. */
export function range (from: string | undefined, to: string | undefined) {
  const f = day(from)
  const t = day(to)
  return f != null && t != null && f > t ? { from: t, to: f } : { from: f, to: t }
}

/** Search text the API accepts (≤ 100 chars). */
export const text = (v: string | undefined) => (v == null || v.trim() === '' ? undefined : v.slice(0, 100))
