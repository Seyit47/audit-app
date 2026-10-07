'use client'

import dynamic from 'next/dynamic'

/** Loads the MapLibre route map on the client only (the map needs the browser). */
export const RouteMap = dynamic(() => import('./RouteMapCanvas'), {
  ssr: false,
  loading: () => <section className='h-[333px] rounded-xl bg-pure-white shadow-[0px_1px_2px_rgba(0,0,0,0.05)]' />
})
