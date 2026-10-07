'use client'

import { useEffect } from 'react'
import { ErrorState } from '@/components/ui/ErrorState'

/** Catches failures of the admin shell itself (e.g. the API is down while loading the layout). */
export default function RootError ({ error, retry }: { error: Error & { digest?: string }, retry: () => void }) {
  useEffect(() => { console.error(error) }, [error])
  return <main className='min-h-screen bg-secondary-bg'><ErrorState retry={retry} digest={error.digest} /></main>
}
