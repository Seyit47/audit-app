# Contract: HTTP API v1

The base path is `/v1`, JSON, and `Authorization: Bearer <access token>`. OpenAPI is generated
at `/docs` from the TypeBox route schemas, and the admin web's types are generated from it.
Every endpoint exists because a Figma frame needs its data or action
([screens.md](./screens.md)).

**Roles**: **A** = admin, **G** = agent (scoped to own data), **·** = public.

**Errors**: `{ error: { code, message, details? }, requestId }`. Codes:

| Code | HTTP | Meaning |
|------|------|---------|
| `VALIDATION_FAILED` | 400 | |
| `UNAUTHENTICATED` | 401 | |
| `FORBIDDEN` | 403 | |
| `DEVICE_NOT_BOUND` | 403 | |
| `NOT_FOUND` | 404 | also returned for out-of-scope agent access |
| `CONFLICT` | 409 | stale version |
| `GEOFENCE` | 422 | |
| `GPS_ACCURACY` | 422 | |
| `RATE_LIMITED` | 429 | |

**Lists**:
- `?page=&size=` returns `{ items, total, page, size }`, for tables with page numbers (Shops,
  Products, Salesmen).
- `?cursor=&limit=` returns `{ items, nextCursor }`, for photo streams and histories.

**Image object**: `{ id, url, previewUrl400, previewUrl1200, width, height, takenAt }`, with
presigned URLs valid for 10 min.

## Auth (the approved sign-in exception)

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| POST | `/auth/login` | · | `{ login, password, device? {installId, model} }` → `{ accessToken, refreshToken, user }`. Agents must send `device`. The first login binds it; otherwise it must match (403 `DEVICE_NOT_BOUND`). Rate-limited |
| POST | `/auth/refresh` | · | Rotate. Fails after the idle limit (web 12 h, mobile 30 days, by `lastUsedAt`) |
| POST | `/auth/logout` | A G | Revoke |
| GET | `/me` | A G | User, role, agent profile, and the settings subset the app needs (company name and logo, radius, accuracy, working hours, time zone) |

**Deactivated agents**: new logins fail. For 72 h after deactivation the existing session may
still refresh, but only outbox submissions (`POST /audits`, `/uploads*`, `/shops`,
`/tracking/pings`) whose recorded time is before `deactivatedAt` are accepted; everything else
returns 401. After 72 h refresh and submissions return 401. (Decided 2026-10-07: with 15-min
access tokens, refusing refresh would shrink the grace period to 15 min.)

## Settings and regions (Settings page, approved exception A4)

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| GET | `/settings` | A | All company settings |
| PATCH | `/settings` | A | Update the company name, logo, working hours, time zone, visit frequency, radius, accuracy and no-signal threshold |
| GET | `/regions` | A G | For filters and the "Регион *" select |
| POST / PATCH / DELETE | `/regions[/:id]` | A | Manage regions on Settings. Deleting is blocked while the region is in use |

## Activity feed (bell, approved exception A6)

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| GET | `/feed` | A | Cursor list of `{type: VIOLATION \| MISSED_VISIT, at, shop, agent, comment?, photos?}`, with `unreadCount` (items newer than `feedSeenAt`) |
| POST | `/feed/seen` | A | Set `feedSeenAt = now` |

## Agents (Salesmen)

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| GET | `/agents` | A | Page list. Filters: `q, status, regionId, from, to`. Row: `code, fullName, phone, photo, region, locations, visits, photos, lastActivityAt, workStatus, onRoute, needsContact, topPerformer, active` (`31:2307`) |
| GET | `/agents/summary` | A | KPIs for `from`/`to`: total staff, on route (% of pool), audits completed, shops visited/planned (remaining), photos uploaded, needs contact (`31:2307`, `265:27616`) |
| POST | `/agents` | A | Add Salesman (`495:3932`). Returns the code and a temporary password |
| GET | `/agents/:id` | A | Profile, device, live position (accuracy, speed, battery), KPIs for the period |
| PATCH | `/agents/:id` | A | Edit, including `workStatus` (Активен/Отпуск) and `active` (deactivate/reactivate). Uses `version` |
| PUT | `/agents/:id/device` | A | Rebind (clears the binding), and set `imeiLabel` |
| POST | `/agents/:id/reset-password` | A | Returns a temporary password |
| GET | `/agents/:id/timeline?date=` | A | Checkpoints (time, shop, photo count, status) |
| GET | `/agents/:id/track?date=` | A | Polyline of pings |
| GET | `/agents/positions` | A | Latest position of working agents (map, polled every 30 s) |

## Shops

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| GET | `/shops` | A G | **A**: page list with filters `q, status, regionId, agentId, sort` (`3:407`, `246:23300`). **G**: own shops, `?updatedAfter=` for sync (with tombstones) |
| GET | `/shops/counts` | G | Chip counts: all, scheduled, overdue, visited (`83:16884`) |
| GET | `/shops/map` | A G | Markers `[{id, lat, lng, status, visitState, thumbUrl, agentId}]`, with filters `agentIds[], regionIds[]` (`21:2`, `83:17636`) |
| GET | `/shops/:id` | A G | Details and KPIs: total audits, products carried, audit photos, compliance, contacts, agent, last and next visit |
| POST | `/shops` | A G | **A** → ACTIVE (`252:25542`, `162:20071`). **G** → PENDING_REVIEW assigned to self (`252:26607`), requires `accuracyM ≤ 50` (else 422 `GPS_ACCURACY`). Idempotent on the client id |
| PATCH | `/shops/:id` | A | Edit dialog fields + `status` (the toggle). Uses `version` → 409 if stale |
| PUT | `/shops/:id/contacts` | A | Up to 5 `{phone, label}` |
| PUT | `/shops/:id/products` | A | Products carried (multi-select in the edit dialog, A11) |
| POST | `/shops/bulk/assign` | A | `{shopIds[], agentId}` (`53:151`) |
| POST | `/shops/bulk/delete` | A | `{shopIds[]}` → soft delete (`53:151`, row menu) |
| GET | `/shops/:id/visits` | A G | Visit history with totals: all, completed, missed (`47:7387`, `83:17057`, `248:24538`) |

## Routes

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| GET | `/routes/today` | G | Own route with stops (synced) |

Generation, the end-of-day misses and the re-ordering after each visit run as server jobs.
There are no manual route-edit endpoints, because Figma has no route-edit UI.

## Audits

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| POST | `/audits/check-start` | G | `{shopId, lat, lng, accuracyM}` → ok, or 422 `GEOFENCE` / `GPS_ACCURACY`. Also checked offline on the device |
| POST | `/audits` | G | Idempotent on the client id: `{id, shopId, routeStopId?, startedAt, finishedAt, lat, lng, accuracyM, comment, hasViolation, photoIds[1..20]}`. The photos must be the caller's own `READY` AUDIT uploads with `auditId` NULL. In one transaction the server inserts the audit, links the photos, computes distance and within-radius, sets skew, updates the shop and stop, and auto-verifies photos. Scope: the agent must have been assigned the shop at `startedAt` (`shop_assignments`) |
| GET | `/audits` | A G | Filters: `shopId, agentId, from, to, hasViolation`, cursor |
| GET | `/audits/:id` | A G | Audit with photos |

There is no PATCH or DELETE (405).

## Uploads and photos

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| POST | `/uploads` | A G | `{id, kind (AUDIT\|FACADE\|PRODUCT\|AVATAR\|LOGO\|ADMIN_UPLOAD), mime, sizeBytes, sha256, takenAt, lat?, lng?, accuracyM?, shopId?}` → `{uploadUrl, headers, expiresAt}`. `ADMIN_UPLOAD` (Pictures upload, B1) requires `shopId` and is admin only. Idempotent. **No `auditId`**: audit photos are linked by `POST /audits` |
| POST | `/uploads/:id/complete` | A G | Check the object's size, type and sha256 → READY, and queue previews |
| GET | `/photos` | A G | Filters: `type, shopId, agentId, regionId, verified, from, to`, cursor, with day-group counts. **G**: own audit photos only |
| GET | `/photos/summary` | A G | `{total, today}` ("1,240 Total Photos", "+48 Today", "142 фото") |
| GET | `/photos/:id` | A G | Shop, agent, audit comment and violation, related photos of the same audit |

## Products

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| GET | `/products` | A | Page list. Filters: `q, status, regionId, date`. Rows include locations, coverage %, regions, last activity, status (`30:574`) |
| GET | `/products/summary` | A | Total products (active/inactive), distribution reach, avg outlets per SKU, audited compliance |
| GET | `/product-categories` | A | Category select |
| POST | `/products` | A | Add Product (`495:2311`) |
| PATCH | `/products/:id` | A | Edit |

## Tracking

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| POST | `/tracking/pings` | G | Up to 200 per batch: `{recordedAt, lat, lng, accuracyM, speedKmh?, batteryPct?, trigger}`. Accepted only for an ACTIVE agent within working hours (`ON_LEAVE` is rejected) |

## Exports

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| POST | `/exports` | A | `{type: SHOPS_XLSX \| PRODUCTS_XLSX \| AGENT_REPORT_PDF \| AGENT_REPORT_XLSX, params}` |
| GET | `/exports/:id` | A | Status, and `downloadUrl` when DONE |

## Health

| Method | Path | Role | Purpose |
|--------|------|------|---------|
| GET | `/health` | · | `{status, db, storage}` |
