# Research: Retail Audit Platform (Production Release)

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-06

**Scope rule**: only what the Figma frames show, plus the user-approved exceptions listed in the spec's gaps table. The stack is fixed by the constitution (v2.2.0): Fastify + Prisma + PostgreSQL, Next.js, and one
Flutter app. The decisions below choose the fewest, most standard pieces that satisfy the spec
in production (Principle IV). Each one names the requirement that justifies it.

## R-01 Projects and repository

- **Decision**: one monorepo. Each app is created with its official starter, and the generated
  configuration is kept:
  - `apps/api`: `fastify generate --lang=ts --esm`, plus `prisma init`
  - `apps/admin-web`: `create-next-app`
  - `apps/mobile`: `flutter create`

  pnpm workspaces cover api and admin-web. The code from feature 001 is replaced. Root files are
  `package.json`, `pnpm-workspace.yaml`, `.gitignore`, `README.md`, `.github/workflows/ci.yml`
  and `docker-compose.yml` (see R-14).
- **Alternatives**: hand-assembled projects, which the user rejected.

## R-02 Backend structure

- **Decision**: the Fastify starter's autoload layout. Each domain is a folder under
  `src/modules/<domain>/` with:
  - `*.routes.ts`: HTTP, with TypeBox schemas for validation and serialization
  - `*.service.ts`: business rules
  - `*.repository.ts`: Prisma

  `src/app.ts` wires the repositories and services through constructors (Principle II).
  Cross-cutting plugins live in `src/plugins/`: prisma, auth, storage, jobs, errors.
- **Rationale**: the user chose Fastify. TypeBox schemas give validation and OpenAPI docs from
  one definition.

## R-03 API style and client types

- **Decision**: REST under `/v1`, JSON, with cursor pagination for long lists (photos,
  activity) and page/size pagination where the design shows page numbers (Shops, Products,
  Salesmen tables: "Showing 1-6 of 1,420"). Errors have the shape
  `{ error: { code, message, details? }, requestId }`. `@fastify/swagger` publishes OpenAPI at
  `/docs`. The admin web generates its request and response types from it with
  `openapi-typescript`, so web and API cannot drift.
- **Alternatives**: GraphQL (rejected as more moving parts for two first-party clients), and
  tRPC (rejected because it doesn't serve Flutter).

## R-04 Authentication, sessions, device binding

- **Decision**:
  - **Passwords**: argon2id. Agents use phone + password and admins email + password.
  - **Tokens**: a 15-min access JWT plus a rotating, hashed refresh token. The refresh fails
    once it has been idle past the limit (web 12 h, mobile 30 days), tracked by `lastUsedAt`.
  - **Storage**: on mobile, tokens are in `flutter_secure_storage`. On the web, the Next server
    keeps them in httpOnly, Secure, SameSite=Lax cookies.
  - **Device binding** (Add Salesman's "Привязка рабочего устройства"): the app sends a stable
    installId and model. The first login binds; after that it must match. Admins rebind from
    the device field. IMEI is an admin-entered label, because Android doesn't expose it to apps.
  - **Deactivation grace**: queued data recorded before `deactivatedAt` is accepted for 72 h.
  - **Admin accounts**: created and reset by an operator CLI (A5).
  - **Sign-in screens**: the one approved non-Figma UI, built from existing components only.

## R-05 Authorization

- **Decision**: role checks in a route `preHandler`, and agent scoping in the repository layer.
- **Audit scope**: an agent may submit an audit for a shop they were assigned when the audit
  started, using the `shop_assignments` history. This covers offline audits submitted after a
  reassignment (spec edge case).
- **Tests**: every agent endpoint returns 404 for another agent's data (SC-007).

## R-06 File storage and images

- **Decision**: S3-compatible storage (AWS SDK v3; MinIO in development and self-hosting).
  1. `POST /uploads` returns a presigned PUT. Limits are ≤ 10 MB, or ≤ 5 MB for products. **No
     audit link is set at upload**, since the audit doesn't exist yet when photos sync first.
  2. The client PUTs the file directly to storage.
  3. `POST /uploads/:id/complete` verifies size, type and sha256 and marks the photo READY.
  4. sharp writes 400 px and 1200 px WebP previews plus `width`/`height`. The original is
     never touched.
- **Linking**: `POST /audits` links the photos (`auditId` set once, from NULL) in the same
  transaction as the audit insert.
- **Database trigger**: allows only the NULL→value `auditId` change, the preview fields and the
  verification fields on READY audit photos.
- **Reads**: 10-min presigned GET URLs from a private bucket.

## R-07 Background jobs

- **Decision**: pg-boss, a job queue stored in PostgreSQL, so there is no Redis. Jobs:
  - **Daily routes**: at the start of working hours
  - **End-of-day misses**: at the end of working hours
  - **Route re-ordering**: after each completed visit
  - **Previews**: after each upload completes
  - **Exports**
  - **Nightly retention purge**

"Требуют связи (>45 мин)" is computed at query time from `agent_positions`, so it needs no job.

## R-08 Route generation (FR-009)

- **Decision**:
  1. For each ACTIVE agent (not Отпуск, not deactivated), take the assigned non-deleted ACTIVE
     shops with `nextDueAt <= today`, overdue first. Cap the count at `dailyVisitPlan`, and mark
     the first `dailyAuditPlan` as audit tasks.
  2. Order the stops with nearest-neighbour from the last known position (or the region
     centroid), then improve with 2-opt.
  3. After each DONE, re-order the remaining PLANNED stops from that shop.
  4. At the end of working hours, mark the remaining stops MISSED.
- **No manual editing**: Figma has no route-edit UI.
- **Visit frequency**: company-wide, edited on Settings (A3/A4), default 7 days.

## R-09 Compliance (spec US8, resolved)

- **Decision**: compliance is calculated at query time as completed audits without a violation
  ÷ completed audits, per shop for a period. The product-level figure covers all shops carrying
  the product.

## R-10 Mobile offline-first (FR-015, Principle VI)

- **Decision**:
  - **Local store**: **drift** (SQLite) as the local database, mirroring the agent's data:
    shops, contacts, today's route, recent audits and photo metadata, plus an **outbox** table.
  - **Writes**: every write (new audit, new shop, location pings) is saved locally first with a
    client UUID and enqueued.
  - **Photos**: files are written to app storage before anything else.
  - **Sync engine**: runs on app start, on resume, on regaining connectivity
    (`connectivity_plus`), and periodically in the background (`workmanager` on Android). It
    sends the outbox in order: create audit, request upload URLs, upload photos, complete. It
    retries with backoff. The server de-duplicates by client UUID (idempotent upserts), so a
    repeated send is safe.
  - **Pull**: incremental by `updatedAt` cursor for shops, contacts and routes.
  - **Sync status** ("Данные синхронизированы" / "Синхронизация…" / N pending) comes from the
    outbox size.
- **Repositories**: features read only from drift, so the UI renders the same online and
  offline.
- **Alternatives**: Hive or Isar (rejected because their relational queries and migrations are
  weaker), and online-only with caching (rejected because it violates Principle VI).

## R-11 Location tracking (FR-017)

- **Decision**: tracking is active only while a signed-in agent is ACTIVE (not Отпуск) and
  within working hours. Figma has no shift control, so there is none.
  - **Collection**: `geolocator` with an Android foreground service and notification, a 25 m
    distance filter and a heartbeat at least every 2 min.
  - **Geofence pings**: immediate `GEOFENCE_ENTER`/`GEOFENCE_EXIT` pings for today's route shops
    (radius from the shop).
  - **Battery**: `battery_plus`.
  - **Delivery**: pings are buffered in drift and sent in batches.
  - **Permissions**: an explanation screen (approved exception A9) and then the operating
    system's dialogs.
- **Live views**: `agent_positions` holds the latest ping per agent.

## R-12 Maps

- **Decision**: **MapLibre** on both clients, using `maplibre-gl` via `react-map-gl` on the web
  and `maplibre_gl` on Flutter. Vector tiles come from an OpenStreetMap-based provider
  (OpenFreeMap by default, configurable). A **custom map style** reproduces the Figma map
  palette for land, water, parks, roads and labels. Markers, clusters, popups, sheets and
  controls are app UI built from the Figma frames. Clustering uses MapLibre's built-in GeoJSON
  clustering.
- **Rationale**: vector tiles with our own style are the only way to get close to the Figma map
  look with real geography (Principle I). Raster tiles can't be restyled.
- **Alternatives**: Google or Yandex (rejected because they need keys and billing, and their
  style control is limited); static images (rejected because the maps must be real).
- **Navigation**: "В навигаторе" / navigate opens the phone's maps app with a geo URI via
  `url_launcher`. There is no in-app turn-by-turn.

## R-13 Admin web data flow

- **Decision**:
  - **Pages**: server components through a typed `api` helper (generated types, bearer from the
    cookie).
  - **Mutations**: server actions.
  - **Live parts**: the map and agent positions are client components polling every 30 s.
  - **Text**: shown exactly as in each Figma frame. The admin web has no language switch in
    Figma, so there is no web i18n library.
  - **Icons**: only SVGs exported from Figma (`download_assets`); no icon font (Constitution I).

## R-14 Deployment

- **Decision**:
  - **Containers**: Dockerfiles for `api` (Node 24 slim) and `admin-web` (Next standalone
    output).
  - **docker-compose.yml**: runs postgres, minio, api and admin-web for production on one host.
    Development uses only the postgres and minio services from the same file.
  - **Migrations**: `prisma migrate deploy` runs on API start.
  - **Mobile**: Android App Bundle and APK (agents use Android phones and tablets). iOS builds
    are supported by Flutter but out of scope until needed.
  - **Configuration**: all of it through environment variables.
  - **Observability**: structured pino logs and `/health`.
- **Justification**: production readiness requires reproducible deploys. These are the only
  infrastructure files added.

## R-15 Exports and reports (FR-006, FR-020, FR-021)

- **Decision**: `exceljs` for XLSX and `pdfmake` for PDF, generated by a pg-boss job. The client
  requests an export, polls `GET /v1/exports/:id`, and downloads through a presigned URL.

## R-16 Activity feed (approved exception A6)

- **Decision**: the header bell opens a SidePanel listing recent violations and missed visits,
  built from the existing visit-history cards. It is derived by query (`GET /v1/feed`), with no
  notification tables. Unread = items newer than `users.feedSeenAt`. It is polled every 30 s
  for the unread dot. There are no push notifications.

## R-17 Testing (Principle V)

- **Decision**:
  - **API**: the starter's runner with `app.inject` against real PostgreSQL and MinIO.
    Test-first for auth and device binding, idle expiry, deactivation grace, scoping (incl.
    reassignment), the geofence, audit immutability and photo linking, uploads and previews,
    route generation, misses and re-ordering, compliance, exports and retention.
  - **Mobile**: the sync engine, geofence, visit state, the audit and add-shop enabling rules,
    and the tracking rules.
  - **Web**: Vitest for the server actions (validation, error mapping) and the session cookies.
  - **Performance**: SC-005 with a load-seed script; SC-008 measured with `--trace-startup`.
  - **Reliability**: SC-002 with a scripted run of 100 offline audits.
  - **Screens**: checked against Figma screenshots.

## R-18 Design implementation workflow (Principle I)

- **Decision**: build each screen from its Figma frame.
  1. `get_design_context` returns the exact structure, values and variable names.
  2. Implement it with the shared components.
  3. Capture the app at the frame size and compare with `get_screenshot`.

  The theme mirrors the Figma variables (contracts/figma-frames.md). Icons, logo and markers come
  from `download_assets`. Figma calls are budgeted (Starter plan): one context call per frame, at
  build time.

## R-19 Company settings (approved exception A4)

- **Decision**: a single `company_settings` row, edited on the web Settings page and cached in
  the API for 60 s. Jobs (routes, end-of-day), the geofence, tracking and `/me` read from it. A
  change to the working hours re-schedules the route jobs.

## R-20 Map layers (B2)

- **Decision**: Layers switches between the custom Figma-matched vector style and a satellite
  raster source. The satellite provider URL is configurable, with a free imagery tile source by
  default.
