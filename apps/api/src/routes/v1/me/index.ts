import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { MeResponse } from '../../../modules/auth/auth.schema.js'

const me: FastifyPluginAsyncTypebox = async (fastify) => {
  fastify.get('/', { schema: { response: { 200: MeResponse }, tags: ['auth'] }, config: { auth: 'ANY' } },
    async (request) => fastify.services.auth.me(request.user))
}

export default me
