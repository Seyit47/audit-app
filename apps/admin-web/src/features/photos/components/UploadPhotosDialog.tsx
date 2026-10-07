'use client'

import { useRouter } from 'next/navigation'
import { useRef, useState } from 'react'
import { Button } from '@/components/ui/Button'
import { Dialog } from '@/components/ui/Dialog'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { FormField, SelectInput } from '@/components/ui/FormField'
import { uploadImage } from '@/lib/upload'
import { photosUploaded } from '../actions'
import type { PhotosCopy } from '../copy'

const MB = 1024 * 1024

/** Pictures "Upload Photos" (gap B1): choose a shop, add photos; stored as ADMIN_UPLOAD for that shop. */
export function UploadPhotosDialog ({ shops, copy, onClose }: { shops: Array<{ id: string, name: string, code: string }>, copy: PhotosCopy, onClose: () => void }) {
  const d = copy.uploadDialog
  const router = useRouter()
  const input = useRef<HTMLInputElement>(null)
  const [shopId, setShopId] = useState('')
  const [files, setFiles] = useState<File[]>([])
  const [busy, setBusy] = useState(false)
  const [message, setMessage] = useState<string | null>(null)

  async function upload () {
    setBusy(true); setMessage(null)
    let ok = 0
    for (const f of files) {
      try { await uploadImage(f, 'ADMIN_UPLOAD', { shopId }); ok++ } catch { /* reported below */ }
    }
    setBusy(false)
    await photosUploaded()
    router.refresh()
    if (ok === files.length) onClose()
    else setMessage(`${d.failed} (${d.done.replace('{n}', String(ok))})`)
  }

  return (
    <Dialog open variant='form' width={560} onClose={onClose} closeLabel={d.cancel} title={d.title} subtitle={d.subtitle}
      footer={
        <>
          {message != null && <p role='alert' className='mr-auto text-xs text-error'>{message}</p>}
          <Button variant='outline' size='md' onClick={onClose}>{d.cancel}</Button>
          <Button size='md' disabled={busy || shopId === '' || files.length === 0} onClick={() => { void upload() }}>{d.save}</Button>
        </>
      }>
      <FormField variant='form' label={d.shop} required htmlFor='upload-shop'>
        <SelectInput variant='form' id='upload-shop' value={shopId} onChange={(e) => setShopId(e.target.value)}>
          <option value='' disabled>{d.shopPlaceholder}</option>
          {shops.map((s) => <option key={s.id} value={s.id}>{s.name} ({s.code})</option>)}
        </SelectInput>
      </FormField>
      <FormField variant='form' label={d.files} required hint={d.hint}>
        <div className='flex flex-col gap-3 rounded-2xl border border-border/70 bg-slate-50/80 p-4'>
          <button type='button' onClick={() => input.current?.click()} className='flex h-[30px] items-center gap-1.5 self-start rounded-xl border border-border bg-pure-white px-3.5 text-xs font-medium leading-4 text-slate-700 shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
            <FigmaIcon name='upload' width={14} height={14} />{d.choose}
          </button>
          {files.length > 0 && (
            <div className='grid grid-cols-5 gap-1.5'>
              {files.map((f) => (
                // eslint-disable-next-line @next/next/no-img-element -- local preview
                <img key={f.name + f.size} src={URL.createObjectURL(f)} alt={f.name} className='aspect-square w-full rounded-lg object-cover' />
              ))}
            </div>
          )}
          <input ref={input} type='file' accept='image/jpeg,image/png,image/webp' multiple hidden
            onChange={(e) => setFiles([...(e.target.files ?? [])].filter((f) => f.size <= 10 * MB))} />
        </div>
      </FormField>
    </Dialog>
  )
}
