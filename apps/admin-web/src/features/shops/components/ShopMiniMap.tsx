'use client'

import dynamic from 'next/dynamic'

const MapView = dynamic(() => import('@/components/ui/MapView').then((m) => m.MapView), { ssr: false })
const ShopMarker = dynamic(() => import('@/components/ui/MapView').then((m) => m.ShopMarker), { ssr: false })

/** Map in "Quick Location Snapshot Preview" of 47:7387. */
export function ShopMiniMap ({ lat, lng, name }: { lat: number, lng: number, name: string }) {
  return (
    <MapView initialView={{ latitude: lat, longitude: lng, zoom: 13 }} className='size-full'>
      <ShopMarker latitude={lat} longitude={lng} label={name} />
    </MapView>
  )
}
