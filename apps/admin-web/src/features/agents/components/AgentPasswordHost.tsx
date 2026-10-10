'use client'

import { useSearchParams } from 'next/navigation'
import { useState, useTransition } from 'react'
import { Button } from '@/components/ui/Button'
import { Dialog } from '@/components/ui/Dialog'
import { guard, say } from '@/lib/feedback'
import { setAgentPassword } from '../actions'
import type { AgentsCopy } from '../copy'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { passwordSchema, type PasswordValues } from '../schema'
import { PasswordFields } from './PasswordInput'

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

  // Each field reports what is wrong once it has been changed, and both on Save.
  const [schema] = useState(() => passwordSchema(f))
  const { register, control, handleSubmit, formState: { errors } } = useForm<PasswordValues>({
    resolver: zodResolver(schema),
    mode: 'onChange',
    defaultValues: { password: '', confirmPassword: '' }
  })

  const save = handleSubmit(({ password }) => {
    setError(null)
    startTransition(() => guard(async () => {
      const res = await setAgentPassword(id, password)
      if (!res.ok) return setError(f.errors.generic)
      say('passwordChanged')
      close()
    }))
  })

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
      <form id='agent-password-form' noValidate onSubmit={(e) => { void save(e) }} className='flex flex-col gap-2'>
        <PasswordFields copy={f} label={f.newPassword} autoFocus register={register} control={control} errors={errors} />
        <p className='text-xs leading-4 text-muted'>{f.passwordHint}</p>
      </form>
    </Dialog>
  )
}
