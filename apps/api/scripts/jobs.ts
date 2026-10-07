// Operator CLI: run a route job now. Usage: pnpm job:routes [YYYY-MM-DD] | pnpm job:end-of-day [YYYY-MM-DD]
import 'dotenv/config'
import helper from 'fastify-cli/helper.js'
import * as path from 'node:path'
import { fileURLToPath } from 'node:url'
import { options } from '../src/app.js'

process.env.JOBS_DISABLED = '1'
const [job, day] = process.argv.slice(2)
// skipOverride exposes the app's decorators (services) to this script, as in the tests.
const appPath = path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'src', 'app.ts')
const fastify = await helper.build([appPath], { skipOverride: true }, { ...options, logger: false })
await fastify.ready()
const result = job === 'end-of-day' ? await fastify.services.routes.endOfDay(day) : await fastify.services.routes.generateAll(day)
console.log(JSON.stringify(result))
await fastify.close()
