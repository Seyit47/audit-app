import { copyFileSync, mkdirSync } from "node:fs";
import { createRequire } from "node:module";
import { dirname, join } from "node:path";
import type { NextConfig } from "next";

// MapLibre resolves its module worker relative to the bundle, which breaks under Turbopack, so the installed
// version's worker (and the shared chunk it imports) is served from /map. Copied here because every
// `next dev`, `next build` and `next start` loads this file, whatever command or host starts it (a
// `prebuild` script is skipped when a host runs `next build` directly, leaving maps without a worker).
const dist = join(dirname(createRequire(import.meta.url).resolve("maplibre-gl/package.json")), "dist");
const out = join(import.meta.dirname, "public", "map");
mkdirSync(out, { recursive: true });
for (const file of ["maplibre-gl-worker.mjs", "maplibre-gl-shared.mjs"]) copyFileSync(join(dist, file), join(out, file));

const nextConfig: NextConfig = {
  output: "standalone",
};

export default nextConfig;
