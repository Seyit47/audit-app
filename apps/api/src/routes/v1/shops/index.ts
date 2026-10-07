import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { ShopProductsBody } from '../../../modules/products/products.schema.js'
import { BulkAssignBody, BulkDeleteBody, ContactsBody, CreateShopBody, IdParams, ListShopsQuery, MapQuery, PatchShopBody, VisitsQuery } from '../../../modules/shops/shops.schema.js'

const shops: FastifyPluginAsyncTypebox = async (fastify) => {
  const service = fastify.services.shops
  const tags = ['shops']

  fastify.get('/', { schema: { querystring: ListShopsQuery, tags }, config: { auth: 'ANY' } },
    async (req) => service.list(req.user, req.query))

  fastify.post('/', { schema: { body: CreateShopBody, tags }, config: { auth: 'ANY', grace: true } }, async (req, reply) => {
    const { status, shop } = await service.create(req.user, req.body)
    return reply.status(status).send(shop)
  })

  fastify.get('/counts', { schema: { tags }, config: { auth: 'AGENT' } }, async (req) => service.counts(req.user.id))

  fastify.get('/map', { schema: { querystring: MapQuery, tags }, config: { auth: 'ANY' } }, async (req) => service.map(req.user, req.query))

  fastify.post('/bulk/assign', { schema: { body: BulkAssignBody, tags }, config: { auth: 'ADMIN' } },
    async (req) => service.bulkAssign(req.body.shopIds, req.body.agentId))

  fastify.post('/bulk/delete', { schema: { body: BulkDeleteBody, tags }, config: { auth: 'ADMIN' } },
    async (req) => service.bulkDelete(req.body.shopIds))

  fastify.get('/:id', { schema: { params: IdParams, tags }, config: { auth: 'ANY' } },
    async (req) => service.get(req.user, req.params.id))

  fastify.patch('/:id', { schema: { params: IdParams, body: PatchShopBody, tags }, config: { auth: 'ADMIN' } },
    async (req) => service.patch(req.params.id, req.body))

  fastify.put('/:id/contacts', { schema: { params: IdParams, body: ContactsBody, tags }, config: { auth: 'ADMIN' } },
    async (req) => service.contacts(req.params.id, req.body))

  fastify.get('/:id/products', { schema: { params: IdParams, tags }, config: { auth: 'ADMIN' } },
    async (req) => ({ productIds: await fastify.services.products.shopProducts(req.params.id) }))

  fastify.put('/:id/products', { schema: { params: IdParams, body: ShopProductsBody, tags }, config: { auth: 'ADMIN' } },
    async (req) => fastify.services.products.setShopProducts(req.params.id, req.body.productIds))

  fastify.get('/:id/visits', { schema: { params: IdParams, querystring: VisitsQuery, tags }, config: { auth: 'ANY' } }, async (req) => {
    await service.assertVisible(req.user, req.params.id)
    return service.visits(req.params.id, req.query.cursor, req.query.limit)
  })
}

export default shops
