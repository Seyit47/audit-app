import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox';
import { HealthStatusSchema } from './health.schema.js';
import type { HealthService } from './health.service.js';

export const healthRoutes: FastifyPluginAsyncTypebox<{ healthService: HealthService }> = async (
  app,
  { healthService },
) => {
  app.get(
    '/health',
    {
      schema: {
        tags: ['system'],
        summary: 'Service and database health',
        response: { 200: HealthStatusSchema, 503: HealthStatusSchema },
      },
    },
    async (_request, reply) => {
      const health = await healthService.check();
      return reply.status(health.status === 'ok' ? 200 : 503).send(health);
    },
  );
};
