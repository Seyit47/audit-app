import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { CreateAgentBody, DeviceBody, IdParams, ListAgentsQuery, PatchAgentBody } from '../../../modules/agents/agents.schema.js'

const agents: FastifyPluginAsyncTypebox = async (fastify) => {
  const service = fastify.services.agents
  const admin = { auth: 'ADMIN' as const }
  const tags = ['agents']

  fastify.get('/', { schema: { querystring: ListAgentsQuery, tags }, config: admin }, async (req) => service.list(req.query))

  fastify.post('/', { schema: { body: CreateAgentBody, tags }, config: admin }, async (req, reply) =>
    reply.status(201).send(await service.create(req.body)))

  fastify.get('/next-code', { schema: { tags }, config: admin }, async () => ({ code: await service.nextCode() }))

  fastify.get('/:id', { schema: { params: IdParams, tags }, config: admin }, async (req) => service.get(req.params.id))

  fastify.patch('/:id', { schema: { params: IdParams, body: PatchAgentBody, tags }, config: admin },
    async (req) => service.patch(req.params.id, req.body))

  fastify.post('/:id/reset-password', { schema: { params: IdParams, tags }, config: admin },
    async (req) => service.resetPassword(req.params.id))

  fastify.put('/:id/device', { schema: { params: IdParams, body: DeviceBody, tags }, config: admin },
    async (req) => service.rebindDevice(req.params.id, req.body.imeiLabel))
}

export default agents
