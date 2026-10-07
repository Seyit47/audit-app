import type { FastifyInstance } from 'fastify'

export const RETENTION_QUEUE = 'retention'

/** Purges location pings and export files older than the retention period (FR-025). Audits and photos are kept. */
export async function runRetention (app: FastifyInstance, years = app.config.retentionYears): Promise<{ pings: number, exports: number }> {
  const cutoff = new Date(Date.now() - years * 365.25 * 86_400_000)
  const pings = await app.prisma.locationPing.deleteMany({ where: { recordedAt: { lt: cutoff } } })
  const old = await app.prisma.export.findMany({ where: { createdAt: { lt: cutoff } }, select: { id: true, fileKey: true } })
  for (const e of old) if (e.fileKey != null) await app.storage.deleteObject(e.fileKey).catch(() => undefined)
  const exports = await app.prisma.export.deleteMany({ where: { id: { in: old.map((e) => e.id) } } })
  return { pings: pings.count, exports: exports.count }
}

export async function registerRetentionWorker (app: FastifyInstance): Promise<void> {
  await app.jobs.work(RETENTION_QUEUE, async () => { app.log.info(await runRetention(app), 'retention') })
  const s = await app.services.settings.get()
  await app.jobs.schedule(RETENTION_QUEUE, '30 2 * * *', null, s.timezone)
}
