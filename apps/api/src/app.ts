import cors from '@fastify/cors';
import swagger from '@fastify/swagger';
import swaggerUi from '@fastify/swagger-ui';
import type { TypeBoxTypeProvider } from '@fastify/type-provider-typebox';
import Fastify from 'fastify';
import type { Env } from './config/env.js';
import { registerErrorHandling } from './errors/error-handler.js';
import { appVersion } from './lib/app-version.js';
import { loggerOptions, requestIdFor } from './lib/logger.js';
import type { PrismaClient } from './lib/prisma.js';
import { PrismaHealthRepository } from './modules/health/health.repository.js';
import { healthRoutes } from './modules/health/health.routes.js';
import { HealthService } from './modules/health/health.service.js';
import { versionRoutes } from './modules/version/version.routes.js';
import { VersionService } from './modules/version/version.service.js';

export interface AppDependencies {
  env: Env;
  prisma: PrismaClient;
}

/** Builds the Fastify app. All dependencies are passed in so tests can build it the same way. */
export async function buildApp({ env, prisma }: AppDependencies) {
  const app = Fastify({
    logger: loggerOptions(env.LOG_LEVEL),
    genReqId: requestIdFor,
  }).withTypeProvider<TypeBoxTypeProvider>();

  app.addHook('onSend', async (request, reply) => {
    reply.header('X-Request-Id', request.id);
  });

  registerErrorHandling(app);

  await app.register(cors, { origin: env.CORS_ORIGINS });

  await app.register(swagger, {
    openapi: { info: { title: 'Audit App API', version: appVersion } },
  });
  await app.register(swaggerUi, { routePrefix: '/docs' });

  const healthService = new HealthService(new PrismaHealthRepository(prisma), appVersion);
  const versionService = new VersionService(env, appVersion);

  await app.register(
    async (v1) => {
      await v1.register(healthRoutes, { healthService });
      await v1.register(versionRoutes, { versionService });
    },
    { prefix: '/v1' },
  );

  return app;
}

export type App = Awaited<ReturnType<typeof buildApp>>;
