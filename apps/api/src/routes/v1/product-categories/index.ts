import { Type } from '@sinclair/typebox'
import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { AppError } from '../../../lib/app-error.js'

const Body = Type.Object({ name: Type.String({ minLength: 1, maxLength: 80 }) }, { additionalProperties: false })
const Params = Type.Object({ id: Type.String({ format: 'uuid' }) })

/** Trimmed name; blank (only spaces) is rejected like an empty one. */
function name (raw: string) {
  const v = raw.trim()
  if (v === '') throw new AppError(400, 'VALIDATION_FAILED', 'name must not be blank', [{ field: '/name', message: 'must not be blank' }])
  return v
}

const categories: FastifyPluginAsyncTypebox = async (fastify) => {
  const repo = fastify.services.repositories.categories
  fastify.get('/', { schema: { tags: ['products'] }, config: { auth: 'ADMIN' } }, async () => repo.list())
  fastify.post('/', { schema: { body: Body, tags: ['products'] }, config: { auth: 'ADMIN' } }, async (req) => repo.create(name(req.body.name)))
  fastify.patch('/:id', { schema: { params: Params, body: Body, tags: ['products'] }, config: { auth: 'ADMIN' } },
    async (req) => repo.rename(req.params.id, name(req.body.name)))
  fastify.delete('/:id', { schema: { params: Params, tags: ['products'] }, config: { auth: 'ADMIN' } }, async (req, reply) => {
    await repo.delete(req.params.id)
    return reply.status(204).send()
  })
}

export default categories
