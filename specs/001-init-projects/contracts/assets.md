# Contract: Design Assets to Export From Figma

These replace cropping from the screenshots (research R-06). Put everything in a root folder
named `design-assets/` using the names below. I'll place the files into the apps.

**Formats**
- **Photos**: JPG at 2× (and 3× for mobile if convenient), exported from the image fill at its
  largest displayed size.
- **Maps, logo, illustrations, custom icons**: SVG. Use PNG at 2× only if a map is a raster
  image in Figma.
- If an image appears on several screens, export it once.

Fonts don't need exporting. Inter and Space Grotesk come from Google Fonts.

## 1. Brand

| File | What | Used in |
|------|------|---------|
| `brand/logo-mark.svg` | Crosshair/target logo mark next to "COMPANY NAME" in the sidebar | Admin web, all screens |
| `brand/app-icon.png` (1024×1024) | App icon, if one exists in Figma | Mobile launcher |

## 2. Map backgrounds

| File | What | Used in |
|------|------|---------|
| `maps/admin-map.svg` | Stylized map with region polygon, roads and water (the full map area) | W1, W2 (Map) |
| `maps/admin-shop-geo.png` | "Geographic Distribution" map of Ashgabat (Hayrat Market, airport, Gulistan) | W5 (Shop details) |
| `maps/admin-salesman-route.svg` | "Маршрут и трекинг сотрудника" route map | W9 (Salesman details) |
| `maps/mobile-map.svg` | Full-screen map, the "SVG Realistic Map Background (Ashgabat C…)" layer, 390×844 | A4, A5, M4, M5 |
| `maps/mobile-map-dark.svg` | Dark version of the full-screen map, if it differs | A4, A5 dark |
| `maps/mobile-shop-geo.png` | "Геолокация объекта" small map | M3 (admin Shop details) |
| `maps/mobile-agent-route.png` | "Маршрут и трекинг" map | M10 (Agent details) |

Please also export the **map markers** if they are custom shapes:
- `maps/marker-photo.svg`: pin frame around a shop photo; the red, green and grey variants on mobile.
- `maps/marker-shop.svg`: the green round shop icon on the admin map.
- `maps/marker-cluster.svg`: the round count badges (128, 64, 32) on the admin map.
- `maps/marker-me.svg`: the "you are here" blue dot.

## 3. Shop storefront photos

Export one file per distinct shop. Each is used as a list thumbnail, details header and map pin
image.

| File | Shop / where seen |
|------|-------------------|
| `shops/noor-retail-group.jpg` | Noor Retail Group header (W5), edit dialog facade photo (W6), Pictures detail header (W11) |
| `shops/kamil-market.jpg` | Kamil market (W2 popup, M3 header) |
| `shops/altyn.jpg` | Магазин Алтын (A2, A3, A5, A7, M5, M7) |
| `shops/sunrise-corner.jpg` | Sunrise Corner Shop (A2) |
| `shops/hazar.jpg` | Магазин Хазар (A2) |
| `shops/yunus.jpg` | Магазин Юнус (A2) |
| `shops/al-noor.jpg`, `shops/city-fresh.jpg`, `shops/u-doma-14.jpg` | Admin mobile shop cards (M2), if they have photos |
| `shops/vesna.jpg`, `shops/udacha.jpg` | Visit history thumbnails «Весна», «Удача» (W5, W9, M10) |
| `shops/zad-alyoum.jpg` | "ZAD ALYOUM MINI MART" storefront in Add shop filled (A9, M8b) |

## 4. Audit and gallery photos

Export every distinct photo once. The screens reuse them in different orders.

| File pattern | What | Seen in |
|--------------|------|---------|
| `photos/shelf-01.jpg` … `shelf-NN.jpg` | Shelf/aisle photos: drinks, snacks, dairy, cosmetics shelves, "ALTYN" shelf | W5, W9, W10, A3, A6, A7, A11, M3, M6, M10 |
| `photos/storefront-01.jpg` … | Exterior photos: mall with palms, "CITY FRESH LOCAL MARKET", supermarket entrances | W10, W11, A6, M6 |
| `photos/checkout-01.jpg` … | Cashier/counter photos | W10, A11 |
| `photos/hero-chips-shelf.jpg` | Large chips shelf photo at the top of admin Gallery detail | M7 |
| `photos/pictures-detail.jpg` | Large mall photo in the Pictures detail panel | W11 |

As a guide, Pictures (W10) shows 20 tiles, audit finish (A11) 7, the galleries (A6, M6) about 30
tiles built from about 8 distinct images, and the history rows show 5–8 thumbnails each.
Exporting the **unique image fills** covers all of them.

## 5. Products

| File | Product (W7) |
|------|--------------|
| `products/loreal-pro-keratin.jpg` | L'Oréal Pro Keratin Set |
| `products/argan-elixir.jpg` | Argan Elixir Hair Oil 100ml |
| `products/olaplex-no3.jpg` | Olaplex Bond No. 3 Repair |
| `products/matrix-color-protect.jpg` | Matrix Color Protect Shampoo |
| `products/schwarzkopf-silhouette.jpg` | Schwarzkopf Silhouette Spray |

## 6. People

| File | What | Used in |
|------|------|---------|
| `people/admin-avatar.*` | Top-right profile avatar, if it is a photo (it looks like an icon) | Admin web |
| `people/user-avatar.*` | Home screen avatar, if it is a photo | A1, M1 |
| `people/agent-*.jpg` | Agent photos, if any agent shows a photo instead of initials | W8, M9 |

## 7. Icons (only if they are not Material Symbols)

The plan assumes the icons are **Material Symbols Outlined**. If the Figma file uses a different
or custom icon library, please either tell me its name, or export the icons used as 24×24 SVGs
into `icons/` with descriptive names (e.g. `icons/storefront.svg`). The known exception is
`akar-icons:clock` in the salesman timeline. Please export it as `icons/clock.svg`.
