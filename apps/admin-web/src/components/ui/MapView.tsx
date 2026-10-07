'use client'

import 'maplibre-gl/dist/maplibre-gl.css'
import { setWorkerUrl } from 'maplibre-gl'
import { forwardRef, type ReactNode } from 'react'
import MapGL, { Layer, Marker, Source, type MapRef, type ViewState } from 'react-map-gl/maplibre'
import { FigmaIcon } from './FigmaIcon'

// Served from /map by scripts/copy-maplibre-worker.mjs (Turbopack can't resolve the bundled worker).
setWorkerUrl('/map/maplibre-gl-worker.mjs')

/** Ashgabat: the default view until data provides bounds. */
export const DEFAULT_VIEW: Partial<ViewState> = { longitude: 58.383, latitude: 37.95, zoom: 12 }

/**
 * MapLibre canvas in the Figma 21:2 palette (`/map/style.json`, research R-12). Markers and
 * overlays are passed as children; controls are app UI positioned by the page.
 */
export const MapView = forwardRef<MapRef, {
  initialView?: Partial<ViewState>
  mapStyle?: string
  children?: ReactNode
  onClick?: (point: { lng: number, lat: number }) => void
  className?: string
}>(function MapView ({ initialView = DEFAULT_VIEW, mapStyle = '/map/style.json', children, onClick, className = 'size-full' }, ref) {
  return (
    <div className={className}>
      <MapGL ref={ref} initialViewState={initialView} mapStyle={mapStyle} attributionControl={{ compact: true }} onClick={(e) => onClick?.({ lng: e.lngLat.lng, lat: e.lngLat.lat })} style={{ width: '100%', height: '100%' }}>
        {children}
      </MapGL>
    </div>
  )
})

const shadowLg = 'shadow-[0px_4px_6px_-4px_rgba(0,0,0,0.1),0px_10px_15px_-3px_rgba(0,0,0,0.1)]'
const shadowMd = 'shadow-[0px_2px_4px_-2px_rgba(0,0,0,0.1),0px_4px_6px_-1px_rgba(0,0,0,0.1)]'

/** Cluster markers of 21:2: large accent with unit label (21:79), medium blue (21:88), small grey (21:94). */
export function ClusterMarker ({ longitude, latitude, count, unitLabel, onClick }: {
  longitude: number
  latitude: number
  count: number
  unitLabel?: string
  onClick?: () => void
}) {
  const size = count >= 100 ? 'lg' : count >= 50 ? 'md' : 'sm'
  return (
    <Marker longitude={longitude} latitude={latitude} onClick={(e) => { e.originalEvent.stopPropagation(); onClick?.() }}>
      <button type='button' aria-label={String(count)} className='relative flex items-center justify-center'>
        {size === 'lg' && (
          <>
            <span className='absolute size-12 rounded-full bg-accent/20' />
            <span className={`relative flex size-11 flex-col items-center justify-center rounded-full bg-accent text-white ${shadowLg}`}>
              <span className='text-xs font-bold leading-4'>{count}</span>
              {unitLabel != null && <span className='-mt-1 text-[9px] leading-4 opacity-80'>{unitLabel}</span>}
            </span>
          </>
        )}
        {size === 'md' && (
          <>
            <span className='absolute size-10 rounded-full bg-[#448ffd]/25' />
            <span className={`relative flex size-9 items-center justify-center rounded-full bg-[#005cba] text-xs font-bold leading-4 text-white ${shadowMd}`}>{count}</span>
          </>
        )}
        {size === 'sm' && (
          <span className='flex size-8 items-center justify-center rounded-full bg-inactive-bg text-xs font-semibold leading-4 text-ink shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>{count}</span>
        )}
      </button>
    </Marker>
  )
}

/** Shop marker of 21:2 (21:108) with the dark label pin when active (21:120). */
export function ShopMarker ({ longitude, latitude, label, active = false, onClick }: {
  longitude: number
  latitude: number
  label: string
  active?: boolean
  onClick?: () => void
}) {
  return (
    <Marker longitude={longitude} latitude={latitude} anchor='bottom' onClick={(e) => { e.originalEvent.stopPropagation(); onClick?.() }}>
      <button type='button' aria-label={label} aria-pressed={active} className='flex flex-col items-center'>
        {active && (
          <span className={`mb-2.5 flex items-center gap-1.5 rounded-md bg-[#2e303b] px-2.5 py-1 text-[11px] font-semibold leading-[16.5px] tracking-[-0.28px] text-[#f0effe] ${shadowLg}`}>
            {label}
            <span className='size-1.5 rounded-full bg-[#72f8df]' />
          </span>
        )}
        <span className={`flex size-8 items-center justify-center rounded-full bg-[#008372] ${shadowMd} ring-2 ring-white`}>
          <FigmaIcon name='marker-shop' width={13.32} height={13.33} />
        </span>
        {active && <span className='-mt-1 size-[8.49px] rotate-45 bg-[#008372]' />}
      </button>
    </Marker>
  )
}

/** Region zone of 21:2 ("region-polygon" 21:77): accent tint with a dashed accent outline. */
export function RegionZone ({ id, polygon }: { id: string, polygon: { type: 'Polygon', coordinates: number[][][] } }) {
  return (
    <Source id={`region-${id}`} type='geojson' data={{ type: 'Feature', properties: {}, geometry: polygon }}>
      <Layer id={`region-${id}-fill`} type='fill' paint={{ 'fill-color': '#493ee5', 'fill-opacity': 0.08 }} />
      <Layer id={`region-${id}-line`} type='line' paint={{ 'line-color': '#493ee5', 'line-width': 2.4, 'line-dasharray': [3, 2] }} />
    </Source>
  )
}
