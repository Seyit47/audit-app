# Audit App Constitution

## Core Principles

### I. Pixel-Perfect Design Fidelity

The Figma file is the specification for every screen. The UI MUST match it exactly.

- **Single source of truth**: the Figma file `9s5b56r9zs1s0Ty2UgvL0W` ("Map"), section "MAP"
  (`7:1130`), read through the Figma MCP server. No other design source is used. Screenshots and
  CSS exports previously in the repository are not references and MUST NOT be used to resolve a
  layout, value or copy question.
- **Exact values**: structure (auto-layout direction, gaps, padding, alignment, sizes) and values
  (colors, font family, size, weight, line height, letter spacing, radii, borders, shadows,
  opacity) are taken from the Figma node via `get_design_context`, never estimated by eye.
  Colors use the file's Figma variables (e.g. `Dark Mobile/Light Mobile/Accent`). Where a node
  uses a raw value instead of a variable, that raw value is used for that node.
- **Reference frames**: each screen is built and checked at its Figma frame size: 1440 wide for
  the admin web, and 390 pt wide for mobile. Agent screens are checked against both the light
  and dark sections.
- Every screen implemented in a feature MUST be compared side by side with its Figma frame
  (`get_screenshot`) at the frame size before the feature is done. Any visible difference in
  layout, spacing, size, color, typography, iconography or copy is a defect, not a polish item.
- Design values are defined once per client as theme values (CSS variables or the Tailwind theme
  for web; `ThemeData` and theme extensions for Flutter), mirroring the Figma variables, and
  reused. Screens never hard-code a value that exists in the theme.
- Icons, logos, map markers and illustrations are exported from the Figma file as SVG
  (`download_assets`), not substituted. User content shown in the designs (photos, names,
  numbers) is not shipped as assets. It comes from the backend.
- Copy matches the Figma text exactly in the language the frame shows. Translations keep the
  same layout without overflow.
- **Figma gap protocol**: a *gap* is anything the product needs that the Figma file does not
  fully define. Examples: a state Figma displays with no control to create it (e.g. "Зафиксировано
  нарушение" without a violation input), a button whose destination has no frame, a production
  need with no screen (e.g. sign-in), or data shown with no source. Gaps MUST NOT be dropped or
  silently invented. Each gap is handled in this order:
  1. **Detect**: while specifying, planning or building, check that every displayed state, value
     and control has a source and a way to be produced. Inspect the Figma layers (names,
     hidden or empty sections) for designer intent before concluding a gap exists.
  2. **Propose**: present the gap to the user with 1–3 concrete options and a recommendation,
     preferring in this order: (a) an existing Figma control or flow that already covers it;
     (b) an automatic system rule or server configuration with no new UI; (c) a new control or
     screen built only from components, variables and typography already in the Figma file.
     Name the trade-offs (reliability, user effort, design impact).
  3. **Decide**: only the user decides. Nothing outside Figma is built without their explicit
     approval.
  4. **Record**: the decision goes into the spec's "Figma Gaps and Resolutions" table. Option (c)
     is also listed as an **approved exception** in the plan's Complexity Tracking.

  The Figma file itself is never modified. Approved exceptions are styled solely from existing
  Figma elements and are checked like any other screen.

Rationale: the product is judged first by how closely it matches the agreed design. A single,
inspectable source with exact values leaves no room for drift.

### II. Clean Architecture

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

### III. Clean, Reusable Code

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

### IV. Simplicity First (YAGNI)

- Build only what the current spec needs. No speculative abstractions, layers, packages or
  configuration "for later".
- Every app is created with its framework's official starter command, as documented in that
  framework's quick-start guide: `create-next-app` for the admin web, `flutter create` for
  mobile, and the official Fastify generator plus `prisma init` for the API. The generated
  structure and configuration are kept as generated. Dependencies are not hand-assembled into a
  hand-written project.
- Configuration files, scripts and dependencies beyond what the starter generates are added only
  when a feature needs them, with a one-line justification in the plan. Prefer framework
  defaults and official, widely used packages over custom tooling.
- The repository contains only source, essential configuration, design references and docs.
  Generated output, local tool state, caches, IDE settings and machine-specific files MUST NOT
  be committed.
- One backend service, one database and one monorepo with plain pnpm workspaces. Adding
  infrastructure (queues, caches, extra services, extra CI pipelines) MUST be justified in the
  plan's Complexity Tracking table.
- A foundation or setup feature delivers only working skeletons and conventions, not
  enforcement machinery.

Rationale: complexity is a cost paid on every future change; it is added only when a real need
appears.

### V. Test-First

- Business logic (services, domain rules, state controllers), API endpoints, and critical user
  flows (offline audit capture and sync, role-based access) are developed test-first. Write the
  failing test, make it pass, then refactor.
- Backend integration tests run against a real PostgreSQL test database; Prisma is not mocked.
- Simple UI composition and styling do not require test-first, but MUST NOT break existing tests.
- Tests are clean code too: readable, focused, and free of duplication (use shared fixtures
  and helpers).

Rationale: tests protect the parts that are expensive to get wrong without slowing down simple
UI work.

### VI. Offline-First Field Operation

When used in the Agent role, the mobile app MUST work without a network connection for every
audit action: viewing assigned shops, starting an audit, taking photos, commenting, adding a
shop and finishing an audit.

- Agent data is saved locally first and synced automatically when the device is online. The UI
  shows the sync state where the Figma design places it: globally on Home ("Данные
  синхронизированы" / "Синхронизация…") and on the audit screen ("Офлайн-режим сохранён").
- Sync is retry-safe: every client-created record has a client-generated UUID, so retries never
  create duplicates.
- Captured photos MUST NOT be lost across app restarts or failed uploads.

Rationale: agents work in stores with poor coverage, and lost audits mean lost evidence.

### VII. Evidence Integrity (NON-NEGOTIABLE)

- Submitted audits and their photos are immutable. Corrections are new linked records with an
  author, a reason and a timestamp. No update or delete paths exist for submitted evidence.
- Every audit records GPS coordinates with accuracy, the device time and the server receipt
  time. Audit photos are taken in-app, not imported from the gallery.
- The server flags audits taken out of range of the shop's location; it never discards them.

Rationale: the product is only valuable if admins can trust what agents recorded on site.

### VIII. Security & Role-Based Access

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
- **Localization**: the mobile app supports Russian (default) and English with Flutter gen-l10n,
  as its Figma Home frames provide a RU/EN switch. No user-facing string is hard-coded in widgets.
  The admin web shows the text of its Figma frames as designed, and has no language switch
  because none is designed. Its strings live in one copy module per feature, not inline in
  markup.
- **Design**: see Principle I (Figma only). The mobile app supports light and dark themes, as in
  the Figma "Agent Mobile light" and "Agent Mobile dark" sections.
- Changing a language, framework or primary datastore is a constitution amendment.

## Development Workflow & Quality Gates

- Features follow the Spec Kit flow: specify → (clarify) → plan → tasks → implement. Each plan
  passes the Constitution Check, and plans and task lists are kept proportional to the feature.
- Every change goes through a pull request with at least one review. The review checks design
  fidelity (app screenshots next to the Figma frame screenshots), architecture boundaries,
  reuse, and test coverage of business logic.
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

**Version**: 2.4.0 | **Ratified**: 2026-10-05 | **Last Amended**: 2026-10-06
