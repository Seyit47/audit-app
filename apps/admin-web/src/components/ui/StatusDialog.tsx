'use client'

import { useState, useTransition } from 'react'
import { guard, say } from '@/lib/feedback'
import { Button } from './Button'
import { Dialog } from './Dialog'
import { StatusSwitch, type StatusTone } from './FormField'

/**
 * "Change status" from a row's actions: only the status switch, so changing it doesn't open the whole edit form.
 * Saves with [onSave]; a failed save keeps the dialog open with [labels.error].
 */
export function StatusDialog<T extends string> ({ title, name, options, initial, labels, onClose, onSave }: {
  title: string
  /** The record being changed (shop, salesman or product name). */
  name: string
  options: Array<{ value: T, label: string, tone?: StatusTone }>
  initial: T
  labels: { cancel: string, save: string, error: string }
  onClose: () => void
  onSave: (status: T) => Promise<{ ok: boolean }>
}) {
  const [status, setStatus] = useState(initial)
  const [pending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)

  const save = () => {
    if (status === initial) return onClose()
    setError(null)
    startTransition(() => guard(async () => {
      const res = await onSave(status)
      if (!res.ok) return setError(labels.error)
      say('status')
      onClose()
    }))
  }

  return (
    <Dialog
      open variant='form' width={520} onClose={onClose} closeLabel={labels.cancel} title={title} subtitle={name}
      footer={
        <>
          {error != null && <p role='alert' className='mr-auto text-xs text-error'>{error}</p>}
          <Button variant='outline' size='md' data-dialog-close className='border-slate-300 text-slate-700'>{labels.cancel}</Button>
          <Button size='md' disabled={pending} onClick={save}>{labels.save}</Button>
        </>
      }
    >
      <StatusSwitch value={status} onChange={setStatus} options={options} />
    </Dialog>
  )
}
