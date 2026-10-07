'use server'

import { revalidatePath } from 'next/cache'
import { api } from '@/lib/api'
import { run } from '@/lib/action-result'

export interface ShopInput {
  name: string
  address: string
  lat: number
  lng: number
  facadePhotoId: string | null
  assignedAgentId: string | null
  contacts: Array<{ phone: string, label: string | null }>
}

const revalidate = (id?: string) => {
  revalidatePath('/shops')
  if (id != null) revalidatePath(`/shops/${id}`)
}

export async function createShop (input: ShopInput) {
  return run(async () => {
    const shop = await api<{ id: string }>('/v1/shops', { method: 'POST', body: input })
    revalidate()
    return { id: shop.id }
  })
}

export async function updateShop (id: string, version: number, input: ShopInput) {
  return run(async () => {
    const { contacts, ...fields } = input
    const shop = await api<{ version: number }>(`/v1/shops/${id}`, { method: 'PATCH', body: { version, ...fields } })
    await api(`/v1/shops/${id}/contacts`, { method: 'PUT', body: { contacts } })
    revalidate(id)
    return { version: shop.version }
  })
}

export async function setShopStatus (id: string, version: number, status: 'ACTIVE' | 'INACTIVE') {
  return run(async () => {
    await api(`/v1/shops/${id}`, { method: 'PATCH', body: { version, status } })
    revalidate(id)
  })
}

export async function assignShops (shopIds: string[], agentId: string | null) {
  return run(async () => {
    await api('/v1/shops/bulk/assign', { method: 'POST', body: { shopIds, agentId } })
    revalidate()
  })
}

export async function deleteShops (shopIds: string[]) {
  return run(async () => {
    await api('/v1/shops/bulk/delete', { method: 'POST', body: { shopIds } })
    revalidate()
  })
}
