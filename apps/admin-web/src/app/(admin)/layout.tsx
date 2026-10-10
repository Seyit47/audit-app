import { layoutCopy } from '@/components/layout/copy'
import { FeedPanel } from '@/components/layout/FeedPanel'
import { Sidebar } from '@/components/layout/Sidebar'
import { Topbar } from '@/components/layout/Topbar'
import { TopbarGate } from '@/components/layout/TopbarGate'
import { feedCopy } from '@/features/feed/copy'
import type { FeedPage } from '@/features/feed/types'
import { api } from '@/lib/api'
import { getLocale } from '@/lib/locale'
import { getMe } from '@/lib/me'
import { QueryProvider } from '@/components/QueryProvider'
import { NuqsAdapter } from 'nuqs/adapters/next/app'

export default async function AdminLayout ({ children }: LayoutProps<'/'>) {
  const [{ config }, locale, feed] = await Promise.all([
    getMe(),
    getLocale(),
    api<FeedPage>('/v1/feed', { query: { limit: 1 } }).catch(() => null)
  ])
  const copy = layoutCopy[locale]

  return (
    <NuqsAdapter>
    <QueryProvider>
    <div className='flex min-h-screen'>
      <Sidebar companyName={config.companyName} logoUrl={config.logo?.previewUrl400 ?? config.logo?.url ?? null} copy={copy} />
      <div className='flex min-w-0 flex-1 flex-col'>
        <TopbarGate><Topbar copy={copy} locale={locale} bell={<FeedPanel initialUnread={feed?.unreadCount ?? 0} copy={feedCopy[locale]} locale={locale} />} /></TopbarGate>
        <main className='flex-1'>{children}</main>
      </div>
    </div>
    </QueryProvider>
    </NuqsAdapter>
  )
}
