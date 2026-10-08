'use client'

import { guard, say } from '@/lib/feedback'
import dynamic from 'next/dynamic'
import { useRouter, useSearchParams } from 'next/navigation'
import { forgetFormData } from '@/lib/url-dialog'
import { useState, useTransition } from 'react'
import { Button } from '@/components/ui/Button'
import { Dialog } from '@/components/ui/Dialog'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { FormField, SelectInput, TextInput } from '@/components/ui/FormField'
import { ImageUpload } from '@/components/ui/ImageUpload'
import { MultiSelect } from '@/components/ui/MultiSelect'
import { createShop, setShopStatus, updateShop, type ShopInput } from '../actions'
import type { Shop } from '../api'
import type { ShopFormCopy } from '../copy'

const MapView = dynamic(() => import('@/components/ui/MapView').then((m) => m.MapView), { ssr: false })
const ShopMarker = dynamic(() => import('@/components/ui/MapView').then((m) => m.ShopMarker), { ssr: false })

const MAX_PHONES = 4
type Phone = { phone: string, label: string }

/** Edit / add shop dialog of Figma 162:20071, with exactly the frame's fields. */
export function ShopEditDialog ({ shop, agents, products, productIds, copy, closeHref, animateIn = true }: {
  shop: Shop | null
  agents: Array<{ id: string, fullName: string, code: string }>
  products: Array<{ id: string, name: string, sku: string }>
  productIds: string[]
  copy: ShopFormCopy
  closeHref: string
  animateIn?: boolean
}) {
  const router = useRouter()
  const [pending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)
  const [name, setName] = useState(shop?.name ?? '')
  const [address, setAddress] = useState(shop?.address ?? '')
  const [agentId, setAgentId] = useState(shop?.agent?.id ?? '')
  const [point, setPoint] = useState<{ lat: number, lng: number } | null>(shop != null ? { lat: shop.lat, lng: shop.lng } : null)
  const [picking, setPicking] = useState(shop == null)
  const [carried, setCarried] = useState<string[]>(productIds)
  const [facadeId, setFacadeId] = useState<string | null>(shop?.facade?.id ?? null)
  const [phones, setPhones] = useState<Phone[]>(shop?.contacts.length ? shop.contacts.map((c) => ({ phone: c.phone, label: c.label ?? '' })) : [{ phone: '', label: '' }])
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

  function save () {
    if (name.trim() === '' || address.trim() === '' || point == null) return setError(copy.errors.required)
    const input: ShopInput = {
      name: name.trim(),
      address: address.trim(),
      lat: point.lat,
      lng: point.lng,
      facadePhotoId: facadeId,
      assignedAgentId: agentId === '' ? null : agentId,
      contacts: phones.filter((p) => p.phone.trim() !== '').map((p) => ({ phone: p.phone.trim(), label: p.label.trim() || null })),
      productIds: carried
    }
    setError(null)
    startTransition(() => guard(async () => {
      const res = shop == null ? await createShop(input) : await updateShop(shop.id, shop.version, input)
      if (!res.ok) return setError(res.code === 'CONFLICT' ? copy.errors.CONFLICT : copy.errors.generic)
      say(shop == null ? 'created' : 'saved')
      close(true)
    }))
  }

  function toggleArchive () {
    if (shop == null) return
    startTransition(() => guard(async () => {
      const res = await setShopStatus(shop.id, shop.version, shop.status === 'INACTIVE' ? 'ACTIVE' : 'INACTIVE')
      if (!res.ok) return setError(res.code === 'CONFLICT' ? copy.errors.CONFLICT : copy.errors.generic)
      say('status')
      close(true)
    }))
  }

  const setPhone = (i: number, patch: Partial<Phone>) => setPhones((ps) => ps.map((p, j) => (j === i ? { ...p, ...patch } : p)))

  return (
    <Dialog
      open={open} animateIn={animateIn} onClose={() => close()} closeLabel={copy.close}
      title={shop == null ? copy.addTitle : copy.editTitle}
      badge={shop?.code}
      subtitle={copy.subtitle}
      footer={
        <>
          {shop != null
            ? <button data-ripple type='button' onClick={toggleArchive} disabled={pending} className='px-2 py-1 text-xs font-medium leading-4 text-error'>{shop.status === 'INACTIVE' ? copy.restore : copy.archive}</button>
            : <span />}
          <div className='flex items-center gap-3'>
            {error != null && <p role='alert' className='max-w-80 text-xs text-error'>{error}</p>}
            <Button variant='outline' size='md' data-dialog-close>{copy.cancel}</Button>
            <Button size='md' disabled={pending} onClick={save}>{copy.save}</Button>
          </div>
        </>
      }
    >
      <ImageUpload
        title={copy.photoTitle}
        hint={copy.photoHint}
        kind='FACADE'
        shopId={shop?.id}
        previewUrl={shop?.facade?.previewUrl400 ?? null}
        caption={copy.photoCaption}
        copy={{ upload: copy.upload, remove: copy.remove, uploading: copy.uploading, failed: copy.uploadFailed }}
        onChange={(photo) => setFacadeId(photo?.id ?? null)}
      />

      <div className='grid grid-cols-2 gap-4'>
        <FormField label={copy.name} required hint={copy.nameHint} htmlFor='shop-name'>
          <TextInput id='shop-name' value={name} onChange={(e) => setName(e.target.value)} />
        </FormField>
        <FormField label={copy.agent} hint={copy.agentHint} htmlFor='shop-agent'>
          <div className='pt-0.5'>
            <SelectInput id='shop-agent' value={agentId} onChange={(e) => setAgentId(e.target.value)}>
              <option value=''>{copy.noAgent}</option>
              {agents.map((a) => <option key={a.id} value={a.id}>{a.fullName} {a.code}</option>)}
            </SelectInput>
          </div>
        </FormField>
      </div>

      <FormField label={copy.products} htmlFor='shop-products'>
        <MultiSelect
          id='shop-products' value={carried} onChange={setCarried}
          options={products.map((p) => ({ value: p.id, label: p.name, hint: p.sku }))}
          placeholder={copy.productsPlaceholder} searchPlaceholder={copy.productsSearch}
          summary={(n) => copy.productsSelected.replace('{n}', String(n))}
        />
      </FormField>

      <div className='flex flex-col gap-3'>
        <FormField
          label={copy.address} required htmlFor='shop-address'
          action={
            <button data-ripple type='button' onClick={() => setPicking(!picking)} className='-mx-1.5 -my-1 rounded-md px-1.5 py-1 flex items-center gap-1 text-xs font-semibold leading-4 text-accent'>
              <FigmaIcon name='map-pin-accent' width={14} height={14} />{copy.pickOnMap}
            </button>
          }
        >
          <div className='flex h-[42px] items-center justify-between gap-2 rounded-lg border border-border px-3.5'>
            <span className='flex min-w-0 flex-1 items-center gap-2'>
              <FigmaIcon name='building' width={16} height={16} />
              <input id='shop-address' value={address} onChange={(e) => setAddress(e.target.value)} className='min-w-0 flex-1 bg-transparent text-sm font-medium leading-5 text-black focus:outline-none' />
            </span>
            {point != null
              ? <span className='flex shrink-0 items-center gap-1 rounded-full bg-success-10 px-2 py-0.5 font-display text-[11px] font-medium leading-[16.5px] text-success'><FigmaIcon name='check-success' width={12} height={12} />{copy.gpsBound}</span>
              : <span className='shrink-0 rounded-full bg-error-bg px-2 py-0.5 font-display text-[11px] font-medium leading-[16.5px] text-error'>{copy.gpsMissing}</span>}
          </div>
        </FormField>
        {picking && (
          <div className='h-56 overflow-hidden rounded-lg border border-border'>
            <MapView initialView={point != null ? { latitude: point.lat, longitude: point.lng, zoom: 15 } : undefined} onClick={(p) => setPoint({ lat: p.lat, lng: p.lng })}>
              {point != null && <ShopMarker latitude={point.lat} longitude={point.lng} label={name || copy.name} />}
            </MapView>
          </div>
        )}
        <div className='flex items-center justify-between gap-4 rounded-lg border border-border bg-main-bg px-3.5 py-2'>
          <span className='font-mono text-xs leading-4 text-default-black'>
            {point != null
              ? <>{copy.coords}: <b>{point.lat.toFixed(6)}° N, {point.lng.toFixed(6)}° E</b>{shop?.region != null && ` (${copy.zone}: ${shop.region.name})`}</>
              : copy.mapHint}
          </span>
          <button data-ripple type='button' onClick={() => setPicking(true)} className='-mx-1.5 -my-1 rounded-md px-1.5 py-1 shrink-0 text-[11px] font-medium leading-4 text-accent'>{copy.calibrate}</button>
        </div>
      </div>

      <div className='flex flex-col gap-2 pb-1'>
        <div className='flex items-center justify-between'>
          <span className='text-xs font-semibold leading-4 text-default-black'>{copy.phones}</span>
          <span className='text-xs leading-4 text-off-white'>{copy.phonesHint}</span>
        </div>
        <div className='flex flex-col gap-2.5'>
          {phones.map((p, i) => (
            <div key={i} className='flex items-center gap-2'>
              <div className='relative w-[405px]'>
                <span className='pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 font-display text-xs leading-4 text-off-white'>№{i + 1}</span>
                <input
                  value={p.phone} onChange={(e) => setPhone(i, { phone: e.target.value })} type='tel' aria-label={`${copy.phones} ${i + 1}`}
                  className='h-[38px] w-full rounded-lg border border-border pl-9 pr-3 font-display text-sm leading-5 text-black focus:border-accent focus:outline-none'
                />
              </div>
              <input
                value={p.label} onChange={(e) => setPhone(i, { label: e.target.value })} placeholder={copy.phoneLabel} aria-label={copy.phoneLabel}
                className='h-[34px] w-[223px] rounded-lg border border-border px-3 text-xs leading-4 text-default-black placeholder:text-off-white focus:border-accent focus:outline-none'
              />
              <button data-ripple type='button' aria-label={copy.removePhone} onClick={() => setPhones((ps) => ps.filter((_, j) => j !== i))} className='rounded-lg p-2'>
                <FigmaIcon name='phone-delete' width={16} height={16} />
              </button>
            </div>
          ))}
        </div>
        {phones.length < MAX_PHONES && (
          <button data-ripple type='button' onClick={() => setPhones((ps) => [...ps, { phone: '', label: '' }])} className='-mx-1.5 -mb-1 rounded-md px-1.5 pb-1 flex items-center gap-1.5 self-start pt-0.5 text-xs font-semibold leading-4 text-accent'>
            <FigmaIcon name='plus-accent' width={14} height={14} />{copy.addPhone}
          </button>
        )}
      </div>
    </Dialog>
  )
}
