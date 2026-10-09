import { DialogLink } from '@/components/ui/DialogLink'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { formatPhone, lastActivity } from '@/lib/format'
import { sub, type Locale } from '@/lib/i18n'
import type { AgentDetails } from '../api'
import type { AgentsCopy } from '../copy'
import { ExportMenu } from './ExportMenu'

/** Header of 122:7981 (122:9104): title with the live and online badges, profile line, report export and Edit. */
export function AgentHeader ({ agent, copy, locale, exportHref }: {
  agent: AgentDetails
  copy: AgentsCopy
  locale: Locale
  exportHref: (type: 'AGENT_REPORT_PDF' | 'AGENT_REPORT_XLSX') => string
}) {
  const d = copy.details
  const status = agent.online && agent.position != null
    ? sub(d.online, Math.round(agent.position.accuracyM))
    : agent.position != null ? sub(d.offline, lastActivity(agent.position.recordedAt, locale)) : d.noSignal

  return (
    <div className='flex w-full items-center justify-between gap-4'>
      <div className='flex min-w-0 flex-col'>
        <div className='flex items-center gap-3'>
          <h1 className='text-2xl font-bold leading-8 tracking-[-0.6px] text-ink'>{d.title}</h1>
          <span className='flex items-center gap-1 rounded-full bg-[#e2dfff] px-2.5 py-0.5 text-xs font-semibold leading-4 text-black'>
            <span className='size-1.5 rounded-full bg-accent' />{d.live}
          </span>
          <span className={`flex items-center gap-1.5 rounded-full bg-dark-accent px-2 py-0.5 text-xs font-medium leading-4 ${agent.online ? 'text-success' : 'text-subtle'}`}>
            <span className={`size-2 rounded-full ${agent.online ? 'bg-success' : 'bg-[#c7c4d8]'}`} />{status}
          </span>
        </div>
        <div className='flex flex-wrap items-center gap-4 pt-1.5 text-xs leading-4'>
          <span className='flex items-center gap-1 font-medium text-ink'><FigmaIcon name='agent-person' width={10} height={10} />{agent.fullName}</span>
          <span className='rounded bg-dark-accent px-2 py-0.5 font-display text-muted'>{agent.code}</span>
          <a href={`tel:${agent.phone}`} className='flex items-center gap-1 text-muted'><FigmaIcon name='agent-phone' width={11.25} height={11.25} />{formatPhone(agent.phone)}</a>
          <span className='flex items-center gap-1 text-muted'><FigmaIcon name='agent-sector' width={8.75} height={12.5} />{sub(d.sector, agent.region.name)}</span>
        </div>
      </div>
      <div className='flex shrink-0 items-center gap-3'>
        <ExportMenu label={d.export} items={[{ label: d.exportPdf, href: exportHref('AGENT_REPORT_PDF') }, { label: d.exportXls, href: exportHref('AGENT_REPORT_XLSX') }]} />
        <DialogLink href={`/salesmen/${agent.id}?edit=1`} form={{ kind: 'agent', id: agent.id }} className='flex h-9 items-center gap-2 rounded-lg bg-dark-accent px-4 text-xs font-semibold leading-4 text-ink'>
          <FigmaIcon name='detail-edit' width={13.5} height={13.5} />{copy.edit}
        </DialogLink>
      </div>
    </div>
  )
}
