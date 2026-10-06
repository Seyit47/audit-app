import { Sidebar } from '@/components/layout/Sidebar'
import { Topbar } from '@/components/layout/Topbar'
import { getMe } from '@/lib/me'

export default async function AdminLayout ({ children }: LayoutProps<'/'>) {
  const { config } = await getMe()

  return (
    <div className='flex min-h-screen'>
      <Sidebar companyName={config.companyName} logoUrl={config.logo?.previewUrl400 ?? config.logo?.url ?? null} />
      <div className='flex min-w-0 flex-1 flex-col'>
        <Topbar />
        <main className='flex-1'>{children}</main>
      </div>
    </div>
  )
}
