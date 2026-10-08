import fp from 'fastify-plugin'
import { createPrisma, type PrismaClient } from '../lib/prisma.js'

declare module 'fastify' {
  interface FastifyInstance { prisma: PrismaClient }
}

export default fp(async (fastify) => {
  const prisma = createPrisma(fastify.config.databaseUrl, fastify.config.pool.db)
  fastify.decorate('prisma', prisma)
  fastify.addHook('onClose', async () => { await prisma.$disconnect() })
}, { name: 'prisma', dependencies: ['env'] })
