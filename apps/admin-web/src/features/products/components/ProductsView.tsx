'use client'

import { useState } from 'react'
import { Checkbox } from '@/components/ui/Checkbox'
import { DataTable, type Column } from '@/components/ui/DataTable'
import { RowMenu } from '@/components/ui/RowMenu'
import { StatusBadge } from '@/components/ui/StatusBadge'
import { UrlPagination } from '@/components/ui/UrlPagination'
import type { Page } from '@/lib/api'
import type { Product } from '../api'
import type { ProductsCopy } from '../copy'

/** Products table of 30:574 (31:3037). */
export function ProductsView ({ page, copy }: { page: Page<Product>, copy: ProductsCopy }) {
  const [selected, setSelected] = useState<Set<string>>(new Set())
  const ids = page.items.map((p) => p.id)
  const all = ids.length > 0 && ids.every((id) => selected.has(id))
  const toggle = (id: string) => setSelected((s) => { const n = new Set(s); if (n.has(id)) n.delete(id); else n.add(id); return n })

  const columns: Column<Product>[] = [
    { key: 'check', width: 46, className: 'pl-4 pr-0', header: <Checkbox aria-label={copy.selectAll} checked={all} onChange={() => setSelected(all ? new Set() : new Set(ids))} />, render: (p) => <Checkbox aria-label={copy.selectRow} checked={selected.has(p.id)} onChange={() => toggle(p.id)} /> },
    {
      key: 'product', header: copy.columns.product, width: 323, className: 'pl-4 pr-0',
      render: (p) => (
        <a href={`/products?edit=${p.id}`} className='flex items-center gap-3'>
          <span className='size-10 shrink-0 overflow-hidden rounded-lg bg-dark-accent shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
            {/* eslint-disable-next-line @next/next/no-img-element -- presigned URL */}
            {p.image != null && <img src={p.image.previewUrl400} alt='' className='size-full object-cover' />}
          </span>
          <span className='flex min-w-0 flex-col'>
            <span className='truncate font-semibold text-ink'>{p.name}</span>
            <span className='truncate text-[11px] text-muted'>{p.description ?? p.category.name}</span>
          </span>
        </a>
      )
    },
    { key: 'code', header: copy.columns.code, width: 106, className: 'pl-7 pr-3', render: (p) => <span className={`font-display ${selected.has(p.id) ? 'text-accent' : 'text-muted'}`}>{p.sku}</span> },
    {
      key: 'status', header: copy.columns.status, width: 100, className: 'pl-6 pr-3',
      render: (p) => p.status === 'ACTIVE'
        ? <StatusBadge tone='success'>{copy.statuses.ACTIVE}</StatusBadge>
        : p.status === 'DRAFT' ? <StatusBadge tone='pending'>{copy.statuses.DRAFT}</StatusBadge> : <StatusBadge tone='inactive'>{copy.statuses.INACTIVE}</StatusBadge>
    },
    { key: 'menu', header: '', className: 'px-4 text-right', render: (p) => <RowMenu label={copy.actions} items={[{ label: copy.edit, icon: { name: 'menu-edit', width: 12, height: 12 }, href: `/products?edit=${p.id}` }]} /> }
  ]

  return (
    <DataTable
      columns={columns} rows={page.items} rowKey={(p) => p.id} isSelected={(p) => selected.has(p.id)} empty={copy.empty}
      footer={<UrlPagination page={page.page} size={page.size} total={page.total} noun={copy.pagination.noun} copy={copy.pagination} />}
    />
  )
}
