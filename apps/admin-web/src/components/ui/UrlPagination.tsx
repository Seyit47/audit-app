'use client'

import { pageParams } from '@/lib/search-params'
import { useListParams } from '@/lib/use-list-params'
import { Pagination } from './Pagination'

/** Pagination bound to `?page=&size=` in the URL. */
export function UrlPagination (props: Omit<React.ComponentProps<typeof Pagination>, 'onPage' | 'onSize'>) {
  const { set } = useListParams(pageParams)
  return <Pagination {...props} onPage={(page) => set({ page })} onSize={(size) => set({ size })} />
}
