import { Button } from '@/components/ui/Button'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { PageHeader } from '@/components/ui/PageHeader'
import { getAgent, listAgents, listRegions, type AgentListQuery } from '@/features/agents/api'
import { AgentFormDialog } from '@/features/agents/components/AgentFormDialog'
import { api } from '@/lib/api'
import { AgentsTable } from '@/features/agents/components/AgentsTable'
import { AgentsToolbar } from '@/features/agents/components/AgentsToolbar'
import { agentsCopy } from '@/features/agents/copy'
import { getLocale } from '@/lib/locale'

type Search = Record<string, string | undefined>

export default async function SalesmenPage ({ searchParams }: PageProps<'/salesmen'>) {
  const sp = (await searchParams) as Search
  const locale = await getLocale()
  const copy = agentsCopy[locale]
  const query: AgentListQuery = {
    page: Number(sp.page ?? 1),
    size: Number(sp.size ?? 10),
    q: sp.q,
    status: sp.status as AgentListQuery['status'],
    regionId: sp.regionId,
    from: sp.from,
    to: sp.to,
    sort: sp.sort ?? 'code',
    dir: (sp.dir as 'asc' | 'desc' | undefined) ?? 'asc'
  }
  const editing = sp.edit != null ? await getAgent(sp.edit) : null
  const [page, regions, next] = await Promise.all([
    listAgents(query),
    listRegions(),
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
            <Button variant='secondary' href='/salesmen/export' icon={<FigmaIcon name='export' width={13} height={13} />}>{copy.exportRoster}</Button>
            <Button href='/salesmen?add=1' icon={<FigmaIcon name='plus' width={10.5} height={10.5} />}>{copy.addSalesman}</Button>
          </>
        }
      />
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
