import { createReadStream } from 'node:fs'
import { readFile, stat } from 'node:fs/promises'
import { join } from 'node:path'
import { Type } from '@sinclair/typebox'
import { TypeCompiler } from '@sinclair/typebox/compiler'
import type { FastifyPluginAsyncTypebox } from '@fastify/type-provider-typebox'
import { AppError } from '../../../lib/app-error.js'

/** What the admin puts next to the APK in the updates folder. */
const Latest = TypeCompiler.Compile(Type.Object({
  version: Type.String({ minLength: 1 }),
  build: Type.Integer({ minimum: 1 }),
  /** One APK for every phone (older app versions download this one). */
  file: Type.Optional(Type.String({ pattern: '^[A-Za-z0-9._-]+\\.apk$' })),
  /** Smaller APKs per CPU type ("arm64-v8a", "armeabi-v7a"), for apps that say which they are. */
  files: Type.Optional(Type.Record(Type.String({ pattern: '^[a-z0-9_-]+$' }), Type.String({ pattern: '^[A-Za-z0-9._-]+\\.apk$' }))),
  notes: Type.Optional(Type.String()),
  required: Type.Optional(Type.Boolean())
}))

const File = Type.Object({ file: Type.String({ pattern: '^[A-Za-z0-9._-]+\\.apk$' }) })
/** The file's JSON, or null when it is missing or broken. FTP clients and Notepad may add a byte order mark. */
function parse (raw: string | null): unknown {
  if (raw == null) return null
  try {
    return JSON.parse(raw.replace(/^\uFEFF/, ''))
  } catch {
    return null
  }
}

/** `bytes=start-end` / `bytes=start-` / `bytes=-suffix` within [size]; null without a Range header. */
export function byteRange (header: string | undefined, size: number): { start: number, end: number } | 'invalid' | null {
  if (header == null) return null
  const m = /^bytes=(\d*)-(\d*)$/.exec(header.trim())
  if (m == null || (m[1] === '' && m[2] === '')) return 'invalid'
  const start = m[1] === '' ? Math.max(0, size - Number(m[2])) : Number(m[1])
  const end = m[1] === '' || m[2] === '' ? size - 1 : Math.min(Number(m[2]), size - 1)
  return start > end || start >= size ? 'invalid' : { start, end }
}

const noUpdate = () => new AppError(404, 'NOT_FOUND', 'No app update published')

/**
 * In-app updates of the mobile app (Android). The admin uploads the APK and `latest.json` by FTP into
 * UPDATES_DIR; phones read them here, before and after sign-in. Read-only: nothing is written.
 */
const app: FastifyPluginAsyncTypebox = async (fastify) => {
  const dir = () => fastify.config.updatesDir

  fastify.get('/latest', { schema: { querystring: Type.Object({ abi: Type.Optional(Type.String({ maxLength: 20 })) }), tags: ['app'] } }, async (req) => {
    if (dir() === '') throw noUpdate()
    const raw = await readFile(join(dir(), 'latest.json'), 'utf8').catch(() => null)
    if (raw == null) throw noUpdate()
    const latest = parse(raw)
    if (!Latest.Check(latest)) throw new AppError(500, 'INTERNAL_ERROR', 'latest.json in the updates folder is not valid')
    // The phone's own CPU type when published and uploaded, else the APK for every phone (a per-CPU file
    // still being uploaded must not stop the update).
    const sizeOf = (file: string) => stat(join(dir(), file)).then((s) => s.size, () => null)
    const own = req.query.abi != null ? latest.files?.[req.query.abi] : undefined
    let file = own ?? latest.file
    let size = file == null ? null : await sizeOf(file)
    if (size == null && own != null && latest.file != null && latest.file !== own) {
      req.log.warn({ file: own }, 'per-CPU APK named in latest.json is missing; serving the universal one')
      file = latest.file
      size = await sizeOf(file)
    }
    if (file == null) throw noUpdate()
    if (size == null) throw new AppError(500, 'INTERNAL_ERROR', `${file} named in latest.json is not in the updates folder`)
    return {
      version: latest.version,
      build: latest.build,
      notes: latest.notes ?? '',
      required: latest.required ?? false,
      url: `/v1/app/apk/${file}`,
      sizeBytes: size
    }
  })

  // Ranges, so the phone fetches the APK in pieces on fresh connections: the production network cuts
  // connections ~2 MB into an APK download, and an interrupted download continues where it stopped.
  // Sent as a plain binary file, which filters that block "Android app" downloads let through.
  fastify.get('/apk/:file', { schema: { params: File, tags: ['app'] } }, async (req, reply) => {
    if (dir() === '') throw noUpdate()
    const path = join(dir(), req.params.file)
    const size = await stat(path).then((s) => s.size, () => null)
    if (size == null) throw noUpdate()
    reply.header('Content-Type', 'application/octet-stream').header('Accept-Ranges', 'bytes')
    const range = byteRange(req.headers.range, size)
    if (range === 'invalid') return reply.status(416).header('Content-Range', `bytes */${size}`).send()
    if (range == null) return reply.header('Content-Length', size).send(createReadStream(path))
    return reply
      .status(206)
      .header('Content-Range', `bytes ${range.start}-${range.end}/${size}`)
      .header('Content-Length', range.end - range.start + 1)
      .send(createReadStream(path, range))
  })
}
export default app
