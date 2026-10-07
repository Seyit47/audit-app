import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { CreateProductBody, IdParams, ListProductsQuery, PatchProductBody } from '../../../modules/products/products.schema.js'

const products: FastifyPluginAsyncTypebox = async (fastify) => {
  const service = fastify.services.products
  const admin = { auth: 'ADMIN' as const }
  const tags = ['products']
  fastify.get('/', { schema: { querystring: ListProductsQuery, tags }, config: admin }, async (req) => service.list(req.query))
  fastify.get('/summary', { schema: { tags }, config: admin }, async () => service.summary())
  fastify.get('/:id', { schema: { params: IdParams, tags }, config: admin }, async (req) => service.get(req.params.id))
  fastify.post('/', { schema: { body: CreateProductBody, tags }, config: admin }, async (req, reply) => reply.status(201).send(await service.create(req.body)))
  fastify.patch('/:id', { schema: { params: IdParams, body: PatchProductBody, tags }, config: admin }, async (req) => service.patch(req.params.id, req.body))
}

export default products
