// Session logic shared by server code (session.ts) and proxy.ts. Framework-free so it can be tested.

export const COOKIES = { access: 'at', refresh: 'rt' } as const

// The API ends refresh tokens after 12 h idle; the cookie lives as long so it never outlives the token.
const REFRESH_MAX_AGE_S = 12 * 60 * 60
const ACCESS_MAX_AGE_S = 15 * 60

export interface CookieStore {
  get: (name: string) => { value: string } | undefined
  set: (name: string, value: string, opts: Record<string, unknown>) => void
  delete: (name: string) => void
}

type Fetch = (url: string, init?: RequestInit) => Promise<Response>

export class SessionExpiredError extends Error {
  constructor () { super('Session expired') }
}

export class LoginError extends Error {
  readonly code: string
  constructor (code: string, message: string) { super(message); this.code = code }
}

interface Tokens { accessToken: string, refreshToken: string }

const cookieOptions = (maxAge: number) => ({ httpOnly: true, secure: true, sameSite: 'lax', path: '/', maxAge })

export function createSession ({ cookies, fetch, apiUrl }: { cookies: CookieStore, fetch: Fetch, apiUrl: string }) {
  function store (tokens: Tokens) {
    cookies.set(COOKIES.access, tokens.accessToken, cookieOptions(ACCESS_MAX_AGE_S))
    cookies.set(COOKIES.refresh, tokens.refreshToken, cookieOptions(REFRESH_MAX_AGE_S))
  }

  function clear () {
    cookies.delete(COOKIES.access)
    cookies.delete(COOKIES.refresh)
  }

  async function login (login: string, password: string) {
    const res = await fetch(`${apiUrl}/v1/auth/login`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ login, password })
    })
    const body = await res.json().catch(() => ({}))
    if (!res.ok) throw new LoginError(body?.error?.code ?? 'LOGIN_FAILED', body?.error?.message ?? 'Login failed')
    if (body.user?.role !== 'ADMIN') throw new LoginError('FORBIDDEN', 'Only admins can sign in here')
    store(body)
  }

  /** Rotates the refresh token. Returns false (and clears cookies) when the session is over. */
  async function refresh (): Promise<boolean> {
    const refreshToken = cookies.get(COOKIES.refresh)?.value
    if (refreshToken == null) { clear(); return false }
    const res = await fetch(`${apiUrl}/v1/auth/refresh`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ refreshToken })
    })
    if (!res.ok) { clear(); return false }
    store(await res.json())
    return true
  }

  async function logout () {
    const refreshToken = cookies.get(COOKIES.refresh)?.value
    if (refreshToken != null) {
      await fetch(`${apiUrl}/v1/auth/logout`, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ refreshToken })
      }).catch(() => {})
    }
    clear()
  }

  async function authorizedFetch (url: string, init: RequestInit = {}): Promise<Response> {
    const send = () => {
      const headers = new Headers(init.headers)
      const token = cookies.get(COOKIES.access)?.value
      if (token != null) headers.set('authorization', `Bearer ${token}`)
      return fetch(url, { ...init, headers })
    }
    const res = await send()
    if (res.status !== 401) return res
    if (!(await refresh())) throw new SessionExpiredError()
    return send()
  }

  return { login, logout, refresh, authorizedFetch }
}

/** True when a JWT is missing or expires within `skewS` seconds. Payload is not verified here; the API does that. */
export function isExpiring (jwt: string | undefined, skewS = 60): boolean {
  if (jwt == null) return true
  try {
    const payload = JSON.parse(atob(jwt.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')))
    return typeof payload.exp !== 'number' || payload.exp * 1000 - Date.now() < skewS * 1000
  } catch {
    return true
  }
}
