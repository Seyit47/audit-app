import Link from 'next/link'
import { DataTable, type Column, type TableSort } from '@/components/ui/DataTable'
import { RowMenu } from '@/components/ui/RowMenu'
import { StatusBadge } from '@/components/ui/StatusBadge'
import { UrlPagination } from '@/components/ui/UrlPagination'
import { initials } from '@/components/ui/Avatar'
import { lastActivity, number, shortPhone } from '@/lib/format'
import type { Locale } from '@/lib/i18n'
import type { Page } from '@/lib/api'
import type { AgentRow } from '../api'
import type { AgentsCopy } from '../copy'

const num = 'px-3 text-right font-display font-bold text-ink'

/** Salesmen table of 31:2307 (31:2817). */
export function AgentsTable ({ page, copy, locale, sort }: { page: Page<AgentRow>, copy: AgentsCopy, locale: Locale, sort: TableSort }) {
  const columns: Column<AgentRow>[] = [
    {
      key: 'salesman', header: copy.columns.salesman, width: 216, sortKey: 'fullName', className: 'pl-4 pr-0',
      render: (a) => {
        const working = a.active && a.workStatus === 'ACTIVE'
        const sub = a.topPerformer ? copy.topPerformer : a.workStatus === 'ON_LEAVE' ? copy.onLeave : a.region.name
        return (
          <Link href={`/salesmen/${a.id}`} className='flex items-center gap-3'>
            <span className={`flex size-8 shrink-0 items-center justify-center rounded-full text-xs font-bold leading-4 ${working ? 'bg-accent/20 text-accent' : 'bg-line text-muted'}`}>{initials(a.fullName)}</span>
            <span className='flex min-w-0 flex-col'>
              <span className='truncate font-semibold text-ink'>{a.fullName}</span>
              <span className={`truncate font-display text-[10px] ${a.topPerformer ? 'text-accent' : 'text-subtle'}`}>{sub}</span>
            </span>
          </Link>
        )
      }
    },
    { key: 'code', header: copy.columns.code, width: 82, sortKey: 'code', render: (a) => <span className='font-display text-muted'>{a.code}</span> },
    { key: 'phone', header: copy.columns.phone, width: 96, render: (a) => <span className='font-display text-[11px] text-muted'>{shortPhone(a.phone)}</span> },
    { key: 'locations', header: copy.columns.locations, width: 76, sortKey: 'locations', className: num, render: (a) => number(a.locations, locale) },
    { key: 'visits', header: copy.columns.visits, width: 84, sortKey: 'visits', className: num, render: (a) => number(a.visits, locale) },
    { key: 'photos', header: copy.columns.photos, width: 92, sortKey: 'photos', className: num, render: (a) => number(a.photos, locale) },
    {
      key: 'last', header: copy.columns.lastActivity, width: 112, sortKey: 'lastActivityAt',
      render: (a) => {
        const fresh = a.lastActivityAt != null && new Date(a.lastActivityAt).toDateString() === new Date().toDateString()
        return <span className={fresh ? 'font-semibold text-success' : 'font-medium text-muted'}>{lastActivity(a.lastActivityAt, locale)}</span>
      }
    },
    {
      key: 'status', header: copy.columns.status, width: 104,
      render: (a) => a.active && a.workStatus === 'ACTIVE'
        ? <StatusBadge tone='success'>{copy.active}</StatusBadge>
        : <StatusBadge tone='inactive'>{copy.inactive}</StatusBadge>
    },
    {
      key: 'menu', header: '', className: 'px-3 text-right',
      render: (a) => (
        <RowMenu label={copy.actions} items={[
          { label: copy.viewDetails, icon: { name: 'menu-view', width: 14.667, height: 10 }, href: `/salesmen/${a.id}` },
          { label: copy.edit, icon: { name: 'menu-edit', width: 12, height: 12 }, href: `/salesmen?edit=${a.id}`, dialog: { kind: 'agent', id: a.id } },
          // Opens AgentPasswordHost in the browser (?password=<id>).
          { label: copy.changePassword, icon: { name: 'menu-edit', width: 12, height: 12 }, href: `/salesmen?password=${a.id}`, dialog: { kind: 'agent', id: a.id } }
        ]} />
      )
    }
  ]

  return (
    <DataTable
      density='compact'
      columns={columns}
      rows={page.items}
      rowKey={(a) => a.id}
      rowClassName={(a) => (a.active && a.workStatus === 'ACTIVE' ? '' : 'opacity-75')}
      sort={sort}
      empty={copy.empty}
      footer={<UrlPagination page={page.page} size={page.size} total={page.total} noun={copy.pagination.noun} copy={copy.pagination} />}
    />
  )
}
