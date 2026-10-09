'use client'

import { useState } from 'react'
import { FormField, TextInput } from '@/components/ui/FormField'

/** The salesman password rules, the same as the API (`agents.schema.ts`). */
export const passwordRules = (password: string, confirm: string) => ({
  length: password.length >= 8,
  letter: /\p{L}/u.test(password),
  digit: /\d/.test(password),
  match: password !== '' && password === confirm
})
export const passwordOk = (password: string, confirm: string) => Object.values(passwordRules(password, confirm)).every(Boolean)

export interface PasswordCopy {
  password: string
  confirmPassword: string
  passwordPlaceholder: string
  showPassword: string
  hidePassword: string
  rules: { length: string, letter: string, digit: string, match: string }
}

function Field ({ id, name, placeholder, shown, onToggle, value, onChange, copy, autoFocus }: {
  id: string
  name: string
  placeholder: string
  shown: boolean
  onToggle: () => void
  value: string
  onChange: (v: string) => void
  copy: PasswordCopy
  autoFocus?: boolean
}) {
  return (
    <div className='relative'>
      <TextInput
        variant='form' id={id} name={name} type={shown ? 'text' : 'password'} placeholder={placeholder} value={value} onChange={(e) => onChange(e.target.value)}
        maxLength={128} autoComplete='new-password' autoFocus={autoFocus} required className='pr-24'
      />
      {/* Positioned by a wrapper: data-ripple makes the button itself position: relative. */}
      <span className='absolute right-2 top-1/2 -translate-y-1/2'>
        <button data-ripple type='button' onClick={onToggle} className='rounded-md px-2 py-1 text-[11px] font-semibold leading-4 text-accent'>
          {shown ? copy.hidePassword : copy.showPassword}
        </button>
      </span>
    </div>
  )
}

/**
 * Password and its confirmation, with the rules ticking off as the admin types. Both inputs post with the form
 * (`password`, `confirmPassword`); the caller checks `passwordOk` before saving.
 */
export function PasswordFields ({ copy, label, autoFocus, className = '' }: { copy: PasswordCopy, label?: string, autoFocus?: boolean, className?: string }) {
  const [password, setPassword] = useState('')
  const [confirm, setConfirm] = useState('')
  const [shown, setShown] = useState(false)
  const rules = passwordRules(password, confirm)
  const toggle = () => setShown((s) => !s)
  return (
    <div className={`flex flex-col gap-2 ${className}`}>
      <div className='grid grid-cols-2 gap-x-6 gap-y-4'>
        <FormField variant='form' label={label ?? copy.password} required htmlFor='password'>
          <Field id='password' name='password' placeholder={copy.passwordPlaceholder} shown={shown} onToggle={toggle} value={password} onChange={setPassword} copy={copy} autoFocus={autoFocus} />
        </FormField>
        <FormField variant='form' label={copy.confirmPassword} required htmlFor='confirmPassword'>
          <Field id='confirmPassword' name='confirmPassword' placeholder={copy.passwordPlaceholder} shown={shown} onToggle={toggle} value={confirm} onChange={setConfirm} copy={copy} />
        </FormField>
      </div>
      <ul aria-live='polite' className='flex flex-wrap gap-x-4 gap-y-1'>
        {(['length', 'letter', 'digit', 'match'] as const).map((k) => (
          <li key={k} className={`flex items-center gap-1.5 text-xs leading-4 transition-colors ${rules[k] ? 'text-success' : 'text-muted'}`}>
            <span aria-hidden className={`flex size-3.5 items-center justify-center rounded-full border transition-colors ${rules[k] ? 'border-success bg-success' : 'border-slate-300'}`}>
              {rules[k] && <svg viewBox='0 0 10 10' className='size-2 text-white'><path d='M2 5.2 4.1 7.3 8 3' fill='none' stroke='currentColor' strokeWidth='1.6' strokeLinecap='round' strokeLinejoin='round' /></svg>}
            </span>
            <span className='sr-only'>{rules[k] ? '✓ ' : '✗ '}</span>{copy.rules[k]}
          </li>
        ))}
      </ul>
    </div>
  )
}
