'use server'

import { revalidatePath } from 'next/cache'
import { api } from '@/lib/api'
import { run } from '@/lib/action-result'

export interface AgentInput {
  fullName: string
  code: string
  phone: string
  whatsappPhone: string | null
  routeNotes: string | null
  dailyVisitPlan: number
  dailyAuditPlan: number
  regionId: string
  /** ACTIVE / ON_LEAVE, or ARCHIVED = deactivated ("Архив"). */
  status: 'ACTIVE' | 'ON_LEAVE' | 'ARCHIVED'
}

const fields = (i: AgentInput) => ({
  fullName: i.fullName,
  code: i.code,
  phone: i.phone,
  whatsappPhone: i.whatsappPhone,
  routeNotes: i.routeNotes,
  dailyVisitPlan: i.dailyVisitPlan,
  dailyAuditPlan: i.dailyAuditPlan,
  regionId: i.regionId,
  workStatus: i.status === 'ON_LEAVE' ? 'ON_LEAVE' : 'ACTIVE'
})

/** Adds a salesman with the password the admin typed. */
export async function createAgent (input: AgentInput, password: string) {
  return run(async () => {
    const created = await api<{ id: string, version: number, code: string }>('/v1/agents', { method: 'POST', body: { ...fields(input), password } })
    if (input.status === 'ARCHIVED') await api(`/v1/agents/${created.id}`, { method: 'PATCH', body: { version: created.version, active: false } })
    revalidatePath('/salesmen')
    return { id: created.id, code: created.code }
  })
}

export async function updateAgent (id: string, version: number, input: AgentInput) {
  return run(async () => {
    await api(`/v1/agents/${id}`, { method: 'PATCH', body: { version, ...fields(input), active: input.status !== 'ARCHIVED' } })
    revalidatePath('/salesmen')
    revalidatePath(`/salesmen/${id}`)
  })
}

/** "Изменить пароль": signs the salesman out everywhere. */
export async function setAgentPassword (id: string, password: string) {
  return run(() => api(`/v1/agents/${id}/password`, { method: 'PUT', body: { password } }))
}

export async function rebindAgentDevice (id: string) {
  return run(async () => {
    await api(`/v1/agents/${id}/device`, { method: 'PUT', body: {} })
    revalidatePath('/salesmen')
  })
}
