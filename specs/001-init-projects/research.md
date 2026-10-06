# Research: Fresh Apps With Pixel-Perfect Designed Screens

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-06

This supersedes the earlier research. It follows constitution v2.1.0: Principle I (pixel-perfect
design) and Principle IV (official starters, nothing extra).

## R-01 Starters

- **Decision**:
  - **Admin web**: `pnpm create next-app@latest apps/admin-web` with its defaults (TypeScript,
    ESLint, Tailwind, App Router, `src/`, `@/*` alias).
  - **Mobile**: `flutter create --org com.auditapp --project-name audit_mobile --platforms
    android,ios apps/mobile`.
  - **API**: `npx fastify-cli generate apps/api --lang=ts --esm`, then `npx prisma init
    --datasource-provider postgresql` inside it.
  - Each generated project keeps its own configuration, `.gitignore`, README and test setup as
    generated.
- **Rationale**: Principle IV, and it's what the user asked for: the frameworks' documented
  quick starts.
- **Alternatives**: hand-assembled packages, which is the previous approach and was rejected by
  the user.

## R-02 Repository root

- **Decision**: keep only:
  - a minimal root `package.json` with `dev`/`lint`/`test` scripts that call each app
  - `pnpm-workspace.yaml` listing `apps/api` and `apps/admin-web`
  - the root `.gitignore` for OS and IDE files
  - `README.md`
  - `.github/workflows/ci.yml` (required by the constitution's quality gates)
  - the design references, `.specify/` and `specs/`

  Remove `docker-compose.yml`, `scripts/`, `.editorconfig`, `.prettierrc`, `.prettierignore`,
  `.nvmrc` and the root `.env.example`. Each starter manages its own env files: `prisma init`
  creates `apps/api/.env`, and Next uses `.env.local`.
- **History**: the existing `2dcdfff` commit on `001-init-projects` (not pushed) is replaced by a
  clean commit, so the unwanted files never appear in history.

## R-03 Exact design values

- **Decision**: use a single set of theme values per client, copied from the CSS exports (named
  styles such as "Light Mobile/Accent #493EE5" and "Dark Mobile/Main bg #0B0F19", plus the
  measured sizes):
  - **Web**: CSS variables in `globals.css`, mapped into Tailwind's `@theme`. Tailwind's spacing
    and arbitrary values are written in exact px from the CSS, e.g. `gap-[18px]`, whenever the
    design value is not on the scale.
  - **Mobile**: an `AppColors` light/dark palette, `AppTextStyles` (Inter, with sizes, weights and
    line heights from the CSS), and `AppSpacing`/`AppRadii` constants, wired into `ThemeData` and
    a `ThemeExtension`.
- **How each screen is built**: read the frame's block in the CSS (auto-layout direction, gap,
  padding, width and height, font) and reproduce it with flex/Row/Column using the same
  numbers.

## R-04 Fonts

- **Decision**:
  - **Web**: Inter (body and UI) and Space Grotesk (KPI numbers, as in `admin-design.css`) via
    `next/font/google`, with the latin and cyrillic subsets. Liberation Mono appears once
    (coordinates) and is mapped to the system monospace stack.
  - **Mobile**: Inter bundled as an asset (weights 400/500/600/700/800 are used) and declared in
    `pubspec.yaml`, so text renders the same offline and identically on Android and iOS.

## R-05 Icons

- **Decision**: the icon vectors match **Material Symbols Outlined** (weight 400, grade 0, optical
  size 20–24).
  - **Web**: the `material-symbols` font package, through one `<Icon name>` component.
  - **Mobile**: the `material_symbols_icons` package.
  - The one `akar-icons:clock` glyph used in the salesman route timeline is added as an inline SVG.
- **Rationale**: the same set is used on both clients, as Principle I requires for standard icon
  sets.

## R-06 Images and map backgrounds

- **Decision**: the user exports every image from the Figma file into `design-assets/`, following
  [contracts/assets.md](./contracts/assets.md): photos, map backgrounds, markers, logo and any
  non-Material icons. The implementation copies them to `public/sample/` (web) and
  `assets/sample/` (mobile). Nothing is cropped from the screenshots.
- **Maps**: `MapCanvas` shows the exported map background with markers positioned at the design
  coordinates (from the CSS `left`/`top`). Interactive tile maps are deferred to the map feature
  (spec FR-008).

## R-07 Sample data behind the data layer

- **Decision**: each feature has a repository interface. This feature implements it with sample
  repositories that return the exact content shown in the designs (data-model.md). Screens only
  talk to the repository:
  - **Web**: `features/<f>/data/` (server-side functions).
  - **Mobile**: `features/<f>/data/` with Riverpod providers.

  Later features swap in API-backed repositories.
- **Rationale**: Principle II (clean architecture) without building the API yet.

## R-08 Mobile architecture and packages

- **Decision**: keep the `flutter create` structure and add:
  - **flutter_riverpod**: dependency injection and state
  - **go_router**: role-based routing, as in contracts/screens.md
  - **flutter_localizations / intl** with gen-l10n: RU and EN
  - **material_symbols_icons**: icons

  The theme mode (system/light/dark) and locale are app state toggled on Home. The debug role
  picker stays until auth exists. Nothing else is added: no dio, package_info or drift until a
  feature needs them.

## R-09 Admin web packages

- **Decision**: the create-next-app defaults plus:
  - **next-intl**: RU/EN
  - **material-symbols**: icons

  No component library. The design is custom, and a library would fight pixel-matching.

## R-10 API

- **Decision**: use the Fastify TS/ESM template as generated (its `app.ts`, `plugins/`, `routes/`,
  `test/` and `tsconfig`), plus `prisma init`. No endpoints are added in this feature, since the
  screens use sample repositories. The previous health/version/CORS work is dropped (YAGNI) and
  returns when the first real data feature needs it.

## R-11 Verifying pixel accuracy

- **Decision**:
  - **Web**: headless Chrome screenshots at 1440 × 900
    (`google-chrome --headless --window-size=1440,900 --screenshot`), compared side by side with
    the PNG.
  - **Mobile**: screenshots from the connected phone with `adb exec-out screencap`, or a
    390-wide emulator, compared with the PNG at the same scale, light and dark.

  The screenshots are review evidence and are not committed. No visual-regression tooling is
  added for now (Principle IV).

## R-12 Tests

- **Decision**: following Principle V, tests cover logic only:
  - **Mobile**: the role redirect and the role-to-screen mapping.
  - **Web**: the locale message parity check, using the starter's test runner. Next has none by
    default, so Vitest is added with a one-line justification.
  - **API**: the starter's generated tests run unchanged.

  Screen composition is verified visually, as R-11 describes.

## R-13 CI

- **Decision**: keep a single `ci.yml` with three jobs that run each starter's own scripts:
  - **admin-web**: `lint`, `build`, `test`
  - **mobile**: `flutter analyze`, `flutter test`
  - **api**: `npm test` (generated)

  No path filters or extra checks.
