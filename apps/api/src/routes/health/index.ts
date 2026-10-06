import type { FastifyPluginAsync } from 'fastify'

const health: FastifyPluginAsync = async (fastify) => {
  fastify.get('/', async (_req, reply) => {
    const db = await fastify.prisma.$queryRaw`SELECT 1`.then(() => 'ok', () => 'down')
    const storage = await fastify.storage.head('health-probe').then(() => 'ok', () => 'down')
    const status = db === 'ok' && storage === 'ok' ? 'ok' : 'degraded'
    return reply.status(status === 'ok' ? 200 : 503).send({ status, db, storage })
  })
}
export default health
