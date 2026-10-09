'use client'

import { guard, say } from '@/lib/feedback'
import { useRouter, useSearchParams } from 'next/navigation'
import { forgetFormData } from '@/lib/url-dialog'
import { useState, useTransition } from 'react'
import { Button } from '@/components/ui/Button'
import { Dialog } from '@/components/ui/Dialog'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { FormField, SelectInput, StatusSwitch, TextArea, TextInput } from '@/components/ui/FormField'
import { createAgent, rebindAgentDevice, resetAgentPassword, updateAgent, type AgentInput } from '../actions'
import type { Agent, Region } from '../api'
import type { AgentsCopy } from '../copy'
import { displayPhone, phoneInputProps, tmPhone } from '@/lib/phone'

type Status = AgentInput['status']

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
  const [password, setPassword] = useState<string | null>(null)
  const [code, setCode] = useState(agent?.code ?? nextCode)
  const [status, setStatus] = useState<Status>(agent == null ? 'ACTIVE' : !agent.active ? 'ARCHIVED' : agent.workStatus)
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

  function submit (form: FormData) {
    const s = (k: string) => String(form.get(k) ?? '').trim()
    const input: AgentInput = {
      fullName: s('fullName'),
      code: code.trim(),
      phone: s('phone'),
      whatsappPhone: s('whatsappPhone') || null,
      routeNotes: s('routeNotes') || null,
      dailyVisitPlan: Number(s('dailyVisitPlan') || 25),
      dailyAuditPlan: Number(s('dailyAuditPlan') || 20),
      regionId: s('regionId'),
      status
    }
    if (!input.fullName || !input.code || !input.phone || !input.regionId) return setError(f.errors.required)
    // Sign-in and contact: a Turkmen mobile number, sent in the stored form +993XXXXXXXX.
    const phone = tmPhone(input.phone, 'mobile')
    const whatsapp = input.whatsappPhone == null ? null : tmPhone(input.whatsappPhone, 'mobile')
    if (phone == null || (input.whatsappPhone != null && whatsapp == null)) return setError(f.errors.phone)
    input.phone = phone
    input.whatsappPhone = whatsapp
    if (input.dailyAuditPlan > input.dailyVisitPlan) return setError(f.errors.plan)
    setError(null)
    startTransition(() => guard(async () => {
      if (agent == null) {
        const res = await createAgent(input)
        if (!res.ok) return setError(res.code === 'CONFLICT' ? f.errors.CONFLICT : f.errors.generic)
        setPassword(res.data.temporaryPassword)
      } else {
        const res = await updateAgent(agent.id, agent.version, input)
        if (!res.ok) return setError(res.code === 'CONFLICT' ? f.errors.CONFLICT : f.errors.generic)
        if (form.get('device') === 'reset') await rebindAgentDevice(agent.id)
        say('saved')
        close(true)
      }
    }))
  }

  function resetPassword () {
    if (agent == null) return
    startTransition(() => guard(async () => {
      const res = await resetAgentPassword(agent.id)
      if (res.ok) setPassword(res.data.temporaryPassword)
      else setError(f.errors.generic)
    }))
  }

  if (password != null) {
    return (
      <Dialog open={open} variant='form' width={560} onClose={() => close(true)} closeLabel={f.close} title={agent == null ? f.created : f.resetPassword}
        footer={<Button size='md' onClick={() => close(true)}>{f.done}</Button>}>
        <p className='text-sm leading-5 text-slate-700'>{f.passwordNote}</p>
        <p className='select-all rounded-xl border border-border bg-slate-50 px-3.5 py-2.5 font-mono text-base text-slate-800'>{password}</p>
      </Dialog>
    )
  }

  const device = agent?.device
  const deviceLabel = device?.model != null ? `${device.model}${device.imeiLabel != null ? ` (IMEI: ${device.imeiLabel})` : ''}` : null

  return (
    <Dialog
      open={open} enterStartedAt={enterStartedAt} variant='form' width={981} onClose={() => close()} closeLabel={f.close}
      title={agent == null ? f.addTitle : f.editTitle}
      subtitle={f.subtitle}
      footer={
        <>
          {agent != null && <button data-ripple type='button' onClick={resetPassword} disabled={pending} className='mr-auto px-2 py-1 text-xs font-medium text-accent'>{f.resetPassword}</button>}
          {error != null && <p role='alert' className='mr-auto text-xs text-error'>{error}</p>}
          <Button variant='outline' size='md' data-dialog-close className='border-slate-300 text-slate-700'>{f.cancel}</Button>
          <Button type='submit' form='agent-form' size='md' disabled={pending} icon={<FigmaIcon name='check-light' width={16} height={16} />}>{f.save}</Button>
        </>
      }
    >
      <form id='agent-form' action={submit} className='flex flex-col gap-4'>
        <div className='grid grid-cols-2 gap-x-6 gap-y-4'>
          <FormField variant='form' label={f.fullName} required htmlFor='fullName'>
            <TextInput variant='form' id='fullName' name='fullName' defaultValue={agent?.fullName} placeholder={f.fullNamePlaceholder} required />
          </FormField>
          <FormField
            variant='form' label={f.code} required htmlFor='code'
            action={agent == null && <button data-ripple type='button' onClick={() => setCode(nextCode)} className='-mx-1.5 rounded-md px-1.5 py-0.5 text-[10px] font-medium leading-[15px] text-[#4f46e5]'>{f.generate}</button>}
          >
            <TextInput variant='form' id='code' value={code} onChange={(e) => setCode(e.target.value)} className='bg-slate-50/70 font-mono font-medium' required />
          </FormField>
          <FormField variant='form' label={f.phone} required htmlFor='phone'>
            <TextInput variant='form' id='phone' name='phone' {...phoneInputProps()} defaultValue={displayPhone(agent?.phone)} placeholder='+993 65 124582' icon={<FigmaIcon name='phone-field' width={14} height={14} />} required />
          </FormField>
          <FormField variant='form' label={f.whatsapp} htmlFor='whatsappPhone'>
            <TextInput variant='form' id='whatsappPhone' name='whatsappPhone' {...phoneInputProps()} defaultValue={displayPhone(agent?.whatsappPhone)} placeholder='+993 61 987654' icon={<FigmaIcon name='whatsapp-field' width={14} height={14} />} />
          </FormField>
        </div>
        <FormField variant='form' label={f.notes} htmlFor='routeNotes'>
          <TextArea id='routeNotes' name='routeNotes' defaultValue={agent?.routeNotes ?? ''} placeholder={f.notesPlaceholder} rows={1} />
        </FormField>
        <div className='grid grid-cols-2 gap-x-6'>
          <FormField variant='form' label={f.visitPlan} htmlFor='dailyVisitPlan'>
            <TextInput variant='form' id='dailyVisitPlan' name='dailyVisitPlan' type='number' min={1} max={100} defaultValue={agent?.dailyVisitPlan ?? 25} suffix={f.visitSuffix} />
          </FormField>
          <FormField variant='form' label={f.auditPlan} htmlFor='dailyAuditPlan'>
            <TextInput variant='form' id='dailyAuditPlan' name='dailyAuditPlan' type='number' min={0} max={100} defaultValue={agent?.dailyAuditPlan ?? 20} suffix={f.auditSuffix} />
          </FormField>
        </div>
        <FormField variant='form' label={f.region} required htmlFor='regionId'>
          <SelectInput variant='form' id='regionId' name='regionId' defaultValue={agent?.region.id ?? ''} required>
            <option value='' disabled>{f.regionPlaceholder}</option>
            {regions.map((r) => <option key={r.id} value={r.id}>{r.name}</option>)}
          </SelectInput>
        </FormField>
        <div className='grid grid-cols-2 gap-x-6'>
          <FormField variant='form' label={f.device} htmlFor='device'>
            <SelectInput variant='form' id='device' name='device' defaultValue='keep' disabled={deviceLabel == null} icon={<FigmaIcon name='device-phone' width={14} height={14} />} className='text-xs'>
              <option value='keep'>{deviceLabel ?? f.deviceNone}</option>
              {deviceLabel != null && <option value='reset'>{f.deviceReset}</option>}
            </SelectInput>
          </FormField>
          <FormField variant='form' label={f.status}>
            <StatusSwitch<Status>
              value={status}
              onChange={setStatus}
              options={(['ACTIVE', 'ON_LEAVE', 'ARCHIVED'] as const).map((v) => ({ value: v, label: f.statuses[v], tone: v === 'ACTIVE' ? 'success' as const : undefined }))}
            />
          </FormField>
        </div>
      </form>
    </Dialog>
  )
}
