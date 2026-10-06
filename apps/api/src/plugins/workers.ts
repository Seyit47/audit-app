import fp from 'fastify-plugin'
import { registerWorkers } from '../jobs/index.js'

export default fp(async (fastify) => {
  if (process.env.JOBS_DISABLED === '1') return
  fastify.addHook('onReady', async () => { await registerWorkers(fastify) })
}, { name: 'workers', dependencies: ['services', 'jobs'] })
