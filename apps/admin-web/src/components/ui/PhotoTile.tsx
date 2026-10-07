import { FigmaIcon } from './FigmaIcon'

/** "Verified" pin of the photo cards (138:12132). */
export function VerifiedTag ({ label }: { label: string }) {
  return (
    <span className='absolute left-2.5 top-2.5 z-10 flex items-center gap-1 rounded bg-black/60 px-2 py-0.5 text-[10px] font-semibold leading-[15px] text-[#72f8df] backdrop-blur-[6px]'>
      <span className='size-1.5 rounded-full bg-[#72f8df]' />
      {label}
    </span>
  )
}

/**
 * Photo card of 138:11987 (138:12115): image, "Verified" pin, and the bottom gradient with shop,
 * address and date, shown on hover/focus and while the card is active.
 */
export function PhotoTile ({ src, alt, verifiedLabel, title, address, date, active = false, onSelect, onPrefetch, flipId, className = 'h-[170px] w-[286px]' }: {
  src: string
  alt: string
  /** Shown as the pin when the photo is verified. */
  verifiedLabel?: string | null
  title?: string
  address?: string
  date?: string
  active?: boolean
  onSelect?: () => void
  /** Hover or focus: start loading what a click will show. */
  onPrefetch?: () => void
  /** Key for grid reflow animation (useFlip). */
  flipId?: string
  className?: string
}) {
  const overlay = title != null || address != null || date != null
  return (
    <button
      type='button' onClick={onSelect} onPointerEnter={onPrefetch} onFocus={onPrefetch} aria-pressed={active} data-flip={flipId}
      className={`group relative shrink-0 overflow-hidden rounded-xl bg-dark-accent text-left shadow-[0px_1px_2px_rgba(0,0,0,0.05)] focus:outline-none focus-visible:ring-2 focus-visible:ring-accent ${className}`}
    >
      {/* eslint-disable-next-line @next/next/no-img-element -- presigned preview URL */}
      <img src={src} alt={alt} loading='lazy' className='absolute inset-0 size-full object-cover transition-transform duration-500 ease-[var(--ease-standard)] group-hover:scale-[1.04]' />
      {verifiedLabel != null && <VerifiedTag label={verifiedLabel} />}
      {overlay && (
        <span
          className={`absolute inset-x-0 bottom-0 flex h-[90px] items-end p-3.5 transition-opacity bg-[linear-gradient(0deg,rgba(0,0,0,0.9)_0%,rgba(0,0,0,0.63)_45.67%,rgba(0,0,0,0.15)_75.48%,rgba(0,0,0,0)_100%)] ${active ? 'opacity-100' : 'opacity-0 group-hover:opacity-100 group-focus-visible:opacity-100'}`}
        >
          <span className='flex min-w-0 flex-1 flex-col drop-shadow-[0px_1px_1px_rgba(0,0,0,0.05)]'>
            {title != null && <span className='truncate text-sm font-bold leading-5 tracking-[-0.35px] text-white'>{title}</span>}
            {address != null && (
              <span className='flex items-center gap-1 pt-0.5 text-[11px] leading-[16.5px] text-white/80'>
                <FigmaIcon name='photo-pin' width={8.667} height={10.833} />
                <span className='truncate'>{address}</span>
              </span>
            )}
            {date != null && (
              <span className='flex items-center gap-1 pt-0.5 text-[11px] font-medium leading-[16.5px] text-white/80'>
                <FigmaIcon name='photo-clock' width={10} height={10} />
                {date}
              </span>
            )}
          </span>
        </span>
      )}
    </button>
  )
}
