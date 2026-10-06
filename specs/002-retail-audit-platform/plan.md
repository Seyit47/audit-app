# Implementation Plan: Retail Audit Platform (Production Release)

**Branch**: `002-retail-audit-platform` | **Date**: 2026-10-06 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-retail-audit-platform/spec.md` (Figma-only scope)

## Summary

The production platform, derived entirely from the Figma file `9s5b56r9zs1s0Ty2UgvL0W`. Its
46 frames define the screens, fields and data. The only non-Figma UI is the two approved
exceptions: the minimal sign-in screens and the audit violation chip.

The parts:
- a **Fastify + Prisma + PostgreSQL** API with S3-compatible photo storage and pg-boss jobs
- a **Next.js** admin web
- one **Flutter** app with offline-first Agent screens (light and dark) and online Admin screens

The data model ([data-model.md](./data-model.md)) holds exactly what the frames show. The API
([contracts/api.md](./contracts/api.md)) serves exactly what the screens need
([contracts/screens.md](./contracts/screens.md)). Behaviors Figma shows without input UI
(approval, misses, frequency, verification, settings) are resolved through existing controls,
automatic rules, or user-approved exceptions (spec "Figma Gaps and Resolutions").

## Technical Context

**Language/Version**: TypeScript (Node 24) for the API and admin web; Dart 3 / Flutter 3.47 for
mobile

**Primary Dependencies**:
- **API** (Fastify TS/ESM starter): Prisma, @fastify/jwt, @fastify/rate-limit, @fastify/swagger,
  TypeBox, argon2, AWS SDK v3 (S3), sharp, pg-boss, exceljs, pdfmake
- **Admin web** (create-next-app): Tailwind, react-map-gl + maplibre-gl, openapi-typescript,
  Vitest
- **Mobile** (flutter create): flutter_riverpod, go_router, gen-l10n, drift, dio,
  flutter_secure_storage, device_info_plus, geolocator, battery_plus, connectivity_plus,
  workmanager, camera, image_picker (admin facade "Открыть галерею" only), maplibre_gl,
  url_launcher, flutter_svg

**Storage**: PostgreSQL (data + job queue); S3-compatible object storage (originals + previews);
drift/SQLite on agent devices

**Testing**:
- **API**: the starter's runner with `app.inject` against real PostgreSQL and SeaweedFS
- **Mobile**: `flutter test`
- **Web**: Vitest for server actions and the session
- **Screens**: compared against Figma `get_screenshot`

**Target Platform**: Linux server (Docker); desktop browsers (1440 reference); Android phones and
tablets (390 reference), with iOS buildable

**Project Type**: monorepo (web service + web app + mobile app)

**Performance Goals**: SC-003 (audit visible < 1 min), SC-004 (position ≤ 2 min), SC-005 (lists
< 2 s, search < 1 s at 10k shops / 100k photos), SC-008 (cold start < 2 s)

**Constraints**:
- Figma-only scope
- offline agent flow with no loss or duplicates
- immutable audits and photos
- server-side agent scoping
- location only while working

**Scale/Scope**: one company; about 100 agents, 10k shops, 100k photos per year. 46 Figma frames
(13 admin web, 22 agent across light and dark, 11 admin mobile) plus 2 sign-in screens. About 40
endpoints.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Compliance | Result |
|-----------|-----------|--------|
| I. Pixel-Perfect (Figma only) | Every screen is a Figma frame ([screens.md](./contracts/screens.md)). Values come from `get_design_context`, and the themes mirror the Figma variables. Icons, logo and markers are exported as SVG from Figma (no icon font). Each frame is checked against `get_screenshot`. Figma is never modified. The sign-in screens and the violation chip are approved exceptions under the v2.3.0 clause (Complexity Tracking) | PASS |
| II. Clean Architecture | API: routes → services → repositories, wired in `app.ts`. Web: `features/*`. Mobile: `features/*/{data,domain,presentation}`, with agent features reading drift | PASS |
| III. Clean, Reusable Code | Shared components per client, derived from repeated Figma elements. One upload flow, one error shape, one pagination | PASS |
| IV. Simplicity First | Official starters. Every dependency maps to a requirement. No Redis, no sockets, no push notifications. Company settings live in the database (A4) and the feed is derived by query (A6) | PASS |
| V. Test-First | Tests first for every rule in research R-17 | PASS |
| VI. Offline-First | drift + outbox + client UUIDs, photos saved first, auto sync ([sync.md](./contracts/sync.md)) | PASS |
| VII. Evidence Integrity | No update or delete path for audits. A trigger guards audits and READY audit photos (only allowed fields change). Server-computed GPS checks and clock-skew flag. Originals stored unaltered with sha256 | PASS |
| VIII. Security & Roles | Server scoping (with assignment history), short-lived JWT + rotating refresh with idle expiry, secure storage and httpOnly cookies, device binding, private bucket, wipe on sign-out | PASS |
| Stack & gates | Fastify/Prisma/PostgreSQL, Next.js, one Flutter app. CI runs lint, types, tests and migration status | PASS |

### Justified additions beyond the starters (Principle IV)

| Addition | Requirement |
|----------|-------------|
| `docker-compose.yml`, `apps/api/Dockerfile`, `apps/admin-web/Dockerfile` | Production deploy; local PostgreSQL + SeaweedFS |
| pg-boss | Daily routes, end-of-day misses, re-ordering, previews, exports, retention |
| AWS SDK S3 + sharp | Photo originals + previews (FR-015, FR-025) |
| exceljs + pdfmake | Export Shops, Export Catalog, Экспорт отчёта (PDF/XLS) |
| openapi-typescript | Web types generated from the API |
| MapLibre (web + Flutter) | Real maps styled to the Figma palette |
| drift, workmanager, connectivity_plus | Offline agent app (FR-014) |
| geolocator, battery_plus | Tracking (FR-017) |
| device_info_plus, flutter_secure_storage | Device binding (FR-002a), token storage |
| camera / image_picker | In-app audit capture (FR-012) / admin facade "Открыть галерею" (`252:25423`) |
| flutter_svg | Figma-exported SVG icons |
| share_plus | OS share sheet for the shop share icon (B5), only if present in `248:24538` |

**Post-design re-check**: PASS.

## Project Structure

### Documentation (this feature)

```text
specs/002-retail-audit-platform/
├── spec.md                  # Figma-only scope, gaps and resolutions
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── figma-frames.md      # 46 frames: node IDs, states, variables
│   ├── screens.md           # frame → route → data → actions
│   ├── api.md               # /v1 endpoints
│   └── sync.md              # mobile outbox and pull
├── checklists/requirements.md
└── tasks.md
```

### Source Code (repository root)

```text
package.json  pnpm-workspace.yaml  pnpm-lock.yaml  .gitignore  README.md
docker-compose.yml  .github/workflows/ci.yml

apps/api/                    # fastify generate --lang=ts --esm (starter layout kept)
├── Dockerfile
├── prisma/{schema.prisma, migrations/, seed.ts}
├── scripts/admin.ts         # operator CLI: create / reset admin (A5)
└── src/
    ├── app.ts               # composition root
    ├── plugins/             # env, prisma, auth, storage, jobs, errors, swagger
    ├── modules/
    │   ├── auth/  settings/  regions/  agents/  shops/  routes/  audits/  photos/
    │   ├── products/  tracking/  feed/  exports/
    │   └── each: *.routes.ts, *.service.ts, *.repository.ts, *.schema.ts
    ├── jobs/                # routes (daily, end-of-day, re-order), previews, exports, retention
    └── lib/                 # geo, time, pagination, ids
    test/

apps/admin-web/              # create-next-app (starter layout kept)
├── Dockerfile
├── public/icons/  public/map/style.json
└── src/
    ├── app/login/                    # approved exception
    ├── app/(admin)/{map, shops, shops/[id], products, products/new, products/[id],
    │                salesmen, salesmen/new, salesmen/[id], salesmen/[id]/edit, pictures, settings}
    ├── components/layout/            # Sidebar, Topbar (from the Figma header)
    ├── components/ui/                # shared components derived from the frames
    ├── features/<domain>/            # components/, hooks/, api/ (typed calls + server actions), copy.ts
    └── lib/                          # api (generated types), session, upload

apps/mobile/                 # flutter create (starter layout kept)
├── env/{dev,prod}.json
├── assets/{fonts,icons,map}/
└── lib/
    ├── main.dart  app.dart
    ├── core/{theme, l10n, router, network, db, sync, location, auth, widgets}
    └── features/
        ├── auth/  home/  shops/  shop_details/  audit/  add_shop/  map/  gallery/
        ├── permission/                   # A9
        └── admin/{home, shops, shop_details, shop_form, map, gallery, agents, agent_details,
                   agent_form, products}      # agent_form + products: A7
```

**Structure Decision**: three apps under `apps/` in their starter layouts, with domain modules
mirrored across them. Audits have no correction mechanism in this release (no Figma UI), so they
remain fully immutable (Constitution VII). **Naming**: the UI says "Salesman/Salesmen" (web Figma) and "Агент"
(mobile Figma), while code and API use `agent`. Both refer to the same entity.

## Complexity Tracking

| Deviation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Sign-in screens (web + mobile) are not in Figma (Constitution I, approved exception) | Production requires authentication and agent scoping. **The user explicitly approved** building a minimal sign-in from existing Figma components only | Device-activation links without a sign-in screen still leave admins without a way in. Adding frames to Figma is not allowed |
| Approved gap resolutions with new UI (A4 Settings page, A6 activity feed, A7 mobile Add Salesman and Products, A9 permission screen, A11 products multi-select, B1–B5 control behaviors) | Each was presented under the Figma gap protocol and **explicitly approved by the user on 2026-10-06** (spec gaps table) | Leaving them out would leave Figma-visible controls without behavior, or block production needs |
| Violation chip/toggle on the audit screen is not in Figma (Constitution I, approved exception) | Figma displays "Зафиксировано нарушение" on audits but has no control to record it. **The user explicitly approved** a chip in the comment section (the "Quick Chips" layer), styled from existing chips and error colors | Detecting violations from comment wording is unreliable. Dropping violations would leave a designed state unimplemented |

## Delivery Phases (input for /speckit-tasks)

1. **Reset and scaffold**: remove the 001 code and the PNG/CSS files. Create the official
   starters, docker-compose, CI, the themes from the Figma variables and the Figma SVG exports.
2. **Platform**: schema + triggers, plugins, uploads and previews, shared UI from the frames,
   mobile core (drift, sync, router).
3. **US1** sign-in, agents and device binding → **US4** shops → **US3** routes and the agent's
   day → **US2** audit (P1 MVP).
4. **US5** agent add-shop → **US6** monitoring and tracking → **US7** photos (P2).
5. **US8** products → **US9** map (P3).
6. **Polish**: retention, the design pass over all 46 frames, performance, security and the
   offline reliability run, deploy.
