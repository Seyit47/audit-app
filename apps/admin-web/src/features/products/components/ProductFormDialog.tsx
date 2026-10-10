'use client'

import { guard, say } from '@/lib/feedback'
import { useRouter, useSearchParams } from 'next/navigation'
import { forgetFormData } from '@/lib/url-dialog'
import { useRef, useState, useTransition } from 'react'
import { Controller, useForm, useWatch } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Button } from '@/components/ui/Button'
import { Dialog } from '@/components/ui/Dialog'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { FormField, SelectInput, StatusSwitch, TextArea, TextInput } from '@/components/ui/FormField'
import { Toggle } from '@/components/ui/Toggle'
import { uploadImage } from '@/lib/upload'
import { saveProduct } from '../actions'
import type { Product } from '../api'
import type { ProductsCopy } from '../copy'
import { productSchema, type ProductValues } from '../schema'

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
  const [schema] = useState(() => productSchema(f))
  // A field reports what is wrong once it has been changed, and every field on Save.
  const { register, control, handleSubmit, formState: { errors } } = useForm<ProductValues, unknown, ReturnType<typeof schema.parse>>({
    resolver: zodResolver(schema),
    mode: 'onChange',
    defaultValues: {
      name: product?.name ?? '',
      sku: product?.sku ?? '',
      categoryId: product?.category.id ?? '',
      brand: product?.brand ?? '',
      description: product?.description ?? '',
      retailPrice: product != null ? product.retailPrice.toFixed(2) : '',
      status: product?.status ?? 'ACTIVE',
      stockTracked: product?.stockTracked ?? false,
      stockQty: String(product?.stockQty ?? 0),
      minStockAlert: String(product?.minStockAlert ?? 0)
    }
  })
  const stock = useWatch({ control, name: 'stockTracked' })
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

  const save = handleSubmit((v) => {
    setError(null)
    startTransition(() => guard(async () => {
      const res = await saveProduct(product?.id ?? null, { ...v, imageId: image?.id ?? null })
      if (!res.ok) return setError(res.code === 'CONFLICT' ? f.errors.CONFLICT : f.errors.generic)
      say(product == null ? 'created' : 'saved')
      close(true)
    }))
  })

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
      <form id='product-form' noValidate onSubmit={(e) => { void save(e) }} className='flex flex-col gap-5'>
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
            <TextArea id='description' placeholder={f.descriptionPlaceholder} className='h-[114px] text-sm leading-5 shadow-none' {...register('description')} />
          </FormField>
        </div>
        <div className='grid grid-cols-2 gap-5'>
          <FormField variant='form' label={f.name} required htmlFor='name' error={errors.name?.message}>
            <TextInput variant='form' id='name' placeholder={f.namePlaceholder} className={big} {...register('name')} />
          </FormField>
          <FormField variant='form' label={f.sku} required htmlFor='sku' error={errors.sku?.message}>
            <TextInput variant='form' id='sku' placeholder={f.skuPlaceholder} className={`${big} font-mono`} {...register('sku')} />
          </FormField>
        </div>
        <div className='grid grid-cols-2 gap-4'>
          <FormField variant='form' label={f.category} required htmlFor='categoryId' error={errors.categoryId?.message}>
            <SelectInput variant='form' id='categoryId' className='h-[46px] shadow-none' {...register('categoryId')}>
              <option value='' disabled>{f.categoryPlaceholder}</option>
              {categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </SelectInput>
          </FormField>
          <FormField variant='form' label={f.brand} htmlFor='brand'>
            <TextInput variant='form' id='brand' placeholder={f.brandPlaceholder} className={big} {...register('brand')} />
          </FormField>
        </div>
        <div className='grid grid-cols-2 gap-4'>
          <FormField variant='form' label={f.price} required htmlFor='retailPrice' error={errors.retailPrice?.message}>
            <TextInput variant='form' id='retailPrice' inputMode='decimal' placeholder='185.00' suffix={f.currency} className={big} {...register('retailPrice')} />
          </FormField>
          <FormField variant='form' label={f.statusLabel}>
            <Controller
              control={control} name='status'
              render={({ field }) => (
                <StatusSwitch compact value={field.value} onChange={field.onChange} options={([['ACTIVE', 'success'], ['DRAFT', 'error'], ['INACTIVE', 'muted']] as const).map(([v, tone]) => ({ value: v, label: f.statuses[v], tone }))} />
              )}
            />
          </FormField>
        </div>
        <section className='flex flex-col gap-4 rounded-2xl border border-border bg-slate-50 p-6'>
          <div className='flex items-center justify-between'>
            <span className='flex items-center gap-2 text-sm font-semibold leading-5 text-ink'><FigmaIcon name='stock-box' width={16} height={16} />{f.stock}</span>
            <Controller control={control} name='stockTracked' render={({ field }) => <Toggle checked={field.value} onChange={field.onChange} label={f.stock} />} />
          </div>
          {stock && (
            <div className='grid grid-cols-2 gap-4'>
              <FormField variant='form' label={f.stockQty} htmlFor='stockQty' error={errors.stockQty?.message}>
                <TextInput variant='form' id='stockQty' type='number' min={0} className={big} {...register('stockQty')} />
              </FormField>
              <FormField variant='form' label={f.minStock} htmlFor='minStockAlert' error={errors.minStockAlert?.message}>
                <TextInput variant='form' id='minStockAlert' type='number' min={0} className={big} {...register('minStockAlert')} />
              </FormField>
            </div>
          )}
        </section>
      </form>
    </Dialog>
  )
}
