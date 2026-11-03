import { listDistricts } from '@/features/districts/api'
import { PhotosView } from '@/features/photos/components/PhotosView'
import { photosCopy } from '@/features/photos/copy'
import type { GalleryPage, GalleryQuery, PhotoDetail } from '@/features/photos/types'
import { api } from '@/lib/api'
import { getLocale } from '@/lib/locale'
import { loadPicturesParams } from '@/features/photos/search-params'
import { isoDay, startOfDay } from '@/lib/time-zone'

type Search = Record<string, string | undefined>

function since (date: string | undefined): string | undefined {
  if (date === 'all') return undefined
  // "Today" starts at the company's midnight; the other periods are whole days back from now.
  const d = date === 'today' ? startOfDay(isoDay()) : new Date(Date.now() - Number(date === '30' ? 30 : 7) * 86_400_000)
  return d.toISOString()
}

export default async function PicturesPage ({ searchParams }: PageProps<'/pictures'>) {
  const sp = (await searchParams) as Search
  const locale = await getLocale()
  // The web gallery is audit photos only (no storefront or admin uploads).
  const p = await loadPicturesParams(searchParams)
  const query: GalleryQuery = { type: 'AUDIT', districtId: p.districtId ?? undefined, verified: p.verified ?? undefined, from: since(p.date), shopId: p.shopId ?? undefined, agentId: p.agentId ?? undefined, q: p.q ?? undefined }
  const photoId = p.photo
  const [first, summary, districts, detail] = await Promise.all([
    api<GalleryPage>('/v1/photos', { query: { ...query, limit: 24, groups: sp.mode === 'byDate' || undefined } }),
    api<{ total: number, today: number }>('/v1/photos/summary', { query: { type: 'AUDIT' } }),
    listDistricts(),
    photoId != null ? api<PhotoDetail>(`/v1/photos/${photoId}`).catch(() => null) : Promise.resolve(null)
  ])
  return (
    <div className='flex flex-col gap-2.5 p-4'>
      <PhotosView key={JSON.stringify([query, sp.mode])} first={first} query={query} summary={summary} districts={districts.flatMap((d) => d.id == null || d.name == null ? [] : [{ id: d.id, name: d.name }])} copy={photosCopy[locale]} locale={locale} initialDetail={detail} />
    </div>
  )
}
