import fp from 'fastify-plugin'
import { randomUUID } from 'node:crypto'
import { Prisma } from '../generated/prisma/client.js'
import { AppError } from '../lib/app-error.js'

interface ErrorBody { error: { code: string, message: string, details?: unknown }, requestId: string }

/** One error shape for every response: { error: { code, message, details? }, requestId }. */
export default fp(async (fastify) => {
  fastify.setNotFoundHandler((request, reply) => {
    const body: ErrorBody = { error: { code: 'NOT_FOUND', message: 'Route not found' }, requestId: request.id }
    return reply.status(404).send(body)
  })

  fastify.setErrorHandler((err, request, reply) => {
    const send = (status: number, code: string, message: string, details?: unknown) => {
      const body: ErrorBody = { error: details === undefined ? { code, message } : { code, message, details }, requestId: request.id }
      return reply.status(status).send(body)
    }
    if (err instanceof AppError) return send(err.statusCode, err.code, err.message, err.details)
    const e = err as { validation?: Array<{ instancePath?: string, message?: string }>, statusCode?: number, message: string }
    if (e.validation) {
      return send(400, 'VALIDATION_FAILED', 'Request validation failed',
        e.validation.map((v) => ({ field: v.instancePath ?? '', message: v.message ?? 'invalid' })))
    }
    if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2003') {
      return send(400, 'VALIDATION_FAILED', 'Referenced record does not exist')
    }
    if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002') {
      return send(409, 'CONFLICT', 'A record with these values already exists')
    }
    if (e.statusCode === 429) return send(429, 'RATE_LIMITED', 'Too many requests')
    if (e.statusCode === 401) return send(401, 'UNAUTHENTICATED', 'Authentication required')
    // Other client errors raised by Fastify itself (empty JSON body, bad content type, payload too large…).
    if (e.statusCode != null && e.statusCode >= 400 && e.statusCode < 500) {
      return send(e.statusCode, e.statusCode === 404 ? 'NOT_FOUND' : e.statusCode === 403 ? 'FORBIDDEN' : 'VALIDATION_FAILED', e.message)
    }
    request.log.error({ err }, 'Unhandled error')
    return send(500, 'INTERNAL_ERROR', 'Something went wrong')
  })
}, { name: 'errors' })

export const genReqId = (req: { headers: Record<string, unknown> }): string => {
  const incoming = req.headers['x-request-id']
  return typeof incoming === 'string' && incoming.length > 0 && incoming.length <= 128 ? incoming : randomUUID()
}
