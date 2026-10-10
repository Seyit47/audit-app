'use client'

import Link from 'next/link'
import { Fragment } from 'react'
import * as Menu from '@radix-ui/react-dropdown-menu'
import { FigmaIcon } from './FigmaIcon'
import type { FormKind } from '@/lib/url-dialog'
import { DialogLink } from './DialogLink'

export interface RowMenuItem {
  label: string
  icon: { name: string, width: number, height: number }
  href?: string
  /** With href: opens that form's URL dialog in the browser (no server render). */
  dialog?: { kind: FormKind, id?: string | null }
  onSelect?: () => void
  danger?: boolean
  /** Draws the divider above the item ("Delete Shop", 3:1973). */
  separated?: boolean
}

/**
 * Row "more" button and action dropdown of 3:407 (3:1959). Radix DropdownMenu underneath: arrow keys, Home/End
 * and typeahead move between items, Enter picks, Escape closes and returns focus to the button, and the menu
 * flips up near the bottom of the window and follows its row while the page scrolls.
 */
export function RowMenu ({ items, label = 'Actions' }: { items: RowMenuItem[], label?: string }) {
  return (
    <Menu.Root modal={false}>
      <Menu.Trigger asChild>
        <button type='button' aria-label={label} data-ripple className='rounded-full text-ink'>
          <FigmaIcon name='row-more' width={32} height={32} />
        </button>
      </Menu.Trigger>
      <Menu.Portal>
        <Menu.Content
          align='end' sideOffset={4} collisionPadding={8}
          className='anim-menu-in z-40 flex w-44 origin-(--radix-dropdown-menu-content-transform-origin) flex-col rounded-xl bg-pure-white py-1.5 shadow-[0px_20px_25px_-5px_rgba(0,0,0,0.1),0px_8px_10px_-6px_rgba(0,0,0,0.1)]'
        >
          {items.map((item) => {
            const cls = `relative mx-1.5 flex items-center gap-2 rounded-lg px-2.5 py-2 text-left text-xs font-medium leading-4 outline-none ${item.danger === true ? 'text-danger' : 'text-ink'}`
            // Icons differ in width; a fixed centered slot keeps the labels aligned.
            const content = <><span className='flex w-4 shrink-0 justify-center'><FigmaIcon {...item.icon} /></span>{item.label}</>
            const entry = item.href != null && item.dialog != null
              ? <DialogLink href={item.href} form={item.dialog} className={cls}>{content}</DialogLink>
              : item.href != null
              ? <Link data-ripple href={item.href} prefetch className={cls}>{content}</Link>
              : <button data-ripple type='button' className={cls}>{content}</button>
            return (
              <Fragment key={item.label}>
                {/* "Delete Shop" (3:1973) sits under a divider. */}
                {item.separated === true && <Menu.Separator className='my-1 h-px bg-secondary-bg' />}
                <Menu.Item asChild onSelect={item.href == null ? item.onSelect : undefined}>{entry}</Menu.Item>
              </Fragment>
            )
          })}
        </Menu.Content>
      </Menu.Portal>
    </Menu.Root>
  )
}
