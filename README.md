# Audit App

A retail-execution platform. Field agents visit shops on daily routes and record audits:
GPS-checked in-app photos, a comment, and an optional violation. Admins manage shops, agents
and products, watch agents live on the map, review photos and export reports.

| App | Path | Created with |
|-----|------|--------------|
| API | `apps/api` | `fastify generate --lang=ts --esm` + `prisma init` (PostgreSQL) |
| Admin web | `apps/admin-web` | `create-next-app` |
| Mobile (agent + admin roles) | `apps/mobile` | `flutter create` |

## Design source

The Figma file **9s5b56r9zs1s0Ty2UgvL0W** is the only design source. Every screen is built
pixel-perfect from its frame (node IDs are in
`specs/002-retail-audit-platform/contracts/figma-frames.md`). The Figma file is never modified.
Anything Figma doesn't define follows the **Figma gap protocol** in
`.specify/memory/constitution.md` (Principle I): detect, propose options, the product owner
decides, record.

## Setup

Requirements: Node 24 + pnpm, Flutter stable, PostgreSQL 16 and an S3-compatible store (SeaweedFS),
either via `docker compose up -d postgres seaweedfs` or installed locally.

```bash
pnpm install
cp apps/api/.env.example apps/api/.env              # database, JWT, S3, WEB_ORIGIN
cp apps/admin-web/.env.example apps/admin-web/.env.local
pnpm --filter api exec prisma migrate deploy
pnpm --filter api exec prisma db seed                # default settings, regions, categories
pnpm --filter api admin:create -- --email admin@company.tm --password '…'
pnpm --filter api dev                                # API on :3000, docs at /docs
pnpm --filter admin-web dev                          # admin web on :3002
adb reverse tcp:3000 tcp:3000
cd apps/mobile && flutter run --dart-define-from-file=env/dev.json
```

### Tests

```bash
pnpm --filter api test           # API: scoping (SC-007) and offline-replay soak (SC-002) included
pnpm --filter admin-web test     # web unit tests
cd apps/mobile && flutter test   # sync, visit state, audit, add shop, tracker
# Screen renders for the design pass (written to $SCREENS_OUT, default build/screens):
cd apps/mobile && SCREENS_OUT=/tmp/screens flutter test test_screens
```

## Environment

| App | Variable | Notes |
|-----|----------|-------|
| API | `DATABASE_URL` | PostgreSQL 16 (also holds the pg-boss job queue) |
| API | `JWT_SECRET` | ≥ 32 random characters |
| API | `S3_ENDPOINT`, `S3_BUCKET`, `S3_ACCESS_KEY`, `S3_SECRET_KEY` | the bucket is created on start |
| API | `WEB_ORIGIN` | admin web origin(s); the only browser origins CORS allows |
| API | `RETENTION_YEARS` (3), `CURRENCY` (TMT), `JOBS_DISABLED` | optional |
| Admin web | `API_URL` | API base URL, called from the Next server only |
| Admin web | `SATELLITE_TILES_URL` | raster tiles for the map's Layers button |
| Mobile | `API_URL`, `MAP_TILES_URL` | `--dart-define-from-file=env/<flavor>.json`; tiles default to OpenFreeMap |

Secrets live only in these env files, which are git-ignored. `infra/seaweedfs-s3.json` holds the
**development** S3 credentials; production must use its own.

## Production deploy

```bash
# On the server: Docker + compose, a domain with TLS in front (Caddy/nginx → :3000 and :3001).
cp apps/api/.env.example apps/api/.env          # production values, S3 keys matching the S3 config
cp apps/admin-web/.env.example apps/admin-web/.env.local
docker compose --profile prod up -d --build      # postgres, seaweedfs, api (migrates on start), admin-web
docker compose exec api pnpm exec prisma db seed
docker compose exec api pnpm admin:create -- --email admin@company.tm --password '…'
```

- The API runs its own jobs (pg-boss): route generation at the company's start of day, missed
  stops at the end of day, photo previews, exports and the nightly retention purge.
- Photos upload straight from the browser and the app to S3 with presigned URLs, so the bucket's
  CORS must allow `PUT` from `WEB_ORIGIN` (SeaweedFS allows it by default; set a bucket CORS rule
  on other providers).
- Maps: the vector tiles come from OpenFreeMap by default. For production volume, self-host
  tiles (e.g. an OpenMapTiles/PMTiles server) and point `MAP_TILES_URL` (mobile) and the
  `openmaptiles` source in `apps/admin-web/public/map/style.json` to it.

### Backups

- **PostgreSQL** (all data and the job queue): nightly
  `docker compose exec -T postgres pg_dump -U audit -Fc audit > backup/audit-$(date +%F).dump`;
  restore with `pg_restore -c -d audit`. Keep at least 14 days off the server.
- **SeaweedFS** (photos, previews, exports): back up the `s3data` volume, or mirror the bucket
  with `aws s3 sync s3://audit-photos ./backup/photos --endpoint-url $S3_ENDPOINT`.
- Restore the database and the bucket from the same night so photo rows match their files.

### Operator CLIs (`apps/api`)

| Command | Purpose |
|---------|---------|
| `pnpm admin:create -- --email … --password …` | create an admin (admins have no screen in Figma) |
| `pnpm admin:reset-password -- --email … --password …` | reset an admin password |
| `pnpm job:routes [YYYY-MM-DD]` | generate the day's routes now |
| `pnpm job:end-of-day [YYYY-MM-DD]` | mark unvisited stops as missed now |
| `pnpm seed:load` / `pnpm bench` | load data and list benchmarks (empty database only) |

### Mobile release

1. Set `apps/mobile/env/prod.json` → `API_URL` (and `MAP_TILES_URL` if self-hosted).
2. Create a keystore once and keep it safe:
   `keytool -genkey -v -keystore ~/audit-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias audit`
3. Add `apps/mobile/android/key.properties` (git-ignored):
   `storeFile=/home/…/audit-release.jks`, `storePassword=…`, `keyAlias=audit`, `keyPassword=…`
4. Bump `version:` in `pubspec.yaml`, then
   `flutter build appbundle --release --dart-define-from-file=env/prod.json`
   (`build/app/outputs/bundle/release/app-release.aab`), or `flutter build apk --release …` for
   direct installs.
5. Release builds only allow HTTPS; cleartext HTTP is enabled in the debug manifest only.

## Architecture

- **API**: `src/routes/v1/<domain>/` (HTTP) and `src/modules/<domain>/` with `*.service.ts`
  (rules), `*.repository.ts` (Prisma) and `*.schema.ts` (TypeBox), wired in `src/plugins/services.ts`. Jobs (routes, previews, exports,
  retention) run on pg-boss in PostgreSQL. Photos go directly to S3 with presigned URLs.
- **Admin web**: `src/features/<feature>/{components,hooks,api}` plus `copy.ts` (the Figma text
  for that feature). Shared UI lives in `src/components/ui`.
- **Mobile**: `lib/core` (theme from the Figma variables, router, network, offline database,
  sync) and `lib/features/<feature>/{data,domain,presentation}`. The agent role works offline
  through an outbox.

## Workflow

Spec Kit: `/speckit-specify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-analyze` →
`/speckit-implement`. The current feature is `specs/002-retail-audit-platform/`.
