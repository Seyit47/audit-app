import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { CreateAgentBody, CursorQuery, DateQuery, DeviceBody, IdParams, ListAgentsQuery, PatchAgentBody, PeriodQuery } from '../../../modules/agents/agents.schema.js'

const agents: FastifyPluginAsyncTypebox = async (fastify) => {
  const service = fastify.services.agents
  const admin = { auth: 'ADMIN' as const }
  const tags = ['agents']

  fastify.get('/', { schema: { querystring: ListAgentsQuery, tags }, config: admin }, async (req) => service.list(req.query))

  fastify.post('/', { schema: { body: CreateAgentBody, tags }, config: admin }, async (req, reply) =>
    reply.status(201).send(await service.create(req.body)))

  const insights = fastify.services.agentInsights
  fastify.get('/summary', { schema: { querystring: PeriodQuery, tags }, config: admin }, async (req) => insights.summary(req.query.from, req.query.to))
  fastify.get('/positions', { schema: { tags }, config: admin }, async () => fastify.services.tracking.positions())
  fastify.get('/:id/timeline', { schema: { params: IdParams, querystring: DateQuery, tags }, config: admin }, async (req) => insights.timeline(req.params.id, req.query.date))
  fastify.get('/:id/track', { schema: { params: IdParams, querystring: DateQuery, tags }, config: admin }, async (req) => insights.track(req.params.id, req.query.date))
  fastify.get('/:id/visits', { schema: { params: IdParams, querystring: CursorQuery, tags }, config: admin }, async (req) => insights.visits(req.params.id, req.query.cursor, req.query.limit))

  fastify.get('/next-code', { schema: { tags }, config: admin }, async () => ({ code: await service.nextCode() }))

  fastify.get('/:id', { schema: { params: IdParams, querystring: PeriodQuery, tags }, config: admin }, async (req) => service.get(req.params.id, req.query))

  fastify.patch('/:id', { schema: { params: IdParams, body: PatchAgentBody, tags }, config: admin },
    async (req) => service.patch(req.params.id, req.body))

  fastify.post('/:id/reset-password', { schema: { params: IdParams, tags }, config: admin },
    async (req) => service.resetPassword(req.params.id))

  fastify.put('/:id/device', { schema: { params: IdParams, body: DeviceBody, tags }, config: admin },
    async (req) => service.rebindDevice(req.params.id, req.body.imeiLabel))
}

export default agents
