'use client'

import type { GeoJSONSource } from 'maplibre-gl'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useCallback, useMemo, useRef, useState } from 'react'
import { Layer, Marker, Source, type MapRef, type StyleSpecification } from 'react-map-gl/maplibre'
import { FigmaIcon } from '@/components/ui/FigmaIcon'
import { SearchAutocomplete } from '@/components/ui/SearchAutocomplete'
import { Bone } from '@/components/ui/Skeleton'
import { ClusterMarker, DEFAULT_VIEW, MapView, RegionZone, ShopMarker, type InitialView } from '@/components/ui/MapView'
import { plural, sub, type Locale } from '@/lib/i18n'
import { navigationStarted } from '@/lib/feedback'
import { useUrlState } from '@/lib/url-state'
import type { MapCopy } from '../copy'
import { hullRing } from '../hull'
import type { AgentPosition, MapFilterState, MapShop, ShopCardData } from '../types'
import { FilterBanner } from './FilterBanner'
import { MapFilters } from './MapFilters'
import { ShopCard } from './ShopCard'

const shadowMd = 'shadow-[0px_2px_4px_-2px_rgba(0,0,0,0.1),0px_4px_6px_-1px_rgba(0,0,0,0.1)]'
const square = `relative flex size-10 items-center justify-center rounded-xl bg-pure-white ${shadowMd}`

type Clustered =
  | { kind: 'cluster', id: number, lng: number, lat: number, count: number }
  | { kind: 'shop', shop: MapShop }

function satelliteStyle (tiles: string): StyleSpecification {
  return {
    version: 8,
    sources: { satellite: { type: 'raster', tiles: [tiles], tileSize: 256, attribution: 'Imagery © Esri, Maxar, Earthstar Geographics' } },
    layers: [{ id: 'satellite', type: 'raster', source: 'satellite' }]
  }
}

function viewOf (shops: MapShop[]): InitialView {
  if (shops.length === 0) return DEFAULT_VIEW
  if (shops.length === 1) return { longitude: shops[0].lng, latitude: shops[0].lat, zoom: 15 }
  const lngs = shops.map((s) => s.lng)
  const lats = shops.map((s) => s.lat)
  return { bounds: [[Math.min(...lngs), Math.min(...lats)], [Math.max(...lngs), Math.max(...lats)]], fitBoundsOptions: { padding: { top: 96, bottom: 48, left: 64, right: 64 }, maxZoom: 15 } }
}

// A shop card fetched in the last 30 s is reused; only called from event handlers.
const now = () => Date.now()
const stale = (at: number) => now() - at > 30_000

/** Admin Map of 21:2 / 3:2: clustered shops, agent positions, region zones, search, filters and controls (B2). */
export default function AdminMapCanvas ({ shops, positions, regions, agents, filters, initialCard, history, copy, locale, satelliteTiles }: {
  shops: MapShop[]
  positions: AgentPosition[]
  regions: Array<{ id: string, name: string }>
  agents: Array<{ id: string, fullName: string }>
  filters: MapFilterState & { ids: string[] }
  /** The card for a link that opened with `?shop=`. */
  initialCard: ShopCardData | null
  history: React.ComponentProps<typeof ShopCard>['history']
  copy: MapCopy
  locale: Locale
  satelliteTiles: string
}) {
  const router = useRouter()
  const { set } = useUrlState()
  const map = useRef<MapRef>(null)
  const frame = useRef<HTMLDivElement>(null)
  const [q, setQ] = useState('')
  const [panel, setPanel] = useState(false)
  const [satellite, setSatellite] = useState(false)
  const [clusters, setClusters] = useState<Clustered[]>([])
  // Selecting a shop is client-side: its card is fetched from /data/shops/:id/card (cached, and prefetched
  // on marker hover) and only `?shop=` changes in the URL, so the map page is not re-rendered on the server.
  const [selectedId, setSelectedId] = useState<string | null>(initialCard?.shop.id ?? null)
  const [cards, setCards] = useState<Record<string, ShopCardData | null>>(() => initialCard == null ? {} : { [initialCard.shop.id]: initialCard })
  const fetched = useRef(new Map<string, number>())
  // A refresh from the server (auto-refresh, the refresh button) brings a fresh card for the selected shop.
  const [seenInitial, setSeenInitial] = useState(initialCard)
  if (initialCard !== seenInitial) {
    setSeenInitial(initialCard)
    if (initialCard != null) setCards((all) => ({ ...all, [initialCard.shop.id]: initialCard }))
  }
  const loadCard = (id: string) => {
    const at = fetched.current.get(id)
    if (at != null && !stale(at)) return // fresh enough (the page auto-refreshes every 30 s)
    fetched.current.set(id, now())
    fetch(`/data/shops/${id}/card`)
      .then(async (r) => (r.ok ? await r.json() as ShopCardData : null))
      .then((card) => setCards((all) => ({ ...all, [id]: card })))
      .catch(() => { fetched.current.delete(id) })
  }
  const writeShopParam = (id: string | null) => {
    const next = new URLSearchParams(window.location.search)
    if (id == null) next.delete('shop'); else next.set('shop', id)
    const qs = next.toString()
    window.history.replaceState(null, '', qs === '' ? window.location.pathname : `?${qs}`)
  }
  const select = (id: string) => { setSelectedId(id); loadCard(id); writeShopParam(id) }
  const closeCard = () => { setSelectedId(null); writeShopParam(null) }
  const selectedCard = selectedId == null ? undefined : cards[selectedId]
  const selectedShop = selectedId == null ? undefined : shops.find((s) => s.id === selectedId)

  const visible = useMemo(() => {
    const needle = q.trim().toLowerCase()
    return needle === '' ? shops : shops.filter((s) => `${s.name} ${s.code} ${s.address}`.toLowerCase().includes(needle))
  }, [q, shops])
  const byId = useMemo(() => new Map(visible.map((s) => [s.id, s])), [visible])
  const data = useMemo(() => ({
    type: 'FeatureCollection' as const,
    features: visible.map((s) => ({ type: 'Feature' as const, properties: { id: s.id }, geometry: { type: 'Point' as const, coordinates: [s.lng, s.lat] } }))
  }), [visible])
  const zones = useMemo(() => filters.regionIds.flatMap((id) => {
    const ring = hullRing(shops.filter((s) => s.regionId === id).map((s) => [s.lng, s.lat]))
    return ring == null ? [] : [{ id, polygon: { type: 'Polygon' as const, coordinates: [ring] } }]
  }), [filters.regionIds, shops])
  const [initialView] = useState(() => viewOf(shops))

  // Clusters come from MapLibre's GeoJSON clustering (research R-12) and render as the Figma markers.
  const recluster = useCallback(() => {
    const m = map.current?.getMap()
    if (m == null || m.getSource('shops') == null) return
    const seen = new Set<string>()
    const next: Clustered[] = []
    for (const f of m.querySourceFeatures('shops')) {
      const props = f.properties as { cluster?: boolean, cluster_id?: number, point_count?: number, id?: string }
      const key = props.cluster === true ? `c${props.cluster_id}` : `s${props.id}`
      if (seen.has(key)) continue
      seen.add(key)
      const [lng, lat] = (f.geometry as { coordinates: [number, number] }).coordinates
      if (props.cluster === true) next.push({ kind: 'cluster', id: props.cluster_id!, lng, lat, count: props.point_count! })
      else if (props.id != null && byId.has(props.id)) next.push({ kind: 'shop', shop: byId.get(props.id)! })
    }
    setClusters(next)
  }, [byId])

  const expand = async (clusterId: number, lng: number, lat: number) => {
    const source = map.current?.getMap().getSource('shops') as GeoJSONSource | undefined
    const zoom = await source?.getClusterExpansionZoom(clusterId)
    map.current?.easeTo({ center: [lng, lat], zoom: zoom ?? (map.current.getZoom() + 2) })
  }
  const recenter = () => {
    const v = viewOf(visible)
    if (v.bounds != null) map.current?.fitBounds(v.bounds, v.fitBoundsOptions)
    else map.current?.flyTo({ center: [v.longitude!, v.latitude!], zoom: v.zoom })
  }
  const search = () => { if (visible.length > 0) recenter() }

  const activeFilters = filters.agentIds.length + filters.regionIds.length
  const filtered = activeFilters > 0 || filters.ids.length > 0 || q.trim() !== ''
  const banner = [
    `${visible.length} ${plural(locale, visible.length, copy.locations)}`,
    filters.agentIds.length > 0 ? `${filters.agentIds.length} ${plural(locale, filters.agentIds.length, copy.salesmen)}` : null,
    filters.regionIds.length > 0 ? `${filters.regionIds.length} ${plural(locale, filters.regionIds.length, copy.regions)}` : null
  ].filter(Boolean).join(' • ')

  return (
    <div ref={frame} className='relative size-full overflow-hidden bg-secondary-bg'>
      <MapView ref={map} initialView={initialView} mapStyle={satellite ? satelliteStyle(satelliteTiles) : '/map/style.json'} onIdle={recluster}>
        {zones.map((z) => <RegionZone key={z.id} id={z.id} polygon={z.polygon} />)}
        <Source id='shops' type='geojson' data={data} cluster clusterRadius={56} clusterMaxZoom={14}>
          {/* Invisible: keeps the source's tiles loaded so the clusters can be queried. */}
          <Layer id='shops-hit' type='circle' paint={{ 'circle-radius': 1, 'circle-opacity': 0 }} />
        </Source>
        {clusters.map((c) => c.kind === 'cluster'
          ? <ClusterMarker key={`c${c.id}`} longitude={c.lng} latitude={c.lat} count={c.count} unitLabel={c.count >= 100 ? copy.unit : undefined} onClick={() => { void expand(c.id, c.lng, c.lat) }} />
          : <ShopMarker key={c.shop.id} longitude={c.shop.lng} latitude={c.shop.lat} label={c.shop.name} active={c.shop.id === selectedId} onHover={() => loadCard(c.shop.id)} onClick={() => select(c.shop.id)} />)}
        {positions.map((p) => (
          <Marker key={p.agentId} longitude={p.lng} latitude={p.lat} anchor='center'>
            <Link href={`/salesmen/${p.agentId}`} className='group relative flex flex-col items-center' title={`${p.fullName} · ${sub(copy.hereNow, new Date(p.recordedAt).toLocaleTimeString(locale === 'ru' ? 'ru-RU' : 'en-US', { hour: '2-digit', minute: '2-digit' }))}`}>
              <span className='absolute size-10 rounded-full bg-accent/25' />
              <span className='relative flex size-8 items-center justify-center rounded-full border-2 border-white bg-accent'>
                <FigmaIcon name='marker-walk' width={8.66} height={14.34} />
              </span>
              <span className={`absolute top-full mt-1 hidden whitespace-nowrap rounded-md bg-[#2e303b] px-2.5 py-1 text-[11px] font-semibold leading-[16.5px] text-[#f0effe] group-hover:block ${shadowMd}`}>{p.fullName}</span>
            </Link>
          </Marker>
        ))}
      </MapView>

      <div className='pointer-events-none absolute inset-x-4 top-6 z-30 flex items-center justify-between gap-4'>
        <div className='pointer-events-auto flex items-center gap-4'>
          <SearchAutocomplete
            className='w-[440px]' placeholder={copy.search} delay={120}
            icon={<FigmaIcon name='map-search' width={15} height={15} className='pointer-events-none absolute left-3.5 top-1/2 z-[1] -translate-y-1/2' />}
            inputClassName={`h-10 w-full rounded-xl bg-pure-white pl-[39.5px] pr-3.5 text-sm leading-[17px] text-ink placeholder:text-muted hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-accent/30 ${shadowMd}`}
            onQueryChange={setQ}
            load={async (term) => {
              const needle = term.toLowerCase()
              const hits = shops.filter((s) => `${s.name} ${s.code} ${s.address}`.toLowerCase().includes(needle)).slice(0, 8)
              return [{ label: copy.search, hits: hits.map((s) => ({ id: s.id, title: s.name, detail: s.address, image: s.thumbUrl, href: `/map?shop=${s.id}` })) }]
            }}
            onPick={(hit) => {
              const s = shops.find((x) => x.id === hit.id)
              if (s != null) map.current?.flyTo({ center: [s.lng, s.lat], zoom: Math.max(map.current.getZoom(), 15) })
              select(hit.id)
            }}
            onSubmit={search}
          />
          {filtered && <FilterBanner text={sub(copy.filtered, banner)} />}
        </div>
        <div className='pointer-events-auto flex items-center gap-3'>
          <button data-ripple type='button' onClick={() => setPanel((o) => !o)} aria-expanded={panel} className='flex h-10 items-center gap-2 rounded-lg bg-pure-white px-3 text-xs font-semibold leading-4 text-ink shadow-[0px_1px_2px_rgba(0,0,0,0.05)]'>
            <FigmaIcon name='map-filters-btn' width={13.5} height={13.5} />{copy.filters}
            {activeFilters > 0 && <span className='flex size-4 items-center justify-center rounded-full bg-accent text-[10px] font-bold leading-4 text-white'>{activeFilters}</span>}
          </button>
          {/* Layers, Fullscreen and Refresh are approved additions (spec gap B2) in the recenter button's style. */}
          <button data-ripple type='button' onClick={() => setSatellite((v) => !v)} aria-pressed={satellite} aria-label={copy.layers} title={copy.layers} className={square}><FigmaIcon name='map-layers' width={18} height={18} /></button>
          <button
            data-ripple type='button' aria-label={copy.fullscreen} title={copy.fullscreen} className={square}
            onClick={() => { if (document.fullscreenElement != null) void document.exitFullscreen(); else void frame.current?.requestFullscreen() }}
          ><FigmaIcon name='map-expand' width={18} height={18} />
          </button>
          <button data-ripple type='button' onClick={() => { navigationStarted(); router.refresh() }} aria-label={copy.refresh} title={copy.refresh} className={square}><FigmaIcon name='map-refresh' width={18} height={18} /></button>
          <button data-ripple type='button' onClick={recenter} aria-label={copy.recenter} title={copy.recenter} className={square}><FigmaIcon name='map-gps' width={18.25} height={18.25} /></button>
          <div className={`flex h-10 items-center overflow-hidden rounded-xl bg-pure-white ${shadowMd}`}>
            <button data-ripple type='button' onClick={() => map.current?.zoomIn()} aria-label={copy.zoomIn} className='flex size-10 items-center justify-center'><FigmaIcon name='map-plus' width={10.5} height={10.5} /></button>
            <span className='h-5 w-px bg-line' />
            <button data-ripple type='button' onClick={() => map.current?.zoomOut()} aria-label={copy.zoomOut} className='flex size-10 items-center justify-center'><FigmaIcon name='map-minus' width={10.5} height={1.5} /></button>
          </div>
        </div>
      </div>

      {/* One frame slides in once; the placeholder, the card and other shops' cards swap inside it. */}
      {selectedId != null && selectedCard !== null && (
        <aside className='anim-panel-left absolute bottom-2 left-4 top-[68px] z-20 flex w-96 flex-col overflow-hidden rounded-2xl bg-pure-white shadow-[0px_8px_10px_-6px_rgba(0,0,0,0.1),0px_20px_25px_-5px_rgba(0,0,0,0.1)]'>
          {selectedCard != null
            ? <ShopCard key={selectedCard.shop.id} {...selectedCard} onClose={closeCard} copy={copy} history={history} locale={locale} />
            : (
              <div className='flex flex-col gap-4 p-4'>
                <Bone className='h-5 w-40' />
                <p className='text-lg font-bold leading-[22.5px] text-ink'>{selectedShop?.name}</p>
                <p className='-mt-3 text-xs font-medium leading-4 text-muted'>{selectedShop?.address}</p>
                <Bone className='h-72 rounded-xl' />
                <Bone className='h-24 rounded-xl' />
              </div>
              )}
        </aside>
      )}
      {panel && (
        <MapFilters
          agents={agents} regions={regions} value={filters} copy={copy} onClose={() => setPanel(false)}
          onApply={(next) => { setPanel(false); set({ agents: next.agentIds.join(','), regions: next.regionIds.join(','), ids: null, shop: null }) }}
        />
      )}
    </div>
  )
}
