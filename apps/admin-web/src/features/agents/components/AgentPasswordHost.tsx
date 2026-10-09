'use client'

import { useSearchParams } from 'next/navigation'
import { useState, useTransition } from 'react'
import { Button } from '@/components/ui/Button'
import { Dialog } from '@/components/ui/Dialog'
import { FormField } from '@/components/ui/FormField'
import { guard, say } from '@/lib/feedback'
import { setAgentPassword } from '../actions'
import type { AgentsCopy } from '../copy'
import { MIN_PASSWORD, PasswordInput } from './PasswordInput'

/**
 * "Изменить пароль" from a salesman's row actions: opens from `?password=<id>` in the browser (no server render),
 * like the add / edit dialogs.
 */
export function AgentPasswordHost ({ copy, agents }: { copy: AgentsCopy, agents: Array<{ id: string, fullName: string }> }) {
  const params = useSearchParams()
  const id = params.get('password')
  if (id == null) return null
  return <AgentPasswordDialog key={id} id={id} name={agents.find((a) => a.id === id)?.fullName} copy={copy} />
}

function AgentPasswordDialog ({ id, name, copy }: { id: string, name?: string, copy: AgentsCopy }) {
  const f = copy.form
  const [pending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)
  const close = () => {
    const next = new URLSearchParams(window.location.search)
    next.delete('password')
    const qs = next.toString()
    window.history.replaceState(null, '', `${window.location.pathname}${qs === '' ? '' : `?${qs}`}`)
  }

  function submit (form: FormData) {
    const password = String(form.get('password') ?? '')
    if (password.length < MIN_PASSWORD) return setError(f.errors.password)
    setError(null)
    startTransition(() => guard(async () => {
      const res = await setAgentPassword(id, password)
      if (!res.ok) return setError(f.errors.generic)
      say('passwordChanged')
      close()
    }))
  }

  return (
    <Dialog
      open variant='form' width={480} onClose={close} closeLabel={f.close} title={f.passwordTitle} subtitle={name}
      footer={
        <>
          {error != null && <p role='alert' className='mr-auto text-xs text-error'>{error}</p>}
          <Button variant='outline' size='md' data-dialog-close className='border-slate-300 text-slate-700'>{f.cancel}</Button>
          <Button type='submit' form='agent-password-form' size='md' disabled={pending}>{f.savePassword}</Button>
        </>
      }
    >
      {/* onSubmit, not action: React resets a form after an action, which wiped the fields on a validation error. */}
      <form id='agent-password-form' onSubmit={(e) => { e.preventDefault(); submit(new FormData(e.currentTarget)) }} className='flex flex-col gap-2'>
        <FormField variant='form' label={f.newPassword} required htmlFor='new-password'>
          <PasswordInput id='new-password' name='password' placeholder={f.passwordPlaceholder} showLabel={f.showPassword} hideLabel={f.hidePassword} autoFocus />
        </FormField>
        <p className='text-xs leading-4 text-muted'>{f.passwordHint}</p>
      </form>
    </Dialog>
  )
}
