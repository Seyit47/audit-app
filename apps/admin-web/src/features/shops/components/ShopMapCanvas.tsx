'use client'

import { useRef } from 'react'
import type { MapRef } from 'react-map-gl/maplibre'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { MapView, ShopMarker } from '@/components/ui/MapView'

export interface ShopMapLabels { title: string, region: string, gps: string, recenter: string, fullscreen: string, zoomIn: string, zoomOut: string }

const ZOOM = 13
const shadowMd = 'shadow-[0px_2px_4px_-2px_rgba(0,0,0,0.1),0px_4px_6px_-1px_rgba(0,0,0,0.1)]'

/**
 * "Quick Location Snapshot Preview" of 47:7387, with the map controls of the salesman route map (122:9535):
 * back to the shop and full screen in the header, zoom in the map's corner.
 */
export default function ShopMapCanvas ({ lat, lng, name, labels }: { lat: number, lng: number, name: string, labels: ShopMapLabels }) {
  const map = useRef<MapRef>(null)
  const card = useRef<HTMLElement>(null)
  return (
    <section ref={card} className='flex h-[352px] flex-col gap-[18px] rounded-xl bg-pure-white p-6 shadow-[0px_1px_2px_rgba(0,0,0,0.05)] [&:fullscreen]:h-full [&:fullscreen]:rounded-none'>
      <div className='flex items-center justify-between gap-4'>
        <h2 className='flex items-center gap-2 text-base font-bold leading-6 text-ink'><FigmaIcon name='geo-target' width={16.62} height={16.58} />{labels.title}</h2>
        <div className='flex items-center gap-1'>
          <button data-ripple type='button' onClick={() => map.current?.flyTo({ center: [lng, lat], zoom: ZOOM })} aria-label={labels.recenter} title={labels.recenter} className='rounded p-1 hover:bg-secondary-bg'><FigmaIcon name='map-locate' width={16.42} height={16.42} /></button>
          <button data-ripple
            type='button' aria-label={labels.fullscreen} title={labels.fullscreen} className='rounded p-1 hover:bg-secondary-bg'
            onClick={() => { if (document.fullscreenElement != null) void document.exitFullscreen(); else void card.current?.requestFullscreen() }}
          ><FigmaIcon name='map-fullscreen' width={13.5} height={13.5} />
          </button>
        </div>
      </div>
      {/* The map attribution sits above the region bar instead of covering it. */}
      <div className='relative min-h-0 flex-1 overflow-hidden rounded-lg bg-dark-accent [&_.maplibregl-ctrl-bottom-right]:bottom-10!'>
        <MapView ref={map} initialView={{ latitude: lat, longitude: lng, zoom: ZOOM }}>
          <ShopMarker latitude={lat} longitude={lng} label={name} />
        </MapView>
        <div className={`absolute bottom-[76px] right-2 flex w-8 flex-col overflow-hidden rounded-lg bg-pure-white ${shadowMd}`}>
          <button data-ripple type='button' onClick={() => map.current?.zoomIn()} aria-label={labels.zoomIn} className='flex h-8 items-center justify-center text-sm font-bold leading-5 text-ink'>+</button>
          <span className='h-px bg-dark-accent' />
          <button data-ripple type='button' onClick={() => map.current?.zoomOut()} aria-label={labels.zoomOut} className='flex h-8 items-center justify-center text-sm font-bold leading-5 text-ink'>−</button>
        </div>
        <div className='absolute inset-x-2 bottom-2 flex items-center justify-between rounded bg-white/90 p-2 text-xs leading-4 backdrop-blur-[12px]'>
          <span className='font-medium text-ink'>{labels.region}</span>
          <span className='font-semibold text-success'>{labels.gps}</span>
        </div>
      </div>
    </section>
  )
}
