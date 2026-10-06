'use client'

import { useRef, useState } from 'react'
import { uploadImage } from '@/lib/upload'
import type { UploadKind } from '@/lib/upload-actions'
import { FigmaIcon } from './FigmaIcon'

/**
 * "Photo / Avatar Upload Section" of 162:20071 (495:4534): preview with caption, title, hint,
 * upload and remove actions. Uploads straight to storage and reports the new photo id.
 */
export function ImageUpload ({ title, hint, kind, shopId, previewUrl, caption, accept = 'image/jpeg,image/png', copy, onChange }: {
  title: string
  hint: string
  kind: UploadKind
  shopId?: string
  previewUrl: string | null
  caption?: string
  accept?: string
  copy: { upload: string, remove: string, uploading: string, failed: string }
  /** The uploaded photo, or null when removed. */
  onChange: (photo: { id: string, url: string } | null) => void
}) {
  const input = useRef<HTMLInputElement>(null)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [localUrl, setLocalUrl] = useState<string | null>(null)
  const [removed, setRemoved] = useState(false)
  const shown = removed ? null : (localUrl ?? previewUrl)

  async function pick (file: File | undefined) {
    if (file == null) return
    setBusy(true)
    setError(null)
    try {
      const id = await uploadImage(file, kind, { shopId })
      const url = URL.createObjectURL(file)
      setLocalUrl(url)
      setRemoved(false)
      onChange({ id, url })
    } catch {
      setError(copy.failed)
    } finally {
      setBusy(false)
      if (input.current != null) input.current.value = ''
    }
  }

  return (
    <section className='flex items-center gap-5 rounded-2xl border border-border/70 bg-slate-50/80 p-4'>
      <div className='relative flex size-20 shrink-0 flex-col justify-center overflow-hidden rounded-xl border-2 border-pure-white bg-dark-accent shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
        {shown != null && (
          // eslint-disable-next-line @next/next/no-img-element -- presigned or local object URL
          <img src={shown} alt='' className='size-full object-cover' />
        )}
        {shown != null && caption != null && (
          <span className='absolute inset-x-0 bottom-0 bg-black/60 py-0.5 text-center text-[9px] font-medium leading-[13.5px] text-white'>{caption}</span>
        )}
      </div>
      <div className='flex min-w-0 flex-1 flex-col gap-0.5'>
        <p className='text-sm font-semibold leading-5 text-slate-800'>{title}</p>
        <p className={`text-xs leading-4 ${error != null ? 'text-error' : 'text-slate-500'}`}>{error ?? hint}</p>
        <div className='flex items-center gap-2.5 pt-2'>
          <button
            type='button' disabled={busy} onClick={() => input.current?.click()}
            className='flex h-[30px] items-center gap-1.5 rounded-xl border border-border bg-pure-white px-3.5 text-xs font-medium leading-4 text-slate-700 shadow-[0px_1px_2px_rgba(0,0,0,0.05)] disabled:opacity-60'
          >
            <FigmaIcon name='upload' width={14} height={14} />
            {busy ? copy.uploading : copy.upload}
          </button>
          {shown != null && (
            <button
              type='button' disabled={busy} onClick={() => { setRemoved(true); setLocalUrl(null); onChange(null) }}
              className='flex h-7 items-center gap-1.5 rounded-lg px-3 text-xs font-medium leading-4 text-error'
            >
              <FigmaIcon name='delete' width={14} height={14} />
              {copy.remove}
            </button>
          )}
        </div>
      </div>
      <input ref={input} type='file' accept={accept} hidden onChange={(e) => { void pick(e.target.files?.[0]) }} />
    </section>
  )
}
