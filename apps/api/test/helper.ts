// Shared test helpers: builds the real app against the test database and test bucket.
import 'dotenv/config'
import helper from 'fastify-cli/helper.js'
import * as test from 'node:test'
import * as path from 'node:path'
import { fileURLToPath } from 'node:url'
import { options } from '../src/app.js'

process.env.DATABASE_URL = process.env.DATABASE_URL_TEST ?? process.env.DATABASE_URL
process.env.S3_BUCKET = process.env.S3_BUCKET_TEST ?? 'audit-photos-test'

export type TestContext = { after: typeof test.after }

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const AppPath = path.join(__dirname, '..', 'src', 'app.ts')

export function config () {
  return { skipOverride: true }
}

export async function build (t: TestContext) {
  const app = await helper.build([AppPath], config(), { ...options, logger: false })
  t.after(() => void app.close())
  return app
}
