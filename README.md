# Audit App

A retail-execution platform. Field agents visit shops on daily routes and record audits:
GPS-checked in-app photos, a comment, and an optional violation. Admins manage shops, agents
and products, watch agents live on the map, review photos and export reports.

| App | Path | Created with |
|-----|------|--------------|
| API | `apps/api` | `fastify generate --lang=ts --esm` + `prisma init` (PostgreSQL) |
| Admin web | `apps/admin-web` | `create-next-app` |
| Mobile (agent + admin roles) | `apps/mobile` | `flutter create` |

## Design source

The Figma file **9s5b56r9zs1s0Ty2UgvL0W** is the only design source. Every screen is built
pixel-perfect from its frame (node IDs are in
`specs/002-retail-audit-platform/contracts/figma-frames.md`). The Figma file is never modified.
Anything Figma doesn't define follows the **Figma gap protocol** in
`.specify/memory/constitution.md` (Principle I): detect, propose options, the product owner
decides, record.

## Setup

Requirements: Node 24 + pnpm, Flutter stable, PostgreSQL 16 and an S3-compatible store (SeaweedFS),
either via `docker compose up -d postgres seaweedfs` or installed locally.

```bash
pnpm install
cp apps/api/.env.example apps/api/.env              # database, JWT, S3
pnpm --filter api exec prisma migrate deploy
pnpm --filter api exec prisma db seed                # default settings, regions, categories
pnpm --filter api admin:create -- --email admin@company.tm --password '…'
pnpm --filter api dev                                # API on :3000, docs at /docs
pnpm --filter admin-web dev                          # admin web on :3001
adb reverse tcp:3000 tcp:3000
cd apps/mobile && flutter run --dart-define-from-file=env/dev.json
```

Operator CLI: `admin:create` and `admin:reset-password` (admins have no screen in Figma).

## Architecture

- **API**: `src/modules/<domain>/` contains `*.routes.ts` (HTTP), `*.service.ts` (rules) and
  `*.repository.ts` (Prisma), wired in `src/app.ts`. Jobs (routes, previews, exports,
  retention) run on pg-boss in PostgreSQL. Photos go directly to S3 with presigned URLs.
- **Admin web**: `src/features/<feature>/{components,hooks,api}` plus `copy.ts` (the Figma text
  for that feature). Shared UI lives in `src/components/ui`.
- **Mobile**: `lib/core` (theme from the Figma variables, router, network, offline database,
  sync) and `lib/features/<feature>/{data,domain,presentation}`. The agent role works offline
  through an outbox.

## Workflow

Spec Kit: `/speckit-specify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-analyze` →
`/speckit-implement`. The current feature is `specs/002-retail-audit-platform/`.
