// MapLibre resolves its module worker relative to the bundle, which breaks under Turbopack.
// Serve the installed version's worker (and the shared chunk it imports) from /map instead.
import { copyFileSync, mkdirSync } from 'node:fs'
import { createRequire } from 'node:module'
import { dirname, join } from 'node:path'

const dist = join(dirname(createRequire(import.meta.url).resolve('maplibre-gl/package.json')), 'dist')
const out = join(import.meta.dirname, '..', 'public', 'map')
mkdirSync(out, { recursive: true })
for (const file of ['maplibre-gl-worker.mjs', 'maplibre-gl-shared.mjs']) copyFileSync(join(dist, file), join(out, file))
