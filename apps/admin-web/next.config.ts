import { createHash } from "node:crypto";
import { copyFileSync, mkdirSync, readFileSync, readdirSync } from "node:fs";
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

// Icons are requested as /icons/<name>.svg?v=<hash of all icons> (see iconSrc) and cached for a year: browsers
// stop re-checking every icon on every page load, and a changed icon gets a new URL.
const icons = join(import.meta.dirname, "public", "icons");
const iconsHash = createHash("sha1");
for (const file of readdirSync(icons).sort()) iconsHash.update(file).update(readFileSync(join(icons, file)));

const nextConfig: NextConfig = {
  output: "standalone",
  env: { ICONS_VERSION: iconsHash.digest("hex").slice(0, 10) },
  async headers() {
    return [{ source: "/icons/:file*", headers: [{ key: "Cache-Control", value: "public, max-age=31536000, immutable" }] }];
  },
};

export default nextConfig;
