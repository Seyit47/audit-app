import { Button } from '@/components/ui/Button'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { PageHeader } from '@/components/ui/PageHeader'
import { getAgent, getAgentsSummary, listAgents, listRegions, type AgentListQuery } from '@/features/agents/api'
import { AgentsSummary } from '@/features/agents/components/AgentsSummary'
import { AgentFormDialog } from '@/features/agents/components/AgentFormDialog'
import { api } from '@/lib/api'
import { AgentsTable } from '@/features/agents/components/AgentsTable'
import { AgentsToolbar } from '@/features/agents/components/AgentsToolbar'
import { agentsCopy } from '@/features/agents/copy'
import { int, oneOf, range, text, uuid } from '@/lib/params'
import { getLocale } from '@/lib/locale'

type Search = Record<string, string | undefined>

export default async function SalesmenPage ({ searchParams }: PageProps<'/salesmen'>) {
  const sp = (await searchParams) as Search
  const locale = await getLocale()
  const copy = agentsCopy[locale]
  const period = range(sp.from, sp.to)
  const query: AgentListQuery = {
    page: int(sp.page, 1),
    size: int(sp.size, 10, 1, 100),
    q: text(sp.q),
    status: oneOf(sp.status, ['ACTIVE', 'ON_LEAVE', 'INACTIVE'] as const),
    regionId: uuid(sp.regionId),
    ...period,
    sort: oneOf(sp.sort, ['fullName', 'code', 'locations', 'visits', 'photos', 'lastActivityAt'] as const) ?? 'code',
    dir: oneOf(sp.dir, ['asc', 'desc'] as const) ?? 'asc'
  }
  const editId = uuid(sp.edit)
  const editing = editId != null ? await getAgent(editId).catch(() => null) : null
  const [page, regions, summary, next] = await Promise.all([
    listAgents(query),
    listRegions(),
    getAgentsSummary(period.from, period.to),
    sp.add != null ? api<{ code: string }>('/v1/agents/next-code') : Promise.resolve({ code: '' })
  ])
  const href = (key: string, dir: 'asc' | 'desc') => {
    const next = new URLSearchParams(Object.entries(sp).filter((e): e is [string, string] => e[1] != null))
    next.set('sort', key); next.set('dir', dir); next.delete('page')
    return `/salesmen?${next.toString()}`
  }

  return (
    <div className='flex flex-col gap-2.5 p-4'>
      <PageHeader
        title={copy.title}
        badge={copy.badge}
        description={copy.description}
        actions={
          <>
            <Button variant='secondary' href={`/export?${new URLSearchParams({ type: 'AGENTS_XLSX', back: '/salesmen', ...Object.fromEntries(Object.entries(sp).filter((e): e is [string, string] => e[1] != null && ['status', 'regionId', 'from', 'to', 'q'].includes(e[0]))) }).toString()}`} icon={<FigmaIcon name='export' width={13} height={13} />}>{copy.exportRoster}</Button>
            <Button prefetch href='/salesmen?add=1' icon={<FigmaIcon name='plus' width={10.5} height={10.5} />}>{copy.addSalesman}</Button>
          </>
        }
      />
      <AgentsSummary summary={summary} copy={copy} locale={locale} />
      <AgentsToolbar copy={copy} regions={regions} />
      <AgentsTable page={page} copy={copy} locale={locale} sort={{ key: query.sort!, dir: query.dir!, href }} />
      {(sp.add != null || editing != null) && (
        <AgentFormDialog
          key={editing?.id ?? 'new'}
          agent={editing}
          regions={regions}
          nextCode={next.code}
          copy={copy}
          closeHref={`/salesmen?${new URLSearchParams(Object.entries(sp).filter((e): e is [string, string] => e[1] != null && e[0] !== 'add' && e[0] !== 'edit')).toString()}`}
        />
      )}
    </div>
  )
}
