import type { FastifyInstance } from 'fastify'
import { registerPreviewWorker } from './previews.js'
import { registerExportWorker } from './exports.js'
import { registerRouteWorkers } from './routes.js'
import { registerRetentionWorker } from './retention.js'

/** Registers every background worker. */
export async function registerWorkers (app: FastifyInstance): Promise<void> {
  await registerPreviewWorker(app)
  await registerExportWorker(app)
  await registerRouteWorkers(app)
  await registerRetentionWorker(app)
}
