import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox';
import { VersionInfoSchema } from './version.schema.js';
import type { VersionService } from './version.service.js';

export const versionRoutes: FastifyPluginAsyncTypebox<{ versionService: VersionService }> = async (
  app,
  { versionService },
) => {
  app.get(
    '/version',
    {
      schema: {
        tags: ['system'],
        summary: 'Server version and minimum supported client versions',
        response: { 200: VersionInfoSchema },
      },
    },
    async () => versionService.getVersionInfo(),
  );
};
