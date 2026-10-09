'use client'

import { guard, say } from '@/lib/feedback'
import { useRouter, useSearchParams } from 'next/navigation'
import { forgetFormData } from '@/lib/url-dialog'
import { useRef, useState, useTransition } from 'react'
import { Button } from '@/components/ui/Button'
import { Dialog } from '@/components/ui/Dialog'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { FormField, SelectInput, StatusSwitch, TextArea, TextInput } from '@/components/ui/FormField'
import { Toggle } from '@/components/ui/Toggle'
import { uploadImage } from '@/lib/upload'
import { saveProduct, type ProductInput } from '../actions'
import type { Product } from '../api'
import type { ProductsCopy } from '../copy'

const MB = 1024 * 1024
const big = 'h-[42px] text-sm leading-5 shadow-none'

/** Add / edit product dialog of Figma 495:2311 (495:2553), with exactly the frame's fields. */
export function ProductFormDialog ({ product, categories, copy, closeHref, enterStartedAt }: {
  product: Product | null
  categories: Array<{ id: string, name: string }>
  copy: ProductsCopy
  closeHref: string
  enterStartedAt?: number
}) {
  const f = copy.form
  const router = useRouter()
  const file = useRef<HTMLInputElement>(null)
  const [pending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)
  const [status, setStatus] = useState<ProductInput['status']>(product?.status ?? 'ACTIVE')
  const [stock, setStock] = useState(product?.stockTracked ?? false)
  const [image, setImage] = useState<{ id: string, url: string, name: string } | null>(product?.image != null ? { id: product.image.id, url: product.image.previewUrl400, name: '' } : null)
  const [uploading, setUploading] = useState(false)
  // The server renders the page without the dialog; the progress bar shows while it answers.
  // Open while the URL says so (`?add=1`, `?edit=…`). Closing only rewrites the URL in the browser: the page
  // behind is unchanged, so there is no server round trip to wait for (a slow or failed one used to leave
  // the page blocked). Data is refreshed only after a save.
  const params = useSearchParams()
  const open = params.has('add') || params.has('edit')
  const close = (changed = false) => {
    window.history.replaceState(null, '', closeHref)
    if (changed) { forgetFormData(); router.refresh() }
  }

  async function pick (picked: File | undefined) {
    if (picked == null) return
    if (!['image/png', 'image/jpeg'].includes(picked.type) || picked.size > 5 * MB) return setError(f.errors.image)
    setUploading(true); setError(null)
    try {
      const id = await uploadImage(picked, 'PRODUCT')
      setImage({ id, url: URL.createObjectURL(picked), name: picked.name })
    } catch {
      setError(f.uploadFailed)
    } finally {
      setUploading(false)
    }
  }

  function submit (form: FormData) {
    const s = (k: string) => String(form.get(k) ?? '').trim()
    const input: ProductInput = {
      sku: s('sku'), name: s('name'), categoryId: s('categoryId'), brand: s('brand') || null,
      retailPrice: Number(s('retailPrice').replace(',', '.')), description: s('description') || null,
      imageId: image?.id ?? null, status, stockTracked: stock,
      stockQty: Number(s('stockQty') || product?.stockQty || 0), minStockAlert: Number(s('minStockAlert') || product?.minStockAlert || 0)
    }
    if (!input.sku || !input.name || !input.categoryId || !Number.isFinite(input.retailPrice) || s('retailPrice') === '') return setError(f.errors.required)
    setError(null)
    startTransition(() => guard(async () => {
      const res = await saveProduct(product?.id ?? null, input)
      if (!res.ok) return setError(res.code === 'CONFLICT' ? f.errors.CONFLICT : f.errors.generic)
      say(product == null ? 'created' : 'saved')
      close(true)
    }))
  }

  return (
    <Dialog
      open={open} enterStartedAt={enterStartedAt} variant='form' width={981} onClose={() => close()} closeLabel={f.close}
      title={product == null ? f.addTitle : f.editTitle} subtitle={f.subtitle}
      footer={
        <>
          {error != null && <p role='alert' className='mr-auto text-xs text-error'>{error}</p>}
          <Button variant='outline' size='md' data-dialog-close className='border-slate-300 text-slate-700'>{f.cancel}</Button>
          <Button type='submit' form='product-form' size='md' disabled={pending || uploading} icon={<FigmaIcon name='check-light' width={16} height={16} />}>{f.save}</Button>
        </>
      }
    >
      {/* onSubmit, not action: React resets a form after an action, which wiped the fields on a validation error. */}
      <form id='product-form' onSubmit={(e) => { e.preventDefault(); submit(new FormData(e.currentTarget)) }} className='flex flex-col gap-5'>
        <div className='grid grid-cols-2 gap-5'>
          <div className='flex flex-col gap-1.5'>
            <span className='text-xs font-bold leading-4 text-default-black'>{f.image}</span>
            <div className='flex items-center gap-5 rounded-2xl border border-border/70 bg-slate-50/80 p-4'>
              <button data-ripple type='button' onClick={() => file.current?.click()} className='flex size-20 shrink-0 flex-col items-center justify-center overflow-hidden rounded-2xl border-2 border-dashed border-indigo-200 bg-pure-white shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
                {image != null
                  // eslint-disable-next-line @next/next/no-img-element -- presigned or local preview
                  ? <img src={image.url} alt='' className='size-full object-cover' />
                  : <><FigmaIcon name='product-camera' width={28} height={28} /><span className='pt-1 text-[10px] font-semibold leading-4 text-accent'>{f.photo}</span></>}
              </button>
              <div className='flex min-w-0 flex-1 flex-col gap-0.5'>
                <p className='text-xs leading-4 text-slate-500'>{f.imageHint}</p>
                <div className='flex items-center gap-2.5 pt-2'>
                  <button data-ripple type='button' disabled={uploading} onClick={() => file.current?.click()} className='flex h-[30px] items-center gap-1.5 rounded-xl border border-border bg-pure-white px-3.5 text-xs font-medium leading-4 text-slate-700 shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
                    <FigmaIcon name='upload' width={14} height={14} />{uploading ? f.uploading : f.chooseFile}
                  </button>
                  <span className='truncate text-xs leading-4 text-off-white'>{image?.name || (image == null ? f.noFile : '')}</span>
                </div>
              </div>
              <input ref={file} type='file' accept='image/png,image/jpeg' hidden onChange={(e) => { void pick(e.target.files?.[0]) }} />
            </div>
          </div>
          <FormField variant='form' label={f.descriptionLabel} htmlFor='description'>
            <TextArea id='description' name='description' defaultValue={product?.description ?? ''} placeholder={f.descriptionPlaceholder} className='h-[114px] text-sm leading-5 shadow-none' />
          </FormField>
        </div>
        <div className='grid grid-cols-2 gap-5'>
          <FormField variant='form' label={f.name} required htmlFor='name'>
            <TextInput variant='form' id='name' name='name' defaultValue={product?.name} placeholder={f.namePlaceholder} className={big} />
          </FormField>
          <FormField variant='form' label={f.sku} required htmlFor='sku'>
            <TextInput variant='form' id='sku' name='sku' defaultValue={product?.sku} placeholder={f.skuPlaceholder} className={`${big} font-mono`} />
          </FormField>
        </div>
        <div className='grid grid-cols-2 gap-4'>
          <FormField variant='form' label={f.category} required htmlFor='categoryId'>
            <SelectInput variant='form' id='categoryId' name='categoryId' defaultValue={product?.category.id ?? ''} className='h-[46px] shadow-none'>
              <option value='' disabled>{f.categoryPlaceholder}</option>
              {categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </SelectInput>
          </FormField>
          <FormField variant='form' label={f.brand} htmlFor='brand'>
            <TextInput variant='form' id='brand' name='brand' defaultValue={product?.brand ?? ''} placeholder={f.brandPlaceholder} className={big} />
          </FormField>
        </div>
        <div className='grid grid-cols-2 gap-4'>
          <FormField variant='form' label={f.price} required htmlFor='retailPrice'>
            <TextInput variant='form' id='retailPrice' name='retailPrice' inputMode='decimal' defaultValue={product != null ? product.retailPrice.toFixed(2) : ''} placeholder='185.00' suffix={f.currency} className={big} />
          </FormField>
          <FormField variant='form' label={f.statusLabel}>
            <StatusSwitch<ProductInput['status']> compact value={status} onChange={setStatus} options={([['ACTIVE', 'success'], ['DRAFT', 'error'], ['INACTIVE', 'muted']] as const).map(([v, tone]) => ({ value: v, label: f.statuses[v], tone }))} />
          </FormField>
        </div>
        <section className='flex flex-col gap-4 rounded-2xl border border-border bg-slate-50 p-6'>
          <div className='flex items-center justify-between'>
            <span className='flex items-center gap-2 text-sm font-semibold leading-5 text-ink'><FigmaIcon name='stock-box' width={16} height={16} />{f.stock}</span>
            <Toggle checked={stock} onChange={setStock} label={f.stock} />
          </div>
          {stock && (
            <div className='grid grid-cols-2 gap-4'>
              <FormField variant='form' label={f.stockQty} htmlFor='stockQty'>
                <TextInput variant='form' id='stockQty' name='stockQty' type='number' min={0} defaultValue={product?.stockQty ?? 0} className={big} />
              </FormField>
              <FormField variant='form' label={f.minStock} htmlFor='minStockAlert'>
                <TextInput variant='form' id='minStockAlert' name='minStockAlert' type='number' min={0} defaultValue={product?.minStockAlert ?? 0} className={big} />
              </FormField>
            </div>
          )}
        </section>
      </form>
    </Dialog>
  )
}
