'use client'

import { guard } from '@/lib/feedback'
import { useState, useTransition } from 'react'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { DataTable } from '@/components/ui/DataTable'
import { TextInput } from '@/components/ui/FormField'
import type { ActionResult } from '@/lib/action-result'
import { addCategory, addRegion, deleteCategory, deleteRegion, renameCategory, renameRegion } from '../actions'
import type { SettingsCopy } from '../copy'

type Item = { id: string, name: string }

const actions = {
  regions: { add: addRegion, rename: renameRegion, remove: deleteRegion },
  categories: { add: addCategory, rename: renameCategory, remove: deleteCategory }
}

/**
 * A named list managed in Settings (A4): regions (sales territories) and product categories. Built from the
 * 3:407 table and 162:20071 inputs: add by name, rename in place, delete (refused while still in use).
 */
export function NameListCard ({ kind, items, copy }: { kind: keyof typeof actions, items: Item[], copy: SettingsCopy }) {
  const { add, rename, remove } = actions[kind]
  const labels = kind === 'regions'
    ? { title: copy.regions, name: copy.regionName, add: copy.addRegion, empty: copy.noRegions, inUse: copy.regionInUse }
    : { title: copy.categories, name: copy.categoryName, add: copy.addCategory, empty: copy.noCategories, inUse: copy.categoryInUse }
  const [name, setName] = useState('')
  const [editing, setEditing] = useState<{ id: string, name: string } | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()

  const act = (fn: () => Promise<ActionResult<unknown>>, done?: () => void) => startTransition(() => guard(async () => {
    const r = await fn()
    if (r.ok) { setError(null); done?.() } else setError(r.code === 'CONFLICT' ? labels.inUse : copy.errors[r.code as keyof typeof copy.errors] ?? copy.errors.generic)
  }))

  return (
    <Card className='flex flex-col gap-4 p-5'>
      <h2 className='text-base font-bold leading-6 text-ink'>{labels.title}</h2>
      <form
        className='flex gap-3'
        onSubmit={(e) => { e.preventDefault(); if (name.trim() !== '') act(() => add(name.trim()), () => setName('')) }}
      >
        <TextInput value={name} onChange={(e) => setName(e.target.value)} placeholder={labels.name} aria-label={labels.name} className='h-9 px-3' />
        <Button type='submit' disabled={pending || name.trim() === ''}>{labels.add}</Button>
      </form>
      {error != null && <p role='alert' className='text-[11px] leading-[16.5px] text-error'>{error}</p>}
      <DataTable
        rows={items}
        rowKey={(r) => r.id}
        density='compact'
        empty={labels.empty}
        columns={[
          {
            key: 'name',
            header: labels.name,
            render: (r) => editing?.id === r.id
              ? (
                <form className='flex gap-2' onSubmit={(e) => { e.preventDefault(); act(() => rename(r.id, editing.name.trim()), () => setEditing(null)) }}>
                  <TextInput value={editing.name} onChange={(e) => setEditing({ id: r.id, name: e.target.value })} aria-label={labels.name} className='h-8 px-2' autoFocus />
                  <Button type='submit' disabled={pending || editing.name.trim() === ''}>{copy.confirm}</Button>
                  <Button variant='secondary' onClick={() => setEditing(null)}>{copy.cancel}</Button>
                </form>
                )
              : <span className='text-sm font-medium text-ink'>{r.name}</span>
          },
          {
            key: 'actions',
            header: '',
            width: 220,
            className: 'text-right',
            render: (r) => editing?.id === r.id
              ? null
              : (
                <span className='flex justify-end gap-2'>
                  <Button variant='secondary' onClick={() => setEditing({ id: r.id, name: r.name })}>{copy.rename}</Button>
                  <Button variant='outline' disabled={pending} onClick={() => act(() => remove(r.id))}>{copy.delete}</Button>
                </span>
                )
          }
        ]}
      />
    </Card>
  )
}
