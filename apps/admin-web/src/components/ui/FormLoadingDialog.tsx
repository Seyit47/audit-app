'use client'

import { Dialog } from './Dialog'
import { Bone } from './Skeleton'

/**
 * A URL dialog's frame while its form data loads (only when it wasn't prefetched): the same title, width and
 * variant as the form, with placeholder fields. A failed load shows the message instead.
 */
export function FormLoadingDialog ({ title, width, variant, closeLabel, onClose, failed, failedText, enterStartedAt }: {
  title: string
  width?: number
  variant?: 'edit' | 'form'
  closeLabel: string
  onClose: () => void
  failed: boolean
  failedText: string
  enterStartedAt?: number
}) {
  return (
    <Dialog open title={title} width={width} variant={variant} closeLabel={closeLabel} onClose={onClose} enterStartedAt={enterStartedAt}>
      {failed
        ? <p role='alert' className='py-6 text-center text-sm text-error'>{failedText}</p>
        : (
          <div className='flex flex-col gap-5 py-1'>
            {[0, 1, 2].map((i) => (
              <div key={i} className='grid grid-cols-2 gap-6'>
                <div className='flex flex-col gap-2'><Bone className='h-3.5 w-28' /><Bone className='h-11 rounded-lg' /></div>
                <div className='flex flex-col gap-2'><Bone className='h-3.5 w-24' /><Bone className='h-11 rounded-lg' /></div>
              </div>
            ))}
            <Bone className='h-20 rounded-lg' />
          </div>
          )}
    </Dialog>
  )
}
