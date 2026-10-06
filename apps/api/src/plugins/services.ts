import fp from 'fastify-plugin'
import { PhotosRepository } from '../modules/photos/photos.repository.js'
import { UploadsService } from '../modules/photos/uploads.service.js'
import { SettingsService } from '../modules/settings/settings.service.js'
import { RegionsRepository } from '../modules/regions/regions.repository.js'

/** Composition root: builds repositories and services once and exposes them to routes. */
export function buildServices (app: import('fastify').FastifyInstance) {
  const photos = new PhotosRepository(app.prisma)
  return {
    repositories: { photos, regions: new RegionsRepository(app.prisma) },
    settings: new SettingsService(app.prisma),
    uploads: new UploadsService(photos, app.storage, app.jobs)
  }
}

export type Services = ReturnType<typeof buildServices>

declare module 'fastify' {
  interface FastifyInstance { services: Services }
}

export default fp(async (fastify) => {
  fastify.decorate('services', buildServices(fastify))
}, { name: 'services', dependencies: ['prisma', 'storage', 'jobs'] })
