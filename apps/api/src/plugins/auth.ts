import fp from 'fastify-plugin'
import jwt from '@fastify/jwt'
import rateLimit from '@fastify/rate-limit'
import type { FastifyRequest } from 'fastify'
import { AppError } from '../lib/app-error.js'

export type AuthRole = 'ADMIN' | 'AGENT' | 'ANY'
export interface AuthUser {
  id: string, role: 'ADMIN' | 'AGENT', agentId?: string
  /** Set while a deactivated user submits within the grace period (`grace` routes only). */
  deactivatedAt?: Date
}
export type AccountCheck = (user: AuthUser, grace: boolean) => Promise<void>
interface TokenPayload { sub: string, role: 'ADMIN' | 'AGENT', agentId?: string }

declare module '@fastify/jwt' {
  interface FastifyJWT { payload: TokenPayload, user: AuthUser }
}
declare module 'fastify' {
  interface FastifyContextConfig {
    auth?: AuthRole
    /** Outbox submissions a deactivated agent may still make for 72 h (api.md). */
    grace?: boolean
  }
  interface FastifyInstance { setAccountCheck: (check: AccountCheck) => void }
}

/**
 * JWT authentication and role checks. Routes opt in with `config: { auth: 'ADMIN' | 'AGENT' | 'ANY' }`.
 * Agent data scoping is enforced in repositories, not here. The account check (deactivation) is
 * registered by the services plugin so this plugin stays free of database access.
 */
export default fp(async (fastify) => {
  await fastify.register(jwt, {
    secret: fastify.config.jwtSecret,
    formatUser: (p: TokenPayload): AuthUser => (p.agentId ? { id: p.sub, role: p.role, agentId: p.agentId } : { id: p.sub, role: p.role })
  })
  await fastify.register(rateLimit, { global: false })

  let accountCheck: AccountCheck | null = null
  fastify.decorate('setAccountCheck', (check: AccountCheck) => { accountCheck = check })

  const guard = (required: AuthRole, grace: boolean) => async (request: FastifyRequest) => {
    try {
      await request.jwtVerify()
    } catch {
      throw new AppError(401, 'UNAUTHENTICATED', 'Authentication required')
    }
    if (required !== 'ANY' && request.user.role !== required) {
      throw new AppError(403, 'FORBIDDEN', 'Not allowed for this role')
    }
    if (accountCheck != null) await accountCheck(request.user, grace)
  }

  fastify.addHook('onRoute', (route) => {
    const required = route.config?.auth
    if (!required) return
    const existing = route.preHandler ? [route.preHandler].flat() : []
    route.preHandler = [guard(required, route.config?.grace === true), ...existing]
  })
}, { name: 'auth', dependencies: ['env', 'errors'] })
