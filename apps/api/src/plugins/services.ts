import fp from 'fastify-plugin'
import { PhotosRepository } from '../modules/photos/photos.repository.js'
import { UploadsService } from '../modules/photos/uploads.service.js'
import { SettingsService } from '../modules/settings/settings.service.js'
import { RegionsRepository } from '../modules/regions/regions.repository.js'
import { AuthRepository } from '../modules/auth/auth.repository.js'
import { AuthService } from '../modules/auth/auth.service.js'
import { AgentsRepository } from '../modules/agents/agents.repository.js'
import { AgentsService } from '../modules/agents/agents.service.js'
import { ShopsRepository } from '../modules/shops/shops.repository.js'
import { ShopsService } from '../modules/shops/shops.service.js'
import { ExportsService } from '../modules/exports/exports.service.js'

/** Composition root: builds repositories and services once and exposes them to routes. */
export function buildServices (app: import('fastify').FastifyInstance) {
  const photos = new PhotosRepository(app.prisma)
  const settings = new SettingsService(app.prisma)
  const shopsRepo = new ShopsRepository(app.prisma)
  const sign = (payload: { sub: string, role: 'ADMIN' | 'AGENT', agentId?: string }) => app.jwt.sign(payload, { expiresIn: '15m' })
  return {
    repositories: { photos, shops: shopsRepo, regions: new RegionsRepository(app.prisma) },
    settings,
    auth: new AuthService(new AuthRepository(app.prisma), sign, settings, photos, app.storage),
    agents: new AgentsService(new AgentsRepository(app.prisma), settings, photos, app.storage),
    shops: new ShopsService(shopsRepo, photos, app.storage, settings),
    exports: new ExportsService(app.prisma, app.jobs, app.storage),
    uploads: new UploadsService(photos, app.storage, app.jobs)
  }
}

export type Services = ReturnType<typeof buildServices>

declare module 'fastify' {
  interface FastifyInstance { services: Services }
}

export default fp(async (fastify) => {
  const services = buildServices(fastify)
  fastify.decorate('services', services)
  fastify.setAccountCheck((user, grace) => services.auth.checkAccount(user, grace))
}, { name: 'services', dependencies: ['prisma', 'storage', 'jobs', 'auth'] })
