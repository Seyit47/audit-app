type Point = [number, number]

const cross = (o: Point, a: Point, b: Point) => (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

/**
 * Convex hull (Andrew's monotone chain) as a closed GeoJSON ring. Regions have no stored polygon,
 * so a "region zone" is drawn around its shops. Fewer than 3 distinct points give no ring.
 */
export function hullRing (points: Point[]): Point[] | null {
  const pts = [...new Map(points.map((p) => [`${p[0]},${p[1]}`, p])).values()].sort((a, b) => a[0] - b[0] || a[1] - b[1])
  if (pts.length < 3) return null
  const lower: Point[] = []
  for (const p of pts) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower[lower.length - 1], p) <= 0) lower.pop()
    lower.push(p)
  }
  const upper: Point[] = []
  for (const p of [...pts].reverse()) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper[upper.length - 1], p) <= 0) upper.pop()
    upper.push(p)
  }
  const ring = [...lower.slice(0, -1), ...upper.slice(0, -1)]
  return ring.length < 3 ? null : [...ring, ring[0]]
}
