'use client'

import { guard, say } from '@/lib/feedback'
import { useRouter, useSearchParams } from 'next/navigation'
import { forgetFormData } from '@/lib/url-dialog'
import { useState, useTransition } from 'react'
import { Controller, useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Button } from '@/components/ui/Button'
import { Dialog } from '@/components/ui/Dialog'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { FormField, SelectInput, StatusSwitch, TextArea, TextInput } from '@/components/ui/FormField'
import { phoneField } from '@/lib/form'
import { displayPhone } from '@/lib/phone'
import { createAgent, rebindAgentDevice, updateAgent } from '../actions'
import type { Agent, Region } from '../api'
import type { AgentsCopy } from '../copy'
import { agentSchema, type AgentValues } from '../schema'
import { PasswordFields } from './PasswordInput'

/** Add / edit salesman dialog of Figma 495:3932, with exactly the frame's fields. */
export function AgentFormDialog ({ agent, regions, nextCode, copy, closeHref, enterStartedAt }: {
  agent: Agent | null
  regions: Region[]
  nextCode: string
  copy: AgentsCopy
  closeHref: string
  enterStartedAt?: number
}) {
  const f = copy.form
  const router = useRouter()
  const [pending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)
  const [schema] = useState(() => agentSchema(f, agent == null))
  // A field reports what is wrong once it has been changed, and every field on Save.
  const { register, control, handleSubmit, setValue, formState: { errors } } = useForm<AgentValues, unknown, ReturnType<typeof schema.parse>>({
    resolver: zodResolver(schema),
    mode: 'onChange',
    defaultValues: {
      fullName: agent?.fullName ?? '',
      code: agent?.code ?? nextCode,
      phone: displayPhone(agent?.phone),
      whatsappPhone: displayPhone(agent?.whatsappPhone),
      routeNotes: agent?.routeNotes ?? '',
      dailyVisitPlan: String(agent?.dailyVisitPlan ?? 25),
      dailyAuditPlan: String(agent?.dailyAuditPlan ?? 20),
      regionId: agent?.region.id ?? '',
      device: 'keep',
      status: agent == null ? 'ACTIVE' : !agent.active ? 'ARCHIVED' : agent.workStatus,
      password: '',
      confirmPassword: ''
    }
  })
  // The server renders the page without the dialog; the progress bar shows while it answers.
  // Open while the URL says so (`?add=1`, `?edit=…`). Closing only rewrites the URL in the browser: the page
  // behind is unchanged, so there is no server round trip to wait for (a slow or failed one used to leave
  // the page blocked). Data is refreshed only after a save.
  const params = useSearchParams()
  const open = params.has('add') || params.has('edit')
  const close = (changed = false) => {
    window.history.replaceState(null, '', closeHref)
    if (changed) { forgetFormData(); router.refresh() }
  }

  const save = handleSubmit((v) => {
    setError(null)
    const input = { ...v, whatsappPhone: v.whatsappPhone, phone: v.phone! }
    startTransition(() => guard(async () => {
      if (agent == null) {
        const res = await createAgent(input, v.password)
        if (!res.ok) return setError(res.code === 'CONFLICT' ? f.errors.CONFLICT : f.errors.generic)
        say('created')
        close(true)
      } else {
        const res = await updateAgent(agent.id, agent.version, input)
        if (!res.ok) return setError(res.code === 'CONFLICT' ? f.errors.CONFLICT : f.errors.generic)
        if (v.device === 'reset') await rebindAgentDevice(agent.id)
        say('saved')
        close(true)
      }
    }))
  })

  const device = agent?.device
  const deviceLabel = device?.model != null ? `${device.model}${device.imeiLabel != null ? ` (IMEI: ${device.imeiLabel})` : ''}` : null

  return (
    <Dialog
      open={open} enterStartedAt={enterStartedAt} variant='form' width={981} onClose={() => close()} closeLabel={f.close}
      title={agent == null ? f.addTitle : f.editTitle}
      subtitle={f.subtitle}
      footer={
        <>
          {error != null && <p role='alert' className='mr-auto text-xs text-error'>{error}</p>}
          <Button variant='outline' size='md' data-dialog-close className='border-slate-300 text-slate-700'>{f.cancel}</Button>
          <Button type='submit' form='agent-form' size='md' disabled={pending} icon={<FigmaIcon name='check-light' width={16} height={16} />}>{f.save}</Button>
        </>
      }
    >
      <form id='agent-form' noValidate onSubmit={(e) => { void save(e) }} className='flex flex-col gap-4'>
        <div className='grid grid-cols-2 gap-x-6 gap-y-4'>
          <FormField variant='form' label={f.fullName} required htmlFor='fullName' error={errors.fullName?.message}>
            <TextInput variant='form' id='fullName' placeholder={f.fullNamePlaceholder} {...register('fullName')} />
          </FormField>
          <FormField
            variant='form' label={f.code} required htmlFor='code' error={errors.code?.message}
            action={agent == null && <button data-ripple type='button' onClick={() => setValue('code', nextCode, { shouldValidate: true, shouldDirty: true })} className='-mx-1.5 rounded-md px-1.5 py-0.5 text-[10px] font-medium leading-[15px] text-[#4f46e5]'>{f.generate}</button>}
          >
            <TextInput variant='form' id='code' className='bg-slate-50/70 font-mono font-medium' {...register('code')} />
          </FormField>
          <FormField variant='form' label={f.phone} required htmlFor='phone' error={errors.phone?.message}>
            <TextInput variant='form' id='phone' placeholder='+993 65 124582' icon={<FigmaIcon name='phone-field' width={14} height={14} />} {...phoneField(register('phone'))} />
          </FormField>
          <FormField variant='form' label={f.whatsapp} htmlFor='whatsappPhone' error={errors.whatsappPhone?.message}>
            <TextInput variant='form' id='whatsappPhone' placeholder='+993 61 987654' icon={<FigmaIcon name='whatsapp-field' width={14} height={14} />} {...phoneField(register('whatsappPhone'))} />
          </FormField>
        </div>
        {/* Sign-in password, set when adding; later changes go through "Изменить пароль" in the row actions. */}
        {agent == null && <PasswordFields copy={f} register={register} control={control} errors={errors} />}
        <FormField variant='form' label={f.notes} htmlFor='routeNotes'>
          <TextArea id='routeNotes' placeholder={f.notesPlaceholder} rows={1} {...register('routeNotes')} />
        </FormField>
        <div className='grid grid-cols-2 gap-x-6'>
          <FormField variant='form' label={f.visitPlan} htmlFor='dailyVisitPlan' error={errors.dailyVisitPlan?.message}>
            <TextInput variant='form' id='dailyVisitPlan' type='number' min={1} max={100} suffix={f.visitSuffix} {...register('dailyVisitPlan', { deps: ['dailyAuditPlan'] })} />
          </FormField>
          <FormField variant='form' label={f.auditPlan} htmlFor='dailyAuditPlan' error={errors.dailyAuditPlan?.message}>
            <TextInput variant='form' id='dailyAuditPlan' type='number' min={0} max={100} suffix={f.auditSuffix} {...register('dailyAuditPlan')} />
          </FormField>
        </div>
        <FormField variant='form' label={f.region} required htmlFor='regionId' error={errors.regionId?.message}>
          <SelectInput variant='form' id='regionId' {...register('regionId')}>
            <option value='' disabled>{f.regionPlaceholder}</option>
            {regions.map((r) => <option key={r.id} value={r.id}>{r.name}</option>)}
          </SelectInput>
        </FormField>
        <div className='grid grid-cols-2 gap-x-6'>
          <FormField variant='form' label={f.device} htmlFor='device'>
            <SelectInput variant='form' id='device' disabled={deviceLabel == null} icon={<FigmaIcon name='device-phone' width={14} height={14} />} className='text-xs' {...register('device')}>
              <option value='keep'>{deviceLabel ?? f.deviceNone}</option>
              {deviceLabel != null && <option value='reset'>{f.deviceReset}</option>}
            </SelectInput>
          </FormField>
          <FormField variant='form' label={f.status}>
            {/* Same switch as the product status (761:2324): Активен green, Отпуск red, Архив grey. */}
            <Controller
              control={control} name='status'
              render={({ field }) => (
                <StatusSwitch
                  compact value={field.value} onChange={field.onChange}
                  options={([['ACTIVE', 'success'], ['ON_LEAVE', 'error'], ['ARCHIVED', 'muted']] as const).map(([v, tone]) => ({ value: v, label: f.statuses[v], tone }))}
                />
              )}
            />
          </FormField>
        </div>
      </form>
    </Dialog>
  )
}
