import { Icon } from '@/components/ui/Icon'
import { AvatarMenu } from './AvatarMenu'
import { GlobalSearch } from './GlobalSearch'
import type { Locale } from '@/lib/i18n'
import type { LayoutCopy } from './copy'

/** Header of Figma 3:407 (3:853). `bell` is the slot for the activity feed (A6). */
export function Topbar ({ copy, locale, bell }: { copy: LayoutCopy, locale: Locale, bell?: React.ReactNode }) {
  return (
    <header className='sticky top-0 z-30 mt-0.5 flex h-16 shrink-0 items-center justify-between bg-white/90 px-4 shadow-[0px_1px_8px_0px_rgba(0,0,0,0.04)] backdrop-blur-[12px]'>
      <GlobalSearch copy={copy} />

      <div className='flex items-center gap-3'>
        {bell ?? (
          <button data-ripple type='button' aria-label={copy.notifications} className='flex size-9 items-center justify-center rounded-lg text-muted'>
            <Icon name='bell' width={13.333} height={16.667} />
          </button>
        )}
        {/* Help has no designed behavior (spec A6): rendered, inert. */}
        <button type='button' aria-label={copy.help} className='flex size-9 cursor-default items-center justify-center rounded-lg text-muted'>
          <Icon name='help' width={16.667} height={16.667} />
        </button>
        <div className='flex h-6 w-[9px] px-1'><div className='h-6 w-px bg-line' /></div>
        <AvatarMenu copy={copy} locale={locale} />
      </div>
    </header>
  )
}
