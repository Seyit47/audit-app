'use server'

import { revalidatePath } from 'next/cache'
import { run } from '@/lib/action-result'
import { api } from '@/lib/api'

const revalidate = () => { revalidatePath('/districts'); revalidatePath('/shops') }

export async function addDistrict (name: string) {
  return run(async () => { await api('/v1/districts', { method: 'POST', body: { name } }); revalidate() })
}

export async function renameDistrict (id: string, name: string) {
  return run(async () => { await api(`/v1/districts/${id}`, { method: 'PATCH', body: { name } }); revalidate() })
}

export async function deleteDistrict (id: string) {
  return run(async () => { await api(`/v1/districts/${id}`, { method: 'DELETE' }); revalidate() })
}
