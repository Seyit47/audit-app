import { layoutCopy } from '@/components/layout/copy'
import { Sidebar } from '@/components/layout/Sidebar'
import { Topbar } from '@/components/layout/Topbar'
import { TopbarGate } from '@/components/layout/TopbarGate'
import { getLocale } from '@/lib/locale'
import { getMe } from '@/lib/me'

export default async function AdminLayout ({ children }: LayoutProps<'/'>) {
  const [{ config }, locale] = await Promise.all([getMe(), getLocale()])
  const copy = layoutCopy[locale]

  return (
    <div className='flex min-h-screen'>
      <Sidebar companyName={config.companyName} logoUrl={config.logo?.previewUrl400 ?? config.logo?.url ?? null} copy={copy} />
      <div className='flex min-w-0 flex-1 flex-col'>
        <TopbarGate><Topbar copy={copy} locale={locale} /></TopbarGate>
        <main className='flex-1'>{children}</main>
      </div>
    </div>
  )
}
