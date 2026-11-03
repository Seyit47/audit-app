import { afterEach, describe, expect, it, vi } from 'vitest'
import { NextRequest } from 'next/server'
import { proxy } from './proxy'

const json = (status: number, body: unknown) => new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } })
const req = (path: string, cookie?: string) => new NextRequest(`http://web.local${path}`, { headers: cookie != null ? { cookie } : {} })

describe('proxy', () => {
  afterEach(() => vi.unstubAllGlobals())

  it('no session: pages go to /login, /login renders', async () => {
    expect((await proxy(req('/map'))).headers.get('location')).toBe('http://web.local/login')
    expect((await proxy(req('/login'))).status).toBe(200)
  })

  it('/login with a live session goes to the map', async () => {
    vi.stubGlobal('fetch', async () => json(200, { accessToken: 'a2', refreshToken: 'r2', user: { role: 'ADMIN' } }))
    const res = await proxy(req('/login', 'rt=r1; at=a1'))
    expect(res.headers.get('location')).toBe('http://web.local/map')
    expect(res.cookies.get('rt')?.value).toBe('r2')
  })

  it('/login with cookies another API rejects shows the form and clears them (no redirect loop)', async () => {
    vi.stubGlobal('fetch', async () => json(401, { error: { code: 'UNAUTHENTICATED' } }))
    const res = await proxy(req('/login', 'rt=foreign; at=foreign'))
    expect(res.status).toBe(200)
    expect(res.headers.get('location')).toBeNull()
    expect(res.cookies.get('rt')?.value).toBe('')
    expect(res.cookies.get('at')?.value).toBe('')
  })

  it('a page with a valid access token passes without touching the API', async () => {
    const exp = Math.floor(Date.now() / 1000) + 600
    const jwt = `x.${Buffer.from(JSON.stringify({ exp })).toString('base64url')}.y`
    vi.stubGlobal('fetch', async () => { throw new Error('must not be called') })
    expect((await proxy(req('/map', `rt=r1; at=${jwt}`))).status).toBe(200)
  })
})
