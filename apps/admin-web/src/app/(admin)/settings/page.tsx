import { PageHeader } from '@/components/ui/PageHeader'
import { listRegions } from '@/features/agents/api'
import { listCategories } from '@/features/products/api'
import type { SettingsInput } from '@/features/settings/actions'
import { NameListCard } from '@/features/settings/components/NameListCard'
import { SettingsForm } from '@/features/settings/components/SettingsForm'
import { settingsCopy } from '@/features/settings/copy'
import { api } from '@/lib/api'
import { getLocale } from '@/lib/locale'
import { getMe } from '@/lib/me'

/** Settings (approved exception A4): company, working hours, visit and GPS rules, regions, product categories. */
export default async function SettingsPage () {
  const locale = await getLocale()
  const copy = settingsCopy[locale]
  const [settings, regions, categories, me] = await Promise.all([api<SettingsInput>('/v1/settings'), listRegions(), listCategories(), getMe()])
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
        <div className='flex flex-col gap-4'>
          <NameListCard kind='regions' items={regions} copy={copy} />
          <NameListCard kind='categories' items={categories} copy={copy} />
        </div>
      </div>
    </div>
  )
}
