'use client'

import { useRef } from 'react'
import { Layer, Marker, Source, type MapRef } from 'react-map-gl/maplibre'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { DEFAULT_VIEW, MapView, type InitialView } from '@/components/ui/MapView'
import type { AgentTrack, StopStatus } from '../api'

export interface RouteMapLabels { route: string, recenter: string, fullscreen: string, zoomIn: string, zoomOut: string }

const shadowMd = 'shadow-[0px_2px_4px_-2px_rgba(0,0,0,0.1),0px_4px_6px_-1px_rgba(0,0,0,0.1)]'
const dot: Record<StopStatus, string> = { DONE: 'bg-success', MISSED: 'bg-error', IN_PROGRESS: 'bg-[#005cba]', PLANNED: 'bg-[#c7c4d8]' }

function boundsOf (coords: Array<[number, number]>): InitialView {
  if (coords.length === 0) return DEFAULT_VIEW
  if (coords.length === 1) return { longitude: coords[0][0], latitude: coords[0][1], zoom: 14 }
  const lngs = coords.map((c) => c[0])
  const lats = coords.map((c) => c[1])
  return { bounds: [[Math.min(...lngs), Math.min(...lats)], [Math.max(...lngs), Math.max(...lats)]], fitBoundsOptions: { padding: { top: 32, bottom: 72, left: 72, right: 72 }, maxZoom: 15 } }
}

/** "Маршрут и трекинг сотрудника" of 122:7981 (122:9535): track, checkpoints and the live position. */
export default function RouteMapCanvas ({ track, checkpointLabel, live, labels }: {
  track: AgentTrack
  /** "Весна (10:15)" */
  checkpointLabel: Record<string, string>
  /** "сейчас здесь · 12 км/ч · батарея 84%" for the live marker; null hides it. */
  live: string | null
  labels: RouteMapLabels
}) {
  const map = useRef<MapRef>(null)
  const card = useRef<HTMLElement>(null)
  const coords: Array<[number, number]> = [
    ...track.points.map((p): [number, number] => [p.lng, p.lat]),
    ...track.checkpoints.map((c): [number, number] => [c.lng, c.lat]),
    ...(track.current != null ? [[track.current.lng, track.current.lat] as [number, number]] : [])
  ]
  const view = boundsOf(coords)
  const recenter = () => {
    if (view.bounds != null) map.current?.fitBounds(view.bounds, view.fitBoundsOptions)
    else map.current?.flyTo({ center: [view.longitude ?? DEFAULT_VIEW.longitude!, view.latitude ?? DEFAULT_VIEW.latitude!], zoom: view.zoom })
  }
  const line = track.points.length > 1
    ? { type: 'Feature' as const, properties: {}, geometry: { type: 'LineString' as const, coordinates: track.points.map((p) => [p.lng, p.lat]) } }
    : null

  return (
    <section ref={card} className='flex h-[333px] flex-col gap-3 rounded-xl bg-pure-white p-5 shadow-[0px_1px_2px_rgba(0,0,0,0.05)] [&:fullscreen]:h-full [&:fullscreen]:rounded-none'>
      <div className='flex items-center justify-between gap-4'>
        <h2 className='flex items-center gap-2 text-sm font-bold leading-5 text-ink'><FigmaIcon name='route-explore' width={16.67} height={16.67} />{labels.route}</h2>
        <div className='flex items-center gap-1'>
          <button type='button' onClick={recenter} aria-label={labels.recenter} title={labels.recenter} className='rounded p-1 hover:bg-secondary-bg'><FigmaIcon name='map-locate' width={16.42} height={16.42} /></button>
          <button
            type='button' aria-label={labels.fullscreen} title={labels.fullscreen} className='rounded p-1 hover:bg-secondary-bg'
            onClick={() => { if (document.fullscreenElement != null) void document.exitFullscreen(); else void card.current?.requestFullscreen() }}
          ><FigmaIcon name='map-fullscreen' width={13.5} height={13.5} />
          </button>
        </div>
      </div>
      <div className='relative min-h-0 flex-1 overflow-hidden rounded-xl bg-dark-accent shadow-[inset_0px_2px_4px_rgba(0,0,0,0.05)]'>
        <MapView ref={map} initialView={view}>
          {line != null && (
            <Source id='agent-track' type='geojson' data={line}>
              <Layer id='agent-track-line' type='line' layout={{ 'line-cap': 'round', 'line-join': 'round' }} paint={{ 'line-color': '#493ee5', 'line-width': 3, 'line-dasharray': [1, 2] }} />
            </Source>
          )}
          {track.checkpoints.map((c) => (
            <Marker key={c.id} longitude={c.lng} latitude={c.lat} anchor='top'>
              <span className='flex -translate-y-3.5 flex-col items-center'>
                <span className={`flex size-7 items-center justify-center rounded-full ${dot[c.status]} ${shadowMd}`}>
                  {c.status === 'DONE' && <FigmaIcon name='marker-check' width={14} height={14} />}
                  {c.status === 'MISSED' && <span className='text-xs font-bold leading-none text-white'>!</span>}
                </span>
                <span className='mt-1 whitespace-nowrap rounded bg-pure-white px-1.5 py-0.5 text-[10px] font-bold leading-[15px] text-ink'>{checkpointLabel[c.id]}</span>
              </span>
            </Marker>
          ))}
          {track.current != null && live != null && (
            <Marker longitude={track.current.lng} latitude={track.current.lat} anchor='top'>
              <span className='flex -translate-y-5 flex-col items-center'>
                <span className='relative flex size-10 items-center justify-center'>
                  <span className='absolute size-12 rounded-full bg-accent/25' />
                  <span className='relative flex size-10 items-center justify-center rounded-full border-2 border-white bg-accent'>
                    <FigmaIcon name='marker-walk' width={10.83} height={17.92} />
                  </span>
                </span>
                <span className={`mt-1.5 flex items-center gap-1.5 whitespace-nowrap rounded-md bg-[#2e303b] px-2.5 py-1 text-[11px] font-semibold leading-[16.5px] text-[#f0effe] ${shadowMd}`}>
                  <span className='size-2 rounded-full bg-[#72f8df]' />{live}
                </span>
              </span>
            </Marker>
          )}
        </MapView>
        <div className={`absolute bottom-8 right-[9px] flex w-8 flex-col overflow-hidden rounded-lg bg-pure-white ${shadowMd}`}>
          <button type='button' onClick={() => map.current?.zoomIn()} aria-label={labels.zoomIn} className='flex h-8 items-center justify-center text-sm font-bold leading-5 text-ink'>+</button>
          <span className='h-px bg-dark-accent' />
          <button type='button' onClick={() => map.current?.zoomOut()} aria-label={labels.zoomOut} className='flex h-8 items-center justify-center text-sm font-bold leading-5 text-ink'>−</button>
        </div>
      </div>
    </section>
  )
}
