import { listRegions } from '@/features/agents/api'
import { PhotosView } from '@/features/photos/components/PhotosView'
import { photosCopy } from '@/features/photos/copy'
import type { GalleryPage, GalleryQuery, PhotoDetail } from '@/features/photos/types'
import { api } from '@/lib/api'
import { getLocale } from '@/lib/locale'
import { bool, oneOf, text, uuid } from '@/lib/params'

type Search = Record<string, string | undefined>

function since (date: string | undefined): string | undefined {
  if (date === 'all') return undefined
  const d = new Date()
  if (date === 'today') d.setHours(0, 0, 0, 0)
  else d.setDate(d.getDate() - Number(date === '30' ? 30 : 7))
  return d.toISOString()
}

export default async function PicturesPage ({ searchParams }: PageProps<'/pictures'>) {
  const sp = (await searchParams) as Search
  const locale = await getLocale()
  const query: GalleryQuery = { type: oneOf(sp.type, ['AUDIT', 'FACADE', 'ADMIN_UPLOAD'] as const), regionId: uuid(sp.regionId), verified: bool(sp.verified), from: since(sp.date), shopId: uuid(sp.shopId), agentId: uuid(sp.agentId), q: text(sp.q) }
  const photoId = uuid(sp.photo)
  const [first, summary, regions, shops, detail] = await Promise.all([
    api<GalleryPage>('/v1/photos', { query: { ...query, limit: 24, groups: sp.mode === 'byDate' || undefined } }),
    api<{ total: number, today: number }>('/v1/photos/summary'),
    listRegions(),
    api<{ items: Array<{ id: string, name: string, code: string }> }>('/v1/shops', { query: { size: 100, sort: 'name', dir: 'asc' } }),
    photoId != null ? api<PhotoDetail>(`/v1/photos/${photoId}`).catch(() => null) : Promise.resolve(null)
  ])
  return (
    <div className='flex flex-col gap-2.5 p-4'>
      <PhotosView key={JSON.stringify([query, sp.mode])} first={first} query={query} summary={summary} regions={regions} shops={shops.items} copy={photosCopy[locale]} locale={locale} initialDetail={detail} />
    </div>
  )
}
