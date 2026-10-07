'use client'

import { guard } from '@/lib/feedback'
import { useState, useTransition } from 'react'
import { Button } from '@/components/ui/Button'
import { Card } from '@/components/ui/Card'
import { DataTable } from '@/components/ui/DataTable'
import { TextInput } from '@/components/ui/FormField'
import type { ActionResult } from '@/lib/action-result'
import { addRegion, deleteRegion, renameRegion } from '../actions'
import type { SettingsCopy } from '../copy'

type Region = { id: string, name: string }

/** Regions (sales territories) for Settings (A4), from the 3:407 table and 162:20071 inputs. */
export function RegionsCard ({ regions, copy }: { regions: Region[], copy: SettingsCopy }) {
  const [name, setName] = useState('')
  const [editing, setEditing] = useState<{ id: string, name: string } | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()

  const act = (fn: () => Promise<ActionResult<unknown>>, done?: () => void) => startTransition(() => guard(async () => {
    const r = await fn()
    if (r.ok) { setError(null); done?.() } else setError(copy.errors[r.code as keyof typeof copy.errors] ?? copy.errors.generic)
  }))

  return (
    <Card className='flex flex-col gap-4 p-5'>
      <h2 className='text-base font-bold leading-6 text-ink'>{copy.regions}</h2>
      <form
        className='flex gap-3'
        onSubmit={(e) => { e.preventDefault(); if (name.trim() !== '') act(() => addRegion(name.trim()), () => setName('')) }}
      >
        <TextInput value={name} onChange={(e) => setName(e.target.value)} placeholder={copy.regionName} aria-label={copy.regionName} className='h-9 px-3' />
        <Button type='submit' disabled={pending || name.trim() === ''}>{copy.addRegion}</Button>
      </form>
      {error != null && <p role='alert' className='text-[11px] leading-[16.5px] text-error'>{error}</p>}
      <DataTable
        rows={regions}
        rowKey={(r) => r.id}
        density='compact'
        empty={copy.noRegions}
        columns={[
          {
            key: 'name',
            header: copy.regionName,
            render: (r) => editing?.id === r.id
              ? (
                <form className='flex gap-2' onSubmit={(e) => { e.preventDefault(); act(() => renameRegion(r.id, editing.name.trim()), () => setEditing(null)) }}>
                  <TextInput value={editing.name} onChange={(e) => setEditing({ id: r.id, name: e.target.value })} aria-label={copy.regionName} className='h-8 px-2' autoFocus />
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
                  <Button variant='outline' disabled={pending} onClick={() => act(() => deleteRegion(r.id))}>{copy.delete}</Button>
                </span>
                )
          }
        ]}
      />
    </Card>
  )
}
