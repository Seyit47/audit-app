'use server'

import { revalidatePath } from 'next/cache'
import { api } from '@/lib/api'
import { run } from '@/lib/action-result'

export interface ProductInput {
  sku: string
  name: string
  categoryId: string
  brand: string | null
  retailPrice: number
  description: string | null
  imageId: string | null
  status: 'ACTIVE' | 'DRAFT' | 'INACTIVE'
  stockTracked: boolean
  stockQty: number
  minStockAlert: number
}

export async function saveProduct (id: string | null, input: ProductInput) {
  return run(async () => {
    const p = await api<{ id: string }>(id == null ? '/v1/products' : `/v1/products/${id}`, { method: id == null ? 'POST' : 'PATCH', body: input })
    revalidatePath('/products')
    return { id: p.id }
  })
}
