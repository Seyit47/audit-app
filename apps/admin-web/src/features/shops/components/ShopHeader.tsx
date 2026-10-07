'use client'

import { say } from '@/lib/feedback'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useTransition } from 'react'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { Toggle } from '@/components/ui/Toggle'
import { formatPhone } from '@/lib/format'
import { setShopStatus } from '../actions'
import type { ShopDetails } from '../api'
import type { ShopsCopy } from '../copy'

/** "Client Header Entity Card" of 47:7387. The toggle also approves Pending Review shops (gap A1). */
export function ShopHeader ({ shop, copy }: { shop: ShopDetails, copy: ShopsCopy }) {
  const router = useRouter()
  const [pending, startTransition] = useTransition()
  const d = copy.details
  const active = shop.status === 'ACTIVE'
  const statusText = copy.statuses[shop.status]

  return (
    <div className='flex items-center justify-between gap-6 rounded-xl bg-pure-white p-6 shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
      <div className='flex min-w-0 items-center gap-5'>
        <span className='size-16 shrink-0 overflow-hidden rounded-xl bg-[#e2dfff] shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
          {/* eslint-disable-next-line @next/next/no-img-element -- presigned URL */}
          {shop.facade != null && <img src={shop.facade.previewUrl400} alt='' className='size-full object-cover' />}
        </span>
        <div className='flex min-w-0 flex-col gap-1.5'>
          <div className='flex items-center gap-3'>
            <h1 className='truncate text-2xl font-bold leading-8 tracking-[-0.6px] text-ink'>{shop.name}</h1>
            <span className='rounded bg-dark-accent px-2.5 py-0.5 text-xs font-semibold leading-4 text-muted'>{shop.code}</span>
            <span className={`flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium leading-4 ${active ? 'bg-success-10 text-success' : shop.status === 'PENDING_REVIEW' ? 'bg-pending-bg text-accent' : 'bg-inactive-bg text-muted'}`}>
              <span className={`size-1.5 rounded-full ${active ? 'bg-success' : shop.status === 'PENDING_REVIEW' ? 'bg-accent' : 'bg-subtle'}`} />{statusText}
            </span>
          </div>
          <div className='flex flex-col gap-1 text-xs font-medium leading-4 text-muted'>
            <div className='flex flex-wrap items-center gap-4'>
              {shop.contacts[0] != null && <span className='flex items-center gap-1.5'><FigmaIcon name='detail-phone' width={12} height={12} />{formatPhone(shop.contacts[0].phone)}</span>}
              <span className='flex items-center gap-1.5'><FigmaIcon name='pin-accent-small' width={10.67} height={13.33} />{shop.address}</span>
            </div>
            {shop.agent != null && (
              <span className='flex items-center gap-1.5'><FigmaIcon name='assigned-agent' width={13.33} height={13.33} />{d.assigned} <span className='text-ink'>{shop.agent.fullName}</span> ({shop.agent.code})</span>
            )}
          </div>
        </div>
      </div>
      <div className='flex shrink-0 items-center gap-3'>
        <span className='text-sm font-semibold leading-4 text-ink'>{d.statusLabel} {statusText}</span>
        <Toggle
          label={`${d.statusLabel} ${statusText}`} checked={active} disabled={pending}
          onChange={(on) => startTransition(async () => { await setShopStatus(shop.id, shop.version, on ? 'ACTIVE' : 'INACTIVE'); say('status'); router.refresh() })}
        />
        <Link data-ripple href={`/map?ids=${shop.id}`} className='flex h-9 items-center gap-2 rounded-lg bg-dark-accent px-4 text-xs font-semibold leading-4 text-ink'>
          <FigmaIcon name='detail-map' width={13.5} height={13.5} />{copy.viewOnMap}
        </Link>
        <Link data-ripple prefetch href={`/shops/${shop.id}?edit=1`} className='flex h-9 items-center gap-2 rounded-lg bg-dark-accent px-4 text-xs font-semibold leading-4 text-ink'>
          <FigmaIcon name='detail-edit' width={13.5} height={13.5} />{d.edit}
        </Link>
      </div>
    </div>
  )
}
