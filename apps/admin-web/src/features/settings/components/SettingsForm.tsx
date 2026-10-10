'use client'

import { guard, say } from '@/lib/feedback'
import { useRouter } from 'next/navigation'
import { useState, useTransition } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { FormField, SelectInput, TextInput } from '@/components/ui/FormField'
import { ImageUpload } from '@/components/ui/ImageUpload'
import { saveSettings, type SettingsInput } from '../actions'
import type { SettingsCopy } from '../copy'
import { settingsSchema, type SettingsValues } from '../schema'

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
  const [status, setStatus] = useState<'idle' | 'saved' | string>('idle')
  const [pending, startTransition] = useTransition()
  const [schema] = useState(() => settingsSchema(copy))
  // A field reports what is wrong once it has been changed, and every field on Save.
  const { register, handleSubmit, setValue, formState: { errors } } = useForm<SettingsValues, unknown, ReturnType<typeof schema.parse>>({
    resolver: zodResolver(schema),
    mode: 'onChange',
    defaultValues: {
      ...initial,
      visitFrequencyDays: String(initial.visitFrequencyDays),
      defaultAuditRadiusM: String(initial.defaultAuditRadiusM),
      minGpsAccuracyM: String(initial.minGpsAccuracyM),
      noSignalMinutes: String(initial.noSignalMinutes)
    }
  })
  const num = (k: 'visitFrequencyDays' | 'defaultAuditRadiusM' | 'minGpsAccuracyM' | 'noSignalMinutes') =>
    ({ type: 'number', inputMode: 'numeric' as const, ...register(k, { onChange: () => setStatus('idle') }) })

  const submit = handleSubmit((v) => {
    startTransition(() => guard(async () => {
      const r = await saveSettings(v)
      if (r.ok) { setStatus('saved'); say('saved'); router.refresh() } else setStatus(copy.errors[r.code as keyof typeof copy.errors] ?? copy.errors.generic)
    }))
  })

  return (
    <form noValidate onSubmit={(e) => { void submit(e) }} className='flex flex-col gap-4'>
      <Section title={copy.company}>
        <ImageUpload
          title={copy.logo} hint={copy.logoHint} kind='LOGO' previewUrl={logoUrl} copy={copy.upload}
          onChange={(photo) => setValue('logoPhotoId', photo?.id ?? null, { shouldDirty: true })}
        />
        <FormField label={copy.companyName} required htmlFor='companyName' error={errors.companyName?.message}>
          <TextInput id='companyName' maxLength={120} className='h-11 px-3' {...register('companyName', { onChange: () => setStatus('idle') })} />
        </FormField>
      </Section>

      <Section title={copy.hours}>
        <div className='grid grid-cols-3 gap-4'>
          <FormField label={copy.workStart} htmlFor='workStart'>
            <TextInput id='workStart' type='time' className='h-11 px-3' {...register('workStart', { deps: ['workEnd'], onChange: () => setStatus('idle') })} />
          </FormField>
          <FormField label={copy.workEnd} htmlFor='workEnd' error={errors.workEnd?.message}>
            <TextInput id='workEnd' type='time' className='h-11 px-3' {...register('workEnd', { onChange: () => setStatus('idle') })} />
          </FormField>
          <FormField label={copy.timezone} htmlFor='timezone'>
            <SelectInput id='timezone' {...register('timezone', { onChange: () => setStatus('idle') })}>
              {timezones.map((tz) => <option key={tz} value={tz}>{tz}</option>)}
            </SelectInput>
          </FormField>
        </div>
        <p className='text-[11px] leading-[16.5px] text-off-white'>{copy.hoursHint}</p>
      </Section>

      <Section title={copy.rules}>
        <div className='grid grid-cols-2 gap-4'>
          <FormField label={copy.visitFrequency} htmlFor='visitFrequencyDays' error={errors.visitFrequencyDays?.message}>
            <TextInput id='visitFrequencyDays' min={1} max={90} {...num('visitFrequencyDays')} variant='form' suffix={copy.days} className='h-11' />
          </FormField>
          <FormField label={copy.radius} hint={copy.radiusHint} htmlFor='defaultAuditRadiusM' error={errors.defaultAuditRadiusM?.message}>
            <TextInput id='defaultAuditRadiusM' min={10} max={1000} {...num('defaultAuditRadiusM')} variant='form' suffix={copy.meters} className='h-11' />
          </FormField>
          <FormField label={copy.accuracy} htmlFor='minGpsAccuracyM' error={errors.minGpsAccuracyM?.message}>
            <TextInput id='minGpsAccuracyM' min={5} max={200} {...num('minGpsAccuracyM')} variant='form' suffix={copy.meters} className='h-11' />
          </FormField>
          <FormField label={copy.noSignal} htmlFor='noSignalMinutes' error={errors.noSignalMinutes?.message}>
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
