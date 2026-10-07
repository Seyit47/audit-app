import Link from 'next/link'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { sub, type Locale } from '@/lib/i18n'
import type { GalleryPhoto } from '@/features/photos/types'
import type { AgentsCopy } from '../copy'
import { hhmm } from './RouteTimeline'

const SHOWN = 5

/** "Фотоотчёты аудитов" of 122:7981 (122:9618): five latest photos and the gallery tile. */
export function PhotoReports ({ photos, total, galleryHref, copy, locale }: { photos: GalleryPhoto[], total: number, galleryHref: string, copy: AgentsCopy, locale: Locale }) {
  const d = copy.details
  const shown = photos.slice(0, SHOWN)
  return (
    <section className='flex flex-col gap-4 rounded-xl bg-pure-white p-5 shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
      <div className='flex items-center justify-between gap-4'>
        <h2 className='flex items-center gap-2 text-sm font-bold leading-5 text-ink'><FigmaIcon name='photos-counter' width={16.67} height={16.67} />{d.photoReports}</h2>
        {total > 0 && <Link href={galleryHref} className='text-xs font-semibold leading-4 text-accent'>{sub(d.allPhotos, total)}</Link>}
      </div>
      {shown.length === 0
        ? <p className='py-6 text-center text-xs text-muted'>{d.noPhotos}</p>
        : (
          <div className='grid grid-cols-3 gap-3'>
            {shown.map((p) => (
              <Link key={p.id} href={`/pictures?agentId=${p.agent?.id ?? ''}&photo=${p.id}`} className='relative h-[107px] overflow-hidden rounded-lg bg-dark-accent shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
                {/* eslint-disable-next-line @next/next/no-img-element -- presigned preview URL */}
                <img src={p.previewUrl400} alt='' loading='lazy' className='absolute inset-0 size-full object-cover' />
                <span className='absolute inset-0 flex items-end bg-[linear-gradient(0deg,rgba(46,48,59,0.8)_0%,rgba(46,48,59,0)_50%)] p-2 font-display text-[10px] leading-[15px] text-[#f0effe]'>{hhmm(p.takenAt, locale)}</span>
              </Link>
            ))}
            <Link href={galleryHref} className='flex h-[107px] flex-col items-center justify-center rounded-lg bg-secondary-bg p-3 text-center'>
              <FigmaIcon name='photos-counter' width={23.33} height={21} />
              <span className='pt-1 text-xs font-bold leading-4 text-ink'>{total > shown.length ? sub(d.morePhotos, total - shown.length) : d.openGallery}</span>
              {total > shown.length && <span className='pt-0.5 text-[10px] leading-[15px] text-subtle'>{d.openGallery}</span>}
            </Link>
          </div>
          )}
    </section>
  )
}
