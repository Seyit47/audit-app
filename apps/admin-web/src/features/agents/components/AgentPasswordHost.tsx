'use client'

import { useSearchParams } from 'next/navigation'
import { useState, useTransition } from 'react'
import { Button } from '@/components/ui/Button'
import { Dialog } from '@/components/ui/Dialog'
import { guard, say } from '@/lib/feedback'
import { setAgentPassword } from '../actions'
import type { AgentsCopy } from '../copy'
import { PasswordFields, passwordOk, passwordRules } from './PasswordInput'
import { useLiveValidation } from '@/lib/use-live-validation'

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

  // Each field says what is wrong as soon as it has been changed (and both on Save).
  const live = useLiveValidation({
    password: (v) => { const r = passwordRules(v, v); return r.length && r.letter && r.digit ? null : f.errors.password },
    confirmPassword: (v, get) => v !== get('password') ? f.errors.confirm : null
  })

  function submit (form: FormData, el: HTMLFormElement) {
    if (!live.validate(el)) return setError(null)
    const password = String(form.get('password') ?? '')
    if (!passwordOk(password, String(form.get('confirmPassword') ?? ''))) return setError(f.errors.password)
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
      open variant='form' width={640} onClose={close} closeLabel={f.close} title={f.passwordTitle} subtitle={name}
      footer={
        <>
          {error != null && <p role='alert' className='mr-auto text-xs text-error'>{error}</p>}
          <Button variant='outline' size='md' data-dialog-close className='border-slate-300 text-slate-700'>{f.cancel}</Button>
          <Button type='submit' form='agent-password-form' size='md' disabled={pending}>{f.savePassword}</Button>
        </>
      }
    >
      {/* onSubmit, not action: React resets a form after an action, which wiped the fields on a validation error. */}
      <form id='agent-password-form' noValidate onInput={live.onInput} onSubmit={(e) => { e.preventDefault(); submit(new FormData(e.currentTarget), e.currentTarget) }} className='flex flex-col gap-2'>
        <PasswordFields copy={f} label={f.newPassword} autoFocus errors={{ password: live.error('password'), confirmPassword: live.error('confirmPassword') }} />
        <p className='text-xs leading-4 text-muted'>{f.passwordHint}</p>
      </form>
    </Dialog>
  )
}
