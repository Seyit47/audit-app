# Feature Specification: Retail Audit Platform (Production Release)

**Feature Branch**: `002-retail-audit-platform`

**Created**: 2026-10-06 (rescoped to Figma-only on 2026-10-06)

**Status**: Draft

**Input**: User description: "Images and assets are loaded from the backend because clients
upload them. Build the architecture of the full app starting with data models and the backend.
Write the full plan of the final app ready for production." Plus the user's rule: "Figma is the
source of truth. Don't change it. Everything is planned by analyzing the Figma design."

## Scope Rule

The Figma file `9s5b56r9zs1s0Ty2UgvL0W` defines the product. The release contains **exactly the
screens, states, fields, controls and data shown in its 46 frames**
([contracts/figma-frames.md](./contracts/figma-frames.md)). The Figma file is never modified,
and no screen, field or flow is added beyond it.

- **Behaviors the designs display but give no input UI for** are resolved without new UI:
  through a control that exists in Figma, an automatic system rule, or server configuration. See
  "Figma Gaps and Resolutions" below.
- **Approved exceptions** (Constitution I): built only from existing Figma components, colors
  and typography, without modifying Figma:
  1. **Sign-in screens** (web and mobile). Production needs them and Figma has none.
  2. **A violation chip/toggle** in the audit comment section (Figma layer "Section - Step 3:
     Global Audit Feedback & Quick Chips"). Figma displays violations but has no control to
     record one.
  3. **Admin web Settings page** (the sidebar item has no frame).
  4. **Admin activity feed** opened from the header bell (recent violations and missed visits).
  5. **Mobile admin Add Salesman and Products screens** (the Агенты "Добавить" button and the
     Home "Продукции" tile have no mobile frames).
  6. **Location-permission explanation screen** on mobile.
  7. **Product multi-select ("Products carried")** in the shop edit dialog.
  8. **Controls Figma shows without a designed result**: Pictures upload dialog, map
     Layers/Fullscreen/Refresh, mobile filter bottom sheets, Pictures view modes, Share sheet.

  Every item in this list was explicitly approved by the user under the Figma gap protocol on
  2026-10-06.
- **Content**: every value shown (shop facades, audit photos, avatars, product images, names,
  numbers, statuses, histories, positions) comes from the backend and is uploaded by users. The
  apps ship no content.

## Overview

A retail-execution platform for one company. Field **agents** visit shops on automatically
planned routes and prove each visit with GPS-checked in-app photos and a comment (an "audit"),
including violations they find. **Admins** manage shops, agents and products, watch agents live
on the map, review photos, and export reports.

- **Admin web** (Figma "Admin Web" `246:22821`): Map, Shops, Shop details + Edit, Products,
  Add Product, Salesmen, Add Salesman, Salesman details, Pictures.
- **Mobile app**, one app with two roles:
  - Agent role: Figma "Agent Mobile light" `111:6815` and "Agent Mobile dark" `111:6814`. Home,
    Shops, Shop details, Map, Audit, Add shop, Gallery, Photo detail.
  - Admin role: Figma "Admin mobile light" `248:23959`. Home, Shops, Shop details, Map, Gallery,
    Photo detail, Add/Edit shop, Agents, Agent details.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Sign in and land in the right workspace (Priority: P1)

Admins sign in on the web or mobile app. Agents sign in on their bound phone. Each lands on their
role's home (web: Shops; mobile admin: `246:23129`; agent: `83:16786`). Admins create agents on
"Add Salesman" (`495:3932`), including the bound work device.

**Why this priority**: every other story depends on knowing the user and enforcing what they may
see.

**Independent Test**: Create an agent on Add Salesman and sign in on the phone, which binds the
device. A second phone is refused. The agent is refused on the web. Setting the agent to
"Отпуск" or deactivating them stops route assignment, and deactivation blocks sign-in.

**Acceptance Scenarios**:

1. **Given** an agent account, **When** the agent signs in on the mobile app, **Then** the agent
   Home opens and shows only that agent's shops, route and photos.
2. **Given** an agent, **When** they try to sign in to the admin web, **Then** access is refused.
3. **Given** an admin, **When** they sign in on the web or mobile, **Then** the admin workspace
   opens with all company data.
4. **Given** Add Salesman, **When** the admin saves the form (ФИО *, Контактный телефон *,
   WhatsApp, Примечания / График маршрута, Дневной план визитов, План чек-листов, Регион *,
   Привязка рабочего устройства, Статус), **Then** an agent with the next SL- code exists and
   can sign in on that device only.
5. **Given** a signed-in user, **When** they sign out or their session expires, **Then** they
   must sign in again, and on mobile the cached data is wiped.

---

### User Story 2 - Agent completes an audit, even offline (Priority: P1)

From a shop (list, details or map sheet), the agent opens Audit (`83:17207`). The app locates the
agent, takes POSM photos in-app, and accepts a comment. With the violation chip (approved
exception) switched on, the comment is recorded as a violation. Finish is
enabled once there is a photo and a comment (`83:17285`). Without network, it saves and syncs
later ("Офлайн-режим сохранён").

**Why this priority**: trustworthy shelf evidence is the core value.

**Independent Test**: With airplane mode on, audit a shop inside its radius (3 photos +
comment). Reconnect and confirm the admin sees the visit with photos, GPS and times. Outside
the radius the audit is blocked.

**Acceptance Scenarios**:

1. **Given** the agent is outside the shop's radius, **When** they try to start, **Then** it is
   blocked with "Начать аудит можно только на территории магазина" (map sheet `83:17775`).
2. **Given** no photo or an empty comment, **Then** "Завершить аудит" is disabled (`83:17207`).
   With at least 1 photo and a comment, it is enabled (`83:17285`).
3. **Given** no network, **When** the agent finishes, **Then** the audit is saved locally and
   synced automatically later without duplicates or lost photos.
4. **Given** a synced audit, **Then** it records start and finish times (device and server), GPS
   position and accuracy, distance from the shop, and whether it was within the radius. It can
   never be edited or deleted.
5. **Given** the agent switches on the violation chip and writes the comment, **Then** the audit
   shows as "Зафиксировано нарушение" with that comment in the visit histories and photo details
   (`83:17057`, `83:18045`, `248:24538`, `248:24402`). Without the chip, the comment shows as a
   normal remark ("Замечаний нет.").

---

### User Story 3 - Agent's working day: route, shops, map (Priority: P1)

The agent sees their shops with statuses (Все, Запланирован, Просрочен, Пройден), opens details
(contact, last and next visit, audit history), calls the contact, opens navigation, and sees
shops on the map around them. Routes are generated automatically each morning.

**Why this priority**: it tells agents where to go. Together with US2 it makes up the agent
workflow.

**Independent Test**: Generate today's route for an agent with 5 due shops, one overdue. Their
Shops chips, map markers and details match the plan, and call/navigate open the phone's dialer
and maps app.

**Acceptance Scenarios**:

1. **Given** assigned shops, **When** the agent opens Магазины (`83:16884`), **Then** the shops
   are listed with photo, name, address and last visit, and the chips show counts.
2. **Given** a shop past its due date, **Then** it shows as overdue with days
   ("Срочно (просрочен на 2 дня)", `83:17057`).
3. **Given** the map (`83:17636`), **When** the agent taps a marker, **Then** a sheet shows the
   shop, distance, last visit and the audit button state (`83:17775`).
4. **Given** today's route, **When** the day ends, **Then** unvisited stops become "Пропущен",
   and admins see the checkpoints as done, missed or in progress.

---

### User Story 4 - Admin manages shops (Priority: P1)

The admin lists, searches and filters shops (`3:407`), uses the row menu, selects rows for bulk
actions (Assign salesman, View on Map, Delete Shop; `53:151`), opens details (`47:7387`), edits
via the dialog (`162:20071`), switches status with the Status toggle, and exports. Admin mobile
offers the same through Shops (`246:23300`), Shop details (`248:24538`) and Add/Edit shop
(`252:25423`, `252:25542`).

**Why this priority**: shops are the master data.

**Independent Test**: Create a shop with a facade photo and two contact phones, assign it,
filter for it, edit it, bulk-assign it with others, export, and delete it (its audit history is
kept).

**Acceptance Scenarios**:

1. **Given** Shops, **When** searching or filtering by status or region, **Then** the table
   updates with paging ("Showing 1-6 of 1,420").
2. **Given** selected rows, **When** Assign salesman, View on Map or Delete Shop is used,
   **Then** it applies to all selected shops after confirmation.
3. **Given** the edit dialog, **When** the admin uploads a facade photo (JPG, PNG or WEBP,
   ≤ 10 MB), sets the address and pin, edits the contact phones and the assigned agent and
   saves, **Then** the change shows on web and mobile. A concurrent edit by another admin is
   refused with a reload prompt.
4. **Given** "Delete Shop", **Then** the shop leaves all lists and routes, but its audits and
   photos remain in histories and the gallery.
5. **Given** the Status toggle on Shop details, **Then** the shop switches between Active and
   inactive. This is also how a "Pending Review" shop is approved.

---

### User Story 5 - Agent adds a new shop from the field (Priority: P2)

The agent adds a shop on Add shop (`252:26487` → `252:26607`): name, address, owner and phone,
the current location ("Текущее местоположение", "Проверить заново") and a storefront photo. It
appears as "Pending Review" in the admin Shops list until an admin activates it with the Status
toggle.

**Independent Test**: The agent adds a shop offline with a photo. After sync the admin sees it as
Pending Review, activates it, and it appears in the agent's shops.

**Acceptance Scenarios**:

1. **Given** a missing required field or no storefront photo, **Then** "Сохранить" is disabled.
   Valid fields show a check.
2. **Given** no network, **When** saved, **Then** the shop syncs later like an audit.
3. **Given** a Pending Review shop, **When** an admin turns its Status toggle on, **Then** it
   becomes Active, assigned to that agent.

---

### User Story 6 - Admin monitors agents (Priority: P2)

Salesmen (`31:2307`) shows KPIs (total staff, on route, audits, shops visited, photos uploaded,
"Требуют связи (>45 мин)"), date filters (Дата от / Дата до, Сегодня / Вчера / Текущая неделя)
and the agent table. Salesman details (`122:7981`) and mobile Agent details (`273:153`) show
the live position with GPS accuracy, speed and battery, today's route timeline, photo reports,
visit history with missed visits, and "Экспорт отчёта (PDF/XLS)".

**Independent Test**: With an agent moving between shops during working hours, the position on
Salesman details is never older than 2 minutes, the timeline reflects visits, and the export
contains them. When pings stop for 45 minutes, the agent is counted under "Требуют связи".

**Acceptance Scenarios**:

1. **Given** an agent working during working hours, **Then** their position, accuracy
   ("В сети (GPS активен, точность 5м)"), speed and battery are shown, at most 2 minutes old.
2. **Given** outside working hours, an agent on "Отпуск", or a signed-out agent, **Then** no
   location is collected.
3. **Given** a date range, **Then** KPIs, timeline and history reflect it.
4. **Given** "Экспорт отчёта (PDF/XLS)", **Then** a file with the period's visits, durations,
   photos and missed visits downloads.

---

### User Story 7 - Photo library and review (Priority: P2)

Admins browse photos on Pictures (`53:1375`): grouped, filtered by Type, Location, Status and
Date, with totals. Clicking a photo opens the detail panel (`138:11987`) with the shop, agent,
comment and related audit photos. Agents (`83:17954`, `83:18045`) and mobile admins
(`248:24311`, `248:24402`) have a gallery and photo detail.

**Independent Test**: After two audits sync, their photos appear under today with the right shop
and agent. Opening one shows its related photos. The status filter separates verified from
unverified.

**Acceptance Scenarios**:

1. **Given** filters, **Then** only matching photos show, newest first, loading as the admin
   scrolls.
2. **Given** a photo, **When** opened, **Then** the detail shows the shop, agent, comment or
   violation, and the other photos of the same audit.
3. **Given** an agent, **Then** their gallery shows only their own audit photos, grouped by date.

---

### User Story 8 - Products and assortment (Priority: P3)

Products (`30:574`) shows KPIs (total products, distribution reach, avg outlets per SKU, audited
compliance), filters and the product table. Add Product (`495:2311`) creates a product with an
image, name, SKU, category, brand, retail price, description, status, current stock and minimum
alert level. Admins set the products each shop carries in the shop edit dialog (approved
exception A11), and they are shown as "Products carried" on Shop details (`47:7387`).

**Independent Test**: Add a product, select it for 3 shops in the edit dialog, and check
locations, coverage and regions on Products and "Products carried" on Shop details.

**Acceptance Scenarios**:

1. **Given** search or filters, **Then** the table and KPIs update.
2. **Given** a product linked to shops, **Then** its locations, coverage % and regions are
   correct.
3. **Given** audits at a shop, **Then** shelf compliance is the % of completed audits in the
   period without a violation. The catalog figure covers all shops carrying the product.

---

### User Story 9 - Map overview (Priority: P3)

Admins see all shops and agents on the Map (`21:2`), filter by salesmen and region zone (filters
panel in `3:2`), see the "Filtered view: N locations • N salesmen • N region" banner, and open a
shop's card with visit history (`3:2`). Admin mobile has the Map with filter chips and a shop
sheet (`248:23963`, `248:24102`).

**Independent Test**: Filter to 1 agent and 1 region. The banner, markers, clusters and popup
match the filtered data.

**Acceptance Scenarios**:

1. **Given** filters applied, **Then** only matching shops show and the banner counts match.
2. **Given** a marker, **When** it is clicked, **Then** the shop card shows contacts, photos and
   visit history.

---

### Cross-cutting (as shown in Figma)

- **Mobile**: RU/EN toggle and light/dark toggle on Home (`83:16786`, `246:23129`). The
  default follows the system, with Russian as the language fallback.
- **Mobile sync status**: "Данные синхронизированы" / "Синхронизация…" on Home.
- **Admin web**: shows exactly the Figma text of each frame (single language, as designed).

### Edge Cases

- **Poor GPS accuracy (worse than 50 m)**: starting an audit or capturing a new shop's location
  waits for better accuracy ("Проверить заново").
- **Wrong phone clock**: the server receipt time is stored next to the device time. A difference
  over 10 minutes is flagged.
- **App closed mid-audit**: the in-progress audit and its photos are restored.
- **A photo upload fails repeatedly**: it stays queued and is retried, never dropped. Home shows
  "Синхронизация…" until it succeeds.
- **Two admins edit the same shop**: the second save is refused with a reload prompt.
- **A shop is reassigned while an agent has an unsynced audit for it**: the audit is accepted if
  the agent was assigned the shop when the audit started.
- **An agent is deactivated while offline**: data recorded before the deactivation is accepted
  for 72 hours, then the agent is signed out.
- **Very large lists**: lists page or scroll incrementally.
- **A file that isn't an image, or is over the limit**: rejected with a clear message.

## Figma Gaps and Resolutions

These are behaviors the designs imply but give no input UI for. Each is resolved without new UI.

| # | Gap | Approved resolution |
|---|-----|---------------------|
| G1 | No sign-in screen | **New UI**: minimal sign-in screens from existing Figma components (web and mobile) |
| G2 | "Зафиксировано нарушение" shown, no input on the audit screen | **New UI**: a violation chip/toggle in the audit comment section. When it is on, the comment is the violation text |
| A1 | "Pending Review" status, no approval screen | Approve with the existing **Status toggle** on Shop details (`47:7387`) |
| A2 | Missed visits with "Причина отмены визита", no entry UI | Unvisited stops become "Пропущен" automatically at the end of working hours. No reason is collected, so the reason block is hidden |
| A3 | "Просрочен / Запланирован", no visit-frequency field | One company-wide visit frequency (default 7 days), editable on the Settings page (A4) |
| A4 | Dashboard and Settings in the sidebar, no frames | Dashboard opens Map. **New UI**: a Settings page built from existing components: company name and logo, working hours and time zone, visit frequency, audit radius, GPS accuracy, no-signal threshold, regions |
| A5 | No admin account screen | Admins are created and reset by an operator CLI on the server |
| A6 | Bell and Help in headers, no panel | **New UI**: the bell opens an **activity feed** panel listing recent violations and missed visits, using the existing visit-history cards. Unread dot when new items exist since the admin last opened it. Help is rendered but inert |
| A7 | Mobile admin "Добавить" on Агенты and the "Продукции" tile have no mobile frames | **New UI**: mobile Add Salesman and Products (list + add) screens built from existing mobile components, mirroring the web fields |
| A8 | No shift control | Tracking runs automatically during working hours for active agents (not on Отпуск) |
| A9 | No location-permission screen | **New UI**: an explanation screen before the OS permission dialogs, built from existing mobile components |
| A10 | "Verified" / "Проверено" with no verify control | Automatic: verified when the audit was within the radius and the clock was correct |
| A11 | "Products carried" with no assortment field | **New UI**: a product multi-select in the shop edit dialog (`162:20071`), built from existing form components |
| A12 | Admin web frames are in English, but the Map frames (`21:2`, `3:2`) show the sidebar in Russian | The admin web supports **RU (default) and EN**. Russian comes from the Map sidebar where Figma has it, otherwise from translations. **New UI**: a RU/EN switch (the mobile Home RU/EN labels) in the header avatar menu. Approved 2026-10-07 |
| B1 | Pictures "Upload" button (`53:1375`) | Opens an upload dialog (existing ImageUpload + the shop select from `162:20071`). Photos are stored as admin uploads for that shop |
| B2 | Map Layers / Fullscreen / Refresh controls (`21:2`, `3:2`) | Layers switches between the Figma-styled map and satellite imagery. Fullscreen uses the browser fullscreen API. Refresh reloads markers and positions |
| B3 | Mobile "Filters" buttons and gallery "Параметры фильтрации" | Open a bottom sheet (existing chips + bottom-sheet card) with the filters the screen supports: status, region, date |
| B4 | Pictures "Mode Toggles" | Switch between a plain grid and the grid grouped by date, using the existing photo tiles |
| B5 | Admin mobile Shop details share icon (if present in `248:24538`) | Opens the OS share sheet with the shop name, address and a map link. Dropped if the icon is absent |

## Requirements *(mandatory)*

### Functional Requirements

**Access**

- **FR-001**: The system MUST have two roles. Admins use the web and mobile apps. Agents use
  only the mobile app, on their bound device.
- **FR-002**: Admins MUST create and edit agents with exactly the Add Salesman fields
  (`495:3932`):
  - ФИО *, an auto code (SL-xxx), Контактный телефон *, Дополнительный телефон / WhatsApp
  - Примечания / График маршрута, Дневной план визитов (ТТ), План чек-листов / аудитов в день
  - Регион / Территория продаж *, Привязка рабочего устройства, Статус (Активен / Отпуск)
- **FR-002a**: An agent MUST only be able to sign in on the bound device. The first sign-in binds
  it, and admins rebind it from the device field.
- **FR-003**: An admin web session MUST expire after 12 hours idle, and a mobile session after 30
  days idle. Signing out wipes the mobile device's cached data.
- **FR-004**: Agents MUST only access their assigned shops, their own route, audits and photos.
  This is enforced on the server.

**Shops**

- **FR-005**: Shops MUST store exactly what Figma shows:
  - code (CL-xxx), name, type, address, region
  - location (lat/lng, "GPS привязан") and audit radius
  - owner, contact phones with role labels (up to 5)
  - facade photo, assigned agent
  - status (Active, Inactive, Pending Review), and whether it is deleted
- **FR-006**: Admins MUST list, search, filter (status, region), page, export, bulk-assign and
  delete shops, and edit them via the edit dialog with optimistic concurrency.
- **FR-007**: Agents MUST be able to add shops with location and storefront photo, offline-capable.
  They start as Pending Review.

**Routes and visits**

- **FR-008**: The system MUST compute each shop's next due date from its last visit and the
  configured visit frequency, and mark overdue shops with the days overdue.
- **FR-009**: Every working day, the system MUST generate each active agent's route: due shops,
  overdue first, up to the agent's Дневной план визитов, with the first План чек-листов marked
  as audit tasks, ordered to minimize travel. Unvisited stops become missed at the end of working
  hours, and the remaining route re-orders after each completed visit.

**Audits and photos**

- **FR-010**: An audit MUST start only within the shop's radius, with GPS accuracy of 50 m or
  better.
- **FR-011**: An audit MUST record:
  - shop, agent, device and server start/finish times, duration
  - GPS position and accuracy, distance, within-radius
  - 1–20 in-app photos, a comment, and a violation flag (from the violation chip; the comment is
    the violation text when it is set)
- **FR-012**: Audit photos MUST be taken with the in-app camera at audit time.
- **FR-013**: Submitted audits and their photos MUST be immutable.
- **FR-014**: The agent app MUST work offline for viewing shops, routes, audits and adding shops.
  It MUST sync automatically and resume after restarts, without duplicates or loss.
- **FR-015**: Photos MUST keep their original quality and be shown through fast-loading previews.
- **FR-016**: Admins MUST browse and filter all photos, switch the view mode, see photo details,
  and upload photos to a shop (B1, B4). Agents see only their own.

**Agents and tracking**

- **FR-017**: While an active agent is signed in during working hours, the app MUST send the
  position with accuracy, speed and battery at least every 2 minutes, and immediately on
  entering or leaving a shop's radius. No location is collected otherwise.
- **FR-018**: Admins MUST see the Salesmen KPIs, live position, route timeline, track, photo
  reports and visit history for a chosen date range, and the agents needing contact (no signal
  for more than 45 minutes while working).
- **FR-018a**: Admins MUST see an activity feed from the header bell: violations and missed
  visits, newest first, with an unread indicator (A6).
- **FR-019**: Admins MUST export: the shop list (Export Shops), the product catalog (Export
  Catalog), and an agent report (PDF/XLS).

**Products**

- **FR-020**: Admins MUST manage products with exactly the Add Product fields (`495:2311`):
  - ИЗОБРАЖЕНИЕ ТОВАРА (PNG/JPG ≤ 5 MB), НАЗВАНИЕ ПРОДУКТА *, АРТИКУЛ (SKU) *, КАТЕГОРИЯ *
  - БРЕНД, РОЗНИЧНАЯ ЦЕНА *, ОПИСАНИЕ И СОСТАВ, СТАТУС ТОВАРА
  - Текущий остаток (шт), Минимальный лимит оповещения

  Admins MUST also see distribution (locations, coverage %, regions, last activity) and
  compliance, and set each shop's products carried in the shop edit dialog (A11).

**Map**

- **FR-021**: Admins MUST see shops (clustered) and agents' live positions on a map, with
  salesman and region-zone filters and a shop card.

**Experience**

- **FR-022**: Every screen MUST match its Figma frame exactly (Constitution I). All content MUST
  come from the backend.
- **FR-023**: The mobile app MUST provide the RU/EN and light/dark toggles shown on Home.
- **FR-024**: Loading, empty and error states MUST reuse the components and styles of their
  frame.
- **FR-024a**: Admins MUST edit company settings on the Settings page (A4). The values feed
  routes, geofences, tracking and the header.
- **FR-025**: Uploaded images MUST be JPG, PNG or WEBP. Shop and audit photos are at most 10 MB,
  and product images (PNG or JPG) at most 5 MB. They are visible only to signed-in users with
  access.

### Key Entities

- **User**: someone who signs in; role Admin or Agent.
- **Agent**: profile from Add Salesman, including region, plans, status and bound device.
- **Device**: the agent's work phone or tablet.
- **Region**: a sales territory or region zone.
- **Shop**: identity, type, address, location and radius, contacts, facade, assigned agent,
  status, last visit and next due date.
- **Route / Route stop**: an agent's daily plan, with stop statuses (planned, in progress, done,
  missed).
- **Audit**: one visit with its evidence. Immutable.
- **Photo**: an uploaded image (audit, facade, product, avatar), with original and previews.
- **Product / Category**: the catalog and per-shop assortment.
- **Location ping / Agent position**: tracking data while working.
- **Export**: a generated file (shops, catalog, agent report).
- **Company settings**: company name, logo, working hours, time zone, visit frequency, audit
  radius, GPS accuracy, no-signal threshold (A4).
- **Activity feed**: derived list of violations and missed visits for admins (A6).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An agent completes an audit (open shop, start, 3 photos, comment, finish) in under
  2 minutes of app time.
- **SC-002**: Across 100 offline test audits, 100% reach the server within 5 minutes of
  connectivity returning, with zero duplicates and zero lost photos.
- **SC-003**: Admins see a synced audit within 1 minute.
- **SC-004**: A working agent's live position on admin screens is never more than 2 minutes old.
- **SC-005**: With 10,000 shops and 100,000 photos, a list's first page loads in under 2 s and
  search returns in under 1 s.
- **SC-006**: Every one of the 46 Figma frames matches its implemented screen in a side-by-side
  review.
- **SC-007**: No agent can read another agent's data, verified on every endpoint.
- **SC-008**: The mobile app shows its first screen within 2 s of a cold start on a mid-range
  Android phone.

## Assumptions

- One company per installation. "COMPANY NAME" and the logo come from Settings (A4).
- Agents sign in with phone + password, and admins with email + password.
- Working hours, visit frequency, audit radius, GPS accuracy and alert threshold are editable on
  Settings, with defaults (08:00–19:00, 7 days, 100 m, 50 m, 45 min). Retention (3 years) is
  server configuration.
- Each shop has one assigned agent.
- The map's base geography comes from a map provider, styled to the Figma palette. Markers,
  cards and controls match the frames.
- Push notifications, a Dashboard page and admin account screens are not part of this release.
