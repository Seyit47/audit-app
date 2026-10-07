import { PageHeader } from '@/components/ui/PageHeader'
import { listRegions } from '@/features/agents/api'
import type { SettingsInput } from '@/features/settings/actions'
import { RegionsCard } from '@/features/settings/components/RegionsCard'
import { SettingsForm } from '@/features/settings/components/SettingsForm'
import { settingsCopy } from '@/features/settings/copy'
import { api } from '@/lib/api'
import { getLocale } from '@/lib/locale'
import { getMe } from '@/lib/me'

/** Settings (approved exception A4): company, working hours, visit and GPS rules, regions. */
export default async function SettingsPage () {
  const locale = await getLocale()
  const copy = settingsCopy[locale]
  const [settings, regions, me] = await Promise.all([api<SettingsInput>('/v1/settings'), listRegions(), getMe()])
  const timezones = Intl.supportedValuesOf('timeZone')
  const initial: SettingsInput = {
    companyName: settings.companyName,
    logoPhotoId: settings.logoPhotoId,
    workStart: settings.workStart,
    workEnd: settings.workEnd,
    timezone: settings.timezone,
    visitFrequencyDays: settings.visitFrequencyDays,
    defaultAuditRadiusM: settings.defaultAuditRadiusM,
    minGpsAccuracyM: settings.minGpsAccuracyM,
    noSignalMinutes: settings.noSignalMinutes
  }

  return (
    <div className='flex flex-col gap-4 p-4'>
      <PageHeader title={copy.title} description={copy.description} />
      <div className='grid grid-cols-[minmax(0,3fr)_minmax(0,2fr)] items-start gap-4'>
        <SettingsForm initial={initial} logoUrl={me.config.logo?.previewUrl400 ?? me.config.logo?.url ?? null} timezones={timezones.includes(initial.timezone) ? timezones : [initial.timezone, ...timezones]} copy={copy} />
        <RegionsCard regions={regions} copy={copy} />
      </div>
    </div>
  )
}
