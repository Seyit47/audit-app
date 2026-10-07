import 'server-only'
import { unstable_rethrow } from 'next/navigation'
import { ApiError } from './api-error'

/** What a server action returns to its form: success data, or an API error code to show. */
export type ActionResult<T = undefined> = { ok: true, data: T } | { ok: false, code: string, message: string }

export async function run<T> (fn: () => Promise<T>): Promise<ActionResult<T>> {
  try {
    return { ok: true, data: await fn() }
  } catch (err) {
    unstable_rethrow(err) // redirects (e.g. an expired session) still navigate
    if (err instanceof ApiError) return { ok: false, code: err.code, message: err.message }
    // API unreachable or an unexpected failure: the form shows its generic error instead of crashing.
    console.error(err)
    return { ok: false, code: 'UNAVAILABLE', message: 'Service unavailable' }
  }
}
