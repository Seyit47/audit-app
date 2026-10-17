'use client'

import { guard } from '@/lib/feedback'
import { useState, useTransition } from 'react'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { DataTable } from '@/components/ui/DataTable'
import { TextInput } from '@/components/ui/FormField'
import type { ActionResult } from '@/lib/action-result'
import { addDistrict, deleteDistrict, renameDistrict } from '../actions'
import type { DistrictsCopy } from '../copy'

type Item = { id: string, name: string, shops: number }

/**
 * The districts list (admins): add by name, rename in place, delete (refused while it has shops). Built like the
 * Settings name lists from the 3:407 table and 162:20071 inputs; not a Figma frame (asked for).
 */
export function DistrictsCard ({ items, copy }: { items: Item[], copy: DistrictsCopy }) {
  const [name, setName] = useState('')
  const [editing, setEditing] = useState<{ id: string, name: string } | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()

  const act = (fn: () => Promise<ActionResult<unknown>>, done?: () => void) => startTransition(() => guard(async () => {
    const r = await fn()
    if (r.ok) { setError(null); done?.() } else setError(r.code === 'CONFLICT' ? copy.inUse : copy.errors[r.code as keyof typeof copy.errors] ?? copy.errors.generic)
  }))

  return (
    <Card className='flex flex-col gap-4 p-5'>
      <form
        className='flex gap-3'
        onSubmit={(e) => { e.preventDefault(); if (name.trim() !== '') act(() => addDistrict(name.trim()), () => setName('')) }}
      >
        <TextInput value={name} onChange={(e) => setName(e.target.value)} placeholder={copy.name} aria-label={copy.name} className='h-9 px-3' />
        <Button type='submit' disabled={pending || name.trim() === ''}>{copy.add}</Button>
      </form>
      {error != null && <p role='alert' className='text-[11px] leading-[16.5px] text-error'>{error}</p>}
      <DataTable
        rows={items}
        rowKey={(r) => r.id}
        density='compact'
        empty={copy.empty}
        columns={[
          {
            key: 'name',
            header: copy.name,
            render: (r) => editing?.id === r.id
              ? (
                <form className='flex gap-2' onSubmit={(e) => { e.preventDefault(); act(() => renameDistrict(r.id, editing.name.trim()), () => setEditing(null)) }}>
                  <TextInput value={editing.name} onChange={(e) => setEditing({ id: r.id, name: e.target.value })} aria-label={copy.name} className='h-8 px-2' autoFocus />
                  <Button type='submit' disabled={pending || editing.name.trim() === ''}>{copy.confirm}</Button>
                  <Button variant='secondary' onClick={() => setEditing(null)}>{copy.cancel}</Button>
                </form>
                )
              : <a href={`/shops?districtId=${r.id}`} className='text-sm font-medium text-ink hover:text-accent'>{r.name}</a>
          },
          { key: 'shops', header: copy.shops, width: 100, render: (r) => <span className='text-sm text-muted'>{r.shops}</span> },
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
                  <Button variant='outline' disabled={pending || r.shops > 0} onClick={() => act(() => deleteDistrict(r.id))}>{copy.delete}</Button>
                </span>
                )
          }
        ]}
      />
    </Card>
  )
}
