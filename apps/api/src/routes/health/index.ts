import type { FastifyPluginAsync } from 'fastify'

/** How long a storage check is reused: Render probes /health every few seconds, and each check is a billed read. */
const STORAGE_CHECK_MS = 10 * 60_000

const health: FastifyPluginAsync = async (fastify) => {
  let storage: { status: 'ok' | 'down', at: number } | null = null
  const checkStorage = async () => {
    if (storage == null || Date.now() - storage.at >= STORAGE_CHECK_MS) {
      storage = { status: await fastify.storage.head('health-probe').then(() => 'ok' as const, () => 'down' as const), at: Date.now() }
    }
    return storage.status
  }

  fastify.get('/', async (_req, reply) => {
    const db = await fastify.prisma.$queryRaw`SELECT 1`.then(() => 'ok', () => 'down')
    const storage = await checkStorage()
    const status = db === 'ok' && storage === 'ok' ? 'ok' : 'degraded'
    return reply.status(status === 'ok' ? 200 : 503).send({ status, db, storage })
  })
}
export default health
