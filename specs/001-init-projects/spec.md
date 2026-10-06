# Feature Specification: Fresh Apps With Pixel-Perfect Designed Screens

**Feature Branch**: `001-init-projects`

**Created**: 2026-10-05 (rescoped 2026-10-06)

**Status**: Draft

**Input**: User description: "init projects", rescoped to "start the apps fresh from the starters
and build the real designed screens right away"

## Overview

Recreate the three apps from their official starters, then build every screen in the approved
designs so that each one matches its screenshot exactly. The screens show the sample content
seen in the designs. Real data, sign-in, offline sync and photo upload are later features. This
feature delivers the complete, navigable, pixel-perfect UI they will plug into.

Design sources: `admin-design-png/` with `admin-design.css`, `mobile-agent-design-png/` with
`mobile-agent-design.css` and `mobile-agent-dark-design.css`, and `mobile-admin-design-png/` with
`mobile-admin-design.css`. The full screen list is in [contracts/screens.md](./contracts/screens.md).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Admin web screens (Priority: P1)

An admin opens the web dashboard and can move through every designed screen. Each screen matches
its design at 1440 × 900: Map (with the shop popup and filters panel), Shops (list, row menu,
selected rows), Shop details (with the edit dialog), Products, Salesmen, Salesman details, and
Pictures (with the photo detail panel).

**Why this priority**: The admin web is the main management surface. It also sets the shared
look (sidebar, top bar, tables, cards) that the rest builds on.

**Independent Test**: Open each admin route at 1440 × 900 and compare it side by side with its
screenshot. Every interaction state listed in contracts/screens.md can be reached by clicking.

**Acceptance Scenarios**:

1. **Given** the admin web at 1440 × 900, **When** any designed screen is opened, **Then** it
   matches its screenshot in layout, spacing, sizes, colors, typography, icons and copy.
2. **Given** the Shops list, **When** the admin opens a row's "more" menu or ticks rows,
   **Then** the menu and selection look exactly as in `Shops.png` and `Shops (1).png`.
3. **Given** the Map screen, **When** the admin clicks a shop marker or the Filters button,
   **Then** the shop popup or the filters panel appears exactly as in `Map.png` and
   `Map (1).png`.
4. **Given** Shop details, **When** the admin clicks Edit, **Then** the edit dialog appears
   exactly as in `Shops _ Details (1).png`.
5. **Given** Pictures, **When** the admin clicks a photo, **Then** the detail panel appears
   exactly as in `Pictures (1).png`.

---

### User Story 2 - Field agent mobile screens (Priority: P1)

A field agent uses the mobile app: Home, My shops, Shop details, Map (with the selected-shop
sheet), Gallery and photo details, Add shop (empty and filled), and Audit (empty and with
photos). Each screen matches its design at 390 pt wide in both light and dark themes.

**Why this priority**: Agents are the primary daily users, and the audit flow is the core of
the product.

**Independent Test**: Run the app as Agent at 390 pt wide. Compare each screen with its light
screenshot, then switch to dark and compare with the dark design.

**Acceptance Scenarios**:

1. **Given** the agent role, **When** each designed screen is opened, **Then** it matches its
   light design. With the dark theme on, it matches the dark design.
2. **Given** Home, **When** the agent taps the theme or language toggle, **Then** the app
   switches between light and dark, or between RU and EN, immediately.
3. **Given** Add shop or Audit, **When** the agent takes or removes a sample photo, **Then** the
   screen moves between its empty and filled design states, including the disabled and enabled
   primary button.
4. **Given** the Map, **When** the agent taps a shop marker, **Then** the bottom sheet appears as
   in `map (1).png`.

---

### User Story 3 - Admin mobile screens (Priority: P2)

An admin uses the same mobile app in the Admin role: Home, Shops, Shop details, Map with sheet,
Gallery and photo details, Add shop, Agents and Agent details. Each screen matches its design at
390 pt wide.

**Why this priority**: The admin mobile experience depends on components built for the agent
screens and the admin web.

**Independent Test**: Run the app as Admin and compare each screen with its screenshot.

**Acceptance Scenarios**:

1. **Given** the admin role, **When** each designed screen is opened, **Then** it matches its
   screenshot.
2. **Given** the admin role, **When** navigating, **Then** agent-only screens (Audit) cannot be
   reached, and admin-only screens (Agents) are not offered to agents.

---

### User Story 4 - Clean projects from official starters (Priority: P1, prerequisite)

A developer clones the repository and finds three apps created by their official starter
commands with their generated configuration intact. The repository holds no extra tooling
files, generated output or machine-specific files.

**Why this priority**: Constitution v2.1.0, Principle IV. Every other story is built on these
projects.

**Independent Test**: Re-run the documented starter commands in an empty folder and compare.
Every file that differs is either feature code or justified in plan.md.

**Acceptance Scenarios**:

1. **Given** a fresh clone, **When** the developer follows the README, **Then** the admin web,
   the mobile app and the API start with the documented commands.
2. **Given** the repository, **When** it is listed, **Then** it contains no build output,
   caches, IDE settings, local env files or unjustified configuration files.

### Edge Cases

- English text is longer than Russian. Switching language must not overflow or break the
  layouts that were checked in the reference language.
- The admin web below 1440 px wide must stay usable, although pixel checks are done at
  1440 × 900.
- Long sample names, such as shop titles, truncate the way the design shows (with an ellipsis).
- Phones narrower or wider than 390 pt keep the layout proportions: the content stretches
  horizontally and is not scaled.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The admin web, mobile app and API MUST be created with their official starter
  commands. The generated configuration is kept, and additions are justified in plan.md.
- **FR-002**: Every frame in contracts/screens.md MUST be implemented at its route and
  interaction state, and MUST match its screenshot at the reference size.
- **FR-003**: Layout, spacing, sizes, colors, typography, radii, borders and shadows MUST use
  the exact values from the design CSS exports, defined once as theme values per client.
- **FR-004**: Screens MUST show the sample content seen in the designs (shops, agents, audits,
  photos, products, numbers), provided through each feature's data layer so that real data can
  replace it later without changing the screens.
- **FR-005**: The mobile app MUST show the Agent or Admin set of screens by session role, with a
  debug-build role picker until sign-in exists.
- **FR-006**: The mobile app MUST support light and dark themes (toggle on Home, default follows
  the system) and RU/EN (toggle on Home, default Russian). The admin web MUST support RU/EN.
- **FR-007**: Components that appear on more than one screen (sidebar, top bar, stat card,
  table, status badge, filter chip, search field, shop card, photo grid, audit history item,
  bottom sheet, form field, primary button) MUST be built once per client and reused.
- **FR-008**: Map screens MUST reproduce the design's map backgrounds and marker positions.
  Interactive maps are a later feature.

### Key Entities

Shop, Agent (salesman), Audit/visit, Photo, Product, Region. Their fields are defined in
[data-model.md](./data-model.md). In this feature they hold sample data only.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the frames in contracts/screens.md are implemented and reachable.
- **SC-002**: In a side-by-side review at the reference size, no screen shows a visible
  difference in layout, spacing, size, color, typography, icon or copy from its screenshot.
- **SC-003**: The agent screens pass the same review in the dark theme against the dark design.
- **SC-004**: Every file in the repository is either starter-generated, feature code, design
  reference or docs. The plan lists every justified addition.
- **SC-005**: The mobile app's first screen appears within 2 s of a cold start on a mid-range
  Android phone.

## Assumptions

- The PNGs are 2× exports. Admin is designed at 1440 × 900 (taller frames scroll). Mobile frames
  are 390 pt wide and scroll vertically.
- The phone status bar in the mobile frames belongs to the operating system and is not drawn by
  the app.
- The admin sidebar labels appear in Russian in the Map frames and in English elsewhere. The
  Russian labels are used for RU and the English labels for EN. Each screen is pixel-checked in
  the language its frame shows. Mobile screens are checked in Russian.
- Dashboard and Settings appear in the admin sidebar but have no design. They show an empty
  page header until they are designed.
- Photos, map backgrounds and the logo are exported from the Figma file by the user
  (contracts/assets.md), since the CSS exports contain no image assets.
- Data, authentication, offline storage, camera and upload behaviour are out of scope. Buttons
  that would need them show their designed states with sample data.
