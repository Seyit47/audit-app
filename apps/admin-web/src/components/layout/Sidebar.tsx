'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useState } from 'react'
import { Icon } from '@/components/ui/Icon'
import type { LayoutCopy } from './copy'

// Every row is one height so moving the active item never shifts the others. The active-tab image
// (nav-active-bg.svg, 3:414) is taller: its tab body matches the row and the corner curves stick out
// above and below, so it is centred on the row.
const ROW = 44
const TAB = 64

// Icon sizes are the Figma slot sizes (3:414).
const navItems = (copy: LayoutCopy) => [
  { href: '/map', label: copy.nav.map, icon: 'nav-grid', w: 15, h: 15, match: '/map' },
  { href: '/shops', label: copy.nav.shops, icon: 'nav-shops', w: 15, h: 13.333, match: '/shops' },
  { href: '/products', label: copy.nav.products, icon: 'nav-products', w: 16.667, h: 16.667, match: '/products' },
  { href: '/salesmen', label: copy.nav.salesmen, icon: 'nav-salesmen', w: 16.667, h: 16.667, match: '/salesmen' },
  { href: '/pictures', label: copy.nav.pictures, icon: 'nav-pictures', w: 16.667, h: 15, match: '/pictures' },
  { href: '/settings', label: copy.nav.settings, icon: 'nav-settings', w: 16.75, h: 16.667, match: '/settings' }
]

export function Sidebar ({ companyName, logoUrl, copy }: { companyName: string | null, logoUrl: string | null, copy: LayoutCopy }) {
  const pathname = usePathname()
  const items = navItems(copy)
  // The clicked item turns active at once, before its page has rendered.
  const [pending, setPending] = useState<{ from: string, to: string } | null>(null)
  const current = pending != null && pending.from === pathname ? pending.to : pathname

  return (
    <aside className='sticky top-0 flex h-screen w-[230px] shrink-0 flex-col bg-accent'>
      <div className='flex h-16 items-center justify-center gap-2 px-2'>
        <div className='flex size-9 shrink-0 items-center justify-center overflow-hidden rounded-lg bg-accent drop-shadow-[0px_1px_1px_rgba(0,0,0,0.05)]'>
          {logoUrl != null
            // eslint-disable-next-line @next/next/no-img-element -- presigned URL from the API
            ? <img src={logoUrl} alt='' className='size-full object-cover' />
            // eslint-disable-next-line @next/next/no-img-element -- static Figma SVG at its own size
            : <img src='/icons/logo.svg' alt='' width={18.2875} height={18.2417} />}
        </div>
        <p className='truncate text-[18px] font-bold leading-4 tracking-[-0.4px] text-white'>
          {companyName ?? copy.companyFallback}
        </p>
      </div>

      <nav className='flex flex-1 flex-col overflow-auto py-4 pl-3'>
        {items.map((item) => {
          const active = current.startsWith(item.match)
          return active
            ? (
              <Link key={item.label} href={item.href} aria-current='page' onClick={(e) => { if (current === pathname) e.preventDefault() }} style={{ height: ROW }} className='relative w-full shrink-0 cursor-default text-accent'>
                {/* eslint-disable-next-line @next/next/no-img-element -- static Figma SVG at its own size */}
                <img src='/icons/nav-active-bg.svg' alt='' width={218} height={TAB} style={{ top: (ROW - TAB) / 2, height: TAB }} className='anim-fade-in pointer-events-none absolute inset-x-0 w-full' />
                <span className='relative flex h-full items-center gap-3 pl-[12.5px]'>
                  <Icon name={item.icon} width={item.w} height={item.h} />
                  <span className='text-sm font-medium leading-6'>{item.label}</span>
                </span>
              </Link>
              )
            : (
              <Link data-ripple key={item.label} href={item.href} onClick={() => setPending({ from: pathname, to: item.href })} style={{ height: ROW }} className='flex w-full shrink-0 items-center gap-3 rounded-lg pl-[12.5px] pr-3 text-white'>
                <Icon name={item.icon} width={item.w} height={item.h} />
                <span className='text-sm font-medium leading-6'>{item.label}</span>
              </Link>
              )
        })}
      </nav>
    </aside>
  )
}
