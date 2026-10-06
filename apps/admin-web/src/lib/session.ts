import 'server-only'
import { cookies } from 'next/headers'
import { redirect } from 'next/navigation'
import { createSession, SessionExpiredError, type CookieStore } from './session-core'

export const API_URL = process.env.API_URL ?? 'http://localhost:3000'

async function session () {
  const jar = await cookies()
  const store: CookieStore = {
    get: (n) => jar.get(n),
    // Cookies can only be written in Server Functions and Route Handlers. During a render the
    // proxy has already refreshed tokens ahead of expiry, so a failed write here is safe to skip.
    set: (n, v, o) => { try { jar.set(n, v, o) } catch {} },
    delete: (n) => { try { jar.delete(n) } catch {} }
  }
  return createSession({ cookies: store, fetch, apiUrl: API_URL })
}

export async function login (login: string, password: string) {
  return (await session()).login(login, password)
}

export async function logout () {
  return (await session()).logout()
}

/** Fetch with the admin's access token; sends the user to /login when the session is over. */
export async function authorizedFetch (url: string, init?: RequestInit): Promise<Response> {
  try {
    return await (await session()).authorizedFetch(url, init)
  } catch (err) {
    if (err instanceof SessionExpiredError) redirect('/login')
    throw err
  }
}
