'use client'

import { FormLoadingDialog } from '@/components/ui/FormLoadingDialog'
import { useUrlForm } from '@/lib/use-url-form'
import type { ShopDetails } from '../api'
import type { ShopFormCopy } from '../copy'
import { ShopEditDialog } from './ShopEditDialog'

interface ShopFormData {
  shop: ShopDetails | null
  agents: Array<{ id: string, fullName: string, code: string }>
  products: Array<{ id: string, name: string, sku: string }>
  productIds: string[]
}

/** Add / edit shop dialog of 162:20071, opened from `?add=1` or `?edit=…` without a server render. */
export function ShopFormHost ({ copy, shopId }: { copy: ShopFormCopy, shopId?: string }) {
  const form = useUrlForm<ShopFormData>('shop', shopId)
  if (!form.open) return null
  if (form.data == null) {
    return (
      <FormLoadingDialog
        title={form.id == null ? copy.addTitle : copy.editTitle} closeLabel={copy.close}
        enterStartedAt={form.enterStartedAt}
        onClose={() => window.history.replaceState(null, '', form.closeHref)}
        failed={form.failed} failedText={copy.errors.generic}
      />
    )
  }
  const d = form.data
  return <ShopEditDialog key={form.key} shop={d.shop} agents={d.agents} products={d.products} productIds={d.productIds} copy={copy} closeHref={form.closeHref} enterStartedAt={form.enterStartedAt} />
}
