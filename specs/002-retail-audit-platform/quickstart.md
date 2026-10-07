# Quickstart & Validation: Retail Audit Platform

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md)

## Prerequisites

- Node 24 + pnpm, Flutter stable (3.47+), Docker, an Android phone or emulator with `adb`.
- Env files: `apps/api/.env` (from `.env.example`), `apps/admin-web/.env.local`, and
  `apps/mobile/env/dev.json`.

## 1. Run locally

```bash
docker compose up -d postgres seaweedfs
pnpm install
pnpm --filter api prisma migrate deploy && pnpm --filter api prisma db seed   # regions, categories
pnpm --filter api admin:create --email admin@company.tm --password '…'       # operator CLI
pnpm --filter api dev            # API + jobs on :3000, docs at /docs
pnpm --filter admin-web dev      # :3001
adb reverse tcp:3000 tcp:3000
cd apps/mobile && flutter run --dart-define-from-file=env/dev.json
```

## 2. End-to-end scenarios

| # | Scenario | Expected |
|---|----------|----------|
| US1 | The admin signs in on the web. Add Salesman creates "Довлет Оразов" (region, plans 25/20). The agent signs in on the phone | The agent lands on Home and the device is bound. A second phone gets `DEVICE_NOT_BOUND`. The agent is refused on the web. After 12 h idle, the web asks to sign in again |
| US4 | Add 3 shops via the dialog (facade, 2 contacts), assign them, edit one in two tabs, bulk-assign, Export Shops, Delete Shop | The changes appear on the phone after sync. The second save → reload prompt. The export XLSX matches. Deleted shops' audits are still in the gallery |
| US3 | `pnpm --filter api job:routes --date today` | The agent's Shops chips and map reflect the route, and the overdue shop shows "просрочен на N дн." At the end of working hours (`job:end-of-day`), unvisited stops show "Пропущен" |
| US2 | In airplane mode, start an audit 30 m from a shop, take 3 photos, write a comment with the violation chip on, finish, then reconnect | "Офлайн-режим сохранён", then synced within 5 min. The admin sees the visit, 3 photos, within-radius, the violation highlighted. Photos are auto-verified. At 300 m the audit is blocked |
| US5 | The agent adds a shop offline with a photo, then syncs | The admin Shops list shows Pending Review. The Status toggle on activates it, and the agent then sees it as Active |
| US6 | The agent walks between two shops during working hours | Salesman details shows the position ≤ 2 min old (accuracy, speed, battery) and the timeline. With pings stopped for 45 min, the agent is counted in "Требуют связи". Экспорт отчёта → PDF/XLS. An agent on "Отпуск" is not tracked |
| US7 | Pictures | Today's photos are grouped, filters work, and the detail panel shows related photos. The agent gallery shows only own photos |
| US8 | Add Product, then select it for 2 shops in the shop edit dialog | Locations, coverage and regions are correct. "Products carried" on Shop details is correct. Export Catalog works |
| US9 | Map filters: 1 salesman, 1 region; Layers, Fullscreen, Refresh | The banner counts, markers and clusters match. The shop card shows visit history. Layers switches to satellite |
| Gaps | Settings: change working hours and radius. Bell: a new violation appears in the feed with the unread dot. Pictures: upload a photo to a shop, toggle the view mode. Mobile: Filters sheets, admin Add Salesman and Products, permission screen | Each works as described in the spec gaps table |

## 3. Reliability, security, performance

```bash
pnpm --filter api test                       # scoping (SC-007) and offline soak (SC-002) suites
# SC-005: on an empty, migrated database (never the dev one):
DATABASE_URL=postgresql://…/audit_load pnpm --filter api seed:load
DATABASE_URL=postgresql://…/audit_load pnpm --filter api bench
cd apps/mobile && flutter run --profile --trace-startup   # SC-008 (< 2 s)
```

Recorded 2026-10-07 (10,000 shops, 100 agents, 30,000 audits, 100,000 photos; dev laptop, local
PostgreSQL 16): every list's first page has a median under 90 ms. The slowest were `/shops/map`
(84 ms) and the grouped gallery `/photos?groups=true` (65 ms, after moving the day counts into
SQL; it took 6 s when counted in the API). No extra indexes were needed. SC-008 still has to be
measured on a mid-range Android device.

## 4. Design check (Constitution I)

For each of the 46 frames in [contracts/figma-frames.md](./contracts/figma-frames.md), capture
the app at the frame size (web 1440; mobile 390, light and dark for agent screens) and compare
it with `get_screenshot` of the node. Any difference is a defect.

## 5. Production

```bash
docker compose --profile prod up -d
flutter build appbundle --dart-define-from-file=env/prod.json
```

**Expected**: `/health` is ok, the admin web is served over HTTPS behind the reverse proxy, and
the app points to the production API.

## Validation log (2026-10-07)

- **Tests**: API 78/78 (scoping, offline soak, uploads, routes, audits…), mobile 32/32, admin web
  build passes. API `build:ts` and the compiled server start (`/health` ok, login ok).
- **Web**: every admin page was driven in Chrome (sign-in, salesmen, salesman details, shops, map
  with filters and shop card, pictures upload, products, settings, bell feed) and compared with its
  Figma frame.
- **Mobile**: screens rendered at 390 px light/dark with `test_screens` and compared with the
  frames. The debug APK ran on an Android 15 emulator: agent sign-in → location screen → Home →
  Shops → Shop details → Audit (geofence inside the radius, camera photo, comment) → Finish while
  the sync was failing, then both queued audits reached the server with their photos; agent Map
  with tiles, pins and the shop sheet; admin Home and Gallery. This run found and fixed the
  empty-JSON upload 500 and the pin size.
- **Open**: `docker compose --profile prod` (Docker isn't installed on the dev machine),
  `flutter build appbundle` with the release keystore, SC-001 (audit < 2 min) and SC-008
  (cold start < 2 s) timed on a mid-range phone, and replacing the 41 approximated icons listed
  in `design/figma/pending-icons.txt` with exact Figma exports once the Figma API limit resets.
