---

description: "Task list for 002-retail-audit-platform (Figma-only scope, production release)"
---

# Tasks: Retail Audit Platform (Production Release)

**Input**: Design documents from `/specs/002-retail-audit-platform/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md,
contracts/ (figma-frames.md, screens.md, api.md, sync.md), quickstart.md

**Scope rule**: build only what the 46 Figma frames show, plus the user-approved exceptions in spec.md's gaps table (G1, G2, A4, A6, A7, A9, A11, B1–B5), built only from existing Figma components.
Never modify the Figma file. Never add screens, fields or flows. Gaps are resolved as in spec.md
"Figma Gaps and Resolutions".

**Tests**: Constitution V. The test tasks in each phase come first, and each MUST be run and seen
to fail before it is implemented. Screens are verified against Figma, not by tests.

**Screen task rule (Constitution I)**: for every task that builds a screen from a Figma node:
1. Load the `figma:figma-design-to-code` skill.
2. Call `get_design_context` on the node (fileKey `9s5b56r9zs1s0Ty2UgvL0W`) and use its exact
   values with the shared components and theme.
3. Wire every value to the listed API or local-store data. No hard-coded user content.
4. Render each element present in the frame, even if it has no behavior; follow the gaps table
   for those.
5. Build the frame's variant states and the loading, empty and error states, using the frame's
   own components.
6. Capture the result at the frame size and compare it with `get_screenshot` of the node. Fix
   every difference.

Figma calls are budgeted: one `get_design_context` per frame, when its task runs.

**Web convention** (Constitution II, Localization): `src/features/<feature>/{components,hooks,api}` plus `copy.ts` holding the frame's text verbatim.

**Organization**: P1 stories in dependency order (US1 → US4 → US3 → US2), then P2 and P3.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on unfinished tasks)
- **[Story]**: The user story from spec.md (US1–US9)

---

## Phase 1: Setup (Shared Infrastructure)

- [X] T001 Create the git branch `002-retail-audit-platform` from `001-init-projects` and commit the constitution and specs/002 documents at the repository root
- [X] T002 Delete the superseded material at the repository root:
  - `apps/` (the 001 code)
  - `admin-design-png/`, `mobile-admin-design-png/`, `mobile-agent-design-png/`
  - `admin-design.css`, `mobile-admin-design.css`, `mobile-agent-design.css`, `mobile-agent-dark-design.css`
  - `docker-compose.yml`, `scripts/`, `.editorconfig`, `.prettierrc`, `.prettierignore`, `.nvmrc`, `.env.example`

  Then set `**Status**: Superseded by 002-retail-audit-platform` in `specs/001-init-projects/spec.md`
- [X] T003 Write the root `package.json` (private, pnpm `packageManager`, scripts `dev`/`lint`/`test` delegating to the apps), `pnpm-workspace.yaml` (`apps/api`, `apps/admin-web`) and `.gitignore` (OS and IDE files, and `.env*` except examples)
- [X] T004 [P] Generate the API with `npx fastify-cli generate apps/api --lang=ts --esm`, then run `npx prisma init --datasource-provider postgresql` inside `apps/api/`. Keep the generated files and name the package `api`
- [X] T005 [P] Generate the admin web with `pnpm create next-app@latest apps/admin-web` (TypeScript, ESLint, Tailwind, App Router, `src/`, `@/*`). Keep the generated files. Name the package `admin-web` and set port 3001 in `apps/admin-web/package.json`
- [X] T006 [P] Generate the mobile app with `flutter create --org com.auditapp --project-name audit_mobile --platforms android,ios apps/mobile`. Keep the generated files
- [X] T007 Create `docker-compose.yml`:
  - dev services: `postgres:16` (db `audit`, healthcheck), and `seaweedfs` (S3 API on 8333; the app creates the `audit-photos` bucket on start)
  - a `prod` profile adding `api` and `admin-web` built from their Dockerfiles, plus volumes
- [X] T008 [P] Create `apps/api/Dockerfile` (Node 24 slim, production install, `prisma generate`; start runs `prisma migrate deploy` then the server)
- [X] T009 [P] Create `apps/admin-web/Dockerfile` (standalone output) and set `output: 'standalone'` in `apps/admin-web/next.config.ts`
- [X] T010 Create `.github/workflows/ci.yml` with three jobs:
  - `api`: postgres service + SeaweedFS started in a step; install, migrate, `prisma migrate status`, lint, typecheck, test
  - `admin-web`: install, lint, typecheck, test, build
  - `mobile`: Flutter stable; `pub get`, `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`
- [X] T011 Add the API dependencies in `apps/api/package.json`: `@fastify/jwt`, `@fastify/rate-limit`, `@fastify/swagger`, `@fastify/swagger-ui`, `@fastify/type-provider-typebox`, `@sinclair/typebox`, `@prisma/client`, `@prisma/adapter-pg`, `argon2`, `@aws-sdk/client-s3`, `@aws-sdk/s3-request-presigner`, `sharp`, `pg-boss`, `exceljs`, `pdfmake`, `uuid`, `csv-parse`; dev `prisma`
- [X] T012 [P] Add the admin web dependencies in `apps/admin-web/package.json`: `maplibre-gl`, `react-map-gl`; dev `openapi-typescript`, `vitest`, `@testing-library/react`, `jsdom`
- [X] T013 [P] Add the mobile dependencies in `apps/mobile/pubspec.yaml`: `flutter_riverpod`, `go_router`, `flutter_localizations`, `intl`, `drift`, `sqlite3_flutter_libs`, `path_provider`, `dio`, `flutter_secure_storage`, `device_info_plus`, `geolocator`, `battery_plus`, `connectivity_plus`, `workmanager`, `camera`, `image_picker`, `maplibre_gl`, `url_launcher`, `flutter_svg`, `shared_preferences`, `share_plus`; dev `drift_dev`, `build_runner`, `mocktail`. Enable `flutter: generate: true`
- [X] T014 [P] Define the web theme from the Figma variables (contracts/figma-frames.md) as CSS variables + Tailwind `@theme inline` in `apps/admin-web/src/app/globals.css`. Load Inter and Space Grotesk via `next/font/google` in `apps/admin-web/src/app/layout.tsx`
- [X] T015 [P] Define the mobile theme from the Figma variables in `apps/mobile/lib/core/theme/app_colors.dart`:
  - **light**: Main bg `#FBF8FF`, Secondary bg `#F3F2FF`, Accent `#493EE5`, Black `#0F172A`, Default black `#62617B`, Border `#E2E8F0`, Dark accent `#EDEDFB`, Grey 3 `#F1F5F9`, Success `#00685A`, Success 10%, Light green `#03D66C`, Error `#CE3437`, Error bg `#F9EDEC`, Pure white, White 5%/20%, Accent 6%
  - **dark**: Main bg `#0B0F19`, Secondary bg `#121A2C`, White `#FCFDFF`, Off white `#94A3B8`, Accent `#493EE5`, Dark accent `#1E2549`, Light accent `#A5B4FC`, Success `#25D998`, Error `#FDA4AF`, Error bg `#450A0A`, Error stroke `#9F1239`, White 5%/20%

  Add `app_text_styles.dart`, `app_spacing.dart` and `app_theme.dart` (light/dark `ThemeData` + `ThemeExtension`). Bundle Inter in `apps/mobile/assets/fonts/`
- [X] T016 Export every icon, the logo and the map markers from Figma with `download_assets`:
  - sidebar and header of `3:407`, plus the icons in `21:2`, `30:574`, `31:2307`, `53:1375` → `apps/admin-web/public/icons/`
  - `83:16786`, `83:16884`, `83:17057`, `83:17207`, `83:17636`, `246:23129`, `265:27616` → `apps/mobile/assets/icons/`

  Save as SVG, named by meaning (e.g. `nav-shops.svg`, `marker-shop-visited.svg`). The web shell icons (sidebar `3:408`, header `3:853`) are exported here. Every other icon is exported together with its screen task, from the `get_design_context` assets, to stay within the Figma call budget
- [X] T017 [P] Set up gen-l10n for mobile only, in `apps/mobile/l10n.yaml` and `apps/mobile/lib/core/l10n/app_{ru,en}.arb`. Russian strings come verbatim from the Figma mobile frames, and English strings are translations with the same keys. The admin web uses the Figma text verbatim, with no i18n
- [X] T018 Write the root `README.md`: the product, apps, setup from quickstart.md, layer conventions, the Figma-only design workflow, the operator CLI (`admin:create`, `admin:reset-password`), and the Spec Kit workflow

**Checkpoint**: the three starters run, docker services are up, and CI is green.

---

## Phase 2: Foundational (Blocking Prerequisites)

**⚠️ CRITICAL**: no user story starts before this phase is complete.

### Database

- [X] T019 Write the account and region models in `apps/api/prisma/schema.prisma`, following data-model.md:
  - `User`: role `ADMIN|AGENT`; email unique, required for ADMIN; phone unique E.164, required for AGENT; argon2id `passwordHash`; status `ACTIVE|DEACTIVATED`; `deactivatedAt` null; `lastActiveAt`; `feedSeenAt` null
  - `CompanySettings` (single row): companyName, logoPhotoId, workStart, workEnd, timezone, visitFrequencyDays 7, defaultAuditRadiusM 100, minGpsAccuracyM 50, noSignalMinutes 45
  - `RefreshToken`: includes `lastUsedAt`
  - `Agent`: code unique `SL-`+sequence; fullName required; whatsappPhone null; regionId required; routeNotes null; `dailyVisitPlan` default 25, 1–100; `dailyAuditPlan` default 20, ≤ dailyVisitPlan; workStatus `ACTIVE|ON_LEAVE`
  - `Device`: agentId unique, installId unique, model, imeiLabel null
  - `Region`
- [X] T020 Add the shop and product models to `apps/api/prisma/schema.prisma`:
  - `Shop`: code unique `CL-`+sequence; type `HYPERMARKET|SUPERMARKET|MARKET|MINIMARKET|OTHER`; lat/lng required; auditRadiusM; status `PENDING_REVIEW|ACTIVE|INACTIVE`; `deletedAt` null; lastVisitAt; nextDueAt; `version`
  - `ShopContact` (≤ 5 per shop), `ShopAssignment` (agentId, from, to), `ShopProduct` (PK shopId+productId), `ProductCategory`
  - `Product`: sku unique; name; categoryId; brand null; retailPriceMinor ≥ 0; description null; imageId; status `ACTIVE|INACTIVE`; stockQty ≥ 0; minStockAlert ≥ 0
- [X] T021 Add the route, audit and photo models to `apps/api/prisma/schema.prisma`:
  - `Route`: unique (agentId, date)
  - `RouteStop`: status `PLANNED|IN_PROGRESS|DONE|MISSED`; isAuditTask; auditId null
  - `Audit`: client id; device times; receivedAt; clockSkewFlag; durationMin; gps; distanceM; withinRadius; comment required; `hasViolation` bool (from the violation chip)
  - `Photo`: client id; kind `AUDIT|FACADE|PRODUCT|AVATAR|LOGO|ADMIN_UPLOAD`; auditId null; shopId null; storageKey; previewKeys null; mime `image/jpeg|png|webp`; sizeBytes; sha256; width/height null; takenAt; geo; status `PENDING_UPLOAD|READY|FAILED`; verifiedById/At
- [X] T022 Add the tracking and export models to `apps/api/prisma/schema.prisma`:
  - `LocationPing`: bigint id; trigger `HEARTBEAT|GEOFENCE_ENTER|GEOFENCE_EXIT`; index (agentId, recordedAt desc)
  - `AgentPosition`: PK agentId
  - `Export`: type `SHOPS_XLSX|PRODUCTS_XLSX|AGENT_REPORT_PDF|AGENT_REPORT_XLSX`; status `QUEUED|RUNNING|DONE|FAILED`
- [X] T023 Create the initial migration in `apps/api/prisma/migrations/` with SQL for:
  - `pg_trgm` and trigram indexes on shops `name`, `code`, `ownerName` and `address`
  - sequences for the `SL-` and `CL-` codes
  - a trigger rejecting UPDATE and DELETE on `audits`
  - a trigger on `photos` where `kind='AUDIT' AND status='READY'`. DELETE is rejected. UPDATE may change only `auditId` (NULL→value once), `previewKeys`, `width`, `height`, `verifiedById` and `verifiedAt`
- [X] T024 Write `apps/api/prisma/seed.ts` (the default company_settings row, regions, product categories) and the operator CLI `apps/api/scripts/admin.ts` (`admin:create`, `admin:reset-password`; A5). Add the scripts to `apps/api/package.json`

### API platform

- [X] T025 [P] Create the env plugin in `apps/api/src/plugins/env.ts`, holding typed configuration that fails fast and names any missing variable:
  - infrastructure: `DATABASE_URL`, `JWT_SECRET`, `S3_*`, `WEB_ORIGIN`
  - `RETENTION_YEARS` 3, `CURRENCY`, `SATELLITE_TILES_URL`

  Company values live in `company_settings` (A4), not env

  Add `apps/api/.env.example`
- [X] T026 [P] Create the prisma plugin in `apps/api/src/plugins/prisma.ts`
- [X] T027 [P] Create the error plugin in `apps/api/src/plugins/errors.ts` with the shape and codes from contracts/api.md, request IDs and log redaction. Add `src/lib/app-error.ts`
- [X] T028 [P] Create the swagger plugin in `apps/api/src/plugins/swagger.ts` (`/docs`, `/docs/json`)
- [X] T029 [P] Create the helpers in `apps/api/src/lib/`:
  - `geo.ts`: haversine
  - `pagination.ts`: page/size and cursor
  - `time.ts`: company-local date and working-hours checks, using the cached company_settings
  - `ids.ts`: uuid v7
- [X] T030 Write failing tests in `apps/api/test/plugins/auth.test.ts`: a missing or expired bearer → 401, a role mismatch → 403, and `request.user` exposes `{id, role, agentId}`
- [X] T031 Implement the auth plugin in `apps/api/src/plugins/auth.ts` (`@fastify/jwt`, `authenticate`, `requireRole` route config, `@fastify/rate-limit` registration)
- [X] T032 Write failing tests in `apps/api/test/plugins/storage.test.ts` against SeaweedFS: presigned PUT and GET round-trip, and `head` returns size and type
- [X] T033 Implement the storage plugin in `apps/api/src/plugins/storage.ts` (`presignPut`, `presignGet` with 10-min expiry, `head`, `getObject`, `putObject`)
- [X] T034 Implement the jobs plugin in `apps/api/src/plugins/jobs.ts` (pg-boss on the same database; `send`/`schedule`/`work`) and the worker registry in `apps/api/src/jobs/index.ts`
- [X] T035 Create the test harness in `apps/api/test/helpers/`:
  - `build-app.ts`: the real app with a test database and bucket
  - `db.ts`: migrate and truncate
  - `factories.ts`: admin, agent+device, region, shop (+assignment), product, audit, photo
  - `auth.ts`: login helpers

### Uploads (shared)

- [X] T036 Write failing tests in `apps/api/test/uploads.test.ts`:
  - `POST /v1/uploads` returns a presigned PUT, is idempotent per id, and **has no auditId field**
  - it rejects a mime other than `image/jpeg|png|webp`, and size > 10 MB (> 5 MB for PRODUCT, PNG or JPG only)
  - complete verifies size and sha256, sets READY and queues previews
  - another user's upload → 404
  - `ADMIN_UPLOAD` requires `shopId` and is admin only
  - the DB trigger lets the preview job set `previewKeys`/`width`/`height` on a READY AUDIT photo, and rejects changes to `storageKey`
- [X] T037 Implement the uploads module in `apps/api/src/modules/photos/` (`uploads.routes.ts`, `uploads.service.ts`, `photos.repository.ts`, `photos.schema.ts`)
- [X] T038 Implement the preview job in `apps/api/src/jobs/previews.ts` (sharp: 400/1200 px WebP + width/height; the original is never modified) and the image serializer in `apps/api/src/modules/photos/photo.view.ts` (`{id,url,previewUrl400,previewUrl1200,width,height,takenAt}`)
- [X] T039 [P] Write failing tests in `apps/api/test/settings.test.ts`: `GET`/`PATCH /v1/settings` are admin only; workEnd > workStart; radius 10–1000; accuracy 5–200; frequency 1–90 days; noSignal 5–240 min; a working-hours change re-schedules the route jobs. Regions CRUD: a region in use can't be deleted (409); agents can GET only
- [X] T040 Implement the settings module in `apps/api/src/modules/settings/` (routes, service with a 60 s cache, repository) and the regions module in `apps/api/src/modules/regions/` (GET for all roles; POST/PATCH/DELETE for admins)
- [X] T041 Wire all modules in `apps/api/src/app.ts` (composition root: repositories → services → route plugins under `/v1`) and add `GET /health` (db + storage) in `apps/api/src/routes/health.ts`

### Admin web platform

- [X] T042 [P] Add the `gen:api` script (openapi-typescript from `/docs/json` → `src/lib/api-types.ts`) and implement `apps/admin-web/src/lib/api.ts` (typed server fetch, bearer from cookie, error mapping, list helpers)
- [X] T043 Write failing Vitest tests in `apps/admin-web/src/lib/session.test.ts`:
  - cookies are httpOnly, Secure and SameSite=Lax
  - a refresh happens on 401
  - after 12 h idle the user goes to `/login`
  - agent-role logins are refused

  Configure `apps/admin-web/vitest.config.ts`
- [X] T044 Implement the session in `apps/admin-web/src/lib/session.ts` and the auth redirect for `(admin)` routes in `apps/admin-web/src/proxy.ts`
- [X] T045 [P] Implement the upload helper in `apps/admin-web/src/lib/upload.ts`: browser sha256 → server action create → PUT → server action complete
- [X] T046 Build the admin layout from the sidebar and header of Figma `3:407` in `apps/admin-web/src/app/(admin)/layout.tsx`, `src/components/layout/Sidebar.tsx` and `src/components/layout/Topbar.tsx`:
  - logo + company name from `GET /v1/me`
  - nav Dashboard (→ `/map`), Map, Shops, Products, Salesmen, Pictures, Settings (→ `/settings`, A4)
  - header: "Search clients…" → `/shops?q=`; bell slot (feed panel added in US9, A6); Help rendered but inert; avatar menu with Sign out
- [X] T047 [P] Build the shared web components in `apps/admin-web/src/components/ui/`, each from the frame where it first appears:
  - `Button`, `PageHeader`, `StatCard`, `FilterSelect`, `FilterChip`, `SearchField` (`30:574`)
  - `DataTable`, `Pagination`, `StatusBadge`, `Avatar`, `RowMenu` (`3:407`)
  - `Dialog`, `FormField`, `ImageUpload` (`162:20071`), `SidePanel`, `PhotoTile` (`138:11987`)
  - `VisitHistoryItem` (`47:7387`), `Timeline` (`122:7981`)
  - `MapView` (MapLibre wrapper + marker components, `21:2`)

### Mobile platform

- [X] T048 [P] Implement `apps/mobile/env/{dev,prod}.json`, `lib/core/config/app_config.dart` and `lib/core/network/api_client.dart` (dio, bearer interceptor, single-flight refresh, `ApiException` from the error shape)
- [X] T049 [P] Implement `apps/mobile/lib/core/auth/session_store.dart` (secure storage) and `session_provider.dart`
- [X] T050 Create the drift database `apps/mobile/lib/core/db/app_database.dart` with `shops`, `shop_contacts`, `routes`, `route_stops`, `audits`, `photos` (+`localPath`), `outbox` (`id, kind, payloadJson, dependsOn, createdAt, attempts, lastError, state`), `pings_buffer` and `sync_cursors` (data-model.md). Run build_runner
- [X] T051 Write failing tests in `apps/mobile/test/core/sync/sync_engine_test.dart` (fake API):
  - FIFO order with dependencies (PHOTO before AUDIT_CREATE and SHOP_CREATE)
  - backoff on network errors and 5xx
  - a repeated create counts as success
  - other 4xx → FAILED, kept and retried on the next sync, with status "Синхронизация…"
  - the pull applies tombstones but keeps items with pending outbox entries
- [X] T052 Implement `apps/mobile/lib/core/sync/` per contracts/sync.md: `outbox_repository.dart`, `sync_engine.dart`, `pull_service.dart`, and `sync_status_provider.dart` (Данные синхронизированы / Синхронизация…). Triggers: start, resume, connectivity, workmanager every 15 min, on demand
- [X] T053 Implement `apps/mobile/lib/core/router/app_router.dart` (go_router per contracts/screens.md; redirect: no session → `/login`; role prefixes; role home)
- [X] T054 [P] Build the shared mobile widgets in `apps/mobile/lib/core/widgets/`, each from the frame where it first appears:
  - `app_top_bar.dart`, `search_field.dart`, `filter_chips.dart`, `shop_list_tile.dart` (`83:16884`)
  - `shop_card.dart` (`246:23300`), `stat_tile.dart` (`265:27616`)
  - `photo_grid.dart` (`83:17954`)
  - `audit_history_item.dart`, `violation_note.dart` (`83:17057`)
  - `form_field.dart`, `primary_button.dart` (enabled and disabled, `252:26487`)
  - `bottom_sheet_card.dart` (`83:17775`)
  - `home_action_tile.dart`, `theme_toggle.dart`, `locale_toggle.dart`, `sync_status_badge.dart` (`83:16786`)
  - `map_view.dart` (maplibre_gl)
  - `filter_sheet.dart`: the B3 filter bottom sheet, built from `bottom_sheet_card.dart` + `filter_chips.dart`, configurable per screen (status, region, date)
- [X] T055 Implement `apps/mobile/lib/app.dart` and `lib/main.dart`: ProviderScope, MaterialApp.router, light/dark themes, persisted theme mode (system default) and locale (ru fallback) via shared_preferences, matching the Home toggles

**Checkpoint**: migrations apply (with triggers), `/docs` lists the endpoints, the platform tests pass, the web shell renders behind auth, and the app boots to `/login`.

---

## Phase 3: User Story 1 - Sign in and land in the right workspace (Priority: P1) 🎯 MVP

**Goal**: sign-in (the approved exception), agents created via Add Salesman, device binding,
sessions.

**Independent Test**: quickstart US1.

### Tests ⚠️

- [X] T056 [P] [US1] Write failing tests in `apps/api/test/auth.test.ts`:
  - admin login by email, agent login by phone
  - the first agent login binds the device, a different installId → 403 `DEVICE_NOT_BOUND`, and a missing device → 400
  - refresh rotates the token, and an old token → 401
  - refresh fails after the idle limit (web 12 h, mobile 30 days, by `lastUsedAt`)
  - deactivated: new login → 401; for 72 h the session may refresh and sync data recorded before `deactivatedAt`, then refresh → 401
  - the 6th failed login in a minute → 429
- [X] T057 [P] [US1] Write failing tests in `apps/api/test/agents.test.ts`:
  - create returns a sequential `SL-` code and a temporary password
  - validation: fullName and regionId required, dailyVisitPlan 1–100, dailyAuditPlan ≤ dailyVisitPlan
  - PATCH `workStatus` Активен/Отпуск
  - deactivate unassigns the agent's shops (closing the `shop_assignments` rows), and reactivate works
  - reset-password works
  - `PUT /agents/:id/device` clears the binding
  - list filters and pagination
  - agents get 403

### Implementation

- [X] T058 [US1] Implement the auth module in `apps/api/src/modules/auth/` (routes, service, repository, schema): login with device binding, refresh with rotation and idle expiry, logout, `GET /v1/me` with the config subset, the deactivation grace check, and the login rate limit
- [X] T059 [US1] Implement the agents module in `apps/api/src/modules/agents/` (routes, service, repository, schema): list, create, get, patch (version), deactivate/reactivate (via patch `active`), reset-password, device rebind
- [X] T060 [US1] Build the web sign-in (approved exception) in `apps/admin-web/src/app/login/page.tsx` + `src/features/auth/api/actions.ts`: email + password, using only the existing Figma components (FormField, Button, colors and type from `162:20071` / `495:3932`), refusing agents with a message
- [X] T061 [US1] Build the Salesmen table area of Figma `31:2307` (columns, search, status filter, pagination, "Add Salesman") in `apps/admin-web/src/app/(admin)/salesmen/page.tsx` + `src/features/agents/{api/,copy.ts,components/AgentsTable.tsx}`, with data from `GET /v1/agents`
- [X] T062 [US1] Build Add Salesman from Figma `495:3932` in `apps/admin-web/src/app/(admin)/salesmen/new/page.tsx`, `salesmen/[id]/edit/page.tsx` and `src/features/agents/components/AgentForm.tsx`, with exactly the frame's fields, the bound device (model/IMEI label + rebind) and Статус. Show the temporary password once, and offer reset password and deactivate
- [X] T063 [US1] Build the mobile sign-in (approved exception) in `apps/mobile/lib/features/auth/presentation/login_screen.dart` + `data/auth_repository.dart`: phone/email + password, device payload from device_info_plus, `DEVICE_NOT_BOUND` and deactivated messages, using only existing Figma widgets, colors and type (`252:26487` form styles). It routes to the role home
- [X] T064 [US1] Implement sign-out in `apps/mobile/lib/features/auth/data/sign_out_service.dart` (flush the outbox for 10 s, then wipe drift, photo files and secure storage, keeping only theme and locale) and expose it from the Home avatar (`83:16786` / `246:23129`)

**Checkpoint**: US1 works on its own.

---

## Phase 4: User Story 4 - Admin manages shops (Priority: P1)

**Independent Test**: quickstart US4.

### Tests ⚠️

- [ ] T065 [P] [US4] Write failing tests in `apps/api/test/shops.test.ts`:
  - admin create → ACTIVE with a `CL-` code and a `shop_assignments` row
  - list filters (q trigram, status, regionId, agentId) with totals
  - PATCH with a stale version → 409
  - PATCH `status` toggles ACTIVE/INACTIVE, and PENDING_REVIEW → ACTIVE approves
  - contacts ≤ 5
  - bulk assign closes and opens assignment rows
  - bulk delete sets `deletedAt`, keeps audits and photos, and removes the shop from lists, map and future routes
  - an agent sees only assigned shops (others → 404)
  - `updatedAfter` returns changes and tombstones (deleted or unassigned)
  - `/shops/:id/visits` totals: all, completed, missed
- [ ] T066 [P] [US4] Write failing tests in `apps/api/test/exports.test.ts`: SHOPS_XLSX goes QUEUED→DONE, and its rows match the filters

### Implementation

- [ ] T067 [US4] Implement the shops module in `apps/api/src/modules/shops/` (routes, service, repository, schema, `shop.view.ts`): list, get (KPIs: total audits, products carried, audit photos, compliance), create, patch (version + status), contacts, bulk assign, bulk delete, visits (cursor, with missed visits from route stops; missed visits carry no reason), agent scoping
- [ ] T068 [US4] Implement the exports module in `apps/api/src/modules/exports/` and `apps/api/src/jobs/exports.ts` (exceljs SHOPS_XLSX → storage → presigned download)
- [ ] T069 [US4] Build Shops from Figma `3:407` (row menu) and `53:151` (selection) in `apps/admin-web/src/app/(admin)/shops/page.tsx` + `src/features/shops/{api/,copy.ts,components/ShopsTable.tsx,components/BulkBar.tsx,components/AssignAgentDialog.tsx}`:
  - `GET /v1/shops` with status filter values including Pending Review
  - Export Shops, Add Shop
  - row menu actions as in the frame
  - bulk Assign salesman / View on Map (→ `/map?ids=`) / Delete Shop, with confirmation
- [ ] T070 [US4] Build Shop details from Figma `47:7387` in `apps/admin-web/src/app/(admin)/shops/[id]/page.tsx` + `src/features/shops/components/{ShopHeader,ShopStats,ShopMiniMap,VisitHistory}.tsx`:
  - the Status toggle (PATCH status)
  - View on Map, Edit
  - stats, mini map
  - visit history with totals, photo strips and missed visits
- [ ] T071 [US4] Build the edit/add dialog from Figma `162:20071` in `apps/admin-web/src/features/shops/components/ShopEditDialog.tsx`, with exactly the frame's fields:
  - facade upload ≤ 10 MB, name *, assigned agent
  - address * + map pin + coordinates
  - contact phones with labels, add number
  - Cancel / Save (409 → reload prompt)

  It is opened from Shop details (Edit) and Shops (Add Shop)
- [ ] T072 [P] [US4] Build admin mobile Shops from Figma `246:23300` in `apps/mobile/lib/features/admin/shops/presentation/admin_shops_screen.dart` + `data/admin_shops_repository.dart`: infinite pages, total, Сортировка A-Z, search, Filters → `filter_sheet` (B3), cards with Подробнее / call / navigate, Добавить
- [ ] T073 [P] [US4] Build admin mobile Shop details from Figma `248:24538` in `apps/mobile/lib/features/admin/shop_details/presentation/admin_shop_details_screen.dart`: KPIs, address and region, agent + Связаться, photo reports (`GET /v1/photos?shopId&limit=3`), geolocation mini map + В навигаторе, audit history, Редактировать точку (→ form). If the frame has a share icon, it opens the OS share sheet with name, address and map link (B5)
- [ ] T074 [US4] Build admin mobile Add/Edit shop from Figma `252:25423` (empty) and `252:25542` (filled) in `apps/mobile/lib/features/admin/shop_form/presentation/admin_shop_form_screen.dart`:
  - exactly the frame's fields
  - Проверить заново location
  - facade via Открыть галерею (image_picker) or Сделать фото (camera)
  - Save enabled only when valid → upload + `POST/PATCH /v1/shops`

**Checkpoint**: US1 and US4 work on their own.

---

## Phase 5: User Story 3 - Agent's working day (Priority: P1)

**Independent Test**: quickstart US3.

### Tests ⚠️

- [ ] T075 [P] [US3] Write failing tests in `apps/api/test/route-generator.test.ts`:
  - only assigned, non-deleted, ACTIVE shops with `nextDueAt <= date` are selected, overdue first
  - the count is capped at `dailyVisitPlan`, and the first `dailyAuditPlan` stops are audit tasks
  - agents on Отпуск or deactivated get no route
  - nearest-neighbour + 2-opt order is never longer than the input
  - it is idempotent per (agent, date)
  - the end-of-day job marks the remaining stops MISSED
  - the re-order after DONE starts from that shop
- [ ] T076 [P] [US3] Write failing tests in `apps/api/test/routes.test.ts`: `GET /v1/routes/today` returns only the agent's own route, and `GET /v1/shops/counts` + `GET /v1/shops/map` match the route and visit states
- [ ] T077 [P] [US3] Write failing tests in `apps/mobile/test/features/shops/visit_state_test.dart` (scheduled / overdue with days / visited / not visited) and `apps/mobile/test/core/sync/pull_service_test.dart` (shops, contacts and today's route land in drift; cursors advance)

### Implementation

- [ ] T078 [US3] Implement the route generator in `apps/api/src/modules/routes/route-generator.ts` and the jobs in `apps/api/src/jobs/routes.ts`:
  - daily at `company_settings.workStart`
  - end-of-day misses at `company_settings.workEnd` (company time zone); both are re-scheduled when settings change
  - re-order after DONE

  Add CLI scripts `job:routes` and `job:end-of-day` to `apps/api/package.json`
- [ ] T079 [US3] Implement the routes module in `apps/api/src/modules/routes/` (`GET /v1/routes/today`), and `GET /v1/shops/counts` + `GET /v1/shops/map` in `apps/api/src/modules/shops/`
- [ ] T080 [US3] Implement drift-backed repositories in `apps/mobile/lib/features/shops/data/shops_local_repository.dart` and `lib/features/route/data/route_local_repository.dart`, plus `lib/features/shops/domain/visit_state.dart`
- [ ] T081 [US3] Build agent Home from Figma `83:16786` / `101:1880` in `apps/mobile/lib/features/home/presentation/agent_home_screen.dart`: avatar (sign-out menu), theme toggle, RU/EN, "Начать аудит" (opens the next route stop's audit), Мои магазины, Карта, Галерея, sync status
- [ ] T082 [US3] Build Shops from Figma `83:16884` / `101:1985` in `apps/mobile/lib/features/shops/presentation/shops_screen.dart`: title + count, Добавить, search, chips Все/Запланирован/Просрочен/Пройден with counts, the Filters button → `filter_sheet` (B3), tiles, pull-to-refresh
- [ ] T083 [US3] Build Shop details from Figma `83:17057` / `106:4035` in `apps/mobile/lib/features/shop_details/presentation/shop_details_screen.dart`: header with coordinates and distance, contact + call, last/next visit with the overdue warning, Карта (geo URI) and Аудит, audit history with violations and photos
- [ ] T084 [US3] Create the MapLibre styles matching the Figma map palette (sampled from `get_design_context` of `83:17636`, `106:5485` and `21:2`): `apps/mobile/assets/map/style-light.json`, `style-dark.json` and `apps/admin-web/public/map/style.json`. The tile source comes from env
- [ ] T085 [US3] Build the agent Map from Figma `83:17636` and `83:17775` / `106:5485` and `106:5609` in `apps/mobile/lib/features/map/presentation/agent_map_screen.dart`:
  - search, chips Все / Не посещённые / Посещённые, Filters button → `filter_sheet` (B3)
  - photo pins by state, current location, zoom and recenter
  - sheet with the shop, distance, last visit, the geofence warning and Начать Аудит (enabled only inside the radius)

**Checkpoint**: an agent sees and navigates the day offline.

---

## Phase 6: User Story 2 - Agent completes an audit, even offline (Priority: P1)

**Independent Test**: quickstart US2.

### Tests ⚠️

- [ ] T086 [P] [US2] Write failing tests in `apps/api/test/audits.test.ts`:
  - **check-start**: 422 GEOFENCE outside `auditRadiusM` (with distance), 422 GPS_ACCURACY above 50 m
  - **create**: idempotent on id. It requires 1–20 of the caller's own READY AUDIT photos with `auditId` NULL, links them in the same transaction (a photo already linked → 409), and requires a comment
  - **server computations**: distanceM, withinRadius, clockSkewFlag (> 10 min); updates the shop's lastVisitAt/nextDueAt and the stop DONE; auto-verifies photos when withinRadius and there is no skew
  - **scope**: accepted when the agent was assigned at `startedAt` even if reassigned since; another agent's shop otherwise → 404; a deactivated agent's audit recorded before deactivation is accepted within 72 h
  - **immutability**: there is no PATCH or DELETE (405), and a direct SQL UPDATE is rejected by the trigger
  - **violation**: `hasViolation` is stored and returned. `/shops/:id/visits` and `/photos/:id` expose it, so the clients render "Зафиксировано нарушение" + the comment
  - **missed visits**: appear in `/shops/:id/visits` as MISSED with no reason
- [ ] T087 [P] [US2] Write failing tests in `apps/mobile/test/features/audit/audit_controller_test.dart`:
  - the geofence and accuracy check with the cached shop
  - Finish is disabled without a photo or comment, and enabled with ≥ 1 photo and a comment
  - at most 20 photos
  - the draft is restored after a restart
  - the violation chip toggles `hasViolation`, and the comment is required either way
  - Finish enqueues PHOTO items, then AUDIT_CREATE (with `hasViolation`) with dependencies

### Implementation

- [ ] T088 [US2] Implement the audits module in `apps/api/src/modules/audits/` (routes, service, a repository with no update/delete, schema, `audit.view.ts`): check-start, create (transactional linking and the computations above), list, get
- [ ] T089 [US2] Implement the camera capture in `apps/mobile/lib/core/widgets/photo_capture.dart` (camera only; file + takenAt + GPS saved before anything else) and the draft persistence in `apps/mobile/lib/features/audit/data/audit_local_repository.dart`
- [ ] T090 [US2] Implement `apps/mobile/lib/features/audit/presentation/audit_controller.dart` (locate, geofence, photos, comment, violation chip state, finish → outbox, local stop status)
- [ ] T091 [US2] Build the Audit screen from Figma `83:17207` → `83:17285` / `106:4374` → `106:6229` in `apps/mobile/lib/features/audit/presentation/audit_screen.dart`:
  - header "Проведение Аудита" with "Офлайн-режим сохранён"
  - the location bar
  - the POSM empty state + "Сделать фото"; the photo grid with delete
  - the comment field
  - **approved exception 2**: a violation chip/toggle inside the "Section - Step 3: Global Audit Feedback & Quick Chips" section, under the textarea, labelled "Нарушение". It is styled only from existing Figma elements: the filter chip from `83:16884` for the off state, and the Error / Error bg variables plus the warning icon from "Зафиксировано нарушение" in `83:17057` for the on state, in light and dark. No other layout changes
  - "Завершить аудит" disabled and enabled
- [ ] T092 [US2] Trigger sync right after Finish and Save in `apps/mobile/lib/core/sync/sync_engine.dart`, and show "Синхронизация…" while the outbox has items, in the Home sync badge

**Checkpoint**: the P1 MVP (US1, US4, US3, US2) is complete.

---

## Phase 7: User Story 5 - Agent adds a new shop (Priority: P2)

**Independent Test**: quickstart US5.

- [ ] T093 [P] [US5] Write failing tests in `apps/api/test/shop-agent-create.test.ts`: an agent create → PENDING_REVIEW assigned to self, idempotent, facade required, `accuracyM > 50` → 422 GPS_ACCURACY; an admin PATCH status ACTIVE approves it and it appears in the agent's next pull
- [ ] T094 [US5] Extend `apps/api/src/modules/shops/shops.service.ts` for agent creation (PENDING_REVIEW, self-assignment, GPS accuracy ≤ 50 m)
- [ ] T095 [US5] Build agent Add shop from Figma `252:26487` → `252:26607` / `101:2472` → `106:5970` in `apps/mobile/lib/features/add_shop/presentation/add_shop_screen.dart` + `add_shop_controller.dart`:
  - exactly the frame's fields, with valid checks
  - Текущее местоположение + Проверить заново
  - storefront photo (camera) with Retake and delete
  - Сохранить enabled only when valid → outbox PHOTO + SHOP_CREATE
- [ ] T096 [US5] Make sure the "Pending Review" badge renders in `apps/admin-web/src/features/shops/components/ShopsTable.tsx` (matching the frame's row style), and that the Status toggle in `ShopHeader.tsx` approves it

---

## Phase 8: User Story 6 - Admin monitors agents (Priority: P2)

**Independent Test**: quickstart US6.

### Tests ⚠️

- [ ] T097 [P] [US6] Write failing tests in `apps/api/test/tracking.test.ts`:
  - pings are accepted only for ACTIVE agents within working hours (ON_LEAVE or outside hours → rejected)
  - batches of ≤ 200, `trigger` stored
  - `agent_positions` upserted
- [ ] T098 [P] [US6] Write failing tests in `apps/api/test/agent-insights.test.ts`:
  - `/agents/summary`: total staff, on route %, audits, shops visited and remaining, photos, needs contact (> 45 min without a ping while working)
  - timeline statuses and photo counts
  - the track polyline
  - date ranges (from/to and presets)
  - AGENT_REPORT_PDF/XLSX contents
- [ ] T099 [P] [US6] Write failing tests in `apps/mobile/test/core/location/tracker_test.dart`:
  - no collection off working hours, on Отпуск or signed out
  - a 2-min heartbeat and 25 m filter
  - GEOFENCE_ENTER/EXIT pings for today's stops
  - buffered and batched upload

### Implementation

- [ ] T100 [US6] Implement the tracking module in `apps/api/src/modules/tracking/` (`POST /v1/tracking/pings`, `GET /v1/agents/positions`)
- [ ] T101 [US6] Add summary, timeline and track to `apps/api/src/modules/agents/`, and the agent report generators (pdfmake, exceljs) to `apps/api/src/jobs/exports.ts`
- [ ] T102 [US6] Implement `apps/mobile/lib/core/location/tracker.dart`: geolocator foreground service gated by session + ACTIVE + working hours, geofences for today's stops, battery_plus, pings_buffer → outbox PINGS, the permission explanation screen first (A9), then the OS dialogs
- [X] T103 [US6] Build the location-permission explanation screen (approved exception A9) in `apps/mobile/lib/features/permission/presentation/permission_screen.dart`, using only existing mobile components (icon tile from `83:16786`, text styles, `primary_button.dart`), RU/EN copy. It is shown once before tracking first needs background location, then requests the OS permissions
- [ ] T104 [US6] Add the KPI cards, Дата от/до, Сегодня/Вчера/Текущая неделя, Top Performer / On Leave / Inactive badges and "Требуют связи (>45 мин)" from Figma `31:2307` to `apps/admin-web/src/app/(admin)/salesmen/page.tsx` + `src/features/agents/components/AgentsSummary.tsx`
- [ ] T105 [US6] Build Salesman details from Figma `122:7981` in `apps/admin-web/src/app/(admin)/salesmen/[id]/page.tsx` + `src/features/agents/components/{AgentHeader,AgentKpis,RouteMap,RouteTimeline,PhotoReports,AgentVisitHistory}.tsx`:
  - header and online status ("В сети (GPS активен, точность 5м)")
  - date range, Экспорт отчёта (PDF/XLS)
  - KPIs; route map (track, stops, live position with the speed/battery badge, 30 s poll)
  - timeline, photo reports, visit history with misses
- [ ] T106 [P] [US6] Build admin mobile Agents from Figma `265:27616` in `apps/mobile/lib/features/admin/agents/presentation/agents_screen.dart`: KPI tiles, search, Filters → `filter_sheet` (B3), cards with Подробнее / call / navigate, Добавить → mobile Add Salesman (A7)
- [ ] T107 [P] [US6] Build admin mobile Agent details from Figma `273:153` in `apps/mobile/lib/features/admin/agent_details/presentation/agent_details_screen.dart`: profile + call, online status, KPIs, route and tracking map, checkpoint timeline, photo reports, visit history, PDF/XLS export
- [ ] T108 [P] [US6] Build mobile admin Add Salesman (approved exception A7) in `apps/mobile/lib/features/admin/agent_form/presentation/agent_form_screen.dart`, with exactly the fields of Figma `495:3932`, built only from the existing mobile `form_field.dart` / `primary_button.dart` (the `252:25542` form style). Save with `POST /v1/agents` and show the temporary password once

---

## Phase 9: User Story 7 - Photo library and review (Priority: P2)

**Independent Test**: quickstart US7.

- [ ] T109 [P] [US7] Write failing tests in `apps/api/test/photos.test.ts`:
  - filters (type, shop, agent, region, verified, date) with a cursor and day-group counts
  - summary total and today (company time zone)
  - detail with shop, agent, comment, violation and related photos
  - an agent sees own photos only
- [ ] T110 [US7] Implement the gallery endpoints in `apps/api/src/modules/photos/` (`photos.routes.ts`, `photos.service.ts`): list, summary, detail
- [ ] T111 [US7] Build Pictures from Figma `53:1375` and `138:11987` in `apps/admin-web/src/app/(admin)/pictures/page.tsx` + `src/features/photos/components/{PhotoGrid,PhotoFilters,PhotoDetailPanel}.tsx`: summary chips, Type/Location/Status/Date filters, the mode toggles switching grid ↔ grouped-by-date (B4), infinite scroll, Verified badge, the detail panel with related photos, and the Upload CTA → a dialog (existing `ImageUpload` + the shop select from `162:20071`) uploading `ADMIN_UPLOAD` photos to the chosen shop (B1)
- [ ] T112 [P] [US7] Build the agent Gallery and Photo detail from Figma `83:17954` and `83:18045` / `106:6558` and `106:6710` in `apps/mobile/lib/features/gallery/presentation/{gallery_screen,photo_detail_screen}.dart`, with the Параметры фильтрации button → `filter_sheet` (B3)
- [ ] T113 [P] [US7] Build the admin mobile Gallery and Photo detail from Figma `248:24311` and `248:24402` in `apps/mobile/lib/features/admin/gallery/presentation/{admin_gallery_screen,admin_photo_detail_screen}.dart`, with the Параметры фильтрации button → `filter_sheet` (B3)

---

## Phase 10: User Story 8 - Products and assortment (Priority: P3)

**Independent Test**: quickstart US8.

- [ ] T114 [P] [US8] Write failing tests in `apps/api/test/products.test.ts`:
  - create validation: SKU unique; name, category and price required; image PNG/JPG ≤ 5 MB
  - list filters and pagination
  - after `PUT /v1/shops/:id/products`, locations, coverage %, regions and last activity are correct
  - compliance = completed audits without a violation ÷ completed audits
  - Shop details "products carried" count
  - PRODUCTS_XLSX export
  - agents get 403
- [ ] T115 [US8] Implement the products module in `apps/api/src/modules/products/` (routes, service, repository, schema): CRUD, categories, summary, distribution and compliance. Add `PUT /v1/shops/:id/products` to the shops module, and PRODUCTS_XLSX to `apps/api/src/jobs/exports.ts`
- [ ] T116 [US8] Build Products from Figma `30:574` in `apps/admin-web/src/app/(admin)/products/page.tsx` + `src/features/products/components/{ProductsSummary,ProductsTable}.tsx` (KPIs, search and filters, applied chips, table with coverage bars, Export Catalog, Add Product)
- [ ] T117 [US8] Build Add Product from Figma `495:2311` in `apps/admin-web/src/app/(admin)/products/new/page.tsx`, `products/[id]/page.tsx` + `src/features/products/components/ProductForm.tsx`, with exactly the frame's fields
- [ ] T118 [US8] Add the "Products carried" multi-select (approved exception A11) to `apps/admin-web/src/features/shops/components/ShopEditDialog.tsx`, built from the dialog's existing select field styles (`162:20071`), saved with `PUT /v1/shops/:id/products`
- [ ] T119 [P] [US8] Build mobile admin Products (approved exception A7) in `apps/mobile/lib/features/admin/products/presentation/{products_screen,product_form_screen}.dart`: a list from `GET /v1/products` styled from the `246:23300` cards, and an add form with exactly the fields of Figma `495:2311`, built from existing mobile form components (`POST /v1/uploads` PRODUCT → `POST /v1/products`)

---

## Phase 11: User Story 9 - Map overview (Priority: P3)

**Independent Test**: quickstart US9.

- [ ] T120 [US9] Build the admin web Map from Figma `21:2` and `3:2` in `apps/admin-web/src/app/(admin)/map/page.tsx` + `src/features/map/components/{AdminMap,ShopCard,MapFilters,FilterBanner}.tsx`:
  - clustered shops (`GET /v1/shops/map`), agent positions (30 s)
  - search, the filters panel (salesmen + region zones, Apply/Clear)
  - the "Filtered view" banner
  - the shop card with visit history
  - zoom and recenter; Layers (Figma style ↔ satellite), Fullscreen (browser API) and Refresh (reload markers and positions) (B2); supports `?ids=` from the Shops bulk "View on Map"
- [ ] T121 [P] [US9] Build the admin mobile Map from Figma `248:23963` and `248:24102` in `apps/mobile/lib/features/admin/map/presentation/admin_map_screen.dart` (chips, Filters → `filter_sheet` (B3), markers, agent positions, sheet + Подробнее)
- [X] T122 [P] [US9] Build admin mobile Home from Figma `246:23129` in `apps/mobile/lib/features/admin/home/presentation/admin_home_screen.dart` (Карта, Магазины, Галерея, Агенты, Продукции → mobile Products (A7); theme toggle; RU/EN; avatar sign-out)
- [ ] T123 [P] [US9] Write failing tests in `apps/api/test/feed.test.ts`: `GET /v1/feed` lists violations and missed visits newest first with a cursor, `unreadCount` counts items newer than `feedSeenAt`, `POST /v1/feed/seen` resets it, admins only
- [ ] T124 [US9] Implement the feed module in `apps/api/src/modules/feed/` (routes, service, repository querying audits with `hasViolation` and MISSED route stops)
- [ ] T125 [US9] Build the bell activity feed (approved exception A6) in `apps/admin-web/src/components/layout/FeedPanel.tsx`: the existing `SidePanel` + `VisitHistoryItem` cards, the unread dot on the Figma bell (poll 30 s), opening calls `POST /v1/feed/seen`, items link to the shop or agent. Mount it in `Topbar.tsx`

---

## Phase 12: Polish & Cross-Cutting Concerns

- [ ] T126 Build the Settings page (approved exception A4) in `apps/admin-web/src/app/(admin)/settings/page.tsx` + `src/features/settings/`, built only from existing web components (PageHeader, FormField, ImageUpload, DataTable, Button from `495:3932` / `162:20071` / `3:407`): company name and logo, working hours and time zone, visit frequency, audit radius, GPS accuracy, no-signal threshold, regions CRUD
- [ ] T127 Implement the retention job in `apps/api/src/jobs/retention.ts` (nightly; purge pings and exports older than `RETENTION_YEARS`), with a test in `apps/api/test/retention.test.ts`
- [ ] T128 Run the design pass on all 46 frames in `contracts/figma-frames.md` (web 1440; mobile 390, light and dark), comparing each with `get_screenshot`. Review every approved-exception screen (sign-in, chip, Settings, feed, mobile Add Salesman and Products, permission, multi-select, upload dialog, filter sheets) for consistency with the existing components. Fix differences and record the results in `specs/002-retail-audit-platform/quickstart.md`
- [ ] T129 [P] Run the performance pass: `apps/api/prisma/seed-load.ts` (10k shops, 100k photos) and a `bench` script for SC-005, adding indexes in a new migration if needed. Measure SC-008 with `flutter run --profile --trace-startup` and record it in quickstart.md
- [ ] T130 [P] Run the security pass: `apps/api/test/scoping.test.ts` covering every agent-reachable endpoint (SC-007); CORS limited to `WEB_ORIGIN`; cookie flags; presigned expiry; secrets only in env
- [ ] T131 [P] Add the offline reliability test `apps/api/test/offline-soak.test.ts`: 100 queued audits with retries and duplicates sent out of order → exactly 100 audits, zero lost photos (SC-002). Script: `test:offline-soak`
- [ ] T132 Run all of quickstart.md (scenarios, reliability, design, `docker compose --profile prod up -d`, `flutter build appbundle`). Time an audit flow under 2 minutes (SC-001) and check that a synced audit appears for admins within 1 minute (SC-003). Fix the gaps and confirm CI is green
- [ ] T133 Update `README.md` with the production deploy, env per app, PostgreSQL/SeaweedFS backups, the operator CLIs and the mobile release steps

---

## Dependencies & Execution Order

- **Setup** comes first. T002 runs after T001, and T004–T006 after T002.
- **Foundational** blocks all stories. The schema (T019–T023) comes first. These pairs are
  test-first: T030→T031, T032→T033, T036→T037→T038, T039→T040, T043→T044, T051→T052.
- **US1**, then **US4**, then **US3** (routes need assigned shops), then **US2** (audits start
  from local shops and stops).
- **US5** runs after US4. **US6** runs after US1, with richer data after US2 and US3. **US7**
  runs after US2. **US8** and **US9** run after US4.
- **Polish** comes last.

## Parallel Opportunities

- **Setup**: T004/T005/T006; T008/T009; T012/T013/T014/T015/T017.
- **Foundational**: T025–T029; T039→T040; the web track (T042–T047) and the mobile track
  (T048–T055) run in parallel with the API once the schema exists.
- **Within a story**: all its [P] test tasks together; then the web and mobile screens in
  parallel once its API is done.
- **After US4**: US5, US6, US8 and US9 can run in parallel.

## Parallel Example: User Story 4

```bash
Task: "Shops API tests in apps/api/test/shops.test.ts"
Task: "Exports tests in apps/api/test/exports.test.ts"
# after T067/T068:
Task: "Admin mobile Shops from Figma 246:23300"
Task: "Admin mobile Shop details from Figma 248:24538"
```

## Implementation Strategy

1. **MVP**: Setup → Foundational → US1 → US4 → US3 → US2. Validate quickstart US1–US4, then
   pilot.
2. **P2**: US5 → US6 → US7.
3. **P3**: US8 → US9.
4. **Polish**: retention, the 46-frame design pass, performance, security, offline soak, deploy.

## Notes

- Never modify Figma, and never add UI beyond the frames (the sign-in exception excepted).
- Never hard-code user content. Every value comes from the API or local store.
- Audits and READY audit photos never get an update or delete path beyond the trigger-allowed
  fields.
