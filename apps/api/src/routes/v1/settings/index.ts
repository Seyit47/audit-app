import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { SettingsPatch } from '../../../modules/settings/settings.schema.js'

const settings: FastifyPluginAsyncTypebox = async (fastify) => {
  fastify.get('/', { schema: { tags: ['settings'] }, config: { auth: 'ADMIN' } }, async () => fastify.services.settings.get())
  fastify.patch('/', { schema: { body: SettingsPatch, tags: ['settings'] }, config: { auth: 'ADMIN' } },
    async (request) => fastify.services.settings.update(request.body, request.user.id))
}
export default settings
