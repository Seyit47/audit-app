'use client'

import * as Menu from '@radix-ui/react-dropdown-menu'
import { FigmaIcon } from '@/components/ui/FigmaIcon'

/** "Экспорт отчёта (PDF/XLS)" of 122:9104 with its two formats (Radix DropdownMenu: keyboard and focus handled). */
export function ExportMenu ({ label, items }: { label: string, items: Array<{ label: string, href: string }> }) {
  return (
    <Menu.Root modal={false}>
      <Menu.Trigger asChild>
        <button
          data-ripple type='button'
          className='flex h-9 shrink-0 items-center gap-2 rounded-lg bg-secondary-bg px-4 text-xs font-semibold leading-4 text-ink shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'
        >
          <FigmaIcon name='export-download' width={12} height={12} />{label}
        </button>
      </Menu.Trigger>
      <Menu.Portal>
        <Menu.Content
          align='end' sideOffset={4} collisionPadding={8}
          className='anim-menu-in z-40 flex w-(--radix-dropdown-menu-trigger-width) origin-(--radix-dropdown-menu-content-transform-origin) flex-col overflow-hidden rounded-lg bg-pure-white py-1 shadow-[0px_4px_6px_-4px_rgba(0,0,0,0.1),0px_10px_15px_-3px_rgba(0,0,0,0.1)]'
        >
          {/* Plain links: an export starts a server job and must not be prefetched. */}
          {items.map((i) => (
            <Menu.Item key={i.href} asChild>
              <a data-ripple href={i.href} className='mx-1 rounded-md px-3 py-2 text-xs font-medium leading-4 text-ink outline-none'>{i.label}</a>
            </Menu.Item>
          ))}
        </Menu.Content>
      </Menu.Portal>
    </Menu.Root>
  )
}
