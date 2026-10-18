import { Type } from '@sinclair/typebox'
import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { AppError } from '../../../lib/app-error.js'

const Lat = Type.Number({ minimum: -90, maximum: 90 })
const Lng = Type.Number({ minimum: -180, maximum: 180 })
const Query = Type.Object({
  fromLat: Lat,
  fromLng: Lng,
  toLat: Lat,
  toLng: Lng
})

interface GraphHopperRoute { paths?: Array<{ distance: number, time: number, points: { coordinates: Array<[number, number]> } }>, message?: string }

/** Directions from the agent to a shop along the roads: GraphHopper's car route as `[lat, lng]` points, its length and time. */
const directions: FastifyPluginAsyncTypebox = async (fastify) => {
  fastify.get('/', { schema: { querystring: Query, tags: ['directions'] }, config: { auth: 'ANY' } }, async (req) => {
    const q = req.query
    const url = new URL(`${fastify.config.routingUrl}/route`)
    url.searchParams.append('point', `${q.fromLat},${q.fromLng}`)
    url.searchParams.append('point', `${q.toLat},${q.toLng}`)
    url.searchParams.set('profile', 'car')
    url.searchParams.set('points_encoded', 'false')
    url.searchParams.set('instructions', 'false')
    let res: Response
    try {
      res = await fetch(url, { signal: AbortSignal.timeout(10_000) })
    } catch (err) {
      req.log.warn({ err }, 'routing unavailable')
      throw new AppError(503, 'ROUTING_UNAVAILABLE', 'Directions are unavailable right now')
    }
    const body = await res.json().catch(() => ({})) as GraphHopperRoute
    const path = body.paths?.[0]
    // GraphHopper answers 400 when a point is off the road network (or outside the map).
    if (res.status === 400 || (res.ok && path == null)) throw new AppError(422, 'NO_ROUTE', body.message ?? 'No route between these points')
    if (!res.ok || path == null) {
      req.log.warn({ status: res.status, message: body.message }, 'routing failed')
      throw new AppError(503, 'ROUTING_UNAVAILABLE', 'Directions are unavailable right now')
    }
    return {
      distanceM: Math.round(path.distance),
      durationS: Math.round(path.time / 1000),
      points: path.points.coordinates.map(([lng, lat]) => [lat, lng])
    }
  })
}
export default directions
