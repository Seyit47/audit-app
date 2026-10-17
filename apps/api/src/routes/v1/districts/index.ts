import { Type } from '@sinclair/typebox'
import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'

const Body = Type.Object({ name: Type.String({ maxLength: 120 }) }, { additionalProperties: false })
const Params = Type.Object({ id: Type.String({ format: 'uuid' }) })

/** Districts with shop counts (an agent's: their own shops); admins manage them. */
const districts: FastifyPluginAsyncTypebox = async (fastify) => {
  const repo = fastify.services.repositories.districts
  fastify.get('/', { schema: { tags: ['districts'] }, config: { auth: 'ANY' } },
    async (req) => repo.list(req.user.role === 'AGENT' ? req.user.id : undefined))
  fastify.post('/', { schema: { body: Body, tags: ['districts'] }, config: { auth: 'ADMIN' } }, async (req) => repo.create(req.body.name))
  fastify.patch('/:id', { schema: { params: Params, body: Body, tags: ['districts'] }, config: { auth: 'ADMIN' } },
    async (req) => repo.rename(req.params.id, req.body.name))
  fastify.delete('/:id', { schema: { params: Params, tags: ['districts'] }, config: { auth: 'ADMIN' } }, async (req, reply) => {
    await repo.delete(req.params.id)
    return reply.status(204).send()
  })
}
export default districts
