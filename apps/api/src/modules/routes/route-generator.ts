import { distanceM } from '../../lib/geo.js'

export interface Point { lat: number, lng: number }

/** Total travel length from `start` through `stops` in order, in metres. */
export function pathLength (start: Point, stops: Point[]): number {
  let total = 0
  let at = start
  for (const s of stops) { total += distanceM(at, s); at = s }
  return total
}

/** Nearest-neighbour from `start`, then 2-opt until no swap shortens the path (research R-08). */
export function orderStops<T extends Point> (start: Point, stops: T[]): T[] {
  const left = [...stops]
  const route: T[] = []
  let at: Point = start
  while (left.length > 0) {
    let best = 0
    for (let i = 1; i < left.length; i++) if (distanceM(at, left[i]!) < distanceM(at, left[best]!)) best = i
    at = left[best]!
    route.push(...left.splice(best, 1))
  }
  // 2-opt on an open path: reverse route[i..j] when that shortens it.
  let improved = true
  while (improved) {
    improved = false
    for (let i = 0; i < route.length - 1; i++) {
      for (let j = i + 1; j < route.length; j++) {
        const before = i === 0 ? start : route[i - 1]!
        const after = route[j + 1]
        const current = distanceM(before, route[i]!) + (after ? distanceM(route[j]!, after) : 0)
        const swapped = distanceM(before, route[j]!) + (after ? distanceM(route[i]!, after) : 0)
        if (swapped + 1e-6 < current) {
          route.splice(i, j - i + 1, ...route.slice(i, j + 1).reverse())
          improved = true
        }
      }
    }
  }
  // Nearest-neighbour + 2-opt is a heuristic: keep the input order when it is shorter.
  return pathLength(start, route) <= pathLength(start, stops) ? route : [...stops]
}
