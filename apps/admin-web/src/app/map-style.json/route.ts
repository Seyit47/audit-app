import style from '@/features/map/style.json'

const OPENFREEMAP_TILES = 'https://tiles.openfreemap.org/planet'
const OPENFREEMAP_GLYPHS = 'https://tiles.openfreemap.org/fonts/{fontstack}/{range}.pbf'

/**
 * The street map style (Figma 21:2 palette), pointed at the tile and font servers from the environment:
 * `MAP_TILES_URL` (a TileJSON URL) and `MAP_GLYPHS_URL`, the self-hosted Martin of infra/maptiles. Without them
 * it uses openfreemap.
 */
export function GET () {
  const body = {
    ...style,
    glyphs: process.env.MAP_GLYPHS_URL ?? OPENFREEMAP_GLYPHS,
    sources: { ...style.sources, openmaptiles: { ...style.sources.openmaptiles, url: process.env.MAP_TILES_URL ?? OPENFREEMAP_TILES } }
  }
  // no-cache: browsers check every time (a tiny request), so a changed map address or style applies at once.
  return Response.json(body, { headers: { 'Cache-Control': 'no-cache' } })
}
