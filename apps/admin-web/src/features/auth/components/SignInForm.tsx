'use client'

import { useActionState } from 'react'
import { Button } from '@/components/ui/Button'
import { FormField, TextInput } from '@/components/ui/FormField'
import { signIn, type SignInState } from '../actions'
import type { authCopy } from '../copy'

export function SignInForm ({ copy }: { copy: typeof authCopy.en }) {
  const [state, action, pending] = useActionState<SignInState, FormData>(signIn, { error: null })
  return (
    <form action={action} className='flex flex-col gap-4'>
      <FormField label={copy.email} htmlFor='email' required>
        <TextInput id='email' name='email' type='email' autoComplete='username' required aria-invalid={state.error != null} />
      </FormField>
      <FormField label={copy.password} htmlFor='password' required error={state.error != null ? copy.errors[state.error] : undefined}>
        <TextInput id='password' name='password' type='password' autoComplete='current-password' required aria-invalid={state.error != null} />
      </FormField>
      <Button type='submit' size='md' disabled={pending} className='mt-2 h-10 w-full'>{copy.submit}</Button>
    </form>
  )
}
