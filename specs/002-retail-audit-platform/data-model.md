# Data Model: Retail Audit Platform

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-06

This is the PostgreSQL schema, managed by Prisma migrations. Every field exists because a Figma
frame shows it, or because a rule in the spec needs it. Conventions:
- IDs are UUID v7. Mobile-created records use client-generated UUIDs (idempotent sync).
- All times are UTC `timestamptz`.
- `createdAt` and `updatedAt` are on mutable tables, and `updatedAt` drives the mobile pull.
- Money is stored as integer minor units.

**Server configuration** (env): retention (3 years), currency, infrastructure.

### company_settings (single row, edited on the Settings page, approved exception A4)
`companyName` ("COMPANY NAME"), `logoPhotoId`, `workStart` (08:00), `workEnd` (19:00),
`timezone` (Asia/Ashgabat), `visitFrequencyDays` (7), `defaultAuditRadiusM` (100),
`minGpsAccuracyM` (50), `noSignalMinutes` (45), `updatedAt`, `updatedById`.

## Accounts

### users
| Column | Type | Rules |
|--------|------|-------|
| id | uuid PK | |
| role | enum `ADMIN`, `AGENT` | |
| email | text unique null | required for ADMIN |
| phone | text unique null | required for AGENT, E.164 |
| passwordHash | text | argon2id |
| status | enum `ACTIVE`, `DEACTIVATED` | |
| deactivatedAt | timestamptz null | queued agent data recorded before this is accepted for 72 h |
| lastActiveAt | timestamptz | drives idle expiry (web 12 h, mobile 30 days) |
| feedSeenAt | timestamptz null | admins: last time the bell feed was opened (unread dot, A6) |

Admins are created and reset with the operator CLI (`pnpm --filter api admin:create`).

### refresh_tokens
`id`, `userId`, `tokenHash`, `deviceId null`, `expiresAt`, `revokedAt null`, `lastUsedAt`.

### agents (Add Salesman `495:3932`)
| Column | Type | Rules |
|--------|------|-------|
| userId | uuid PK → users | |
| code | text unique | `SL-` + sequence, auto |
| fullName | text | required ("ФИО сотрудника *") |
| phone | text | required ("Контактный телефон *"), same as users.phone |
| whatsappPhone | text null | "Дополнительный телефон / WhatsApp" |
| photoId | uuid null → photos | avatar in tables and details |
| regionId | uuid → regions | required ("Регион / Территория продаж *") |
| routeNotes | text null | "Примечания / График маршрута" |
| dailyVisitPlan | int | default 25, 1–100 ("Дневной план визитов (ТТ)") |
| dailyAuditPlan | int | default 20, ≤ dailyVisitPlan ("План чек-листов / аудитов в день") |
| workStatus | enum `ACTIVE`, `ON_LEAVE` | "Статус активности сотрудника": Активен / Отпуск |

**Derived, not stored** (Salesmen `31:2307`, details `122:7981`):
- *On route*: working hours and a ping within 45 min.
- *Needs contact*: working hours, active, and no ping for more than 45 min.
- *Top performer*: top 10% by audits in the period.

### devices ("Привязка рабочего устройства")
`id`, `agentId → agents unique`, `installId unique`, `model` (e.g. "Samsung Galaxy Tab A8
[SM-X205]"), `imeiLabel null` (entered by an admin), `boundAt`.

### regions ("Region Zone", "Регион 2 (West District)")
`id`, `name`, `centroidLat`, `centroidLng`.

## Shops (`3:407`, `47:7387`, `162:20071`, `252:26607`, `246:23300`, `248:24538`)

### shops
| Column | Type | Rules |
|--------|------|-------|
| id | uuid PK | client-generated when an agent creates it |
| code | text unique | `CL-` + sequence |
| name | text | required ("Название торговой точки *") |
| type | enum `HYPERMARKET`, `SUPERMARKET`, `MARKET`, `MINIMARKET`, `OTHER` | badges "МАРКЕТ", "МИНИМАРКЕТ", "Гипермаркет" |
| address | text | required ("Фактический адрес и геопозиция *") |
| addressDetail | text null | e.g. "Next to State Mall" |
| regionId | uuid → regions | |
| lat, lng | double | required ("GPS привязан") |
| auditRadiusM | int | default from config |
| ownerName | text | "Владелец *" (add shop), "OWNER" column |
| facadePhotoId | uuid null → photos | "Фотография фасада" |
| assignedAgentId | uuid null → agents | "Закрепленный торговый представитель" |
| status | enum `PENDING_REVIEW`, `ACTIVE`, `INACTIVE` | "Status: Active" toggle, "Pending Review" badge |
| deletedAt | timestamptz null | "Delete Shop" (soft delete; audits kept) |
| lastVisitAt | timestamptz null | |
| nextDueAt | timestamptz null | `lastVisitAt + configured frequency`, or created + frequency |
| version | int | optimistic lock |

**Status transitions**: an agent creates a shop as `PENDING_REVIEW`. The Status toggle on moves
it to `ACTIVE`, and the toggle off moves it to `INACTIVE`. Delete sets `deletedAt`. Admins
create shops as `ACTIVE`.

**Indexes**: `(assignedAgentId, status)`, `(regionId)`, `(nextDueAt)`, and trigram on `name`,
`code`, `ownerName` and `address`.

### shop_contacts ("Контактные телефоны точки")
`id`, `shopId`, `phone`, `label` ("Администрация / Ресепшн", "Управляющий закупками"),
`position`. At most 5 per shop.

### shop_assignments (history, needed for the reassignment rule)
`id`, `shopId`, `agentId null`, `from`, `to null`. The audit scope check uses this table: was
the agent assigned at the audit's start time?

### shop_products ("Products carried")
PK `(shopId, productId)`. Set in the shop edit dialog with the product multi-select (approved
exception A11).

## Products (`30:574`, `495:2311`)

### product_categories
`id`, `name` ("Выберите категорию…").

### products
| Column | Type | Rules |
|--------|------|-------|
| id | uuid PK | |
| sku | text unique | required ("АРТИКУЛ (SKU) *") |
| name | text | required ("НАЗВАНИЕ ПРОДУКТА *") |
| categoryId | uuid → product_categories | required ("КАТЕГОРИЯ *") |
| brand | text null | "БРЕНД" |
| retailPriceMinor | int | required, ≥ 0 ("РОЗНИЧНАЯ ЦЕНА *") |
| description | text null | "ОПИСАНИЕ И СОСТАВ" |
| imageId | uuid null → photos | "ИЗОБРАЖЕНИЕ ТОВАРА" (PNG/JPG ≤ 5 MB) |
| status | enum `ACTIVE`, `INACTIVE` | "СТАТУС ТОВАРА" |
| stockQty | int ≥ 0 | "Текущий остаток (шт)" |
| minStockAlert | int ≥ 0 | "Минимальный лимит оповещения" |

**Derived for the table and KPIs**: locations, coverage %, regions, last activity, audited
compliance (completed audits without a violation ÷ completed audits, at carrying shops).

## Routes (timelines in `122:7981`, `273:153`; statuses in `83:16884`)

### routes
`id`, `agentId`, `date` (company-local), `generatedAt`. Unique `(agentId, date)`.

### route_stops
| Column | Type | Rules |
|--------|------|-------|
| id | uuid PK | |
| routeId | uuid → routes | |
| shopId | uuid → shops | |
| position | int | |
| plannedAt | timestamptz | |
| isAuditTask | bool | first `dailyAuditPlan` stops |
| status | enum `PLANNED`, `IN_PROGRESS`, `DONE`, `MISSED` | "Выполнен" / "В процессе" / "Пропущен" |
| auditId | uuid null → audits | |

**Transitions**:
- `PLANNED → IN_PROGRESS` when an audit starts; `IN_PROGRESS → DONE` when it completes.
- `PLANNED | IN_PROGRESS → MISSED` at the end of working hours (job).
- The remaining `PLANNED` stops re-order after each DONE.

**Miss reason**: not collected (Figma has no input for it), so the history's reason block is hidden for missed stops.

## Audits (`83:17207`, `83:17285`, histories in `47:7387`, `83:17057`, `122:7981`)

### audits (immutable)
| Column | Type | Rules |
|--------|------|-------|
| id | uuid PK | client-generated |
| shopId, agentId | uuid | the agent is the performer |
| routeStopId | uuid null | |
| startedAtDevice, finishedAtDevice | timestamptz | |
| receivedAt | timestamptz | server time |
| clockSkewFlag | bool | when the device–server difference is over 10 min |
| durationMin | int | "Длительность: 30 мин" |
| lat, lng, gpsAccuracyM | double | |
| distanceM | int | |
| withinRadius | bool | "Точность 8 метров (в радиусе магазина)" |
| comment | text | required ("Комментарий к аудиту") |
| hasViolation | bool | set by the violation chip (approved exception). When true, `comment` is shown under "Зафиксировано нарушение" |

**Rules**:
- 1–20 photos per audit.
- A database trigger rejects UPDATE and DELETE.
- On insert, the audit sets the shop's `lastVisitAt` and `nextDueAt`, and the stop `DONE`.

## Photos (`53:1375`, `138:11987`, `83:17954`, `83:18045`, `248:24311`, `248:24402`)

### photos
| Column | Type | Rules |
|--------|------|-------|
| id | uuid PK | client-generated |
| kind | enum `AUDIT`, `FACADE`, `PRODUCT`, `AVATAR`, `LOGO`, `ADMIN_UPLOAD` | `ADMIN_UPLOAD` = Pictures upload (B1); `LOGO` = Settings (A4) |
| auditId | uuid null → audits | **NULL at upload.** Set once when `POST /audits` links it, in the same transaction |
| shopId | uuid null → shops | |
| uploadedById | uuid → users | |
| storageKey | text | original, never modified |
| previewKeys | json null | 400 px and 1200 px WebP, written by the preview job |
| mime | text | `image/jpeg`, `image/png` or `image/webp` |
| sizeBytes | int | ≤ 10 MB (≤ 5 MB for PRODUCT) |
| sha256 | text | |
| width, height | int null | written by the preview job |
| takenAt | timestamptz | |
| lat, lng, accuracyM | double null | |
| status | enum `PENDING_UPLOAD`, `READY`, `FAILED` | |
| verifiedById, verifiedAt | null | "Verified" / "Проверено" badge and status filter |

**Immutability trigger**: for `kind = AUDIT` with `status = READY`, an UPDATE may only change:
- `auditId` from NULL to a value, once
- `previewKeys`, `width`, `height`
- `verifiedById`, `verifiedAt`

`storageKey`, `sha256`, `mime`, `sizeBytes`, `takenAt` and the geo columns can never change.
DELETE is rejected.

**Verification**: there is no Figma control to set it. Photos are marked verified automatically
when their audit is `withinRadius` and has no `clockSkewFlag`. The "Status" filter on Pictures
filters on it.

## Tracking (`122:7981`, `273:153`)

### location_pings
`id` bigint, `agentId`, `recordedAt`, `lat`, `lng`, `accuracyM`, `speedKmh null`,
`batteryPct null`, `trigger` (`HEARTBEAT`, `GEOFENCE_ENTER`, `GEOFENCE_EXIT`), `receivedAt`.
Index `(agentId, recordedAt desc)`. Purged after the retention period.

### agent_positions
`agentId PK`, `recordedAt`, `lat`, `lng`, `accuracyM`, `speedKmh`, `batteryPct`. Upserted with
each ping batch.

## Activity feed (bell, approved exception A6)

No table. The feed is a query over `audits` where `hasViolation` and `route_stops` where
`status = MISSED`, newest first. Unread = items newer than `users.feedSeenAt`.

## Exports ("Export Shops", "Export Catalog", "Экспорт отчёта (PDF/XLS)")

### exports
`id`, `requestedById`, `type` (`SHOPS_XLSX`, `PRODUCTS_XLSX`, `AGENT_REPORT_PDF`,
`AGENT_REPORT_XLSX`), `params json`, `status` (`QUEUED`, `RUNNING`, `DONE`, `FAILED`),
`fileKey null`, `createdAt`, `finishedAt`.

## Mobile local store (drift, Agent role)

- **Mirror**: `shops`, `shop_contacts`, `routes`, `route_stops`, `audits` (own, last 90 days),
  `photos` (metadata + `localPath`).
- **Outbox**: `outbox(id, kind, payloadJson, dependsOn, createdAt, attempts, lastError, state)`.
- **Buffers**: `pings_buffer`, `sync_cursors`.
- **Settings**: theme mode and locale.

Everything except theme and locale is wiped on sign-out. The Admin role is online and caches in
memory only.

## Relationships

- users 1–1 agents 1–1 devices; regions 1–* agents and shops
- agents 1–* shops (assigned), with shop_assignments as history
- agents 1–* routes 1–* route_stops *–1 shops
- shops 1–* audits *–1 agents; audits 1–* photos
- shops *–* products (shop_products); products *–1 product_categories
- agents 1–* location_pings; agents 1–1 agent_positions
