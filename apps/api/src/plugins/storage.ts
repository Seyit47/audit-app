import fp from 'fastify-plugin'
import { CreateBucketCommand, GetObjectCommand, DeleteObjectCommand, HeadBucketCommand, HeadObjectCommand, PutBucketCorsCommand, PutObjectCommand, S3Client } from '@aws-sdk/client-s3'
import { getSignedUrl } from '@aws-sdk/s3-request-presigner'

const URL_TTL_S = 600

/**
 * Read URLs are signed as of the start of the hour and stay valid for two, so the same object gets the same
 * URL all hour: pages that refresh every 30 s and the app's image cache reuse the image instead of
 * downloading it again (each download is a billed storage read).
 */
const READ_WINDOW_MS = 3_600_000
const READ_TTL_S = 7200

export interface Storage {
  presignPut: (key: string, contentType: string, sizeBytes: number) => Promise<{ url: string, headers: Record<string, string>, expiresAt: string }>
  /** `downloadName` makes the browser save the object under that file name. */
  presignGet: (key: string, downloadName?: string) => Promise<string>
  head: (key: string) => Promise<{ sizeBytes: number, contentType: string } | null>
  getObject: (key: string) => Promise<Buffer>
  putObject: (key: string, body: Buffer, contentType: string) => Promise<void>
  deleteObject: (key: string) => Promise<void>
}

declare module 'fastify' {
  interface FastifyInstance { storage: Storage }
}

/** S3-compatible object storage (SeaweedFS locally, any S3 in production). Private bucket, presigned URLs. */
export default fp(async (fastify) => {
  const { endpoint, region, bucket, accessKey, secretKey } = fastify.config.s3
  const s3 = new S3Client({
    endpoint,
    region,
    forcePathStyle: true,
    credentials: { accessKeyId: accessKey, secretAccessKey: secretKey },
    // S3-compatible servers reject the SDK's default flexible checksums on presigned URLs
    requestChecksumCalculation: 'WHEN_REQUIRED',
    responseChecksumValidation: 'WHEN_REQUIRED'
  })

  // The bucket is created when missing (local SeaweedFS). Hosted storage (R2) usually has it created in
  // its dashboard and a token scoped to that bucket, which may not be allowed to check it: warn, go on.
  try {
    await s3.send(new HeadBucketCommand({ Bucket: bucket }))
  } catch (err) {
    const status = (err as { $metadata?: { httpStatusCode?: number } }).$metadata?.httpStatusCode
    if (status === 404) await s3.send(new CreateBucketCommand({ Bucket: bucket }))
    else fastify.log.warn({ err, bucket }, 'storage bucket check failed; continuing')
  }

  // The admin web uploads straight from the browser (presigned PUT), so the bucket must allow its origin;
  // hosted buckets (Backblaze B2, R2) allow no cross-origin requests until told to.
  const origins = fastify.config.webOrigin.split(',').map((o) => o.trim()).filter(Boolean)
  try {
    await s3.send(new PutBucketCorsCommand({
      Bucket: bucket,
      CORSConfiguration: {
        CORSRules: [{ AllowedOrigins: origins, AllowedMethods: ['PUT', 'GET', 'HEAD'], AllowedHeaders: ['*'], ExposeHeaders: ['ETag'], MaxAgeSeconds: 3600 }]
      }
    }))
  } catch (err) {
    fastify.log.warn({ err, bucket, origins },
      'could not set the bucket CORS rules: admin web uploads will fail until the bucket allows PUT from these origins (give the storage key the writeBuckets capability)')
  }

  const storage: Storage = {
    async presignPut (key, contentType, sizeBytes) {
      const url = await getSignedUrl(s3, new PutObjectCommand({ Bucket: bucket, Key: key, ContentType: contentType, ContentLength: sizeBytes }), { expiresIn: URL_TTL_S })
      return { url, headers: { 'Content-Type': contentType }, expiresAt: new Date(Date.now() + URL_TTL_S * 1000).toISOString() }
    },
    presignGet: (key, downloadName) => getSignedUrl(s3, new GetObjectCommand({
      Bucket: bucket,
      Key: key,
      ResponseContentDisposition: downloadName == null ? undefined : `attachment; filename*=UTF-8''${encodeURIComponent(downloadName)}`
    }), { expiresIn: READ_TTL_S, signingDate: new Date(Math.floor(Date.now() / READ_WINDOW_MS) * READ_WINDOW_MS) }),
    async head (key) {
      try {
        const res = await s3.send(new HeadObjectCommand({ Bucket: bucket, Key: key }))
        return { sizeBytes: res.ContentLength ?? 0, contentType: res.ContentType ?? '' }
      } catch {
        return null
      }
    },
    async getObject (key) {
      const res = await s3.send(new GetObjectCommand({ Bucket: bucket, Key: key }))
      return Buffer.from(await res.Body!.transformToByteArray())
    },
    async putObject (key, body, contentType) {
      await s3.send(new PutObjectCommand({ Bucket: bucket, Key: key, Body: body, ContentType: contentType }))
    },
    async deleteObject (key) {
      await s3.send(new DeleteObjectCommand({ Bucket: bucket, Key: key }))
    }
  }
  fastify.decorate('storage', storage)
  fastify.addHook('onClose', async () => { s3.destroy() })
}, { name: 'storage', dependencies: ['env'] })
