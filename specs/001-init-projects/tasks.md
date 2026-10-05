---

description: "Task list for feature 001-init-projects (Project Foundation), constitution v2.0.0"
---

# Tasks: Project Foundation (Init Projects)

**Input**: Design documents from `/specs/001-init-projects/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/api.md,
contracts/mobile-navigation.md, quickstart.md

**Tests**: Included. Constitution Principle IV (Test-First) applies to business logic, API
endpoints and critical flows. Test tasks come before their implementation, and each test must be
run and seen to fail before the code that makes it pass is written. Simple UI composition is not
test-first.

**Organization**: Grouped by user story (US1–US4 from spec.md).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on unfinished tasks)
- **[Story]**: User story the task belongs to

## Path Conventions (from plan.md)

- API (Fastify): `apps/api/src/`, `apps/api/test/{unit,integration}/`, `apps/api/prisma/`
- Admin web (Next.js): `apps/admin-web/src/`, `apps/admin-web/messages/`
- Mobile (Flutter): `apps/mobile/lib/`, `apps/mobile/test/`

---

## Phase 1: Setup

**Purpose**: Remove leftovers from the old plan and generate the three projects with their
framework CLIs.

- [X] T001 Delete leftovers from the superseded plan: `packages/`, `apps/api/`, `apps/admin-web/`, `apps/mobile/` (it only holds the generated `lib/src/theme/tokens.g.dart`), the root `eslint.config.mjs`, `tsconfig.base.json` and `pnpm-lock.yaml`, and `node_modules/`. Keep `.gitignore`, `.nvmrc`, `.editorconfig`, `.prettierrc`, `.prettierignore`, `.env.example`, `docker-compose.yml` and `scripts/db/init.sql`
- [X] T002 Rewrite the root `package.json`: private, `packageManager` pnpm pinned, `engines.node` `>=24 <25`, and scripts `dev` (`pnpm --parallel --filter api --filter admin-web dev`), `lint` (`pnpm -r lint`), `typecheck` (`pnpm -r typecheck`) and `test` (`pnpm -r test`). Set `pnpm-workspace.yaml` packages to `apps/api` and `apps/admin-web`. Remove the `packages/*` entries from `.gitignore` and `.prettierignore`
- [X] T003 [P] Create the API package by hand (no generator): `apps/api/package.json` (name `api`, version `0.1.0`, `type: module`; scripts `dev` (`tsx watch --env-file-if-exists=../../.env src/server.ts`), `build` (`tsc`), `start`, `lint` (`eslint .`), `typecheck` (`tsc --noEmit`), `test` (`vitest run`), `prisma:migrate` (`prisma migrate deploy`), `prisma:status` (`prisma migrate status`)), `tsconfig.json` (strict, NodeNext, outDir `dist`), `eslint.config.mjs` (typescript-eslint recommended) and `vitest.config.ts`. Dependencies: fastify, @fastify/type-provider-typebox, @sinclair/typebox, @fastify/swagger, @fastify/swagger-ui, @prisma/client, @prisma/adapter-pg, zod. Dev dependencies: prisma, typescript, tsx, vitest, @types/node, eslint, @eslint/js, typescript-eslint
- [X] T004 [P] Generate the admin web with `pnpm create next-app@latest apps/admin-web --ts --tailwind --eslint --app --src-dir --import-alias "@/*" --use-pnpm --skip-install`. Set the package name to `admin-web` and version `0.1.0`, the dev and start port to 3001, and add `typecheck: tsc --noEmit` and `test: vitest run` scripts in `apps/admin-web/package.json`
- [X] T005 [P] Generate the mobile app with `flutter create --org com.auditapp --project-name audit_mobile --platforms android,ios apps/mobile`. Set version `0.1.0+1` in `apps/mobile/pubspec.yaml` and add the dependencies flutter_riverpod, go_router, dio, flutter_localizations (sdk), intl and package_info_plus, plus the dev dependency mocktail. Enable `flutter: generate: true`. Delete the counter demo in `lib/main.dart` and `test/widget_test.dart`
- [X] T006 Run `pnpm install` at the root and `flutter pub get` in `apps/mobile`; commit the lockfiles

**Checkpoint**: Three generated projects build. `pnpm -r lint` and `flutter analyze` are clean.

---

## Phase 2: Foundational (blocks all stories)

**Purpose**: Configuration, error handling, logging, database access, i18n, theme and the HTTP
client in each app.

### API

- [X] T007 [P] Write a failing unit test `apps/api/test/unit/env.test.ts`. `loadEnv(env)` must throw an error naming `DATABASE_URL` when it is missing, and reject a non-semver `MIN_MOBILE_VERSION` and an `APP_ENV` that is not `"development" | "staging" | "production"`. Defaults: `PORT` 3000, `APP_ENV` `development`, `LOG_LEVEL` `info`
- [X] T008 Implement `apps/api/src/config/env.ts` (a zod schema, `loadEnv(source = process.env)` returning a typed `Env`, with an error message that lists every invalid variable by name) so T007 passes
- [X] T009 [P] Write a failing unit test `apps/api/test/unit/error-handler.test.ts` on a bare Fastify instance with the handler registered. It must return `{ error: { code, message, details? }, requestId }` where `code` is uppercase snake case: an unknown route gives 404 `NOT_FOUND`, a schema validation failure gives 400 `VALIDATION_FAILED` with `details` listing the fields, an `AppError(409, 'CONFLICT', ...)` passes through, and any other error gives 500 `INTERNAL_ERROR` without leaking its message or stack
- [X] T010 Implement `apps/api/src/errors/app-error.ts` (the `AppError` class with `statusCode`, `code`, `message`, `details?`) and `apps/api/src/errors/error-handler.ts` (`registerErrorHandling(app)` calling `setErrorHandler` and `setNotFoundHandler`) so T009 passes
- [X] T011 Set up Prisma: `apps/api/prisma/schema.prisma` (postgresql, generator `prisma-client` with output `../src/generated/prisma`, no models), `apps/api/prisma.config.ts` (schema path, migrations path, `datasource.url` from `DATABASE_URL`) and the empty initial migration `apps/api/prisma/migrations/0000_init/migration.sql`. Add `src/generated/` to `.gitignore` and a `postinstall: prisma generate` script
- [X] T012 Implement `apps/api/src/lib/prisma.ts` (`createPrismaClient(databaseUrl)` using `PrismaPg` with a 2 s connection timeout; Prisma connects lazily, so the API starts while the database is down) and `apps/api/src/lib/logger.ts` (pino options: level from env, redact `req.headers.authorization` and `req.headers.cookie`, plus a `genReqId` that reuses an incoming `X-Request-Id` of up to 128 chars or else generates `randomUUID()`)
- [X] T013 Implement `apps/api/src/app.ts` (`buildApp({ env, prisma })`: Fastify with the TypeBox type provider, the logger options from T012, an `onSend` hook setting the `X-Request-Id` header, `registerErrorHandling`, `@fastify/swagger` + `@fastify/swagger-ui` at `/docs`, and module routes registered under the `/v1` prefix) and `apps/api/src/server.ts` (calls `loadEnv()`, printing the error and exiting 1 on failure; builds the app; listens on `PORT`; closes Prisma on shutdown)
- [X] T014 [P] Create the test helper `apps/api/test/helpers/app.ts`. `buildTestApp(overrides?)` loads the env with `DATABASE_URL` set to `DATABASE_URL_TEST` (failing with a clear message if that is unset), creates a Prisma client and calls `buildApp`. Also add `UNREACHABLE_DATABASE_URL = 'postgresql://audit:x@127.0.0.1:1/none'`

### Admin web

- [X] T015 [P] Set the theme once in `apps/admin-web/src/app/globals.css`: CSS variables on `:root` for light (`--color-accent #493EE5`, `--color-bg #FBF8FF`, `--color-surface #FFFFFF`, `--color-text #0F172A`, `--color-text-muted #62617B`, `--color-border #D0D0E9`, `--color-success #00685A`, `--color-error #CE3437`) and a `prefers-color-scheme: dark` block (`--color-bg #0B0F19`, `--color-surface #121A2C`, `--color-text #FCFDFF`, `--color-text-muted #94A3B8`, `--color-success #25D998`, `--color-error #FDA4AF`), mapped in Tailwind `@theme inline`. Load Inter via `next/font/google` (latin and cyrillic) in the root layout
- [X] T016 Set up next-intl: `apps/admin-web/src/i18n/routing.ts` (locales `ru`, `en`, default `ru`, `localePrefix: 'as-needed'`), `src/i18n/navigation.ts`, `src/i18n/request.ts`, `src/middleware.ts`, the plugin in `next.config.ts`, and `messages/ru.json` and `messages/en.json` with `nav.*`, `topbar.*`, `status.*` (`checking`, `connected` with `{version}`, `unreachable`, `retry`, `updateRequired`) and `common.comingSoon`. Move the root layout to `src/app/[locale]/layout.tsx` with `NextIntlClientProvider`
- [X] T017 [P] Implement `apps/admin-web/src/lib/env.ts`, which exports `apiBaseUrl()` and throws an error naming `NEXT_PUBLIC_API_BASE_URL` when it is missing, and `apps/admin-web/src/lib/http.ts`, a typed `getJson<T>(path)` wrapper over `fetch` that sends `X-Client-Name: admin-web` and maps non-2xx `ApiError` bodies and network failures to an `HttpError { status, code }`
- [X] T018 [P] Set up Vitest: `apps/admin-web/vitest.config.ts` (jsdom, `@` alias, React plugin), `tests/setup.ts` (jest-dom), and `tests/render.tsx` (a `renderWithIntl(ui, locale = 'ru')` helper). Add the dev dependencies vitest, @vitejs/plugin-react, jsdom, @testing-library/react and @testing-library/jest-dom

### Mobile

- [X] T019 [P] Create `apps/mobile/env/dev.json` (`API_BASE_URL: http://10.0.2.2:3000`, `APP_ENV: development`) and `apps/mobile/env/prod.json`, and `apps/mobile/lib/core/config/app_config.dart` (`AppConfig.fromEnvironment()` reading `String.fromEnvironment`, throwing a `StateError` naming `API_BASE_URL` when it is empty)
- [X] T020 [P] Implement the theme once: `apps/mobile/lib/core/theme/app_colors.dart` (light and dark palettes using the values from T015, plus accent `#493EE5`) and `apps/mobile/lib/core/theme/app_theme.dart` (`AppTheme.light` and `AppTheme.dark` `ThemeData` built only from `AppColors`, Material 3, radius 12 for cards and buttons)
- [X] T021 [P] Set up localization: `apps/mobile/l10n.yaml` (`arb-dir: lib/core/l10n`, `template-arb-file: app_ru.arb`, `untranslated-messages-file: untranslated.json`, `output-class: AppLocalizations`) and `lib/core/l10n/app_ru.arb` and `app_en.arb` with the keys `navHome`, `navShops`, `navMap`, `navGallery`, `navAgents`, `roleAgent`, `roleAdmin`, `rolePickerTitle`, `switchRole`, `signInPlaceholder`, `statusChecking`, `statusConnected` (with a `{version}` placeholder), `statusUnreachable`, `retry`, `updateRequired` and `comingSoon`
- [X] T022 [P] Implement `apps/mobile/lib/core/network/api_client.dart`: a Riverpod `dioProvider` (base URL from `AppConfig`, the headers `X-Client-Name: mobile` and `X-Client-Version` from `package_info_plus`, 10 s timeouts) and an `ApiException` that maps a `DioException` to `{statusCode, code}`
- [X] T023 Implement `apps/mobile/lib/main.dart` (`ProviderScope`) and `apps/mobile/lib/app.dart` (`MaterialApp.router` with `AppTheme.light` and `dark`, `ThemeMode.system`, localization delegates, `supportedLocales` ru and en, and a temporary router with one `/` route showing an empty `Scaffold`) (depends on T019–T022)
- [X] T024 [P] Add the test helper `apps/mobile/test/helpers/pump_app.dart`, which wraps a widget in `ProviderScope` (with overrides), `MaterialApp` with the localization delegates, locale `ru` and `AppTheme.light`

**Checkpoint**: Each app starts. The API fails fast on missing env vars, and errors come back in
one format.

---

## Phase 3: User Story 1 - Run the whole platform locally (P1) 🎯 MVP

**Goal**: The `/v1/health` and `/v1/version` endpoints. The admin web shell with the backend
status. Mobile status and "update required" handling.

**Independent Test**: quickstart.md §1–§2.

### Tests for User Story 1 (write first, confirm they fail)

- [X] T025 [P] [US1] Unit test `apps/api/test/unit/health.service.test.ts` with a fake `HealthRepository` passed to the constructor. `isDatabaseUp()` true gives `{ status: 'ok', checks: { database: 'ok' } }`, false gives `{ status: 'degraded', checks: { database: 'down' } }`, and the result includes `version`, `uptimeSeconds` (an integer ≥ 0) and `timestamp` (ISO UTC)
- [X] T026 [P] [US1] Integration test `apps/api/test/integration/health.test.ts` against the real `audit_test` database via `app.inject`. `GET /v1/health` returns 200 `status: "ok"` with an `X-Request-Id` header. With `UNREACHABLE_DATABASE_URL`, the app still builds and `GET /v1/health` returns 503 `status: "degraded"` within 3 s
- [X] T027 [P] [US1] Integration test `apps/api/test/integration/version.test.ts`. `GET /v1/version` returns exactly `{ serverVersion, minMobileVersion, minAdminWebVersion, environment }` with values from `package.json` and env. `GET /v1/nope` returns 404 `{ error: { code: 'NOT_FOUND' }, requestId }`
- [X] T028 [P] [US1] Component test `apps/admin-web/src/features/system/BackendStatus.test.tsx` with a mocked `features/system/api.ts`. It shows `status.checking` while loading, `status.connected` with the version on success, `status.updateRequired` when the app version is below `minAdminWebVersion`, and `status.unreachable` with a retry button that refetches on error
- [X] T029 [P] [US1] Unit test `apps/mobile/test/features/system/compatibility_test.dart`. The pure function `evaluateCompatibility(appVersion, VersionInfo)` returns `compatible` when the app version is greater than or equal to `minMobileVersion` and `updateRequired` when it is lower. `compatibilityProvider`, with a fake `SystemRepository`, yields `unreachable` when the repository throws `ApiException`, and `retry()` re-checks
- [X] T030 [P] [US1] Widget test `apps/mobile/test/core/widgets/status_banner_test.dart`. `StatusBanner` renders the checking, connected (with the version) and unreachable (with a retry callback) states from the l10n strings. `UpdateRequiredScreen` shows `updateRequired`

### Implementation for User Story 1

- [X] T031 [US1] Implement `apps/api/src/modules/health/`: `health.repository.ts` (`isDatabaseUp()` runs `SELECT 1` through Prisma with a 2 s timeout and returns false on error), `health.service.ts` (`new HealthService(repository, version)`), `health.schema.ts` (TypeBox `HealthStatus`) and `health.routes.ts` (a Fastify plugin taking `{ healthService }`; `GET /health` replies 503 when degraded). Wire it in `buildApp` (T025 and T026 pass)
- [X] T032 [US1] Implement `apps/api/src/modules/version/`: `version.service.ts` (built from `Env` and the package version), `version.schema.ts` (TypeBox `VersionInfo`) and `version.routes.ts` (`GET /version`). Wire it in `buildApp` (T027 passes)
- [X] T033 [P] [US1] Build the reusable UI components in `apps/admin-web/src/components/ui/`: `StatusBanner.tsx` (variants `info`, `success`, `error` with an optional action button), `PageHeader.tsx` (title and subtitle) and `EmptyState.tsx` (icon, message). They are styled only with theme variables
- [X] T034 [US1] Implement `apps/admin-web/src/features/system/api.ts` (`getVersion()` via `lib/http.ts`), `useBackendStatus.ts` (states `checking | connected | updateRequired | unreachable`, plus `retry`) and `BackendStatus.tsx` (renders through `StatusBanner`) (T028 passes)
- [X] T035 [US1] Implement the layout: `apps/admin-web/src/components/layout/Sidebar.tsx` (accent background, 230 px, items in the order Dashboard, Map, Shops, Products, Salesmen, Pictures, Settings with icons from `lucide-react`, active item highlighted, labels from `nav.*`, matching `admin-design-png/Shops.png`) and `Topbar.tsx` (search input, notifications, help and profile icon buttons with translated `aria-label`s, and the `BackendStatus` slot)
- [X] T036 [US1] Add `apps/admin-web/src/app/[locale]/(shell)/layout.tsx` (Sidebar + Topbar + main) and the placeholder pages `page.tsx` (dashboard), `map/page.tsx`, `shops/page.tsx`, `products/page.tsx`, `salesmen/page.tsx`, `pictures/page.tsx` and `settings/page.tsx`. Each renders `PageHeader` and `EmptyState` with `common.comingSoon`
- [X] T037 [US1] Implement `apps/mobile/lib/features/system/` with `domain/version_info.dart` (`fromJson`), `domain/compatibility.dart` (a sealed `Compatibility` type and `evaluateCompatibility`), `data/system_repository.dart` (`getVersion()` via `dioProvider`) and `presentation/compatibility_provider.dart` (`AsyncNotifier` with `retry()`) (T029 passes)
- [X] T038 [US1] Implement the reusable `apps/mobile/lib/core/widgets/status_banner.dart` and `apps/mobile/lib/features/system/presentation/update_required_screen.dart`, and show the `StatusBanner` on the temporary `/` screen in `app.dart` (T030 passes)

**Checkpoint**: quickstart §1–§2 pass. This is the MVP.

---

## Phase 4: User Story 2 - Automated quality gates (P1)

**Goal**: Every pull request runs lint, type checks, tests and the migration status check for
all three apps.

**Independent Test**: A pull request with a deliberately failing test goes red; a clean one goes
green in under 15 minutes.

- [X] T039 [US2] Create `.github/workflows/ci.yml` (on `pull_request` and `push` to `main`) with three jobs:
  - `api`: Node from `.nvmrc`, pnpm cache, a `postgres:16` service, `DATABASE_URL_TEST` set; runs `pnpm --filter api prisma:migrate`, `prisma:status`, `lint`, `typecheck` and `test`
  - `admin-web`: runs `lint`, `typecheck`, `test` and `build` with `NEXT_PUBLIC_API_BASE_URL` set
  - `mobile`: `subosito/flutter-action` (stable, cached), then `flutter pub get`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze` and `flutter test`
- [X] T040 [US2] Verify the gates locally: break one test in each app, confirm the matching command exits non-zero, and revert. Add a "Quality gates" section to `README.md` listing the CI commands and the branch-protection requirement (CI green plus one approving review)

**Checkpoint**: Merges are gated.

---

## Phase 5: User Story 3 - Role-based mobile shell (P2)

**Goal**: Agent and Admin tab shells chosen by the session role; a debug-only role picker.

**Independent Test**: quickstart §3 and the tests in contracts/mobile-navigation.md.

### Tests for User Story 3 (write first, confirm they fail)

- [X] T041 [P] [US3] Unit test `apps/mobile/test/core/router/redirect_test.dart` for the pure function `resolveRedirect({location, session, compatibility, isDebug})`, covering contracts/mobile-navigation.md rules 1–4 in order. `updateRequired` goes to `/update-required`. No session goes to `/role-picker` (debug) or `/sign-in` (release). An agent on `/admin/shops` goes to `/agent/home`, and an admin on `/agent/map` goes to `/admin/home`. A session on `/` goes to `/<role>/home`. Otherwise the result is `null`
- [X] T042 [P] [US3] Widget test `apps/mobile/test/features/shell/role_shells_test.dart`. With an agent session, the navigation bar labels are exactly Home, Shops, Map and Gallery and the app bar shows `roleAgent`. With an admin session, they are exactly Home, Shops, Agents, Map and Gallery and the app bar shows `roleAdmin`
- [X] T043 [P] [US3] Unit test `apps/mobile/test/core/router/app_router_test.dart`. `createRouter(isDebug: false)` registers no `/role-picker` route, and `createRouter(isDebug: true)` does

### Implementation for User Story 3

- [X] T044 [P] [US3] Implement `apps/mobile/lib/features/session/domain/role.dart` (`enum Role { agent, admin }` with `homePath` and `pathPrefix`), `domain/session.dart` (`Session(userId, role)`) and `presentation/session_provider.dart` (`Notifier<Session?>` with `signIn` and `signOut`)
- [X] T045 [P] [US3] Implement the reusable widgets `apps/mobile/lib/core/widgets/placeholder_screen.dart` (title plus `comingSoon`) and `apps/mobile/lib/core/widgets/role_app_bar.dart` (title, active role chip, and in debug builds a "switch role" action calling `signOut`)
- [X] T046 [US3] Implement the placeholder screens, each built on `PlaceholderScreen`: the shared `features/home/home_screen.dart`, `features/shops/shops_screen.dart`, `features/map/map_screen.dart` and `features/gallery/gallery_screen.dart` (used by both shells), and the admin-only `features/agents/agents_screen.dart`
- [X] T047 [US3] Implement `apps/mobile/lib/features/shell/presentation/role_shell.dart`, one reusable `RoleShell` widget that takes a role and a list of tabs and renders a `NavigationBar` with `RoleAppBar`, plus the tab definitions `agent_tabs.dart` and `admin_tabs.dart` (T042 passes)
- [X] T048 [US3] Implement `apps/mobile/lib/features/session/presentation/role_picker_screen.dart` (Agent and Admin buttons calling `signIn(Session('dev-<role>', role))`) and `sign_in_placeholder_screen.dart`
- [X] T049 [US3] Implement `apps/mobile/lib/core/router/redirect.dart` (`resolveRedirect`) and `apps/mobile/lib/core/router/app_router.dart` (`createRouter({required bool isDebug})` with `StatefulShellRoute.indexedStack` for `/agent/*` and `/admin/*`, `/role-picker` only when `isDebug`, `/sign-in` and `/update-required`, and `refreshListenable` on the session and compatibility). Wire `routerProvider` with `kDebugMode` into `app.dart`, replacing the temporary router (T041 and T043 pass)

**Checkpoint**: Each role sees only its own shell.

---

## Phase 6: User Story 4 - Language and look (P2)

**Goal**: RU/EN switching with Russian as the fallback, mobile dark mode, and missing
translations caught automatically.

**Independent Test**: quickstart §4.

### Tests for User Story 4 (write first, confirm they fail)

- [X] T050 [P] [US4] Unit test `apps/admin-web/tests/messages.test.ts`, which asserts that the flattened key sets of `messages/ru.json` and `messages/en.json` are identical and names any missing key
- [X] T051 [P] [US4] Component test `apps/admin-web/src/components/layout/LocaleSwitcher.test.tsx`, which renders RU and EN options and calls the next-intl router `replace` with `{ locale: 'en' }` on selection (mock `@/i18n/navigation`)
- [X] T052 [P] [US4] Widget test `apps/mobile/test/app_locale_theme_test.dart`. Device locale `de` resolves to Russian text (`navHome` in Russian). With `platformBrightness: Brightness.dark`, the scaffold background is `AppColors.dark.background`

### Implementation for User Story 4

- [X] T053 [US4] Add next-intl typed messages in `apps/admin-web/src/global.d.ts` (`AppConfig` with `Messages: typeof ru`), so `tsc` fails on unknown keys. Add the missing English keys until T050 passes
- [X] T054 [US4] Implement `apps/admin-web/src/components/layout/LocaleSwitcher.tsx` (a RU/EN toggle using `useRouter` and `usePathname` from `@/i18n/navigation`), add it to `Topbar.tsx`, and add the `locale.ru` and `locale.en` keys (T051 passes)
- [X] T055 [US4] In `apps/mobile/lib/app.dart`, add a `localeResolutionCallback` that falls back to `ru` for unsupported locales, and confirm that `themeMode: ThemeMode.system` uses `AppTheme.dark` (T052 passes)
- [X] T056 [US4] Add the untranslated-messages check to the `mobile` job in `.github/workflows/ci.yml`: run `flutter gen-l10n`, then fail if `apps/mobile/untranslated.json` exists and is not `{}`

**Checkpoint**: All stories work on their own.

---

## Phase 7: Polish

- [X] T057 [P] Write `README.md`: the product in one paragraph, prerequisites, first-time setup (quickstart §1), the repo layout, the architecture conventions per app (layers, where shared components live, from plan.md), how to run tests per app, and the Spec Kit workflow
- [X] T058 [P] Review all three apps for duplication and layer violations. Check that controllers contain no Prisma calls, widgets and components contain no business logic, and no hard-coded user-facing strings or color literals appear outside the theme files. Fix anything found
- [X] T059 Run quickstart.md §1–§5 end to end and fix any step that needed undocumented action. Measure mobile time to first frame with `flutter run --profile --trace-startup` and note it in quickstart.md (target under 2 s, SC-007)

---

## Dependencies & Execution Order

- **Setup (T001–T006)** comes first. T001 must finish before T003–T005; T006 comes after them.
- **Foundational (T007–T024)** blocks every story. Within it, the API, web and mobile tracks are
  independent. Within the API track: T007 → T008, T009 → T010, T011 → T012 → T013 → T014.
- **US1 (T025–T038)**: tests T025–T030 come first, then implementation.
- **US2 (T039–T040)**: is most meaningful once US1 tests exist.
- **US3 (T041–T049)**: depends only on Foundational. T049 uses `compatibilityProvider` from US1;
  if US3 starts earlier, use a stub that always returns `compatible`.
- **US4 (T050–T056)**: T054 edits the US1 `Topbar` and T056 edits the US2 workflow, so do them
  after those stories.
- **Polish** comes last.

### Parallel Opportunities

- T003, T004 and T005 (scaffolding three apps).
- Foundational: the API track, the web track (T015–T018) and the mobile track (T019–T024) run in
  parallel.
- US1: the six test tasks T025–T030 together. API (T031–T032), web (T033–T036) and mobile
  (T037–T038) by different people.
- US3: T041–T043 together, then T044 and T045 together.
- US4: T050–T052 together.

## Parallel Example: User Story 1

```bash
Task: "Health service unit test in apps/api/test/unit/health.service.test.ts"
Task: "Health integration test in apps/api/test/integration/health.test.ts"
Task: "Version integration test in apps/api/test/integration/version.test.ts"
Task: "BackendStatus component test in apps/admin-web/src/features/system/BackendStatus.test.tsx"
Task: "Compatibility test in apps/mobile/test/features/system/compatibility_test.dart"
Task: "StatusBanner widget test in apps/mobile/test/core/widgets/status_banner_test.dart"
```

## Implementation Strategy

1. **MVP**: Setup, then Foundational, then US1. Validate with quickstart §1–§2 and demo.
2. US2 next, so every later change is gated.
3. US3, then US4, then Polish.

## Notes

- Before running the API integration tests, create the `audit` role and the `audit_dev`/`audit_test`
  databases (quickstart prerequisites).
- The debug role picker is temporary. The auth feature replaces it as the source of the session
  (plan.md Complexity Tracking).
- Commit after each task or logical group.
