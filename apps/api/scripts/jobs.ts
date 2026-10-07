// Operator CLI: run a route job now. Usage: pnpm job:routes [YYYY-MM-DD] | pnpm job:end-of-day [YYYY-MM-DD]
import 'dotenv/config'
import Fastify from 'fastify'
import app, { options } from '../src/app.js'

process.env.JOBS_DISABLED = '1'
const [job, day] = process.argv.slice(2)
const fastify = Fastify({ ...options, logger: false })
await fastify.register(app)
await fastify.ready()
const result = job === 'end-of-day' ? await fastify.services.routes.endOfDay(day) : await fastify.services.routes.generateAll(day)
console.log(JSON.stringify(result))
await fastify.close()
