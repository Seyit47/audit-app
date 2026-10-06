import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { LoginBody, RefreshBody, TokensResponse } from '../../../modules/auth/auth.schema.js'

const auth: FastifyPluginAsyncTypebox = async (fastify) => {
  fastify.post('/login', { schema: { body: LoginBody, response: { 200: TokensResponse }, tags: ['auth'] } },
    async (request) => fastify.services.auth.login(request.body, request.ip))

  fastify.post('/refresh', { schema: { body: RefreshBody, response: { 200: TokensResponse }, tags: ['auth'] } },
    async (request) => fastify.services.auth.refresh(request.body.refreshToken))

  fastify.post('/logout', { schema: { body: RefreshBody, tags: ['auth'] }, config: { auth: 'ANY' } },
    async (request, reply) => {
      await fastify.services.auth.logout(request.user, request.body.refreshToken)
      return reply.status(204).send()
    })
}

export default auth
