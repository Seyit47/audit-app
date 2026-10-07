'use client'

import dynamic from 'next/dynamic'

/** The MapLibre admin map runs in the browser only. */
export const AdminMap = dynamic(() => import('./AdminMapCanvas'), { ssr: false, loading: () => <div className='size-full bg-secondary-bg' /> })
