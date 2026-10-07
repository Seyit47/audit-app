// SC-005 bench: first pages of the admin lists against a loaded database (`prisma/seed-load.ts`).
// `DATABASE_URL=… pnpm bench` prints the median of 5 runs per endpoint; the target is < 2 s.
import 'dotenv/config'
import helper from 'fastify-cli/helper.js'
import * as path from 'node:path'
import { fileURLToPath } from 'node:url'
import { options } from '../src/app.js'

process.env.JOBS_DISABLED = '1'
const appPath = path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'src', 'app.ts')
const app = await helper.build([appPath], { skipOverride: true }, { ...options, logger: false })
await app.ready()
const admin = await app.prisma.user.findFirstOrThrow({ where: { role: 'ADMIN' } })
const headers = { authorization: `Bearer ${app.jwt.sign({ sub: admin.id, role: 'ADMIN' })}` }
const agent = await app.prisma.agent.findFirstOrThrow()
const shop = await app.prisma.shop.findFirstOrThrow()
const urls = [
  '/v1/shops?page=1&size=10', '/v1/shops?page=1&size=10&q=Shop%2099', '/v1/shops?page=1&size=10&sort=lastVisitAt&dir=desc',
  '/v1/agents?page=1&size=10', '/v1/agents/summary', `/v1/agents/${agent.userId}`, `/v1/agents/${agent.userId}/visits`,
  '/v1/photos?limit=24', '/v1/photos?limit=24&groups=true', '/v1/photos/summary', `/v1/shops/${shop.id}`, `/v1/shops/${shop.id}/visits`,
  '/v1/products?page=1&size=10', '/v1/feed', '/v1/shops/map'
]
let worst = 0
for (const url of urls) {
  const times: number[] = []
  for (let i = 0; i < 5; i++) {
    const t = performance.now()
    const res = await app.inject({ url, headers })
    times.push(performance.now() - t)
    if (res.statusCode !== 200) throw new Error(`${url} → ${res.statusCode} ${res.body.slice(0, 200)}`)
  }
  const median = times.sort((a, b) => a - b)[2]
  worst = Math.max(worst, median)
  console.log(`${median.toFixed(0).padStart(6)} ms  ${url}`)
}
console.log(`worst median ${worst.toFixed(0)} ms (${worst < 2000 ? 'OK' : 'OVER'} the 2 s target)`)
await app.close()
