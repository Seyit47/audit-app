import fp from 'fastify-plugin'

export interface AppConfig {
  databaseUrl: string
  jwtSecret: string
  s3: { endpoint: string, region: string, bucket: string, accessKey: string, secretKey: string }
  webOrigin: string
  retentionYears: number
  currency: string
  satelliteTilesUrl: string
}

declare module 'fastify' {
  interface FastifyInstance { config: AppConfig }
}

const required = ['DATABASE_URL', 'JWT_SECRET', 'S3_ENDPOINT', 'S3_BUCKET', 'S3_ACCESS_KEY', 'S3_SECRET_KEY', 'WEB_ORIGIN'] as const

/** Reads and validates the environment. Fails fast and names every missing variable. */
export function loadConfig (env: NodeJS.ProcessEnv = process.env): AppConfig {
  const missing = required.filter((key) => !env[key])
  if (missing.length > 0) throw new Error(`Missing environment variables: ${missing.join(', ')}`)
  if (env.JWT_SECRET!.length < 32) throw new Error('JWT_SECRET must be at least 32 characters')
  return {
    databaseUrl: env.DATABASE_URL!,
    jwtSecret: env.JWT_SECRET!,
    // S3_REGION: `auto` for Cloudflare R2; SeaweedFS and MinIO accept the default.
    s3: { endpoint: env.S3_ENDPOINT!, region: env.S3_REGION ?? 'us-east-1', bucket: env.S3_BUCKET!, accessKey: env.S3_ACCESS_KEY!, secretKey: env.S3_SECRET_KEY! },
    webOrigin: env.WEB_ORIGIN!,
    retentionYears: Number(env.RETENTION_YEARS ?? 3),
    currency: env.CURRENCY ?? 'TMT',
    satelliteTilesUrl: env.SATELLITE_TILES_URL ?? ''
  }
}

export default fp(async (fastify) => {
  fastify.decorate('config', loadConfig())
}, { name: 'env' })
