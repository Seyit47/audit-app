'use client'

import { useState } from 'react'
import { TextInput } from '@/components/ui/FormField'

export const MIN_PASSWORD = 8

/** Password field of the salesman forms, with a Show / Hide toggle. The length rule is checked by the form (its message is localized). */
export function PasswordInput ({ id, name, placeholder, showLabel, hideLabel, autoFocus }: {
  id: string
  name: string
  placeholder: string
  showLabel: string
  hideLabel: string
  autoFocus?: boolean
}) {
  const [shown, setShown] = useState(false)
  return (
    <div className='relative'>
      <TextInput
        variant='form' id={id} name={name} type={shown ? 'text' : 'password'} placeholder={placeholder}
        maxLength={128} autoComplete='new-password' autoFocus={autoFocus} required className='pr-24'
      />
      {/* Positioned by a wrapper: data-ripple makes the button itself position: relative. */}
      <span className='absolute right-2 top-1/2 -translate-y-1/2'>
        <button data-ripple type='button' onClick={() => setShown((s) => !s)} className='rounded-md px-2 py-1 text-[11px] font-semibold leading-4 text-accent'>
          {shown ? hideLabel : showLabel}
        </button>
      </span>
    </div>
  )
}
