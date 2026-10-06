'use server'

import { redirect } from 'next/navigation'
import { LoginError } from '@/lib/session-core'
import { login, logout } from '@/lib/session'

export type SignInState = { error: 'credentials' | 'agent' | 'rateLimited' | 'generic' | null }

export async function signIn (_prev: SignInState, form: FormData): Promise<SignInState> {
  const email = String(form.get('email') ?? '').trim()
  const password = String(form.get('password') ?? '')
  if (email === '' || password === '') return { error: 'credentials' }
  try {
    await login(email, password)
  } catch (err) {
    if (err instanceof LoginError) {
      if (err.code === 'FORBIDDEN') return { error: 'agent' }
      if (err.code === 'RATE_LIMITED') return { error: 'rateLimited' }
      if (err.code === 'UNAUTHENTICATED' || err.code === 'VALIDATION_FAILED') return { error: 'credentials' }
    }
    return { error: 'generic' }
  }
  redirect('/map')
}

export async function signOut () {
  await logout()
  redirect('/login')
}
