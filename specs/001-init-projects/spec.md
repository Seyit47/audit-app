# Feature Specification: Project Foundation (Init Projects)

**Feature Branch**: `001-init-projects`

**Created**: 2026-10-05

**Status**: Draft

**Input**: User description: "init projects"

## Overview

Set up the three applications that make up the audit platform so every later feature has a
working, consistent place to be built:

- **Backend service**: the single source of truth that both clients talk to.
- **Admin web application**: the browser dashboard for admins (Dashboard, Map, Shops,
  Products, Salesmen, Pictures, Settings).
- **Mobile application**: one app that shows either the Field Agent or the Admin experience
  depending on the signed-in user's role.

This feature delivers empty-but-running applications, with shared foundations already set
up: the release checks, the language setup, the shared design values and the role-based
navigation shell. It delivers no business functionality such as audits, shops or real sign-in.

The primary "users" of this feature are the development team; the business stakeholder value
is that every later feature can be built, checked and shown faster and more consistently.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Run the whole platform locally (Priority: P1)

A developer gets a fresh copy of the project, follows one documented setup procedure, and
has the backend service, the admin web application, and the mobile application all running
on their machine, with the clients successfully communicating with the backend.

**Why this priority**: Nothing else can be built or demonstrated until the three applications
exist and can talk to each other.

**Independent Test**: On a clean machine with only the documented prerequisites installed,
follow the setup guide; the admin web app and the mobile app each display a status
indicator confirming they reached the backend.

**Acceptance Scenarios**:

1. **Given** a clean machine with documented prerequisites, **When** the developer follows
   the setup guide, **Then** the backend, admin web, and mobile app start without manual
   fixes not described in the guide.
2. **Given** all three applications are running, **When** the admin web app or mobile app
   starts, **Then** it shows that the backend is reachable and which backend version it
   is talking to.
3. **Given** the backend is stopped, **When** a client starts, **Then** it shows a clear,
   translated "service unavailable" state instead of crashing.
4. **Given** the backend is running, **When** its health check is queried, **Then** it
   reports its own status and the status of its data store.

---

### User Story 2 - Automated quality gates on every change (Priority: P1)

Every proposed change to any of the three applications is automatically checked (code style,
type correctness, tests, data-structure change validity, API contract conformance) and is
blocked from merging if any check fails.

**Why this priority**: The constitution makes test-first and contract conformance
non-negotiable; this is only enforceable if the gates exist from day one.

**Independent Test**: Submit one change with a deliberately failing test and one clean change;
the first is blocked, the second passes.

**Acceptance Scenarios**:

1. **Given** a change that breaks a test in any application, **When** it is submitted for
   review, **Then** the automated checks fail and identify the failing application and test.
2. **Given** a change that makes the backend deviate from its published API contract,
   **When** it is submitted, **Then** the contract check fails.
3. **Given** a change that touches only one application, **When** checks run, **Then**
   at minimum that application's checks run and the result is reported within 15 minutes.
4. **Given** each application, **When** the project is first set up, **Then** each contains
   at least one passing example test of each required kind (unit, integration, and UI/end-to-end
   where applicable) that later features follow as a pattern.

---

### User Story 3 - Role-based mobile app shell (Priority: P2)

The mobile app opens into the correct experience for the user's role. Because real sign-in
is a later feature, this foundation uses a development-only way to choose a role. The Agent
role shows the agent navigation (Home, Shops, Map, Gallery). The Admin role shows the admin
navigation (Home, Shops, Agents, Map, Gallery). Each tab is an empty placeholder screen.

**Why this priority**: The constitution requires a single mobile app with role-based views;
fixing the navigation structure now prevents later features from building on the wrong
structure.

**Independent Test**: Launch the app with each development role; verify the correct tabs
appear and that a route belonging to the other role cannot be opened.

**Acceptance Scenarios**:

1. **Given** the app is started with the Agent role, **When** it opens, **Then** only agent
   navigation is shown and the active role is visibly indicated.
2. **Given** the app is started with the Admin role, **When** it opens, **Then** only admin
   navigation is shown and the active role is visibly indicated.
3. **Given** the Agent role is active, **When** an admin-only screen is requested directly,
   **Then** access is refused and the user is returned to the agent home screen.
4. **Given** a production build, **When** the app runs, **Then** the development role picker
   is not available.

---

### User Story 4 - Consistent language and look across apps (Priority: P2)

Both clients show their placeholder screens in Russian or English and use the shared design
values taken from the approved designs: the primary accent color, the typefaces, spacing and
corner radius. The mobile app also supports light and dark themes.

**Why this priority**: Retrofitting translations and design values later means touching every
screen; establishing them first is far cheaper.

**Independent Test**: Switch language and theme in each client; all visible text changes
language, and colors and typography match the design reference.

**Acceptance Scenarios**:

1. **Given** a client set to Russian, **When** the user switches to English, **Then** every
   visible text on placeholder screens appears in English without restarting the app.
2. **Given** a device whose language is neither Russian nor English, **When** a client first
   opens, **Then** it falls back to Russian.
3. **Given** the mobile app, **When** the device switches between light and dark mode,
   **Then** the app follows it using the dark-theme design values.
4. **Given** a developer adds a new screen, **When** they write any visible text without a
   translation entry, **Then** the automated checks flag it.

---

### Edge Cases

- A developer has an incompatible version of a prerequisite installed: setup MUST detect it
  and report the required version rather than failing obscurely.
- The local data store is unavailable when the backend starts: the backend MUST start,
  report itself unhealthy, and recover when the store becomes available.
- The mobile app talks to a backend whose API version it does not support: it MUST show an
  "update required" state instead of continuing.
- A translation key exists in one language but not the other: the checks MUST flag the gap,
  and at runtime the app MUST show the fallback-language text, not a raw key.
- Required configuration such as the backend address is missing: the application MUST refuse
  to start and name the missing setting.

## Requirements *(mandatory)*

### Functional Requirements

**Platform & environment**

- **FR-001**: The project MUST contain three separately buildable applications: backend
  service, admin web application, and a single mobile application.
- **FR-002**: The project MUST provide one documented setup procedure that brings up all
  three applications and their data store on a developer machine.
- **FR-003**: Each application MUST read environment-specific settings (backend address,
  credentials, feature flags) from configuration outside the source code. No secrets may
  appear in the repository.
- **FR-004**: The project MUST support at least three environments: local development,
  testing/staging, and production.

**Backend foundation**

- **FR-005**: The backend MUST expose a health check reporting service status, data store
  connectivity, and the running version.
- **FR-006**: The backend MUST publish a versioned API contract document, starting at
  version 1. At this stage it describes only the health/version endpoints.
- **FR-007**: The backend MUST expose the minimum client version it supports so that clients
  can detect when an update is required.
- **FR-008**: The backend MUST return errors in one consistent, documented format with a
  machine-readable code and a human-readable message.
- **FR-009**: The backend MUST manage its data structure through recorded, ordered,
  repeatable change steps, starting from an initial empty baseline.
- **FR-010**: The backend MUST log requests and errors in a structured format that includes a
  request identifier.

**Admin web foundation**

- **FR-011**: The admin web application MUST show the application layout from the design:
  a side navigation with Dashboard, Map, Shops, Products, Salesmen, Pictures and Settings, a
  top bar with search, notifications, help and profile placeholders, and an empty placeholder
  page for each section.
- **FR-012**: The admin web application MUST show the backend connection status and version.

**Mobile foundation**

- **FR-013**: The mobile application MUST provide a role-aware navigation shell with
  separate Agent and Admin navigation sets, as described in User Story 3.
- **FR-014**: The mobile application MUST block navigation to screens not permitted for the
  active role.
- **FR-015**: The mobile application MUST provide a development-only role selector that is
  excluded from production builds. It is replaced by real sign-in in a later feature.
- **FR-016**: The mobile application MUST include an on-device storage foundation that keeps
  data separate per user and per role, ready for offline features.
- **FR-017**: The mobile application MUST detect an unsupported backend API version and show
  an "update required" state.

**Cross-cutting**

- **FR-018**: Both clients MUST support Russian and English, with Russian as the default and
  fallback language. All visible text MUST come from translation resources.
- **FR-019**: Both clients MUST use one shared set of design values (colors including the
  primary accent, typography, spacing, radii) taken from the approved designs. The mobile app
  MUST provide light and dark variants.
- **FR-020**: Automated checks MUST run on every proposed change and block merging on failure.
  The checks cover formatting and linting, type checking, all tests, validity of data-structure
  changes, API contract conformance, and missing translations.
- **FR-021**: Each application MUST include example tests of every required kind, wired into
  the automated checks. Backend integration tests MUST run against a real data store instance.
- **FR-022**: The project MUST include contributor documentation covering setup, project
  layout, how to run each kind of test, and the feature workflow required by the constitution.

### Key Entities

- **Application Version Info**: the running version of the backend, the API contract version,
  and the minimum supported client version. Clients read it to decide compatibility.
- **Health Status**: the overall service state plus the state of each dependency (data store).
  Used by developers and monitoring.
- **Role**: Field Agent or Admin. This feature defines only the concept and its effect on
  mobile navigation; accounts and permissions come in a later feature.
- **Design Values**: the named colors, type styles, spacing and radii shared by both clients,
  with light and dark variants.
- **Translation Resource**: a keyed text entry with Russian and English values.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new developer can go from a fresh copy of the project to all three applications
  running and connected in under 30 minutes, following only the written guide.
- **SC-002**: 100% of proposed changes are automatically checked, and a change with a failing
  test or contract deviation is blocked from merging in every case.
- **SC-003**: Automated check results for a typical change are available within 15 minutes.
- **SC-004**: In each role, the mobile app shows exactly that role's navigation, and 0
  other-role screens can be reached in tests.
- **SC-005**: 100% of visible text on all placeholder screens is available in both Russian and
  English, verified by automated check.
- **SC-006**: Placeholder screens match the approved design for layout, accent color and
  typography on side-by-side review by the designer or product owner.
- **SC-007**: The mobile app's first screen appears within 2 seconds of launch on a mid-range
  Android device.

## Assumptions

- All three applications live in a single repository (monorepo) so that shared contracts and
  documentation stay in sync. Separate repositories would be a later decision if needed.
- Technology choices are those fixed in the constitution and are not repeated here.
- Real sign-in, user accounts and permissions, shops, audits, products, maps and photo
  handling are out of scope. They are separate later features.
- Mobile targets are Android and iOS; Android is the primary test target because field devices
  are expected to be mid-range Android phones.
- Russian is the default language, based on the language used in the approved designs.
- The admin web app targets current desktop browsers. Responsive mobile layouts for the admin
  web are out of scope because admins on mobile use the mobile app.
- A hosted automated-check service is available to the team. Deployment to staging and
  production is out of scope for this feature beyond the environments being defined in
  configuration.
- The approved design files in the repository (admin web, mobile admin, mobile agent light
  and dark) are the reference for design values.
