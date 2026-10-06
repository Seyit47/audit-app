import fp from 'fastify-plugin'
import { PgBoss } from 'pg-boss'

export interface Jobs {
  send: (queue: string, data?: object) => Promise<string | null>
  schedule: (queue: string, cron: string, data: object | null, tz: string) => Promise<void>
  work: <T extends object>(queue: string, handler: (data: T) => Promise<void>) => Promise<void>
}

declare module 'fastify' {
  interface FastifyInstance { jobs: Jobs }
}

/** Background jobs on pg-boss, stored in the same PostgreSQL database (no Redis). */
export default fp(async (fastify) => {
  const boss = new PgBoss({ connectionString: fastify.config.databaseUrl })
  boss.on('error', (err) => fastify.log.error({ err }, 'pg-boss error'))
  await boss.start()

  const queues = new Set<string>()
  const ensure = async (queue: string) => {
    if (queues.has(queue)) return
    await boss.createQueue(queue)
    queues.add(queue)
  }

  const jobs: Jobs = {
    async send (queue, data) {
      await ensure(queue)
      return boss.send(queue, data ?? {})
    },
    async schedule (queue, cron, data, tz) {
      await ensure(queue)
      await boss.schedule(queue, cron, data, { tz })
    },
    async work (queue, handler) {
      await ensure(queue)
      await boss.work<object>(queue, async (batch) => {
        for (const job of batch) await handler(job.data as never)
      })
    }
  }
  fastify.decorate('jobs', jobs)
  fastify.addHook('onClose', async () => { await boss.stop({ graceful: false }) })
}, { name: 'jobs', dependencies: ['env'] })
