'use client'

import { useSearchParams } from 'next/navigation'
import { StatusDialog } from '@/components/ui/StatusDialog'
import { setAgentStatus } from '../actions'
import type { AgentsCopy } from '../copy'

type Status = 'ACTIVE' | 'ON_LEAVE' | 'ARCHIVED'

/**
 * "Изменить статус" from a salesman's row actions: opens from `?setStatus=<id>` in the browser (no server render),
 * like "Изменить пароль". (`?status=` is the list's status filter.)
 */
export function AgentStatusHost ({ copy, agents }: { copy: AgentsCopy, agents: Array<{ id: string, fullName: string, status: Status }> }) {
  const id = useSearchParams().get('setStatus')
  const agent = agents.find((a) => a.id === id)
  if (agent == null) return null
  const f = copy.form
  const close = () => {
    const next = new URLSearchParams(window.location.search)
    next.delete('setStatus')
    const qs = next.toString()
    window.history.replaceState(null, '', `${window.location.pathname}${qs === '' ? '' : `?${qs}`}`)
  }
  return (
    <StatusDialog
      key={agent.id} title={copy.changeStatus} name={agent.fullName} initial={agent.status}
      options={([['ACTIVE', 'success'], ['ON_LEAVE', 'error'], ['ARCHIVED', 'muted']] as const).map(([v, tone]) => ({ value: v, label: f.statuses[v], tone }))}
      labels={{ cancel: f.cancel, save: f.save, error: f.errors.generic }}
      onClose={close} onSave={(status) => setAgentStatus(agent.id, status)}
    />
  )
}
