import fp from 'fastify-plugin'
import cors from '@fastify/cors'

/**
 * Browsers may call the API only from the admin web origin. The web app talks to the API from its
 * server and the mobile app is not a browser, so nothing else needs CORS.
 */
export default fp(async (fastify) => {
  await fastify.register(cors, { origin: fastify.config.webOrigin.split(',').map((o) => o.trim()), credentials: false })
}, { name: 'cors', dependencies: ['env'] })
