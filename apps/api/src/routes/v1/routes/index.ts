import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'

const routes: FastifyPluginAsyncTypebox = async (fastify) => {
  fastify.get('/today', { schema: { tags: ['routes'] }, config: { auth: 'AGENT' } }, async (req) => fastify.services.routes.today(req.user.id))
}

export default routes
