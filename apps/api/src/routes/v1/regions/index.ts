import { Type } from '@sinclair/typebox'
import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'

const Body = Type.Object({ name: Type.String({ minLength: 1 }), centroidLat: Type.Optional(Type.Number()), centroidLng: Type.Optional(Type.Number()) }, { additionalProperties: false })
const Params = Type.Object({ id: Type.String({ format: 'uuid' }) })

const regions: FastifyPluginAsyncTypebox = async (fastify) => {
  const repo = fastify.services.repositories.regions
  fastify.get('/', { schema: { tags: ['regions'] }, config: { auth: 'ANY' } }, async () => repo.list())
  fastify.post('/', { schema: { body: Body, tags: ['regions'] }, config: { auth: 'ADMIN' } }, async (req) => repo.create(req.body))
  fastify.patch('/:id', { schema: { params: Params, body: Type.Partial(Body), tags: ['regions'] }, config: { auth: 'ADMIN' } },
    async (req) => repo.update(req.params.id, req.body))
  fastify.delete('/:id', { schema: { params: Params, tags: ['regions'] }, config: { auth: 'ADMIN' } }, async (req, reply) => {
    await repo.delete(req.params.id)
    return reply.status(204).send()
  })
}
export default regions
