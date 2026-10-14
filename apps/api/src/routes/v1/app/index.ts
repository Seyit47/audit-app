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
  file: Type.String({ pattern: '^[A-Za-z0-9._-]+\\.apk$' }),
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

const noUpdate = () => new AppError(404, 'NOT_FOUND', 'No app update published')

/**
 * In-app updates of the mobile app (Android). The admin uploads the APK and `latest.json` by FTP into
 * UPDATES_DIR; phones read them here, before and after sign-in. Read-only: nothing is written.
 */
const app: FastifyPluginAsyncTypebox = async (fastify) => {
  const dir = () => fastify.config.updatesDir

  fastify.get('/latest', { schema: { tags: ['app'] } }, async () => {
    if (dir() === '') throw noUpdate()
    const raw = await readFile(join(dir(), 'latest.json'), 'utf8').catch(() => null)
    const latest = parse(raw)
    if (!Latest.Check(latest)) throw new AppError(500, 'INTERNAL_ERROR', 'latest.json in the updates folder is not valid')
    const size = await stat(join(dir(), latest.file)).then((s) => s.size, () => null)
    if (size == null) throw new AppError(500, 'INTERNAL_ERROR', `${latest.file} named in latest.json is not in the updates folder`)
    return {
      version: latest.version,
      build: latest.build,
      notes: latest.notes ?? '',
      required: latest.required ?? false,
      url: `/v1/app/apk/${latest.file}`,
      sizeBytes: size
    }
  })

  fastify.get('/apk/:file', { schema: { params: File, tags: ['app'] } }, async (req, reply) => {
    if (dir() === '') throw noUpdate()
    const path = join(dir(), req.params.file)
    const size = await stat(path).then((s) => s.size, () => null)
    if (size == null) throw noUpdate()
    return reply
      .header('Content-Type', 'application/vnd.android.package-archive')
      .header('Content-Length', size)
      .header('Content-Disposition', `attachment; filename="${req.params.file}"`)
      .send(createReadStream(path))
  })
}
export default app
