import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { CreateUploadBody, IdParams } from '../../../modules/photos/photos.schema.js'

const uploads: FastifyPluginAsyncTypebox = async (fastify) => {
  fastify.post('/', { schema: { body: CreateUploadBody, tags: ['photos'] }, config: { auth: 'ANY' } },
    async (request) => fastify.services.uploads.create(request.user, request.body))

  fastify.post('/:id/complete', { schema: { params: IdParams, tags: ['photos'] }, config: { auth: 'ANY' } },
    async (request) => fastify.services.uploads.complete(request.user, request.params.id))
}

export default uploads
