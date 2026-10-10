# Self-hosted map tiles

The admin web and the mobile app draw their street map from OpenMapTiles-schema vector tiles plus one label
font, "Noto Sans Regular". By default they load both from openfreemap.org. This folder runs them on your own
server instead: a Turkmenistan-only extract served by [Martin](https://maplibre.org/martin/).

The satellite layer of the web map is not part of this; it still comes from `SATELLITE_TILES_URL` (ArcGIS).

## Run it

On a server with Docker that the phones and admins can reach:

```sh
cd infra/maptiles
docker compose run --rm build   # once: writes data/turkmenistan.mbtiles (a few minutes, ~3 GB temporary disk)
docker compose up -d martin     # tiles and fonts on port 3200
```

The build downloads Geofabrik's Turkmenistan OpenStreetMap extract and the water and Natural Earth layers
Planetiler needs, so the server must reach `download.geofabrik.de`, `osmdata.openstreetmap.de` and
`naciscdn.org` for that step. You can also run the build on any other machine and copy
`data/turkmenistan.mbtiles` to the server; serving needs no internet.

Check it:

- `http://<server>:3200/catalog` lists the `openmaptiles` source and the `Noto Sans Regular` font.
- `http://<server>:3200/openmaptiles` returns the TileJSON.

To refresh the map data, run the build again and `docker compose restart martin`.

## Point the apps at it

Admin web (environment on Vercel, or `apps/admin-web/.env.local`):

```sh
MAP_TILES_URL=http://<server>:3200/openmaptiles
MAP_GLYPHS_URL=http://<server>:3200/font/{fontstack}/{range}
```

Mobile (`apps/mobile/env/prod.json`, then rebuild the APK):

```json
"MAP_TILES_URL": "http://<server>:3200/openmaptiles",
"MAP_GLYPHS_URL": "http://<server>:3200/font/{fontstack}/{range}"
```

The web admin is served over HTTPS, so browsers block an `http://` tile server there (mixed content). For the
web map, put Martin behind HTTPS (a reverse proxy with a certificate, e.g. Caddy) and use the `https://` URLs.
The mobile app allows plain HTTP.

## Files

- `docker-compose.yml`: the one-off `build` (Planetiler 0.10.2) and the `martin` server (1.16.1).
- `martin.yaml`: the tile source and the font folder.
- `fonts/`: Noto Sans Regular (SIL Open Font License, `OFL.txt`); Martin generates the label glyphs from it.
- `data/`: the built extract (not committed).
