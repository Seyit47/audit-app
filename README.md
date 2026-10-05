# Audit App

Retail audit platform. Field agents visit shops and record POSM audits (geotagged photos and
comments) from a mobile app, including offline. Admins manage shops, agents and products, and
review audits, from the web dashboard or the same mobile app.

| App | Path | Stack |
|-----|------|-------|
| API | `apps/api` | Node.js, Fastify, Prisma, PostgreSQL |
| Admin web | `apps/admin-web` | Next.js, React, Tailwind CSS, next-intl |
| Mobile (agent + admin) | `apps/mobile` | Flutter, Riverpod, go_router, dio |

Project rules live in [`.specify/memory/constitution.md`](.specify/memory/constitution.md).

## Prerequisites

- Node 24 (`.nvmrc`) and pnpm (version pinned in `package.json`)
- Flutter stable 3.47+
- PostgreSQL with two databases, one for development and one for tests:

  ```bash
  sudo -u postgres psql -c "CREATE ROLE audit LOGIN CREATEDB PASSWORD '<password>';" \
    -c "CREATE DATABASE audit_dev OWNER audit;" -c "CREATE DATABASE audit_test OWNER audit;"
  ```

  Alternatively, run `docker compose up -d` if Docker is available.

## First-time setup

```bash
cp .env.example .env              # fill in DATABASE_URL and DATABASE_URL_TEST
pnpm install
pnpm --filter api prisma:migrate
pnpm dev                          # API on :3000 (docs at /docs), admin web on :3001
adb reverse tcp:3000 tcp:3000          # phone/emulator localhost:3000 -> this machine
cd apps/mobile && flutter run --dart-define-from-file=env/dev.json
```

The mobile debug build opens a role picker (Agent or Admin) until sign-in is built.

## Architecture conventions

Every app is layered, and dependencies only point inward.

- **API**: `modules/<feature>/` holds `*.routes.ts` (HTTP only), `*.service.ts` (logic) and
  `*.repository.ts` (Prisma). `buildApp()` in `src/app.ts` wires services and repositories through
  constructors. Cross-cutting code lives in `src/config`, `src/lib` and `src/errors`. Every error
  response has the shape `{ error: { code, message, details? }, requestId }`.
- **Admin web**: `src/features/<feature>/` holds the API calls, hooks and components for a
  feature. Reusable UI lives in `src/components/ui`, and the layout lives in
  `src/components/layout`. Colors are CSS variables in `src/app/globals.css`, and all text lives
  in `messages/{ru,en}.json`.
- **Mobile**: `lib/core/` holds config, network, router, theme, l10n and reusable widgets.
  `lib/features/<feature>/{data,domain,presentation}` holds feature code. Colors exist only in
  `core/theme/app_colors.dart`, and text only in `core/l10n/app_{ru,en}.arb`.

## Tests

```bash
pnpm --filter api test            # unit + integration (needs DATABASE_URL_TEST)
pnpm --filter admin-web test
cd apps/mobile && flutter test
```

## Quality gates

CI (`.github/workflows/ci.yml`) runs on every pull request, and all jobs must pass before merge:

| Job | Checks |
|-----|--------|
| api | migrations apply, `prisma migrate status`, lint, type check, tests against PostgreSQL |
| admin-web | lint, type check, tests, production build |
| mobile | `dart format`, `flutter analyze`, `flutter test`, no untranslated messages |

Protect `main` so that it requires the CI checks and one approving review.

## Workflow

Features follow Spec Kit: `/speckit-specify` → `/speckit-clarify` (optional) → `/speckit-plan` →
`/speckit-tasks` → `/speckit-implement`. Specs live in `specs/`.
