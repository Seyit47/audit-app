import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { AppError } from '../../../lib/app-error.js'
import { CheckStartBody, CreateAuditBody, IdParams, ListAuditsQuery } from '../../../modules/audits/audits.schema.js'

const audits: FastifyPluginAsyncTypebox = async (fastify) => {
  const service = fastify.services.audits
  const tags = ['audits']

  fastify.post('/check-start', { schema: { body: CheckStartBody, tags }, config: { auth: 'AGENT' } },
    async (req) => service.checkStart(req.user, req.body))

  fastify.post('/', { schema: { body: CreateAuditBody, tags }, config: { auth: 'AGENT', grace: true } }, async (req, reply) => {
    const { status, audit } = await service.create(req.user, req.body)
    return reply.status(status).send(audit)
  })

  fastify.get('/', { schema: { querystring: ListAuditsQuery, tags }, config: { auth: 'ANY' } }, async (req) => service.list(req.user, req.query))

  fastify.get('/:id', { schema: { params: IdParams, tags }, config: { auth: 'ANY' } }, async (req) => service.get(req.user, req.params.id))

  // Audits are immutable (Constitution VII).
  const immutable = async () => { throw new AppError(405, 'METHOD_NOT_ALLOWED', 'Audits cannot be changed or deleted') }
  fastify.patch('/:id', { schema: { params: IdParams, tags }, config: { auth: 'ANY' } }, immutable)
  fastify.delete('/:id', { schema: { params: IdParams, tags }, config: { auth: 'ANY' } }, immutable)
}

export default audits
