import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { PingsBody } from '../../../modules/tracking/tracking.service.js'

const tracking: FastifyPluginAsyncTypebox = async (fastify) => {
  fastify.post('/pings', { schema: { body: PingsBody, tags: ['tracking'] }, config: { auth: 'AGENT', grace: true } },
    async (req) => fastify.services.tracking.ingest(req.user, req.body))
}

export default tracking
