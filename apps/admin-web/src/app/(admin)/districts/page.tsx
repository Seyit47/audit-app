import { listDistricts } from '@/features/districts/api'
import { DistrictsGrid } from '@/features/districts/components/DistrictsGrid'
import { districtsCopy } from '@/features/districts/copy'
import { getLocale } from '@/lib/locale'

/** Districts (admins): cards with each district's shops, salesmen and today's visits; each opens its shops. */
export default async function DistrictsPage () {
  const locale = await getLocale()
  const districts = await listDistricts()
  return (
    <div className='flex flex-col gap-4 p-4'>
      <DistrictsGrid districts={districts} copy={districtsCopy[locale]} locale={locale} />
    </div>
  )
}
