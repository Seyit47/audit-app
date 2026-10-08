'use client'

import { FormLoadingDialog } from '@/components/ui/FormLoadingDialog'
import { useUrlForm } from '@/lib/use-url-form'
import type { Agent, Region } from '../api'
import type { AgentsCopy } from '../copy'
import { AgentFormDialog } from './AgentFormDialog'

interface AgentFormData { agent: Agent | null, regions: Region[], nextCode: string }

/** Add / edit salesman dialog of 495:3932, opened from `?add=1` or `?edit=<id>` without a server render. */
export function AgentFormHost ({ copy }: { copy: AgentsCopy }) {
  const form = useUrlForm<AgentFormData>('agent')
  if (!form.open) return null
  const f = copy.form
  if (form.data == null) {
    return (
      <FormLoadingDialog
        title={form.id == null ? f.addTitle : f.editTitle} variant='form' width={981} closeLabel={f.close}
        enterStartedAt={form.enterStartedAt}
        onClose={() => window.history.replaceState(null, '', form.closeHref)}
        failed={form.failed} failedText={f.errors.generic}
      />
    )
  }
  const d = form.data
  return <AgentFormDialog key={form.key} agent={d.agent} regions={d.regions} nextCode={d.nextCode} copy={copy} closeHref={form.closeHref} enterStartedAt={form.enterStartedAt} />
}
