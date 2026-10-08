'use client'

import { FormLoadingDialog } from '@/components/ui/FormLoadingDialog'
import { useUrlForm } from '@/lib/use-url-form'
import type { Product } from '../api'
import type { ProductsCopy } from '../copy'
import { ProductFormDialog } from './ProductFormDialog'

interface ProductFormData { product: Product | null, categories: Array<{ id: string, name: string }> }

/** Add / edit product dialog of 495:2311, opened from `?add=1` or `?edit=<id>` without a server render. */
export function ProductFormHost ({ copy }: { copy: ProductsCopy }) {
  const form = useUrlForm<ProductFormData>('product')
  if (!form.open) return null
  const f = copy.form
  if (form.data == null) {
    return (
      <FormLoadingDialog
        title={form.id == null ? f.addTitle : f.editTitle} variant='form' width={981} closeLabel={f.close}
        onClose={() => window.history.replaceState(null, '', form.closeHref)}
        failed={form.failed} failedText={f.errors.generic}
      />
    )
  }
  return <ProductFormDialog key={form.key} product={form.data.product} categories={form.data.categories} copy={copy} closeHref={form.closeHref} animateIn={form.animateIn} />
}
