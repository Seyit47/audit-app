'use client'

import { useEffect } from 'react'
import { ErrorState } from '@/components/ui/ErrorState'

/** A page that fails to load shows this inside the admin shell instead of a blank error screen. */
export default function AdminError ({ error, retry }: { error: Error & { digest?: string }, retry: () => void }) {
  useEffect(() => { console.error(error) }, [error])
  return <ErrorState retry={retry} digest={error.digest} />
}
