import { createParser, parseAsArrayOf, parseAsStringLiteral } from 'nuqs/server'

// URL search params are user input: anything the API would reject parses as "not set", so a hand-edited or stale
// link shows the default view instead of an error page. Each page declares its params once with these parsers;
// the server page reads them with nuqs' createLoader and toolbars update them with useListParams.

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

const string = (parse: (v: string) => string | null) => createParser({ parse, serialize: (v: string) => v })

export const parseAsUuid = string((v) => (UUID.test(v) ? v : null))

/** Comma-separated ids (`?agents=a,b`); invalid entries are dropped. */
export const parseAsUuids = parseAsArrayOf(parseAsUuid, ',')

/** `YYYY-MM-DD` that is a real calendar day. */
export const parseAsDay = string((v) => {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(v)) return null
  const d = new Date(`${v}T00:00:00Z`)
  return !Number.isNaN(d.getTime()) && d.toISOString().startsWith(v) ? v : null
})

/** Search text the API accepts (≤ 100 chars). */
export const parseAsText = string((v) => (v.trim() === '' ? null : v.slice(0, 100)))

/** A whole number within [min, max]. */
export const parseAsIntIn = (min: number, max: number) => createParser({
  parse: (v: string) => { const n = Number(v); return Number.isInteger(n) && n >= min && n <= max ? n : null },
  serialize: (n: number) => String(n)
})

/** `?page=&size=` of the paginated lists. */
export const pageParams = {
  page: parseAsIntIn(1, Number.MAX_SAFE_INTEGER).withDefault(1),
  size: parseAsIntIn(1, 100).withDefault(10)
}

export const literal = <T extends string>(values: readonly T[]) => parseAsStringLiteral(values)

/** A valid day range; a reversed range is swapped. */
export function dayRange (from: string | null, to: string | null) {
  return from != null && to != null && from > to ? { from: to, to: from } : { from: from ?? undefined, to: to ?? undefined }
}
