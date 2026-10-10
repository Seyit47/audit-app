'use client'

import 'maplibre-gl/dist/maplibre-gl.css'
import { setWorkerUrl } from 'maplibre-gl'
import { forwardRef, type ReactNode } from 'react'
import MapGL, { Layer, Marker, Source, type MapRef, type StyleSpecification, type ViewState } from 'react-map-gl/maplibre'

// Served from /map by scripts/copy-maplibre-worker.mjs (Turbopack can't resolve the bundled worker).
setWorkerUrl('/map/maplibre-gl-worker.mjs')

/** Ashgabat: the default view until data provides bounds. */
export const DEFAULT_VIEW: Partial<ViewState> = { longitude: 58.383, latitude: 37.95, zoom: 12 }

/**
 * MapLibre canvas in the Figma 21:2 palette (`/map/style.json`, research R-12). Markers and
 * overlays are passed as children; controls are app UI positioned by the page.
 */
/** A start view; `bounds` ([[west, south], [east, north]]) fits the camera to them instead. */
export type InitialView = Partial<ViewState> & { bounds?: [[number, number], [number, number]], fitBoundsOptions?: { padding?: number | { top: number, bottom: number, left: number, right: number }, maxZoom?: number } }

export const MapView = forwardRef<MapRef, {
  initialView?: InitialView
  mapStyle?: string | StyleSpecification
  children?: ReactNode
  onClick?: (point: { lng: number, lat: number }) => void
  /** After every camera move or data load, once the map has settled. */
  onIdle?: () => void
  className?: string
}>(function MapView ({ initialView = DEFAULT_VIEW, mapStyle = '/map/style.json', children, onClick, onIdle, className = 'size-full' }, ref) {
  return (
    <div className={className}>
      <MapGL ref={ref} initialViewState={initialView} mapStyle={mapStyle} attributionControl={{ compact: true }}
        // MapLibre ignores the first size change of its box, so a box sized after mount kept the 400×300
        // fallback (a blank strip). Follow every size change of the box ourselves.
        onLoad={(e) => {
          const map = e.target
          const watch = new ResizeObserver(() => map.resize())
          watch.observe(map.getContainer())
          map.once('remove', () => watch.disconnect())
        }}
        onClick={(e) => onClick?.({ lng: e.lngLat.lng, lat: e.lngLat.lat })} onIdle={onIdle} style={{ width: '100%', height: '100%' }}>
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

/** Today's visit state from a shop's dates (as the API's map does), for pages that get the shop itself. */
export function visitStateOf (lastVisitAt: string | null, nextDueAt: string | null, now = new Date()): string {
  const dayStart = new Date(now); dayStart.setHours(0, 0, 0, 0)
  const dayEnd = new Date(dayStart.getTime() + 86_400_000)
  if (lastVisitAt != null && new Date(lastVisitAt) >= dayStart) return 'VISITED'
  if (nextDueAt != null && new Date(nextDueAt) < dayStart) return 'OVERDUE'
  if (nextDueAt != null && new Date(nextDueAt) < dayEnd) return 'SCHEDULED'
  return 'ASSIGNED'
}

/** Pin colors of 21:2 / 574:3155 by today's visit: visited green, due (or overdue) and not visited red, other grey. */
export function shopPinColor (visitState: string): string {
  if (visitState === 'VISITED') return '#10b981'
  if (visitState === 'OVERDUE' || visitState === 'SCHEDULED') return '#f43f5e'
  return '#94a3b8'
}

/**
 * Shop pin of 21:2 (574:2732): the storefront photo in a ring of the visit color, with a pointer. The selected
 * one carries the dark name label (21:120).
 */
export function ShopMarker ({ longitude, latitude, label, imageUrl, color, active = false, onClick, onHover }: {
  longitude: number
  latitude: number
  label: string
  imageUrl?: string | null
  color: string
  active?: boolean
  onClick?: () => void
  /** Pointer over the marker: start loading what a click will show. */
  onHover?: () => void
}) {
  return (
    <Marker longitude={longitude} latitude={latitude} anchor='bottom' onClick={(e) => { e.originalEvent.stopPropagation(); onClick?.() }}>
      <button type='button' aria-label={label} aria-pressed={active} onPointerEnter={onHover} onFocus={onHover} className='flex flex-col items-center'>
        {active && (
          <span className={`mb-1.5 flex items-center gap-1.5 rounded-md bg-[#2e303b] px-2.5 py-1 text-[11px] font-semibold leading-[16.5px] tracking-[-0.28px] text-[#f0effe] ${shadowLg}`}>
            {label}
            <span className='size-1.5 rounded-full bg-[#72f8df]' />
          </span>
        )}
        <span className={`relative block h-11 w-[37px] transition-transform ${active ? 'scale-110' : ''}`} style={{ color }}>
          <span className='absolute left-3 top-[31px] size-[13px] bg-current [clip-path:polygon(0_0,100%_0,50%_100%)]' />
          <span className='absolute left-0 top-0 size-[37px] rounded-full bg-current' />
          <span className='absolute left-[3.5px] top-[3.5px] size-[30px] overflow-hidden rounded-full border border-white bg-current'>
            {/* eslint-disable-next-line @next/next/no-img-element -- presigned storefront preview */}
            {imageUrl != null && <img src={imageUrl} alt='' loading='lazy' className='size-full object-cover' />}
          </span>
        </span>
      </button>
    </Marker>
  )
}

/** Agent position of 21:2 (574:2662): a blue dot with a white rim on a 60% light-blue halo. */
export function AgentDot () {
  return (
    <span className='relative flex size-8 items-center justify-center'>
      <span className='absolute inset-0 rounded-full bg-[#60a5fa] opacity-60' />
      <span className='relative size-5 rounded-full border-2 border-white bg-[#2563eb]' />
    </span>
  )
}

/** A circle of `radiusM` meters as a polygon (the selected shop's audit radius). */
function circle (lng: number, lat: number, radiusM: number, steps = 64): number[][] {
  const dLat = radiusM / 111_320
  const dLng = radiusM / (111_320 * Math.cos((lat * Math.PI) / 180))
  return Array.from({ length: steps + 1 }, (_, i) => {
    const a = (i / steps) * 2 * Math.PI
    return [lng + dLng * Math.cos(a), lat + dLat * Math.sin(a)]
  })
}

/** The selected shop's audit radius: where an agent can start its audit (accent tint, dashed outline). */
export function ShopRadius ({ longitude, latitude, radiusM, color }: { longitude: number, latitude: number, radiusM: number, color: string }) {
  return (
    <Source id='shop-radius' type='geojson' data={{ type: 'Feature', properties: {}, geometry: { type: 'Polygon', coordinates: [circle(longitude, latitude, radiusM)] } }}>
      <Layer id='shop-radius-fill' type='fill' paint={{ 'fill-color': color, 'fill-opacity': 0.12 }} />
      <Layer id='shop-radius-line' type='line' paint={{ 'line-color': color, 'line-width': 2, 'line-dasharray': [3, 2] }} />
    </Source>
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
