import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'

const categories: FastifyPluginAsyncTypebox = async (fastify) => {
  fastify.get('/', { schema: { tags: ['products'] }, config: { auth: 'ADMIN' } }, async () => fastify.services.products.categories())
}

export default categories
