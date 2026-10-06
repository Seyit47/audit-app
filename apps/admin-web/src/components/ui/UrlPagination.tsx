'use client'

import { useUrlState } from '@/lib/url-state'
import { Pagination } from './Pagination'

/** Pagination bound to `?page=&size=` in the URL. */
export function UrlPagination (props: Omit<React.ComponentProps<typeof Pagination>, 'onPage' | 'onSize'>) {
  const { set } = useUrlState()
  return <Pagination {...props} onPage={(page) => set({ page })} onSize={(size) => set({ size })} />
}
