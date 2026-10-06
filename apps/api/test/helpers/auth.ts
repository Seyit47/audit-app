import type { FastifyInstance } from 'fastify'

/** Bearer header for a user, signed directly (fast path for tests not about auth). */
export function bearer (app: FastifyInstance, user: { id: string, role: 'ADMIN' | 'AGENT' }) {
  const token = app.jwt.sign(user.role === 'AGENT' ? { sub: user.id, role: 'AGENT', agentId: user.id } : { sub: user.id, role: 'ADMIN' })
  return { authorization: `Bearer ${token}` }
}
