# Audit App Constitution

## Core Principles

### I. Clean Architecture

Every app is organized in layers with one-way dependencies: presentation → domain/application →
data. Inner layers never import outer ones.

- **Backend (Node.js)**: routes/controllers only parse input, call a service, and shape the
  response. Business rules live in services. Database access lives in repositories built on
  Prisma. Routes MUST NOT call Prisma directly.
- **Mobile (Flutter)**: feature-first folders (`features/<feature>/{presentation,domain,data}`).
  Widgets hold no business logic. State lives in controllers or notifiers. Data comes through
  repository interfaces with concrete API and local-storage implementations.
- **Admin web (Next.js)**: feature folders (`features/<feature>/{components,hooks,api}`).
  Pages compose feature components. Data fetching sits behind a typed API module per feature,
  not inline in components.
- Cross-cutting concerns live in one shared place per app (`core/` or `lib/`): config, HTTP
  client, error handling, logging, theme and i18n.
- Dependencies are injected (constructor parameters or providers), not reached for as globals,
  so every layer can be tested in isolation.

Rationale: clear boundaries keep three codebases understandable, testable and easy to change
as features grow.

### II. Clean, Reusable Code

- Follow SOLID and DRY. Each module, class and function has one clear responsibility.
- Logic or UI used in two or more places MUST be extracted into a shared function, hook,
  widget or component. Copy-paste duplication is rejected in review.
- Shared UI elements (buttons, inputs, cards, status badges, empty/error/loading states) are
  built once per client as reusable components and used everywhere.
- Names are descriptive and consistent. Functions stay small. No dead code, commented-out
  code or unused dependencies.
- Code follows each ecosystem's official style: ESLint + Prettier for TypeScript, and
  `flutter analyze` with the recommended lints plus `dart format` for Dart. The linters'
  output is the standard; style debates are settled by the linter.
- Errors are handled explicitly at layer boundaries and shown to users as friendly, translated
  messages. They are never silently swallowed.

Rationale: readable, reusable code is the cheapest way to keep a small team fast.

### III. Simplicity First (YAGNI)

- Build only what the current spec needs. No speculative abstractions, layers, packages or
  configuration "for later".
- Prefer framework defaults and official, widely used packages over custom tooling, scripts or
  code generators. A custom build or check script needs a one-line justification in the plan.
- One backend service, one database and one monorepo with plain pnpm workspaces. Adding
  infrastructure (queues, caches, extra services, extra CI pipelines) MUST be justified in the
  plan's Complexity Tracking table.
- A foundation or setup feature delivers only working skeletons and conventions, not
  enforcement machinery.

Rationale: complexity is a cost paid on every future change; it is added only when a real need
appears.

### IV. Test-First

- Business logic (services, domain rules, state controllers), API endpoints, and critical user
  flows (offline audit capture and sync, role-based access) are developed test-first. Write the
  failing test, make it pass, then refactor.
- Backend integration tests run against a real PostgreSQL test database; Prisma is not mocked.
- Simple UI composition and styling do not require test-first, but MUST NOT break existing tests.
- Tests are clean code too: readable, focused, and free of duplication (use shared fixtures
  and helpers).

Rationale: tests protect the parts that are expensive to get wrong without slowing down simple
UI work.

### V. Offline-First Field Operation

When used in the Agent role, the mobile app MUST work without a network connection for every
audit action: viewing assigned shops, starting an audit, taking photos, commenting, adding a
shop and finishing an audit.

- Agent data is saved locally first and synced automatically when the device is online. The UI
  shows whether each item is saved offline or synced.
- Sync is retry-safe: every client-created record has a client-generated UUID, so retries never
  create duplicates.
- Captured photos MUST NOT be lost across app restarts or failed uploads.

Rationale: agents work in stores with poor coverage, and lost audits mean lost evidence.

### VI. Evidence Integrity (NON-NEGOTIABLE)

- Submitted audits and their photos are immutable. Corrections are new linked records with an
  author, a reason and a timestamp. No update or delete paths exist for submitted evidence.
- Every audit records GPS coordinates with accuracy, the device time and the server receipt
  time. Audit photos are taken in-app, not imported from the gallery.
- The server flags audits taken out of range of the shop's location; it never discards them.

Rationale: the product is only valuable if admins can trust what agents recorded on site.

### VII. Security & Role-Based Access

- Roles are at least Field Agent and Admin. Authorization is enforced on the server for every
  request; hiding things in the client is never an authorization control.
- The single mobile app shows the Agent or Admin view based on the role from the authenticated
  session. Agents only access the shops and audits assigned to them.
- Tokens are stored in platform secure storage on mobile. Cached user data is cleared on logout
  or when the user switches.
- Secrets are never committed; configuration comes from environment variables.

Rationale: the system holds employee location data and clients' commercial data.

## Technology Stack & Constraints

- **Backend**: Node.js + TypeScript, Prisma ORM, PostgreSQL. A versioned REST API (`/v1`).
  Requests are validated with schemas, and errors use one consistent JSON format with a
  machine-readable `code`. Schema changes go through Prisma migrations.
- **Admin web**: Next.js + React + TypeScript.
- **Mobile**: one Flutter app serving the Field Agent and Admin roles through role-based
  navigation. Screens shared by both roles are built once and adapt to the role.
- **Photos**: S3-compatible object storage; only metadata in PostgreSQL.
- **Localization**: Russian (default) and English in both clients, using each framework's
  standard i18n (Flutter `gen-l10n`, `next-intl`). No hard-coded user-facing strings.
- **Design**: follow the approved designs in the repo. Colors, typography and spacing are
  defined once per client as theme values (Flutter `ThemeData`, CSS variables or the Tailwind
  theme), never as ad-hoc literals in widgets or components. The mobile app supports light and
  dark themes.
- Changing a language, framework or primary datastore is a constitution amendment.

## Development Workflow & Quality Gates

- Features follow the Spec Kit flow: specify → (clarify) → plan → tasks → implement. Each plan
  passes the Constitution Check, and plans and task lists are kept proportional to the feature.
- Every change goes through a pull request with at least one review that checks architecture
  boundaries, reuse and test coverage of business logic.
- CI runs on every pull request and MUST pass before merge: lint/format, type check (TypeScript
  strict, `flutter analyze`), tests, and the Prisma migration status check.

## Governance

This constitution supersedes other development practices for this project. Where a guideline,
template or habit conflicts with it, the constitution wins.

- **Amendments**: proposed by a pull request that edits this file and states the rationale and
  the impact on existing code. Amendments take effect when merged.
- **Versioning**: semantic versioning. MAJOR for removing or redefining a principle; MINOR for
  adding a principle or section or materially expanding guidance; PATCH for clarifications.
- **Compliance**: every plan includes a Constitution Check, and every review verifies
  compliance. A deviation is either fixed or justified in the plan's Complexity Tracking table.
  NON-NEGOTIABLE principles change only by amendment.

**Version**: 2.0.0 | **Ratified**: 2026-10-05 | **Last Amended**: 2026-10-06
