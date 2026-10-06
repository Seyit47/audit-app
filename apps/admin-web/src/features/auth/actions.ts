'use server'

import { redirect } from 'next/navigation'
import { logout } from '@/lib/session'

export async function signOut () {
  await logout()
  redirect('/login')
}
