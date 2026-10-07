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

export async function addRegion (name: string) {
  return run(async () => { await api('/v1/regions', { method: 'POST', body: { name } }); revalidatePath('/settings') })
}

export async function renameRegion (id: string, name: string) {
  return run(async () => { await api(`/v1/regions/${id}`, { method: 'PATCH', body: { name } }); revalidatePath('/settings') })
}

export async function deleteRegion (id: string) {
  return run(async () => { await api(`/v1/regions/${id}`, { method: 'DELETE' }); revalidatePath('/settings') })
}
