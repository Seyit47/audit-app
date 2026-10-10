'use client'

import { useState } from 'react'
import { useWatch, type Control, type FieldErrors, type UseFormRegister } from 'react-hook-form'
import { FormField, TextInput } from '@/components/ui/FormField'
import { passwordRules } from '../schema'

export interface PasswordCopy {
  password: string
  confirmPassword: string
  passwordPlaceholder: string
  showPassword: string
  hidePassword: string
  rules: { length: string, letter: string, digit: string, match: string }
}

/** The form fields this block owns. */
interface PasswordFormValues { password?: string, confirmPassword?: string }

/**
 * Password and its confirmation in a react-hook-form form, with the rules ticking off as the admin types and each
 * field's error under it. "Показать" reveals both.
 */
export function PasswordFields<T extends PasswordFormValues, O = T> ({ copy, label, autoFocus, register, control, errors, className = '' }: {
  copy: PasswordCopy
  label?: string
  autoFocus?: boolean
  register: UseFormRegister<T>
  control: Control<T, unknown, O>
  errors: FieldErrors<T>
  className?: string
}) {
  // The block only knows its own two fields; the casts narrow the form's types to them.
  const reg = register as unknown as UseFormRegister<PasswordFormValues>
  const ctl = control as unknown as Control<PasswordFormValues>
  const errs = errors as FieldErrors<PasswordFormValues>
  const [password = '', confirm = ''] = useWatch({ control: ctl, name: ['password', 'confirmPassword'] })
  const [shown, setShown] = useState(false)
  const rules = passwordRules(password, confirm)
  const toggle = (
    // Positioned by a wrapper: data-ripple makes the button itself position: relative.
    <span className='absolute right-2 top-1/2 -translate-y-1/2'>
      <button data-ripple type='button' onClick={() => setShown((s) => !s)} className='rounded-md px-2 py-1 text-[11px] font-semibold leading-4 text-accent'>
        {shown ? copy.hidePassword : copy.showPassword}
      </button>
    </span>
  )
  const input = (name: 'password' | 'confirmPassword', focus?: boolean) => (
    <div className='relative'>
      <TextInput
        variant='form' id={name} type={shown ? 'text' : 'password'} placeholder={copy.passwordPlaceholder}
        maxLength={128} autoComplete='new-password' autoFocus={focus} className='pr-24'
        {...reg(name, name === 'password' ? { deps: ['confirmPassword'] } : undefined)}
      />
      {toggle}
    </div>
  )
  return (
    <div className={`flex flex-col gap-2 ${className}`}>
      <div className='grid grid-cols-2 gap-x-6 gap-y-4'>
        <FormField variant='form' label={label ?? copy.password} required htmlFor='password' error={errs.password?.message}>
          {input('password', autoFocus)}
        </FormField>
        <FormField variant='form' label={copy.confirmPassword} required htmlFor='confirmPassword' error={errs.confirmPassword?.message}>
          {input('confirmPassword')}
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
