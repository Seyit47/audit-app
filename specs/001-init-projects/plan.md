# Implementation Plan: Fresh Apps With Pixel-Perfect Designed Screens

**Branch**: `001-init-projects` | **Date**: 2026-10-06 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-init-projects/spec.md` (rescoped 2026-10-06)

## Summary

Delete the current apps and recreate them with the official starters: `create-next-app`,
`flutter create`, and `fastify generate` plus `prisma init`. Then build all 30 design frames
pixel-perfect ([contracts/screens.md](./contracts/screens.md)):

- 11 admin web frames at 1440 × 900
- 11 agent mobile frames at 390 pt, light and dark
- 10 admin mobile frames

Exact values come from the CSS exports, defined once as theme values per client. Shared
components are built once and reused. Screens read sample content through each feature's data
layer, so real data can replace it later. Photos, map backgrounds and the logo come from Figma exports
([contracts/assets.md](./contracts/assets.md)). The API stays as the bare Fastify starter until a data feature needs it.

## Technical Context

**Language/Version**: TypeScript (Next.js starter and Fastify TS starter defaults); Dart 3 with
Flutter 3.47

**Primary Dependencies**:
- **Admin web**: Next.js App Router + React + Tailwind (starter defaults), next-intl, material-symbols
- **Mobile**: Flutter (starter), flutter_riverpod, go_router, flutter_localizations + intl
  (gen-l10n), material_symbols_icons, Inter bundled as an asset
- **API**: Fastify TS/ESM starter, Prisma (`prisma init` only)

**Storage**: none in this feature. Sample repositories serve the design content.

**Testing**: the starters' own test setups. Mobile `flutter test` covers role routing. The web
uses Vitest for the message-parity test (justified below). The API runs its generated tests.
Pixel accuracy is checked with screenshot comparisons (research R-11).

**Target Platform**: desktop browsers, with the reference at 1440 × 900; Android and iOS phones,
with the reference at 390 pt wide

**Project Type**: monorepo with a web app, a mobile app and an API starter

**Performance Goals**: mobile first frame under 2 s on cold start (SC-005)

**Constraints**: pixel-perfect against the PNGs. No files beyond the starters except those
justified below.

**Scale/Scope**: 30 frames (about 24 distinct screens plus interaction states), with about 15
shared components per client

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Result |
|-----------|-------|--------|
| I. Pixel-Perfect Design | Every frame mapped to a route and state (contracts/screens.md). Values from the CSS, defined once as theme values. Side-by-side check per frame. Same icon set (Material Symbols). Images exported from Figma | PASS |
| II. Clean Architecture | Web and mobile: `features/<f>/{data,presentation}` with repository interfaces. Screens never read data directly. The API is left as the starter | PASS |
| III. Clean, Reusable Code | Shared component lists in contracts/screens.md, built once per client. Starter linters | PASS |
| IV. Simplicity First | Fresh official starters, generated config kept, root trimmed to the essentials, no extra tooling. Additions justified below | PASS |
| V. Test-First | Logic tests (role redirect, add-shop and audit button-enabling rules, locale parity) written first. Screen composition is visual-check only, as allowed | PASS |
| VI. Offline-First | No agent data persisted yet (sample only) | N/A |
| VII. Evidence Integrity | No audit submission yet | N/A |
| VIII. Security & Roles | Role-based routes. Debug role picker until auth (see Complexity Tracking) | PASS with note |
| Stack & gates | Next.js, Flutter, Fastify + Prisma. CI runs each starter's lint/test/build | PASS |

Post-design re-check: PASS.

### Justified additions beyond the starters (Principle IV)

| Addition | Why |
|----------|-----|
| Root `package.json` + `pnpm-workspace.yaml` | Monorepo with pnpm workspaces (Technology Stack) |
| `.github/workflows/ci.yml` | Constitution quality gate |
| `next-intl` + `messages/{ru,en}.json`, `src/i18n/*`, `src/proxy.ts` | RU/EN required. This is next-intl's documented setup |
| `material-symbols` (web) / `material_symbols_icons` (mobile) | The design's icon set (Principle I) |
| Vitest + `vitest.config.ts` in admin-web | Next's starter has no test runner. Used only for the locale-parity test |
| `flutter_riverpod`, `go_router` | DI/state and role-based routing (Principles II and VIII) |
| `l10n.yaml`, `lib/l10n/*.arb` | Flutter's documented gen-l10n setup for RU/EN |
| Inter font files in `apps/mobile/assets/fonts/` | Exact typography offline (research R-04) |
| `public/sample/*`, `assets/sample/*` images | Exported from Figma (contracts/assets.md) |

## Project Structure

### Documentation (this feature)

```text
specs/001-init-projects/
├── spec.md               # rescoped 2026-10-06
├── plan.md
├── research.md           # R-01 … R-13
├── data-model.md         # sample-data shapes from the designs
├── quickstart.md         # run + pixel-check guide
├── contracts/screens.md  # frame → route/state inventory + shared components
├── contracts/assets.md   # images to export from Figma
└── tasks.md              # /speckit-tasks
```

### Source Code (repository root)

```text
package.json  pnpm-workspace.yaml  pnpm-lock.yaml  .gitignore  README.md
.github/workflows/ci.yml
*-design.css  *-design-png/                      # design references (unchanged)

apps/admin-web/                                  # create-next-app (generated files kept)
├── messages/{ru,en}.json
├── public/sample/                               # Figma-exported photos + maps
└── src/
    ├── app/[locale]/
    │   ├── layout.tsx                           # fonts, providers
    │   └── (admin)/                             # Sidebar + Topbar layout
    │       ├── map/  shops/  shops/[id]/  products/  salesmen/  salesmen/[id]/
    │       ├── pictures/  dashboard/  settings/
    ├── components/ui/                           # shared building blocks (contracts/screens.md)
    ├── components/layout/                       # Sidebar, Topbar
    ├── features/{shops,map,products,salesmen,pictures}/
    │   ├── data/                                # repository interface + sample implementation
    │   └── components/                          # feature-specific UI
    ├── i18n/  proxy.ts
    └── app/globals.css                          # design theme values (CSS vars → Tailwind @theme)

apps/mobile/                                     # flutter create (generated files kept)
├── assets/{fonts,sample}/
├── l10n.yaml
└── lib/
    ├── main.dart  app.dart
    ├── core/
    │   ├── theme/                               # AppColors light/dark, AppTextStyles, spacing, radii
    │   ├── l10n/                                # app_ru.arb (template), app_en.arb
    │   ├── router/                              # go_router + role redirect
    │   ├── settings/                            # theme mode + locale state
    │   └── widgets/                             # shared building blocks (contracts/screens.md)
    └── features/
        ├── session/                             # role, debug role picker
        ├── home/  shops/  shop_details/  add_shop/  audit/  map/  gallery/  agents/
        │   └── {data,presentation}/             # sample repository + screens/widgets

apps/api/                                        # fastify generate --lang=ts --esm (as generated)
└── prisma/schema.prisma  .env                   # prisma init (.env git-ignored)
```

**Structure Decision**: three apps under `apps/`, each exactly as its starter generates it plus
the feature folders above. Screens that differ between the mobile roles (shops, shop details,
home) get role-specific presentation built from shared widgets. Screens that are the same in
both roles (gallery, map, add shop) are built once with role-dependent parts (for example, the
Agent field on add shop).

## Complexity Tracking

| Item | Why Needed | Simpler Alternative Rejected Because |
|------|------------|-------------------------------------|
| Debug-only role picker (Principle VIII expects the role from an authenticated session) | Both role UIs must be reachable to build and check them before sign-in exists | Building auth now is out of scope. The picker writes the same session state that auth will use |
| Static map backgrounds instead of an interactive map | The design maps must be reproduced exactly (FR-008) | A tile map can't match the design pixels and isn't needed until there is real location data |

## Implementation Notes

- **Order**: starters (US4), then the theme values and shared components per client, then screens
  in the order of contracts/screens.md, with interaction states last.
- **Building each screen**: open its CSS block. Copy the auto-layout direction, gap, padding,
  sizes and type exactly. Capture a screenshot and compare it with the PNG. Fix differences
  before moving on.
- **History**: the unpushed commit `2dcdfff` is replaced so that the removed files never appear
  in history.
