export interface Page<T> { items: T[], total: number, page: number, size: number }
export interface CursorPage<T> { items: T[], nextCursor: string | null }

export function pageArgs (page = 1, size = 10): { skip: number, take: number, page: number, size: number } {
  const p = Math.max(1, Math.floor(page))
  const s = Math.min(100, Math.max(1, Math.floor(size)))
  return { skip: (p - 1) * s, take: s, page: p, size: s }
}

/** Opaque cursor over (date desc, id desc). */
export const encodeCursor = (at: Date, id: string): string => Buffer.from(`${at.toISOString()}|${id}`).toString('base64url')
export function decodeCursor (cursor?: string): { at: Date, id: string } | null {
  if (!cursor) return null
  const [iso, id] = Buffer.from(cursor, 'base64url').toString().split('|')
  if (!iso || !id) return null
  return { at: new Date(iso), id }
}
