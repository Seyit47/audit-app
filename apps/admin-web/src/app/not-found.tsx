import { ErrorState } from '@/components/ui/ErrorState'

export default function NotFound () {
  return <main className='min-h-screen bg-secondary-bg'><ErrorState kind='notFound' /></main>
}
