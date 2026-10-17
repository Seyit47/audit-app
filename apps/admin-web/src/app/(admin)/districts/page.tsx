import { districtOptions } from '@/features/districts/api'
import { DistrictsCard } from '@/features/districts/components/DistrictsCard'
import { districtsCopy } from '@/features/districts/copy'
import { getLocale } from '@/lib/locale'

/** Districts (admins): add, rename, delete; each links to its shops. */
export default async function DistrictsPage () {
  const copy = districtsCopy[await getLocale()]
  const districts = await districtOptions()
  return (
    <div className='flex flex-col gap-4 p-4'>
      <div>
        <h1 className='text-2xl font-bold leading-8 tracking-[-0.6px] text-ink'>{copy.title}</h1>
        <p className='pt-1 text-sm leading-5 text-muted'>{copy.description}</p>
      </div>
      <DistrictsCard items={districts} copy={copy} />
    </div>
  )
}
