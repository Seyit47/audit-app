import { test, before, after } from 'node:test'
import * as assert from 'node:assert'
import { createServer, type Server } from 'node:http'
import type { AddressInfo } from 'node:net'
import type { FastifyInstance } from 'fastify'
import { build } from '../helper.js'
import { bearer } from '../helpers/auth.js'
import { resetDb } from '../helpers/db.js'
import * as f from '../helpers/factories.js'

// A stand-in GraphHopper: a route for points in Ashgabat, 400 (point not found) for anything else.
let routing: Server
let seen: URL | undefined
let app: FastifyInstance
let h: Record<string, string>

before(async (t) => {
  routing = createServer((req, res) => {
    seen = new URL(req.url!, 'http://x')
    const [lat] = seen.searchParams.getAll('point')[0].split(',').map(Number)
    res.setHeader('content-type', 'application/json')
    if (lat > 30) {
      res.end(JSON.stringify({ paths: [{ distance: 1234.4, time: 185_600, points: { coordinates: [[58.38, 37.95], [58.39, 37.96]] } }] }))
    } else {
      res.statusCode = 400
      res.end(JSON.stringify({ message: 'Cannot find point 0: 1.0,1.0' }))
    }
  })
  await new Promise<void>((resolve) => routing.listen(0, '127.0.0.1', resolve))
  process.env.ROUTING_URL = `http://127.0.0.1:${(routing.address() as AddressInfo).port}/`
  app = await build(t as never)
  await resetDb(app)
  const g = await f.agent(app)
  h = bearer(app, { id: g.userId, role: 'AGENT' })
})
after(() => { routing.close() })

test('directions: the road route as [lat, lng] points with its length and time', async () => {
  const res = await app.inject({ url: '/v1/directions?fromLat=37.95&fromLng=58.38&toLat=37.96&toLng=58.39', headers: h })
  assert.strictEqual(res.statusCode, 200, res.body)
  assert.deepStrictEqual(res.json(), { distanceM: 1234, durationS: 186, points: [[37.95, 58.38], [37.96, 58.39]] })
  assert.deepStrictEqual(seen?.searchParams.getAll('point'), ['37.95,58.38', '37.96,58.39'])
  assert.strictEqual(seen?.searchParams.get('profile'), 'car')

  const none = await app.inject({ url: '/v1/directions?fromLat=1&fromLng=1&toLat=37.96&toLng=58.39', headers: h })
  assert.strictEqual(none.statusCode, 422)
  assert.strictEqual(none.json().error.code, 'NO_ROUTE')
  assert.strictEqual((await app.inject({ url: '/v1/directions?fromLat=37.95&fromLng=58.38&toLat=37.96&toLng=58.39' })).statusCode, 401)
})

test('directions: 503 when the routing service is down', async () => {
  routing.closeAllConnections()
  await new Promise<void>((resolve) => routing.close(() => resolve()))
  const res = await app.inject({ url: '/v1/directions?fromLat=37.95&fromLng=58.38&toLat=37.96&toLng=58.39', headers: h })
  assert.strictEqual(res.statusCode, 503)
  assert.strictEqual(res.json().error.code, 'ROUTING_UNAVAILABLE')
})
