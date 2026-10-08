import fp from 'fastify-plugin'

export interface AppConfig {
  databaseUrl: string
  /** Connections per pool (app queries / job queue); hosted poolers cap the total (Supabase free: 15). */
  pool: { db: number, jobs: number }
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

/**
 * The storage endpoint as a full URL. A bare host (`s3.eu-central-003.backblazeb2.com`, as provider dashboards
 * show it) gets https://; anything still not a URL stops startup instead of failing every upload later.
 */
export function storageEndpoint (value: string): string {
  const url = /^https?:\/\//i.test(value.trim()) ? value.trim() : `https://${value.trim()}`
  try {
    new URL(url)
  } catch {
    throw new Error(`S3_ENDPOINT is not a valid URL: ${value}`)
  }
  return url.replace(/\/+$/, '')
}

/** Reads and validates the environment. Fails fast and names every missing variable. */
export function loadConfig (env: NodeJS.ProcessEnv = process.env): AppConfig {
  const missing = required.filter((key) => !env[key])
  if (missing.length > 0) throw new Error(`Missing environment variables: ${missing.join(', ')}`)
  if (env.JWT_SECRET!.length < 32) throw new Error('JWT_SECRET must be at least 32 characters')
  const s3Endpoint = storageEndpoint(env.S3_ENDPOINT!)
  return {
    databaseUrl: env.DATABASE_URL!,
    pool: { db: Number(env.DATABASE_POOL_MAX ?? 10), jobs: Number(env.JOBS_POOL_MAX ?? 10) },
    jwtSecret: env.JWT_SECRET!,
    // S3_REGION: `auto` for Cloudflare R2; SeaweedFS and MinIO accept the default.
    s3: { endpoint: s3Endpoint, region: env.S3_REGION ?? 'us-east-1', bucket: env.S3_BUCKET!, accessKey: env.S3_ACCESS_KEY!, secretKey: env.S3_SECRET_KEY! },
    webOrigin: env.WEB_ORIGIN!,
    retentionYears: Number(env.RETENTION_YEARS ?? 3),
    currency: env.CURRENCY ?? 'TMT',
    satelliteTilesUrl: env.SATELLITE_TILES_URL ?? ''
  }
}

export default fp(async (fastify) => {
  fastify.decorate('config', loadConfig())
}, { name: 'env' })
