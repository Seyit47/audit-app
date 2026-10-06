# Data Model: Fresh Apps With Pixel-Perfect Designed Screens

**Feature**: [spec.md](./spec.md) | **Date**: 2026-10-06

These are client-side models for the sample repositories (research R-07). Their fields are
exactly what the designs display. There are no database tables in this feature. Real persistence
arrives with the data features, and these shapes are their starting point.

## Shop

| Field | Type | Seen in | Example |
|-------|------|---------|---------|
| `id` | string | all | `cl-102` |
| `code` | string | W3, W5, M2, M3 | `CL-102`, `CL-108` |
| `name` | string | all | `Al-Noor Retail Group`, `Магазин Алтын`, `Kamil market` |
| `type` | `supermarket \| market \| minimarket` | M2, M3, M5, M7 | `МИНИМАРКЕТ` |
| `address` | string | all | `Ashgabat, Bitarap Str. 42`, `г. Алматы, ул. Атамурата, 24` |
| `coordinates` | `{ lat, lng }` | A3, A5, M3 | `43.238949, 76.889709` |
| `distanceKm` | number? | A2, A3, A5 | `1.2` |
| `owner` | string | W3, A9 | `Merdan Jorayev`, `Tariq Mansoor` |
| `phone` | string | W3, A3, M3 | `+993 12 94-20-11` |
| `contactRole` | string? | A3, M3 | `Администратор Бахытжан` |
| `assignedAgentId` | string | W3, M2, M3 | — |
| `status` | `active \| pending_review \| inactive` | W3, M2 | `Active`, `Pending Review` |
| `visitState` | `scheduled \| overdue \| visited \| not_visited` | A2, A4 | `Просрочен`, `Посещённые` |
| `lastVisitAt` / `nextVisitDue` | datetime | W3, A2, A3 | `14 сент. 15:17` |
| `photoUrl` | string | all | storefront crop |
| `auditCount`, `productsCarried`, `auditPhotos` | numbers | W5, M2, M3 | `84`, `2 SKUs`, `42` |
| `mapPosition` | `{ x, y }` (design px) | W1, A4, M4 | marker placement on `MapCanvas` |

## Agent (salesman)

| Field | Type | Seen in | Example |
|-------|------|---------|---------|
| `id`, `code` | string | W8, M9 | `SL-102` |
| `name`, `initials`, `avatarUrl?` | string | W8, M9, M10 | `Ahmed Karimov`, `AK` |
| `phone` | string | W8, M10 | `+993 65 112233` |
| `region` / `sector` | string | W8, W9, M10 | `Сектор: Центральный / Северо-Запад` |
| `status` | `active \| inactive` | W8 | |
| `isOnline`, `gpsAccuracyM` | bool, number | W9, M10 | `В сети (GPS активен, ±5м)` |
| `locations`, `visits`, `photos` | numbers | W8, M9 | `129`, `86`, `342` |
| `lastActivityAt` | datetime | W8, M9 | `Today, 10:42` |
| `routeCheckpoints` | `RouteCheckpoint[]` | W9, M10 | time, place, photo count, status `done \| missed \| in_progress` |

## Audit (visit)

| Field | Type | Seen in | Example |
|-------|------|---------|---------|
| `id` | string | | |
| `shopId`, `agentId` | string | all | |
| `startedAt`, `finishedAt`, `durationMin` | datetime, number | W5, W9, M10 | `Сегодня, 10:15 — 10:45`, `30 мин` |
| `status` | `completed \| missed` | W5, W9, M10 | `Завершён`, `Пропущен` |
| `comment` | string | all | `«Выкладка молочной продукции обновлена…»` |
| `violation` | string? | A3, A7, M3, M7 | `Стойка напитков перекрыта коробками…` |
| `missReason` | string? | W9, M10 | `Магазин закрыт на санитарный день…` |
| `coordinates`, `accuracyM` | | A3, M3 | `Точность 8 метров (в радиусе магазина)` |
| `photoIds` | string[] | all | |

State machine for the audit screen (A10 → A11): `locating → located`. Then photo count 0 → n
and comment empty → filled. **Finish** is enabled when located, with at least 1 photo and a
non-empty comment.

## Photo

| Field | Type | Seen in |
|-------|------|---------|
| `id`, `url` (sample crop), `takenAt` | | W10, A6, M6 |
| `shopId`, `auditId`, `agentId` | | W11, A7, M7 |
| `verified` | bool | W10 badge "Verified" |
| `type` | `posm \| storefront \| shelf` | W10 filter |

The gallery groups photos by date (`Сегодня, 21 сентября`, `18 сентября`) and shows a total
(`142 фото`, `1,240 Total Photos`, `+48 Today`).

## Product (admin web W7)

`name`, `description`, `sku`, `category` (`Cosmetics`, `Hair Care`, `Salon Supplies`,
`Styling`), `locations`, `coveragePct`, `regions`, `lastActivityAt`, `status`, `thumbnailUrl`.
Also the KPI summary: `totalProducts 342`, `distributionReach 840`, `avgOutletsPerSku 68.4`,
`auditedCompliance 94.2%`.

## Session and app settings (mobile)

- **Session**: `{ userId, role: agent | admin }`, set by the debug role picker.
- **AppSettings**: `{ themeMode: system | light | dark, locale: ru | en }`. Both toggles are on
  Home (A1, M1).

## Add-shop form (A8/A9, M8/M8b)

The fields are `name*`, `address*`, `owner*`, `agent*` (admin only), `phone*`, the current
location (`area`, `lat`, `lng`) and the storefront photo. Required fields show a green check
when valid. **Save** is enabled only when every required field is valid and a photo is present.
