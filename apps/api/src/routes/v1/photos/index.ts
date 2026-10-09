import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { GalleryQuery, GallerySummaryQuery } from '../../../modules/photos/gallery.service.js'
import { IdParams } from '../../../modules/photos/photos.schema.js'

const photos: FastifyPluginAsyncTypebox = async (fastify) => {
  const gallery = fastify.services.gallery
  const tags = ['photos']
  fastify.get('/', { schema: { querystring: GalleryQuery, tags }, config: { auth: 'ANY' } }, async (req) => gallery.list(req.user, req.query))
  fastify.get('/summary', { schema: { querystring: GallerySummaryQuery, tags }, config: { auth: 'ANY' } }, async (req) => gallery.summary(req.user, req.query))
  fastify.get('/:id', { schema: { params: IdParams, tags }, config: { auth: 'ANY' } }, async (req) => gallery.detail(req.user, req.params.id))
}

export default photos
