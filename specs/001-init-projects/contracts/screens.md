# Contract: Screen Inventory

Every design frame, mapped to where it is implemented. A frame counts as done when its route or
state matches the screenshot at the reference size (Constitution I). The **Lang** column is the
language the frame is compared in.

## Admin web: 1440 × 900 (`admin-design-png/`, `admin-design.css`)

| # | Frame | Route | State | Lang |
|---|-------|-------|-------|------|
| W1 | `Map (1).png` | `/map` | Default map with markers and cluster counts | RU |
| W2 | `Map.png` | `/map` | Shop popup open (left card) + Filters panel open (right) | RU |
| W3 | `Shops.png` | `/shops` | List with row "more" menu open on the first row | EN |
| W4 | `Shops (1).png` | `/shops` | Three rows selected, bulk actions (Assign salesman, View on Map, Delete Shop) in the header | EN |
| W5 | `Shops _ Details.png` | `/shops/[id]` | Shop header, stats, geographic distribution, visit history | EN |
| W6 | `Shops _ Details (1).png` | `/shops/[id]` | Edit shop dialog open over the details page | RU (dialog) |
| W7 | `Products.png` | `/products` | KPI cards, filters, product table | EN |
| W8 | `Salesman.png` | `/salesmen` | KPI cards, date filters, salesman table | EN |
| W9 | `Salesman details.png` | `/salesmen/[id]` | Activity history, route map, audit photo reports, visit history (1440 × 1578, scrolls) | RU |
| W10 | `Pictures.png` | `/pictures` | Photo grid with filters | EN |
| W11 | `Pictures (1).png` | `/pictures` | Photo detail side panel open | EN |

Sidebar order: Dashboard, Map, Shops, Products, Salesmen, Pictures, Settings. The RU labels
(Аналитика, Карта, Клиенты, Продукции, Агенты, Галерея, Настройки) come from W1/W2. The EN
labels come from the other frames. `/` redirects to `/shops`. `/dashboard` and `/settings` show
only a page header (no design yet).

## Mobile, Agent role: 390 pt, light and dark (`mobile-agent-design-png/`, `mobile-agent-design.css`, `mobile-agent-dark-design.css`)

| # | Frame | Route | State |
|---|-------|-------|-------|
| A1 | `home.png` | `/agent` | Start audit hero, My shops, Map, Gallery tiles; theme and RU/EN toggles; sync status |
| A2 | `shops.png` | `/agent/shops` | Search, status chips, shop list |
| A3 | `shop details.png` | `/agent/shops/:id` | Shop header, contact, visit status, Map/Audit buttons, audit history |
| A4 | `map.png` | `/agent/map` | Map with markers and filter chips, nothing selected |
| A5 | `map (1).png` | `/agent/map` | Marker selected → bottom sheet with "start audit" disabled outside geofence |
| A6 | `gallery.png` | `/agent/gallery` | Grouped photo grid by date |
| A7 | `gallery (1).png` | `/agent/gallery/:photoId` | Photo detail: shop, violation note, related audit photos |
| A8 | `add shop.png` | `/agent/shops/new` | Empty form, no photo, Save disabled |
| A9 | `add shop (1).png` | `/agent/shops/new` | Filled form, storefront photo captured, Save enabled |
| A10 | `audit.png` | `/agent/shops/:id/audit` | Locating, no POSM photo, Finish disabled |
| A11 | `audit finish.png` | `/agent/shops/:id/audit` | Shop resolved, 7 photos, comment filled, Finish enabled |

Each A-frame also has a dark version in `mobile-agent-dark-design.css`, matched with the dark
theme.

## Mobile, Admin role: 390 pt, light (`mobile-admin-design-png/`, `mobile-admin-design.css`)

| # | Frame | Route | State |
|---|-------|-------|-------|
| M1 | `home (1).png` | `/admin` | Map, Shops, Gallery, Agents, Products tiles; theme and RU/EN toggles |
| M2 | `shops.png` | `/admin/shops` | Search, total and sort, shop cards with Details/call/navigate |
| M3 | `Shop details.png` | `/admin/shops/:id` | KPIs, address and agent, audit photo reports, geolocation map, audit history |
| M4 | `map.png` | `/admin/map` | Map, nothing selected |
| M5 | `map (1).png` | `/admin/map` | Marker selected → sheet with agent and "Details" |
| M6 | `gallery.png` | `/admin/gallery` | Grouped photo grid |
| M7 | `gallery (1).png` | `/admin/gallery/:photoId` | Hero photo, shop card, agent, violation, related photos |
| M8 | `add shop.png` | `/admin/shops/new` | Empty form with Agent field, open gallery or take photo |
| M8b | `Map.zip → add/edit shop.png` | `/admin/shops/new` | Filled form with storefront photo, Save enabled |
| M9 | `Агенты.png` | `/admin/agents` | KPI cards, agent cards |
| M10 | `Агенты details.png` | `/admin/agents/:id` | Agent KPIs, route and tracking map, checkpoint history, photo reports, visit history |

Admin Products (tile on M1) has no mobile design. The tile opens a page header only.

## Shared building blocks (built once per client, Constitution III)

- **Web**: Sidebar, Topbar, PageHeader (title + "Operations Live" badge + actions), StatCard,
  FilterSelect, FilterChip, SearchField, DataTable (checkbox, sortable header, pagination),
  StatusBadge, Avatar/initials, RowMenu, Dialog, SidePanel, PhotoTile, VisitHistoryItem,
  MapCanvas (static background + positioned markers).
- **Mobile**: AppTopBar (back + title + actions), SearchField, FilterChips, ShopListTile,
  ShopCard (admin), StatTile, SectionHeader, PhotoGrid, AuditHistoryItem, ViolationNote,
  FormField, PrimaryButton/SecondaryButton (enabled and disabled), PhotoPlaceholder,
  MapCanvas, BottomSheetCard, HomeActionTile, ThemeToggle, LocaleToggle.
