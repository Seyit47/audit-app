import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { CreateExportBody, IdParams } from '../../../modules/exports/exports.schema.js'

const exportsRoutes: FastifyPluginAsyncTypebox = async (fastify) => {
  const service = fastify.services.exports
  fastify.post('/', { schema: { body: CreateExportBody, tags: ['exports'] }, config: { auth: 'ADMIN' } }, async (req, reply) =>
    reply.status(201).send(await service.create(req.user, req.body)))
  fastify.get('/:id', { schema: { params: IdParams, tags: ['exports'] }, config: { auth: 'ADMIN' } }, async (req) =>
    service.get(req.user, req.params.id))
}

export default exportsRoutes
