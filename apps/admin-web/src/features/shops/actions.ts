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
  districtId: string
  agentIds: string[]
  contacts: Array<{ phone: string, label: string | null }>
  /** Products carried (gap A11). */
  productIds: string[]
}

const revalidate = (id?: string) => {
  revalidatePath('/shops')
  if (id != null) revalidatePath(`/shops/${id}`)
}

export async function createShop (input: ShopInput) {
  return run(async () => {
    const { productIds, ...body } = input
    const shop = await api<{ id: string }>('/v1/shops', { method: 'POST', body })
    await api(`/v1/shops/${shop.id}/products`, { method: 'PUT', body: { productIds } })
    revalidate()
    return { id: shop.id }
  })
}

export async function updateShop (id: string, version: number, input: ShopInput) {
  return run(async () => {
    const { contacts, productIds, ...fields } = input
    const shop = await api<{ version: number }>(`/v1/shops/${id}`, { method: 'PATCH', body: { version, ...fields } })
    await api(`/v1/shops/${id}/contacts`, { method: 'PUT', body: { contacts } })
    await api(`/v1/shops/${id}/products`, { method: 'PUT', body: { productIds } })
    revalidate(id)
    return { version: shop.version }
  })
}

export async function setShopStatus (id: string, version: number, status: 'ACTIVE' | 'INACTIVE' | 'PENDING_REVIEW') {
  return run(async () => {
    await api(`/v1/shops/${id}`, { method: 'PATCH', body: { version, status } })
    revalidate(id)
  })
}

/** Bulk "Назначить": the agents join the shops' agents, replace them, or leave them. */
export async function assignShops (shopIds: string[], agentIds: string[], mode: 'add' | 'replace' | 'remove') {
  return run(async () => {
    await api('/v1/shops/bulk/assign', { method: 'POST', body: { shopIds, agentIds, mode } })
    revalidate()
  })
}

/** "Перенести в район" (null: no district). */
export async function moveShops (shopIds: string[], districtId: string | null) {
  return run(async () => {
    await api('/v1/shops/bulk/district', { method: 'POST', body: { shopIds, districtId } })
    revalidate()
    revalidatePath('/districts')
  })
}

export async function deleteShops (shopIds: string[]) {
  return run(async () => {
    await api('/v1/shops/bulk/delete', { method: 'POST', body: { shopIds } })
    revalidate()
  })
}
