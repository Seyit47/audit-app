'use client'

import { say } from '@/lib/feedback'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useState, useTransition } from 'react'
import { Avatar } from '@/components/ui/Avatar'
import { Button } from '@/components/ui/Button'
import { Checkbox } from '@/components/ui/Checkbox'
import { DataTable, type Column } from '@/components/ui/DataTable'
import { Dialog } from '@/components/ui/Dialog'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { FormField, SelectInput } from '@/components/ui/FormField'
import { PageHeader } from '@/components/ui/PageHeader'
import { RowMenu } from '@/components/ui/RowMenu'
import { StatusBadge } from '@/components/ui/StatusBadge'
import { UrlPagination } from '@/components/ui/UrlPagination'
import type { Page } from '@/lib/api'
import { formatPhone } from '@/lib/format'
import type { Locale } from '@/lib/i18n'
import { assignShops, deleteShops } from '../actions'
import type { ShopRow } from '../api'
import type { ShopsCopy } from '../copy'

type AgentOption = { id: string, fullName: string, code: string }

const tag = (l: Locale) => (l === 'ru' ? 'ru-RU' : 'en-US')

function visitTime (iso: string, l: Locale, today: string) {
  const d = new Date(iso)
  const time = new Intl.DateTimeFormat(tag(l), { hour: '2-digit', minute: '2-digit', hour12: l === 'en' }).format(d)
  if (d.toDateString() === new Date().toDateString()) return `${today}, ${time}`
  return `${new Intl.DateTimeFormat(tag(l), { month: 'short', day: 'numeric' }).format(d)}, ${time}`
}

/** Shops list of 3:407 (row menu) and 53:151 (selection with bulk header actions). */
export function ShopsView ({ page, copy, locale, agents, exportHref, children }: {
  page: Page<ShopRow>
  copy: ShopsCopy
  locale: Locale
  agents: AgentOption[]
  exportHref: string
  children?: React.ReactNode
}) {
  const router = useRouter()
  const [selected, setSelected] = useState<Set<string>>(new Set())
  const [assigning, setAssigning] = useState<string[] | null>(null)
  const [deleting, setDeleting] = useState<string[] | null>(null)
  const [pending, startTransition] = useTransition()
  const [error, setError] = useState<string | null>(null)
  const ids = page.items.map((s) => s.id)
  const allChecked = ids.length > 0 && ids.every((id) => selected.has(id))
  const toggle = (id: string) => setSelected((s) => { const n = new Set(s); if (n.has(id)) n.delete(id); else n.add(id); return n })
  const chosen = [...selected]

  const columns: Column<ShopRow>[] = [
    {
      key: 'check', width: 48, className: 'pl-4 pr-0',
      header: <Checkbox aria-label={copy.selectAll} checked={allChecked} onChange={() => setSelected(allChecked ? new Set() : new Set(ids))} />,
      render: (s) => <Checkbox aria-label={copy.selectRow} checked={selected.has(s.id)} onChange={() => toggle(s.id)} />
    },
    {
      key: 'shop', header: copy.columns.shop, width: 280, className: 'pl-2 pr-0',
      render: (s) => (
        <Link href={`/shops/${s.id}`} className='flex items-center gap-3'>
          <Avatar name={s.name} size='lg' tone={selected.has(s.id) ? 'accent' : 'muted'} src={s.facade?.previewUrl400} />
          <span className='flex min-w-0 flex-col'>
            <span className='truncate text-sm font-semibold leading-5 text-ink'>{s.name}</span>
            <span className='flex items-center gap-1.5 text-xs leading-4 text-ink'>
              <FigmaIcon name='pin-small' width={9.333} height={11.667} />
              <span className='max-w-40 truncate'>{s.address}</span>
            </span>
          </span>
        </Link>
      )
    },
    { key: 'code', header: copy.columns.code, width: 78, className: 'px-0', render: (s) => <span className='rounded bg-dark-accent px-2 py-px font-display text-ink'>{s.code}</span> },
    { key: 'owner', header: copy.columns.owner, width: 135, className: 'px-2', render: (s) => <span className='block truncate'>{s.ownerName ?? '—'}</span> },
    { key: 'phone', header: copy.columns.phone, width: 135, className: 'px-2', render: (s) => <span className='font-display'>{s.contacts[0] != null ? formatPhone(s.contacts[0].phone) : '—'}</span> },
    {
      key: 'visit', header: copy.columns.lastVisit, width: 130, className: 'px-3',
      render: (s) => s.lastVisit == null
        ? <span className='text-subtle'>{copy.never}</span>
        : (
          <span className='flex flex-col'>
            <span className='font-medium'>{visitTime(s.lastVisit.at, locale, copy.today)}</span>
            <span className='truncate text-[10px] text-subtle'>{copy.by} {s.lastVisit.agentName}</span>
          </span>
          )
    },
    {
      key: 'agent', header: copy.columns.agent, width: 168, className: 'pl-3 pr-0',
      render: (s) => s.agent == null
        ? <span className='text-subtle'>{copy.unassigned}</span>
        : <span className='flex items-center gap-2'><Avatar name={s.agent.fullName} /><span className='truncate font-medium'>{s.agent.fullName}</span></span>
    },
    {
      key: 'status', header: copy.columns.status, width: 148, className: 'pl-6 pr-3',
      render: (s) => s.status === 'ACTIVE'
        ? <StatusBadge tone='success'>{copy.statuses.ACTIVE}</StatusBadge>
        : s.status === 'PENDING_REVIEW'
          ? <StatusBadge tone='pending'>{copy.statuses.PENDING_REVIEW}</StatusBadge>
          : <StatusBadge tone='inactive'>{copy.statuses.INACTIVE}</StatusBadge>
    },
    {
      key: 'menu', header: '', className: 'px-4 text-right',
      render: (s) => (
        <RowMenu label={copy.actions} items={[
          { label: copy.viewDetails, icon: { name: 'menu-view', width: 14.667, height: 10 }, href: `/shops/${s.id}` },
          { label: copy.editShop, icon: { name: 'menu-edit', width: 12, height: 12 }, href: `/shops/${s.id}?edit=1` },
          { label: copy.viewOnMap, icon: { name: 'menu-map', width: 13.3, height: 13.267 }, href: `/map?ids=${s.id}` },
          { label: copy.assign, icon: { name: 'menu-assign', width: 13.333, height: 13.333 }, onSelect: () => setAssigning([s.id]) },
          { label: copy.deleteShop, icon: { name: 'menu-delete', width: 10.667, height: 12 }, danger: true, separated: true, onSelect: () => setDeleting([s.id]) }
        ]} />
      )
    }
  ]

  function act (fn: () => Promise<{ ok: boolean }>) {
    setError(null)
    startTransition(async () => {
      const res = await fn()
      if (!res.ok) return setError(copy.errors.generic)
      say(deleting != null ? 'deleted' : 'assigned')
      setAssigning(null); setDeleting(null); setSelected(new Set())
      router.refresh()
    })
  }

  return (
    <>
      <PageHeader
        title={copy.title}
        badge={copy.badge}
        description={copy.description}
        actions={
          <>
            <Button variant='secondary' href={exportHref} icon={<FigmaIcon name='export' width={13} height={13} />}>{copy.exportShops}</Button>
            {chosen.length === 0
              ? <Button prefetch href='/shops?add=1' icon={<FigmaIcon name='plus' width={10.5} height={10.5} />}>{copy.addShop}</Button>
              : (
                <>
                  <Button variant='secondary' onClick={() => setAssigning(chosen)} icon={<FigmaIcon name='link' width={12} height={12} />}>{copy.assign}</Button>
                  <Button variant='secondary' href={`/map?ids=${chosen.join(',')}`} icon={<FigmaIcon name='menu-map' width={12} height={12} />}>{copy.viewOnMap}</Button>
                  <Button variant='danger' onClick={() => setDeleting(chosen)} icon={<FigmaIcon name='menu-delete' width={10.667} height={12} />}>{copy.deleteShop}</Button>
                </>
                )}
          </>
        }
      />
      {children}
      <DataTable
        columns={columns}
        rows={page.items}
        rowKey={(s) => s.id}
        isSelected={(s) => selected.has(s.id)}
        empty={copy.empty}
        footer={<UrlPagination page={page.page} size={page.size} total={page.total} noun={copy.pagination.noun} copy={copy.pagination} />}
      />
      {assigning != null && (
        <AssignDialog copy={copy} count={assigning.length} agents={agents} pending={pending} error={error}
          onClose={() => setAssigning(null)} onSave={(agentId) => act(() => assignShops(assigning, agentId))} />
      )}
      {deleting != null && (
        <Dialog open variant='form' width={480} onClose={() => setDeleting(null)} closeLabel={copy.deleteDialog.cancel} title={copy.deleteDialog.title}
          footer={
            <>
              {error != null && <p role='alert' className='mr-auto text-xs text-error'>{error}</p>}
              <Button variant='outline' size='md' data-dialog-close>{copy.deleteDialog.cancel}</Button>
              <Button size='md' disabled={pending} onClick={() => act(() => deleteShops(deleting))} className='bg-danger shadow-none'>{copy.deleteDialog.confirm}</Button>
            </>
          }>
          <p className='text-sm leading-5 text-slate-700'>{copy.deleteDialog.body.replace('{n}', String(deleting.length))}</p>
        </Dialog>
      )}
    </>
  )
}

function AssignDialog ({ copy, count, agents, pending, error, onClose, onSave }: {
  copy: ShopsCopy, count: number, agents: AgentOption[], pending: boolean, error: string | null, onClose: () => void, onSave: (agentId: string | null) => void
}) {
  const [agentId, setAgentId] = useState('')
  const d = copy.assignDialog
  return (
    <Dialog open variant='form' width={480} onClose={onClose} closeLabel={d.cancel} title={d.title} subtitle={d.subtitle.replace('{n}', String(count))}
      footer={
        <>
          {error != null && <p role='alert' className='mr-auto text-xs text-error'>{error}</p>}
          <Button variant='outline' size='md' data-dialog-close>{d.cancel}</Button>
          <Button size='md' disabled={pending} onClick={() => onSave(agentId === '' ? null : agentId)}>{d.save}</Button>
        </>
      }>
      <FormField variant='form' label={d.label} htmlFor='assign-agent'>
        <SelectInput variant='form' id='assign-agent' value={agentId} onChange={(e) => setAgentId(e.target.value)}>
          <option value=''>{d.none}</option>
          {agents.map((a) => <option key={a.id} value={a.id}>{a.fullName} {a.code}</option>)}
        </SelectInput>
      </FormField>
    </Dialog>
  )
}
