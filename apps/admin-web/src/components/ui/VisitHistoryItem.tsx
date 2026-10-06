import type { ReactNode } from 'react'

export interface VisitPhoto { id: string, url: string }

const MAX_THUMBS = 7

/**
 * Visit history card of 47:7387: done (151:13021) and missed (151:13142). Missed visits have no
 * reason block, since no reason is collected (spec gap A2).
 */
export function VisitHistoryItem ({ when, aside, status, statusLabel, thumbnailUrl, title, subtitle, comment, photos = [], morePhotosLabel, onPhoto }: {
  when: string
  /** "Длительность: 30 мин" for done visits, "Отклонён" for missed ones. */
  aside: string
  status: 'done' | 'missed'
  statusLabel: string
  thumbnailUrl?: string | null
  title: string
  subtitle: string
  /** Full line, e.g. `Комментарий агента: «…»`. */
  comment?: ReactNode
  photos?: VisitPhoto[]
  morePhotosLabel?: (n: number) => string
  onPhoto?: (photo: VisitPhoto) => void
}) {
  const missed = status === 'missed'
  const shown = photos.length > MAX_THUMBS ? photos.slice(0, MAX_THUMBS) : photos
  const hidden = photos.length - (MAX_THUMBS - 1)

  return (
    <article className='flex w-full flex-col gap-3 rounded-xl bg-pure-white p-5 shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
      <div className='flex flex-col gap-2'>
        <div className='flex items-center justify-between gap-1'>
          <span className='font-display text-xs leading-4 text-ink'>{when}</span>
          <span className={`text-[11px] leading-[16.5px] ${missed ? 'text-danger' : 'text-subtle'}`}>{aside}</span>
        </div>
        <div className='flex gap-3.5'>
          <span className={`size-10 shrink-0 overflow-hidden rounded-lg ${missed ? 'bg-[#ffdad6]' : 'bg-[#72f8df]'}`}>
            {thumbnailUrl != null && (
              // eslint-disable-next-line @next/next/no-img-element -- presigned preview URL
              <img src={thumbnailUrl} alt='' className='size-full object-cover' />
            )}
          </span>
          <div className='flex min-w-0 flex-col gap-0.5'>
            <div className='flex items-center gap-2'>
              <h3 className='truncate text-sm font-bold leading-5 text-ink'>{title}</h3>
              {missed
                ? <span className='shrink-0 rounded bg-[#ffdad6] px-2 py-0.5 text-[11px] font-semibold leading-[16.5px] text-error'>{statusLabel}</span>
                : (
                  <span className='flex shrink-0 items-center gap-1 rounded-full bg-success-bg px-2 py-0.5 text-[11px] font-semibold leading-[16.5px] text-success'>
                    <span className='size-1.5 rounded-full bg-success' />{statusLabel}
                  </span>
                  )}
            </div>
            <p className='truncate text-xs leading-4 text-muted'>{subtitle}</p>
          </div>
        </div>
      </div>
      {comment != null && (
        <p className='rounded-lg bg-secondary-bg/60 px-3 pb-3 pt-4 text-xs font-bold leading-[19.5px] text-ink'>{comment}</p>
      )}
      {shown.length > 0 && (
        <div className='flex items-center gap-1.5 pt-3'>
          {shown.map((p, i) => {
            const more = photos.length > MAX_THUMBS && i === MAX_THUMBS - 1
            return (
              <button
                key={p.id} type='button' onClick={() => onPhoto?.(p)}
                className='relative flex size-[60px] shrink-0 items-center justify-center overflow-hidden rounded-lg bg-dark-accent'
              >
                {/* eslint-disable-next-line @next/next/no-img-element -- presigned preview URL */}
                <img src={p.url} alt='' loading='lazy' className='absolute inset-0 size-full object-cover' />
                {more && (
                  <span className='relative flex size-full items-center justify-center bg-black/40 text-[11px] font-semibold leading-[16.5px] text-white'>
                    {morePhotosLabel?.(hidden) ?? `+${hidden}`}
                  </span>
                )}
              </button>
            )
          })}
        </div>
      )}
    </article>
  )
}
