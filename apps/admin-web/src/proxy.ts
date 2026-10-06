import { NextResponse, type NextRequest } from 'next/server'
import { COOKIES, createSession, isExpiring, type CookieStore } from './lib/session-core'

const API_URL = process.env.API_URL ?? 'http://localhost:3000'

// Signed-in admins skip /login; everyone else needs a session. Access tokens are refreshed here,
// ahead of expiry, because Server Components cannot write cookies.
export async function proxy (request: NextRequest) {
  const isLogin = request.nextUrl.pathname === '/login'
  const hasSession = request.cookies.has(COOKIES.refresh)

  if (isLogin) {
    return hasSession ? NextResponse.redirect(new URL('/map', request.url)) : NextResponse.next()
  }
  if (!hasSession) return NextResponse.redirect(new URL('/login', request.url))
  if (!isExpiring(request.cookies.get(COOKIES.access)?.value)) return NextResponse.next()

  const writes: Array<(res: NextResponse) => void> = []
  const store: CookieStore = {
    get: (n) => request.cookies.get(n),
    set: (n, v, o) => {
      request.cookies.set(n, v) // visible to this request's render
      writes.push((res) => res.cookies.set(n, v, o))
    },
    delete: (n) => {
      request.cookies.delete(n)
      writes.push((res) => res.cookies.delete(n))
    }
  }
  const ok = await createSession({ cookies: store, fetch, apiUrl: API_URL }).refresh()
  const res = ok
    ? NextResponse.next({ request: { headers: request.headers } })
    : NextResponse.redirect(new URL('/login', request.url))
  for (const write of writes) write(res)
  return res
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|icons|favicon.ico|.*\\.(?:svg|png|jpg|webp)$).*)']
}
