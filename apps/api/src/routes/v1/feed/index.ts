import { Type } from '@sinclair/typebox'
import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'

const Query = Type.Object({ cursor: Type.Optional(Type.String()), limit: Type.Optional(Type.Integer({ minimum: 1, maximum: 50 })) }, { additionalProperties: false })

const feed: FastifyPluginAsyncTypebox = async (fastify) => {
  fastify.get('/', { schema: { querystring: Query, tags: ['feed'] }, config: { auth: 'ADMIN' } },
    async (req) => fastify.services.feed.list(req.user.id, req.query.cursor, req.query.limit))
  fastify.post('/seen', { schema: { tags: ['feed'] }, config: { auth: 'ADMIN' } }, async (req, reply) => {
    await fastify.services.feed.seen(req.user.id)
    return reply.status(204).send()
  })
}

export default feed
