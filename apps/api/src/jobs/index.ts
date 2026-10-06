import type { FastifyInstance } from 'fastify'
import { registerPreviewWorker } from './previews.js'
import { registerExportWorker } from './exports.js'

/** Registers every background worker. */
export async function registerWorkers (app: FastifyInstance): Promise<void> {
  await registerPreviewWorker(app)
  await registerExportWorker(app)
}
