import fp from 'fastify-plugin'
import { CreateBucketCommand, GetObjectCommand, HeadBucketCommand, HeadObjectCommand, PutObjectCommand, S3Client } from '@aws-sdk/client-s3'
import { getSignedUrl } from '@aws-sdk/s3-request-presigner'

const URL_TTL_S = 600

export interface Storage {
  presignPut: (key: string, contentType: string, sizeBytes: number) => Promise<{ url: string, headers: Record<string, string>, expiresAt: string }>
  presignGet: (key: string) => Promise<string>
  head: (key: string) => Promise<{ sizeBytes: number, contentType: string } | null>
  getObject: (key: string) => Promise<Buffer>
  putObject: (key: string, body: Buffer, contentType: string) => Promise<void>
}

declare module 'fastify' {
  interface FastifyInstance { storage: Storage }
}

/** S3-compatible object storage (SeaweedFS locally, any S3 in production). Private bucket, presigned URLs. */
export default fp(async (fastify) => {
  const { endpoint, bucket, accessKey, secretKey } = fastify.config.s3
  const s3 = new S3Client({
    endpoint,
    region: 'us-east-1',
    forcePathStyle: true,
    credentials: { accessKeyId: accessKey, secretAccessKey: secretKey },
    // S3-compatible servers reject the SDK's default flexible checksums on presigned URLs
    requestChecksumCalculation: 'WHEN_REQUIRED',
    responseChecksumValidation: 'WHEN_REQUIRED'
  })

  try {
    await s3.send(new HeadBucketCommand({ Bucket: bucket }))
  } catch {
    await s3.send(new CreateBucketCommand({ Bucket: bucket }))
  }

  const storage: Storage = {
    async presignPut (key, contentType, sizeBytes) {
      const url = await getSignedUrl(s3, new PutObjectCommand({ Bucket: bucket, Key: key, ContentType: contentType, ContentLength: sizeBytes }), { expiresIn: URL_TTL_S })
      return { url, headers: { 'Content-Type': contentType }, expiresAt: new Date(Date.now() + URL_TTL_S * 1000).toISOString() }
    },
    presignGet: (key) => getSignedUrl(s3, new GetObjectCommand({ Bucket: bucket, Key: key }), { expiresIn: URL_TTL_S }),
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
    }
  }
  fastify.decorate('storage', storage)
  fastify.addHook('onClose', async () => { s3.destroy() })
}, { name: 'storage', dependencies: ['env'] })
