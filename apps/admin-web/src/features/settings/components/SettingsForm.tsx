'use client'

import { guard, say } from '@/lib/feedback'
import { useRouter } from 'next/navigation'
import { useState, useTransition } from 'react'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { FormField, SelectInput, TextInput } from '@/components/ui/FormField'
import { ImageUpload } from '@/components/ui/ImageUpload'
import { saveSettings, type SettingsInput } from '../actions'
import type { SettingsCopy } from '../copy'

function Section ({ title, children }: { title: string, children: React.ReactNode }) {
  return (
    <Card className='flex flex-col gap-4 p-5'>
      <h2 className='text-base font-bold leading-6 text-ink'>{title}</h2>
      {children}
    </Card>
  )
}

/** Company settings (approved exception A4) from the 162:20071 form components. */
export function SettingsForm ({ initial, logoUrl, timezones, copy }: { initial: SettingsInput, logoUrl: string | null, timezones: string[], copy: SettingsCopy }) {
  const router = useRouter()
  const [v, setV] = useState(initial)
  const [status, setStatus] = useState<'idle' | 'saved' | string>('idle')
  const [pending, startTransition] = useTransition()
  // Each field says what is wrong once it has been changed (and all of them on Save).
  const [touched, setTouched] = useState<ReadonlySet<string>>(new Set())
  const set = <K extends keyof SettingsInput>(k: K, value: SettingsInput[K]) => {
    setV((x) => ({ ...x, [k]: value })); setStatus('idle')
    if (!touched.has(k)) setTouched(new Set(touched).add(k))
  }
  const range = (n: number, min: number, max: number) => Number.isInteger(n) && n >= min && n <= max ? null : copy.errors.range.replace('{min}', String(min)).replace('{max}', String(max))
  const fieldErrors: Record<string, string | null> = {
    companyName: v.companyName.trim() === '' ? copy.errors.field : null,
    workEnd: v.workEnd <= v.workStart ? copy.errors.hours : null,
    visitFrequencyDays: range(v.visitFrequencyDays, 1, 90),
    defaultAuditRadiusM: range(v.defaultAuditRadiusM, 10, 1000),
    minGpsAccuracyM: range(v.minGpsAccuracyM, 5, 200),
    noSignalMinutes: range(v.noSignalMinutes, 5, 240)
  }
  // The end-time rule also reacts to the start time.
  const fieldError = (k: string) => (touched.has(k) || (k === 'workEnd' && touched.has('workStart')) ? fieldErrors[k] ?? undefined : undefined)
  const num = (k: 'visitFrequencyDays' | 'defaultAuditRadiusM' | 'minGpsAccuracyM' | 'noSignalMinutes') => ({
    type: 'number', inputMode: 'numeric' as const, value: String(v[k]), onChange: (e: React.ChangeEvent<HTMLInputElement>) => set(k, Number(e.target.value))
  })

  const submit = (e: React.FormEvent) => {
    e.preventDefault()
    setTouched(new Set(Object.keys(fieldErrors)))
    if (Object.values(fieldErrors).some((x) => x != null)) { setStatus('idle'); return }
    startTransition(() => guard(async () => {
      const r = await saveSettings({ ...v, companyName: v.companyName.trim() })
      if (r.ok) { setStatus('saved'); say('saved'); router.refresh() } else setStatus(copy.errors[r.code as keyof typeof copy.errors] ?? copy.errors.generic)
    }))
  }

  return (
    <form noValidate onSubmit={submit} className='flex flex-col gap-4'>
      <Section title={copy.company}>
        <ImageUpload
          title={copy.logo} hint={copy.logoHint} kind='LOGO' previewUrl={logoUrl} copy={copy.upload}
          onChange={(photo) => set('logoPhotoId', photo?.id ?? null)}
        />
        <FormField label={copy.companyName} required htmlFor='companyName' error={fieldError('companyName')}>
          <TextInput id='companyName' value={v.companyName} maxLength={120} onChange={(e) => set('companyName', e.target.value)} className='h-11 px-3' />
        </FormField>
      </Section>

      <Section title={copy.hours}>
        <div className='grid grid-cols-3 gap-4'>
          <FormField label={copy.workStart} htmlFor='workStart'>
            <TextInput id='workStart' type='time' value={v.workStart} onChange={(e) => set('workStart', e.target.value)} className='h-11 px-3' />
          </FormField>
          <FormField label={copy.workEnd} htmlFor='workEnd' error={fieldError('workEnd')}>
            <TextInput id='workEnd' type='time' value={v.workEnd} onChange={(e) => set('workEnd', e.target.value)} className='h-11 px-3' />
          </FormField>
          <FormField label={copy.timezone} htmlFor='timezone'>
            <SelectInput id='timezone' value={v.timezone} onChange={(e) => set('timezone', e.target.value)}>
              {timezones.map((tz) => <option key={tz} value={tz}>{tz}</option>)}
            </SelectInput>
          </FormField>
        </div>
        <p className='text-[11px] leading-[16.5px] text-off-white'>{copy.hoursHint}</p>
      </Section>

      <Section title={copy.rules}>
        <div className='grid grid-cols-2 gap-4'>
          <FormField label={copy.visitFrequency} htmlFor='visitFrequencyDays' error={fieldError('visitFrequencyDays')}>
            <TextInput id='visitFrequencyDays' min={1} max={90} {...num('visitFrequencyDays')} variant='form' suffix={copy.days} className='h-11' />
          </FormField>
          <FormField label={copy.radius} hint={copy.radiusHint} htmlFor='defaultAuditRadiusM' error={fieldError('defaultAuditRadiusM')}>
            <TextInput id='defaultAuditRadiusM' min={10} max={1000} {...num('defaultAuditRadiusM')} variant='form' suffix={copy.meters} className='h-11' />
          </FormField>
          <FormField label={copy.accuracy} htmlFor='minGpsAccuracyM' error={fieldError('minGpsAccuracyM')}>
            <TextInput id='minGpsAccuracyM' min={5} max={200} {...num('minGpsAccuracyM')} variant='form' suffix={copy.meters} className='h-11' />
          </FormField>
          <FormField label={copy.noSignal} htmlFor='noSignalMinutes' error={fieldError('noSignalMinutes')}>
            <TextInput id='noSignalMinutes' min={5} max={240} {...num('noSignalMinutes')} variant='form' suffix={copy.minutes} className='h-11' />
          </FormField>
        </div>
      </Section>

      <div className='flex items-center justify-end gap-3'>
        {status === 'saved' && <span role='status' className='text-xs font-semibold text-success'>{copy.saved}</span>}
        {status !== 'idle' && status !== 'saved' && <span role='alert' className='text-xs text-error'>{status}</span>}
        <Button type='submit' size='md' disabled={pending}>{pending ? copy.saving : copy.save}</Button>
      </div>
    </form>
  )
}
