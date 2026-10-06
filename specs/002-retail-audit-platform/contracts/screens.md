# Contract: Screens → Figma → Data

The release builds **only the Figma frames**, plus the approved exceptions listed in spec.md "Scope Rule" and the gaps table (G1, G2, A4, A6, A7, A9, A11, B1–B5). All of them are built only from existing Figma components. Each screen
matches its node pixel-perfect (Constitution I; node IDs and states are in
[figma-frames.md](./figma-frames.md)). Every value shown comes from the API ([api.md](./api.md))
or, for the Agent role, from the local store synced by [sync.md](./sync.md). Loading, empty and
error states reuse the frame's own components and styles.

Elements that appear in a frame but have no behavior designed (the bell, Help, Dashboard,
Settings) are rendered exactly as in Figma. Their behavior follows the spec's "Figma Gaps and
Resolutions" table.

## Admin web (Next.js, admin only)

| Screen | Route | Figma | Data | Actions |
|--------|-------|-------|------|---------|
| Sign in (exception) | `/login` | none (existing components only) | — | `POST /auth/login` |
| Layout | all admin pages | sidebar and header of `3:407` | `GET /me` (company name, logo) | Navigation. Dashboard opens `/map`. Settings opens `/settings`. The bell opens the activity feed panel. Help is inert. "Search clients…" opens `/shops?q=` |
| Map | `/map` | `21:2`; `3:2` (shop card + filters panel) | `GET /shops/map`, `GET /agents/positions` (30 s), `GET /regions`, `GET /agents?size=100`; on marker click `GET /shops/:id` + `GET /shops/:id/visits?limit=3` | Search, filters (salesmen, region zones), Apply/Clear, zoom, recenter, Layers (Figma style ↔ satellite), Fullscreen, Refresh, open details |
| Shops | `/shops` | `3:407` (row menu), `53:151` (selection) | `GET /shops?page&size=10&q&status&regionId` | Export Shops, Add Shop, row menu, bulk Assign salesman / View on Map / Delete Shop |
| Shop details | `/shops/[id]` | `47:7387` | `GET /shops/:id`, `GET /shops/:id/visits` | Status toggle (`PATCH status`; also approves Pending Review), View on Map, Edit |
| Edit / Add shop dialog | dialog on `/shops/[id]` and `/shops` | `162:20071` | `GET /agents`, `GET /regions` | Facade upload, name, agent, address and pin, contacts, products carried multi-select (A11) (`PATCH /shops/:id` or `POST /shops`, `PUT …/contacts`, `PUT …/products`) |
| Products | `/products` | `30:574` | `GET /products`, `GET /products/summary` | Filters, Export Catalog, Add Product |
| Add Product | `/products/new` (and `/products/[id]` to edit) | `495:2311` | `GET /product-categories` | Image upload, save (`POST/PATCH /products`) |
| Salesmen | `/salesmen` | `31:2307` | `GET /agents`, `GET /agents/summary` | Дата от/до, Сегодня/Вчера/Текущая неделя, filters, Add Salesman |
| Add Salesman | `/salesmen/new` (and `/salesmen/[id]/edit`) | `495:3932` | `GET /regions` | `POST/PATCH /agents`, device rebind, reset password, Активен/Отпуск |
| Salesman details | `/salesmen/[id]` | `122:7981` | `GET /agents/:id`, `…/timeline`, `…/track`, `GET /photos?agentId`, `GET /audits?agentId` | Date range, Экспорт отчёта (PDF/XLS) |
| Settings (A4) | `/settings` | none (existing form, card and table components) | `GET /settings`, `GET /regions` | Edit company settings and logo, manage regions |
| Activity feed (A6) | panel from the header bell | none (existing visit-history cards + SidePanel) | `GET /feed`, `POST /feed/seen` | Open the shop or agent of an item |
| Pictures | `/pictures` | `53:1375`; `138:11987` (detail panel) | `GET /photos`, `GET /photos/summary`, `GET /photos/:id` | Filters Type/Location/Status/Date, view mode grid / by date (B4), Upload dialog with shop select (B1: `POST /uploads` kind ADMIN_UPLOAD), open detail |

## Mobile: Agent role (offline-first, light + dark)

| Screen | Route | Figma light / dark | Data (local store ← sync) | Actions |
|--------|-------|--------------------|---------------------------|---------|
| Sign in (exception) | `/login` | none (existing components only) | — | `POST /auth/login` with device |
| Location permission (A9) | `/agent/permission` (before first tracking) | none (existing mobile components) | — | Explains the background location need, then requests the OS permissions |
| Home | `/agent` | `83:16786` / `101:1880` | sync status, next route stop | Начать аудит, Мои магазины, Карта, Галерея, theme toggle, RU/EN |
| Shops | `/agent/shops` | `83:16884` / `101:1985` | shops + counts ← `/shops`, `/routes/today` | Search, chips, Filters sheet (B3), open details, Добавить |
| Shop details | `/agent/shops/:id` | `83:17057` / `106:4035` | shop, contact, visits ← `/shops/:id/visits` | Call, Карта (geo URI), Аудит |
| Map | `/agent/map` | `83:17636`, `83:17775` / `106:5485`, `106:5609` | shops with location and visit state; GPS | Chips, Filters sheet (B3), marker → sheet, Начать Аудит (geofence) |
| Audit | `/agent/shops/:id/audit` | `83:17207` → `83:17285` / `106:4374` → `106:6229` | shop, GPS, local photos | Camera photos, delete, comment, violation chip (approved exception 2), Завершить аудит → outbox |
| Add shop | `/agent/shops/new` | `252:26487` → `252:26607` / `101:2472` → `106:5970` | GPS, regions | Storefront photo (camera), Сохранить → outbox |
| Gallery | `/agent/gallery` | `83:17954` / `106:6558` | own photos ← `/photos` | Search, Параметры фильтрации sheet (B3) |
| Photo detail | `/agent/gallery/:id` | `83:18045` / `106:6710` | `/photos/:id` (cached) | Related photos |

## Mobile: Admin role (online, light)

| Screen | Route | Figma | Data | Actions |
|--------|-------|-------|------|---------|
| Sign in (exception) | `/login` | shared with the agent | — | — |
| Home | `/admin` | `246:23129` | — | Карта, Магазины, Галерея, Агенты, Продукции (A7 mobile Products), theme toggle, RU/EN |
| Shops | `/admin/shops` | `246:23300` | `GET /shops` | Search, Подробнее, call, navigate, Добавить |
| Shop details | `/admin/shops/:id` | `248:24538` | `GET /shops/:id`, `/visits`, `GET /photos?shopId&limit=3` | Share via OS sheet if the icon exists (B5), Редактировать точку, Связаться, В навигаторе |
| Map | `/admin/map` | `248:23963`, `248:24102` | `GET /shops/map`, `GET /agents/positions` | Chips, marker → sheet → Подробнее |
| Gallery | `/admin/gallery` | `248:24311` | `GET /photos` | Параметры фильтрации sheet (B3) |
| Photo detail | `/admin/gallery/:id` | `248:24402` | `GET /photos/:id` | Call, navigate |
| Add / Edit shop | `/admin/shops/new`, `/:id/edit` | `252:25423` → `252:25542` | `GET /agents`, `GET /regions` | Открыть галерею / Сделать фото for the facade, Save |
| Agents | `/admin/agents` | `265:27616` | `GET /agents`, `GET /agents/summary` | Search, Filters sheet (B3), Подробнее, call, navigate, Добавить (A7 mobile Add Salesman) |
| Add Salesman (A7) | `/admin/agents/new` | none (existing mobile form components; fields from `495:3932`) | `GET /regions` | `POST /agents` |
| Products (A7) | `/admin/products`, `/admin/products/new` | none (existing mobile list and form components; fields from `30:574`, `495:2311`) | `GET /products`, `GET /product-categories` | Search, add product (`POST /uploads` PRODUCT, `POST /products`) |
| Agent details | `/admin/agents/:id` | `273:153` | `GET /agents/:id`, `/timeline`, `/track`, `GET /photos?agentId`, `GET /audits?agentId` | Call, PDF/XLS export |
