'use server'

import { revalidatePath } from 'next/cache'
import { run } from '@/lib/action-result'
import { api } from '@/lib/api'

export interface SettingsInput {
  companyName: string
  logoPhotoId: string | null
  workStart: string
  workEnd: string
  timezone: string
  visitFrequencyDays: number
  defaultAuditRadiusM: number
  minGpsAccuracyM: number
  noSignalMinutes: number
}

export async function saveSettings (input: SettingsInput) {
  return run(async () => {
    await api('/v1/settings', { method: 'PATCH', body: input })
    revalidatePath('/', 'layout')
  })
}

// Product categories (products need one; there is no other place to create them).
const revalidateCategories = () => { revalidatePath('/settings'); revalidatePath('/products') }

export async function addCategory (name: string) {
  return run(async () => { await api('/v1/product-categories', { method: 'POST', body: { name } }); revalidateCategories() })
}

export async function renameCategory (id: string, name: string) {
  return run(async () => { await api(`/v1/product-categories/${id}`, { method: 'PATCH', body: { name } }); revalidateCategories() })
}

export async function deleteCategory (id: string) {
  return run(async () => { await api(`/v1/product-categories/${id}`, { method: 'DELETE' }); revalidateCategories() })
}
