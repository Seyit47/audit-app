import fp from 'fastify-plugin'
import jwt from '@fastify/jwt'
import rateLimit from '@fastify/rate-limit'
import type { FastifyReply, FastifyRequest } from 'fastify'
import { AppError } from '../lib/app-error.js'

export type AuthRole = 'ADMIN' | 'AGENT' | 'ANY'
export interface AuthUser { id: string, role: 'ADMIN' | 'AGENT', agentId?: string }
interface TokenPayload { sub: string, role: 'ADMIN' | 'AGENT', agentId?: string }

declare module '@fastify/jwt' {
  interface FastifyJWT { payload: TokenPayload, user: AuthUser }
}
declare module 'fastify' {
  interface FastifyContextConfig { auth?: AuthRole }
}

/**
 * JWT authentication and role checks. Routes opt in with `config: { auth: 'ADMIN' | 'AGENT' | 'ANY' }`.
 * Agent data scoping is enforced in repositories, not here.
 */
export default fp(async (fastify) => {
  await fastify.register(jwt, {
    secret: fastify.config.jwtSecret,
    formatUser: (p: TokenPayload): AuthUser => (p.agentId ? { id: p.sub, role: p.role, agentId: p.agentId } : { id: p.sub, role: p.role })
  })
  await fastify.register(rateLimit, { global: false })

  const guard = (required: AuthRole) => async (request: FastifyRequest, _reply: FastifyReply) => {
    try {
      await request.jwtVerify()
    } catch {
      throw new AppError(401, 'UNAUTHENTICATED', 'Authentication required')
    }
    if (required !== 'ANY' && request.user.role !== required) {
      throw new AppError(403, 'FORBIDDEN', 'Not allowed for this role')
    }
  }

  fastify.addHook('onRoute', (route) => {
    const required = route.config?.auth
    if (!required) return
    const existing = route.preHandler ? [route.preHandler].flat() : []
    route.preHandler = [guard(required), ...existing]
  })
}, { name: 'auth', dependencies: ['env', 'errors'] })
