import 'server-only'
import { api, type Page } from '@/lib/api'
import type { Image } from '@/features/agents/api'

export type ProductStatus = 'ACTIVE' | 'INACTIVE' | 'DRAFT'

export interface Product {
  id: string
  sku: string
  name: string
  description: string | null
  category: { id: string, name: string }
  brand: string | null
  retailPrice: number
  image: Image | null
  status: ProductStatus
  stockTracked: boolean
  stockQty: number
  minStockAlert: number
  locations: number
  coveragePct: number | null
  regions: string[]
  compliancePct: number | null
  lastActivityAt: string | null
}

export interface ProductListQuery { page?: number, size?: number, q?: string, status?: ProductStatus }

export const listProducts = (query: ProductListQuery) => api<Page<Product>>('/v1/products', { query: { ...query } })
export const getProduct = (id: string) => api<Product>(`/v1/products/${id}`)
export const listCategories = () => api<Array<{ id: string, name: string }>>('/v1/product-categories')
