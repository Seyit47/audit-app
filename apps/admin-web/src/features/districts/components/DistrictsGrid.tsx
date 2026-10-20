'use client'

import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useState, useTransition } from 'react'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { Dialog } from '@/components/ui/Dialog'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { FormField, TextInput } from '@/components/ui/FormField'
import { PageHeader } from '@/components/ui/PageHeader'
import { RowMenu } from '@/components/ui/RowMenu'
import type { ActionResult } from '@/lib/action-result'
import { guard, say } from '@/lib/feedback'
import { plural, sub, type Locale } from '@/lib/i18n'
import { addDistrict, deleteDistrict, renameDistrict } from '../actions'
import type { District } from '../api'
import type { DistrictsCopy } from '../copy'

type Editing = { mode: 'add' } | { mode: 'rename', id: string, name: string } | { mode: 'delete', id: string, name: string }

/**
 * Districts as cards (admins): shops and salesmen in each, today's visits as a bar, overdue shops; a card opens
 * its shops. Add from the header; rename and delete (only an empty district) from the card's menu. Not a Figma
 * frame (asked for): built from the page header, cards, row menu and form dialog of the other pages.
 */
export function DistrictsGrid ({ districts, copy, locale }: { districts: District[], copy: DistrictsCopy, locale: Locale }) {
  const [q, setQ] = useState('')
  const [editing, setEditing] = useState<Editing | null>(null)
  const needle = q.trim().toLowerCase()
  const shown = districts.filter((d) => needle === '' || (d.name ?? copy.none).toLowerCase().includes(needle))

  return (
    <>
      <PageHeader
        title={copy.title}
        description={copy.description}
        actions={<Button onClick={() => setEditing({ mode: 'add' })} icon={<FigmaIcon name='plus' width={10.5} height={10.5} />}>{copy.add}</Button>}
      />
      <Card className='flex items-center gap-2 p-4'>
        <label className='flex h-10 w-full max-w-sm items-center gap-2 rounded-lg bg-secondary-bg px-3'>
          <FigmaIcon name='search' width={14} height={14} />
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder={copy.search} aria-label={copy.search}
            className='h-full w-full bg-transparent text-sm text-ink outline-none placeholder:text-muted' />
        </label>
      </Card>
      {shown.length === 0
        ? <Card className='p-10 text-center text-sm text-muted'>{districts.length === 0 ? copy.empty : copy.noMatch}</Card>
        : (
          <div className='grid grid-cols-[repeat(auto-fill,minmax(260px,1fr))] gap-4'>
            {shown.map((d) => <DistrictCardView key={d.id ?? 'none'} d={d} copy={copy} locale={locale} onEdit={setEditing} />)}
          </div>
          )}
      {editing != null && <DistrictDialog editing={editing} copy={copy} onClose={() => setEditing(null)} />}
    </>
  )
}

function DistrictCardView ({ d, copy, locale, onEdit }: { d: District, copy: DistrictsCopy, locale: Locale, onEdit: (e: Editing) => void }) {
  const pct = d.shops === 0 ? 0 : Math.round(d.visitedToday / d.shops * 100)
  const href = `/shops?districtId=${d.id ?? 'none'}`
  return (
    <Card className='group relative flex flex-col gap-4 p-5 transition-shadow hover:shadow-md'>
      {/* The whole card opens the district's shops; the menu sits above the link. */}
      <Link href={href} aria-label={`${copy.openShops}: ${d.name ?? copy.none}`} className='absolute inset-0 rounded-[inherit]' />
      <div className='flex items-start justify-between gap-3'>
        <div className='flex min-w-0 items-center gap-3'>
          <span className={`flex size-10 shrink-0 items-center justify-center rounded-xl ${d.id == null ? 'bg-secondary-bg' : 'bg-dark-accent'}`}>
            <FigmaIcon name='agent-sector' width={12} height={17} />
          </span>
          <div className='min-w-0'>
            <h2 className={`truncate text-base font-bold leading-6 ${d.id == null ? 'text-muted' : 'text-ink group-hover:text-accent'}`}>{d.name ?? copy.none}</h2>
            <p className='text-xs leading-4 text-muted'>
              {d.shops} {plural(locale, d.shops, copy.shops)} · {d.agents} {plural(locale, d.agents, copy.agents)}
            </p>
          </div>
        </div>
        {d.id != null && (
          <div className='relative z-10'>
            <RowMenu label={d.name ?? ''} items={[
              { label: copy.rename, icon: { name: 'menu-edit', width: 12, height: 12 }, onSelect: () => onEdit({ mode: 'rename', id: d.id!, name: d.name! }) },
              // Only an empty district can go (the server refuses otherwise).
              ...(d.shops === 0
                ? [{ label: copy.delete, icon: { name: 'menu-delete', width: 10.667, height: 12 }, danger: true, separated: true, onSelect: () => onEdit({ mode: 'delete', id: d.id!, name: d.name! }) }]
                : [])
            ]} />
          </div>
        )}
      </div>
      {d.shops === 0
        ? <p className='text-sm text-muted'>{copy.noShops}</p>
        : (
          <div className='flex flex-col gap-2'>
            <div className='flex items-baseline justify-between text-xs leading-4'>
              <span className='font-medium text-muted'>{copy.visitedToday}</span>
              <span className='font-semibold text-ink'>{d.visitedToday} / {d.shops}</span>
            </div>
            <div className='h-2 overflow-hidden rounded-full bg-secondary-bg' role='progressbar' aria-valuenow={pct} aria-valuemin={0} aria-valuemax={100} aria-label={copy.visitedToday}>
              <div className={`h-full rounded-full ${pct === 100 ? 'bg-success' : 'bg-accent'}`} style={{ width: `${pct}%` }} />
            </div>
            <div className='flex h-5 items-center'>
              {d.overdue > 0 && (
                <span className='rounded-full bg-[rgba(220,38,38,0.1)] px-2 py-0.5 text-[11px] font-semibold leading-4 text-error'>{sub(copy.overdue, d.overdue)}</span>
              )}
            </div>
          </div>
          )}
    </Card>
  )
}

/** Add or rename (a name field), or confirm deleting an empty district. */
function DistrictDialog ({ editing, copy, onClose }: { editing: Editing, copy: DistrictsCopy, onClose: () => void }) {
  const router = useRouter()
  const [name, setName] = useState(editing.mode === 'rename' ? editing.name : '')
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()
  const run = (fn: () => Promise<ActionResult<unknown>>) => startTransition(() => guard(async () => {
    const r = await fn()
    if (!r.ok) return setError(r.code === 'CONFLICT' ? copy.inUse : copy.errors[r.code as keyof typeof copy.errors] ?? copy.errors.generic)
    say(editing.mode === 'delete' ? 'deleted' : editing.mode === 'add' ? 'created' : 'saved')
    onClose()
    router.refresh()
  }))
  const save = () => {
    if (editing.mode === 'delete') return run(() => deleteDistrict(editing.id))
    if (name.trim() === '') return setError(copy.errors.VALIDATION_FAILED)
    run(() => editing.mode === 'add' ? addDistrict(name.trim()) : renameDistrict(editing.id, name.trim()))
  }
  const title = editing.mode === 'add' ? copy.addTitle : editing.mode === 'rename' ? copy.renameTitle : copy.deleteTitle
  return (
    <Dialog open variant='form' width={440} onClose={onClose} closeLabel={copy.cancel} title={title}
      footer={
        <>
          {error != null && <p role='alert' className='mr-auto text-xs text-error'>{error}</p>}
          <Button variant='outline' size='md' data-dialog-close>{copy.cancel}</Button>
          <Button size='md' disabled={pending} onClick={save} className={editing.mode === 'delete' ? 'bg-danger shadow-none' : ''}>
            {editing.mode === 'delete' ? copy.delete : editing.mode === 'add' ? copy.create : copy.save}
          </Button>
        </>
      }>
      {editing.mode === 'delete'
        ? <p className='text-sm leading-5 text-slate-700'>{sub(copy.deleteBody, editing.name)}</p>
        : (
          <form onSubmit={(e) => { e.preventDefault(); save() }}>
            <FormField variant='form' label={copy.name} htmlFor='district-name'>
              <TextInput variant='form' id='district-name' autoFocus value={name} placeholder={copy.namePlaceholder}
                onChange={(e) => { setName(e.target.value); setError(null) }} />
            </FormField>
          </form>
          )}
    </Dialog>
  )
}
