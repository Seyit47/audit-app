import { describe, expect, it } from 'vitest'
import { createSession, COOKIES, SessionExpiredError, type CookieStore } from './session-core'

function memoryCookies () {
  const jar = new Map<string, { value: string, opts?: Record<string, unknown> }>()
  const store: CookieStore = {
    get: (n) => (jar.has(n) ? { value: jar.get(n)!.value } : undefined),
    set: (n, value, opts) => { jar.set(n, { value, opts }) },
    delete: (n) => { jar.delete(n) }
  }
  return { jar, store }
}

const json = (status: number, body: unknown) => new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })

describe('session', () => {
  it('login stores tokens in httpOnly, Secure, SameSite=Lax cookies', async () => {
    const { jar, store } = memoryCookies()
    const fetch = async () => json(200, { accessToken: 'a1', refreshToken: 'r1', user: { role: 'ADMIN' } })
    await createSession({ cookies: store, fetch, apiUrl: 'http://api' }).login('a@b.c', 'pw')
    for (const name of [COOKIES.access, COOKIES.refresh]) {
      expect(jar.get(name)?.opts).toMatchObject({ httpOnly: true, secure: true, sameSite: 'lax', path: '/' })
    }
    expect(jar.get(COOKIES.access)?.value).toBe('a1')
  })

  it('refuses agent-role logins without setting cookies', async () => {
    const { jar, store } = memoryCookies()
    const fetch = async () => json(200, { accessToken: 'a', refreshToken: 'r', user: { role: 'AGENT' } })
    await expect(createSession({ cookies: store, fetch, apiUrl: 'http://api' }).login('x', 'y')).rejects.toThrow(/admin/i)
    expect(jar.size).toBe(0)
  })

  it('refreshes once on 401 and retries with the new token', async () => {
    const { jar, store } = memoryCookies()
    store.set(COOKIES.access, 'old', {})
    store.set(COOKIES.refresh, 'r1', {})
    const seen: string[] = []
    const fetch = async (url: string, init?: RequestInit) => {
      if (url.endsWith('/v1/auth/refresh')) return json(200, { accessToken: 'new', refreshToken: 'r2' })
      const auth = new Headers(init?.headers).get('authorization')
      seen.push(auth ?? '')
      return auth === 'Bearer new' ? json(200, { ok: true }) : json(401, { error: { code: 'UNAUTHENTICATED', message: '' } })
    }
    const res = await createSession({ cookies: store, fetch, apiUrl: 'http://api' }).authorizedFetch('http://api/v1/x')
    expect(res.status).toBe(200)
    expect(seen).toEqual(['Bearer old', 'Bearer new'])
    expect(jar.get(COOKIES.refresh)?.value).toBe('r2')
  })

  it('after the idle limit the refresh fails, cookies are cleared and the session expires', async () => {
    const { jar, store } = memoryCookies()
    store.set(COOKIES.access, 'old', {})
    store.set(COOKIES.refresh, 'stale', {})
    const fetch = async () => json(401, { error: { code: 'UNAUTHENTICATED', message: 'idle' } })
    await expect(createSession({ cookies: store, fetch, apiUrl: 'http://api' }).authorizedFetch('http://api/v1/x')).rejects.toBeInstanceOf(SessionExpiredError)
    expect(jar.size).toBe(0)
  })
})
