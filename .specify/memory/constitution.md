<!--
Sync Impact Report
Version change: 1.0.0 → 1.5.0
Modified principles:
  - VI. Desktop/Web-First, Compact-Ready Layout — materially expanded with
    explicit cross-screen consistency requirements for shared data/list
    widgets (hover, borders, header alignment, mandatory pagination) [1.1.0],
    then further expanded with anti-horizontal-scroll/ellipsis truncation
    rules (tooltip fallback required; never truncate critical info) [1.2.0],
    then further expanded with mandatory filtering and consistent
    cross-module CRUD action iconography for every catalog/list screen
    [1.3.0], then clarified to define the action set as Create/View
    (read-only Edit form)/Edit/Delete and to require a fixed
    left-to-right icon order, not just matching icons, across modules
    [1.3.1], then expanded with responsive multi-column form layout (shared
    form-grid, no full-width single-field stretch on wide displays) and
    section-divider / side-by-side grouping guidance [1.4.0], then the
    row-level action set was redefined from Create/View/Edit/Delete to
    Create/Edit-only, with a whole-row click opening the read-only view
    (superseding the dedicated View icon) and Delete/soft-delete moving
    off the row entirely onto the record's own detail screen — reflecting
    usage feedback that three row icons and a frozen identity column added
    friction without reducing accidental-edit risk, and that a stray click
    should default to safe (read-only), not to a mutable form [1.5.0]
Added sections: none (redefinition of an existing principle's operative
  rule, not a new principle)
Removed sections: none
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ (Constitution Check gate is
    generic/derived from this file; no edits needed)
  - .specify/templates/spec-template.md ✅ (no changes needed)
  - .specify/templates/tasks-template.md ✅ (no changes needed)
Follow-up TODOs: none — DESIGN.md §4.3's "switches|prices" reference was
  updated to "switches|labels" once specs/007-catalog-ui-improvements-2
  shipped the labels-in-place-of-prices change.
-->

# MBE-UI Constitution

## Core Principles

### I. Feature-First Layered Architecture

Code MUST be organized by business feature under `lib/features/` (`auth`,
`sales`, `inventory`, `invoicing`, `accounting`, and a shared
`master_data`/`catalog` module for entities used across features), each
owning its own `presentation/`, `domain/`, and `data/` layers.

- `presentation` MUST depend only on `domain`; it MUST NOT import `data`
  directly.
- `data` MUST implement repository interfaces defined in `domain`.
- Entities shared across features (e.g. Product, Customer, Warehouse) MUST
  live in a shared kernel (`core/domain` or `master_data`), not be
  redefined per feature.

**Rationale**: keeps each business module independently testable without
spinning up the API, and keeps ownership boundaries clear as the four
business domains grow (DESIGN.md §2.1, §2.2, §5).

### II. Riverpod for State Management & Dependency Injection

All application state and dependency injection MUST go through Riverpod
providers. No separate DI framework (e.g. `get_it`) MAY be introduced
unless Riverpod is formally rejected via a constitution amendment.

- Data sourced from mbe-api MUST be modeled with `AsyncNotifier`/`Notifier`
  exposing `AsyncValue`.
- Local UI state (form state, filters, selections) MUST use plain
  `Notifier`/`StateProvider`.
- Repositories, API clients, and services MUST be exposed as providers so
  tests can override them with fakes/mocks.

**Rationale**: compile-safe DI and state, testable without `BuildContext`,
and `AsyncValue` maps naturally onto API calls (DESIGN.md §2.3, §2.5).

### III. Contract-Driven API Integration

The API client and DTOs MUST be generated from mbe-api's published OpenAPI
spec (`GET /openapi.json`) via `openapi-generator` (dio generator). Hand-written
DTOs for a resource that already has a published schema are NOT permitted.

- Generated DTOs live in `data/` and MUST be mapped to immutable `freezed`
  domain entities in `domain/` before reaching `presentation`.
- All HTTP access MUST go through `dio`. A shared interceptor attaches the
  bearer token and treats any `401` as session-invalid, redirecting to
  `/auth/login` — there is no refresh-on-401 (see Open Questions in
  DESIGN.md §7 regarding refresh tokens).
- API errors (validation, 4xx/5xx, network) MUST be mapped to the shared
  domain error types (`ValidationError`, `NotFoundError`, `AuthError`,
  `ServerError`, `NetworkError`) and surfaced via the shared error-display
  widget rather than handled ad hoc per screen.
- Codegen MUST be re-run whenever mbe-api's OpenAPI spec changes; generated
  files MUST NOT be hand-edited.

**Rationale**: keeps client models in sync with a backend under active
development and gives consistent error UX across modules (DESIGN.md §3.1-§3.4).

### IV. Deny-by-Default RBAC

Every route and every mutable UI action (create/update/delete) MUST be
gated by `can(SystemObject, AccessRight)` from a session-scoped privilege
provider populated from `UserResponse.privileges` at login, mirroring
mbe-api's `SystemObjects`/`AccessRight` bitmask model.

- A missing privilege row for a `SystemObject` MUST be treated as no
  access. `administrator = true` short-circuits to full access.
- go_router redirects/guards and the side nav MUST use `can(object, Read)`
  to hide/block inaccessible routes.
- Shared list/detail screens MUST use
  `can(object, Create|Update|Delete)` to show/hide action buttons.
- Each feature module's routes/screens MUST document which `SystemObject`
  code(s) they correspond to.

**Rationale**: carries over the legacy `mbe` RBAC model wholesale so
client-side checks stay consistent with server-side enforcement
(DESIGN.md §3.7).

### V. Material 3, White-Labeled Design System

The UI MUST use Material 3 components and structure exclusively — no
Cupertino-specific branches.

- Brand tokens (seed color, logo, app display name, typography) MUST be
  configurable per deployment via build-time Flutter flavors
  (`--dart-define`/flavor-specific entry points), never hardcoded in
  `app/theme/`.
- Both light and dark `ColorScheme` MUST be derived from the same
  per-customer seed color via `ColorScheme.fromSeed`. Users MUST be able to
  choose Light/Dark/System, persisted per device.
- `es-MX` MUST be treated as a first-class locale from the start via
  `flutter_localizations` + `intl` (`.arb` files); currency (MXN) and date
  formatting MUST use `intl`, not manual string formatting.

**Rationale**: MBE is open source and deployed for multiple customers from
one codebase — consistent structure with swappable branding avoids
per-customer forks (DESIGN.md §4.1, §4.4, §4.5).

### VI. Desktop/Web-First, Compact-Ready Layout

The first delivery MUST target the **Expanded** (desktop/web) layout tier:
persistent side navigation, multi-pane list+detail views, data tables, and
multi-column forms.

- `LayoutBuilder`/`MediaQuery` breakpoints MUST be centralized in `core/`
  from the start, even though the **Compact** (phone) tier is deferred, so
  adding it later does not require each feature to retrofit breakpoints.
- Shared data tables, formatted fields, date pickers, status badges, and
  form-field wrappers MUST live in `core/widgets/` rather than being
  reimplemented per module.
- Every shared data table/list MUST present identical visual behavior
  regardless of which feature module renders it: row hover highlighting,
  consistent bottom/row borders, and consistent header alignment (text
  columns left-aligned, numeric/currency columns right-aligned, action
  columns centered). These behaviors MUST be implemented once in the
  shared `core/widgets/` table component, not re-implemented per screen.
- Any list/table screen backed by a dataset that can grow unbounded MUST
  use the shared pagination component from `core/widgets/`. A list screen
  MUST NOT ship without pagination unless the underlying dataset is
  provably bounded (e.g. a small fixed enum-like list).
- Every catalog/list screen MUST ship with filtering (a search box and, if
  the entity has obvious facets — status, category, type — corresponding
  filter controls) using the shared filter pattern from `core/widgets/`. A
  catalog MUST NOT ship search-less, even if pagination alone could make
  it "usable."
- Every catalog/list screen's row MUST expose exactly one row-level
  action, Edit, using one fixed icon sourced from `core/widgets/`. A
  module MUST NOT invent its own icon for Edit, MUST NOT add other
  row-level action icons (no per-row View or Delete icon), and MUST NOT
  render the Edit icon for a user lacking the RBAC update privilege (see
  Principle IV) rather than disabling/hiding it inconsistently.
- Clicking anywhere on a row (outside the Edit icon) MUST open that
  record's detail screen in **read-only** mode — the same form Edit
  opens, rendered non-editable — never the editable form. This is the
  row's sole non-icon affordance and MUST behave identically across
  modules; a stray click MUST NOT risk an unintended edit.
- The read-only detail screen MUST label itself as a "View" screen (not
  an "Edit" title) and, when the current user holds the update privilege,
  MUST offer an explicit control to switch to the editable form for the
  same record; a user lacking that privilege MUST NOT be shown that
  control.
- Create remains a toolbar-only action (never a row action). Delete/
  soft-delete MUST be surfaced on the record's own detail screen (e.g. a
  warning-styled button in the form body for catalog records), not as a
  row/app-bar icon on the list — a module MAY additionally keep a
  delete affordance on its detail screen's app bar if a form-body warning
  button does not fit that module's layout, but MUST NOT place it back on
  the list row. A module MUST NOT render a delete action a user lacks the
  RBAC delete privilege for (see Principle IV) rather than hiding it.
- Horizontal scrolling on data tables MUST be avoided wherever possible.
  When a column's content would otherwise force horizontal scroll, the
  shared table component MUST truncate that cell's text with an ellipsis
  instead of widening the row, subject to:
  - **Fallback required**: a truncated cell MUST expose the full text via
    a hover tooltip (desktop/web) or an equivalent reveal-on-tap/expand
    affordance, never truncate-and-hide with no way to read the rest.
  - **Never truncate critical info**: fields the user needs to complete
    the task at hand — totals, monetary amounts, error/validation
    messages, status badges, and primary navigation/identifier links —
    MUST NOT be ellipsized; only secondary/descriptive text columns may
    be truncated.
- Multi-field forms (create/edit/detail screens) MUST use the shared
  responsive multi-column form layout from `core/widgets/` rather than a
  full-width single-column stack: one column on the Compact tier and two or
  more columns on wider tiers, so text fields never stretch across the full
  width of a wide/desktop display. A screen MAY cap its own maximum column
  count (e.g. two columns even on the widest tier when paired fields read
  better than three narrow ones) but MUST NOT stretch single fields edge to
  edge. This column logic MUST live in the shared form-grid component, not be
  re-implemented per screen.
- Logically distinct groups within a form or panel (an attribute/toggle
  block, a prices sub-panel, a labels section, etc.) SHOULD be delimited from
  the surrounding content with the shared Material 3 divider where it improves
  scanability or reclaims otherwise-wasted vertical space, and naturally
  related blocks SHOULD be paired side by side (a two-column band) on wide
  tiers rather than each stacked full-width.

**Rationale**: avoids four slightly-different implementations across
sales/inventory/invoicing/accounting and keeps a future mobile tier viable
(DESIGN.md §4.2-§4.3). Added after the Users catalog screen shipped without
filtering or pagination, diverging from other list screens — this
codifies the shared table contract so future features inherit it by
construction instead of
each one being corrected after the fact. The truncation rule follows
standard ellipsis UX guidance: always give users a way to recover the full
text, and never hide information they need to act.

### VII. Online-Only, Server-Rendered Documents

mbe-ui MUST NOT implement offline storage, local sync, or caching layers.
All reads and writes go directly to mbe-api.

- PDF generation (CFDI invoice representations, POS tickets) MUST remain
  server-side in mbe-api. mbe-ui only previews, prints, downloads, or
  shares the rendered bytes via the `printing` package.

**Rationale**: keeps the client simple and lets mbe-api own the canonical
document representation (DESIGN.md §3.5-§3.6).

## Technology Stack (Non-Negotiable Defaults)

- **HTTP client**: `dio`.
- **Navigation**: `go_router`; route structure mirrors feature folders
  (`/auth`, `/sales`, `/inventory`, `/invoicing`, `/accounting`).
- **Domain models**: `freezed` (+ `json_serializable` as needed) for
  immutable entities mapped from generated OpenAPI DTOs.
- **Token storage**: `flutter_secure_storage` for the access token on
  mobile/desktop; web storage is acceptable given the 8-hour token plus
  server-side `session_version` revocation.
- **Local device prefs**: `shared_preferences` for theme mode and similar
  device-local settings.
- **Documents**: `printing` package for PDF preview/print/share.
- **i18n**: `flutter_localizations` + `intl`, `.arb` files, `es-MX` default.

## Development Workflow & Quality Gates

- **Unit tests**: domain logic and repositories, with the API client
  mocked.
- **Widget tests**: `core/widgets/` components and critical per-module
  screens.
- **Integration tests**: golden-path flows (e.g. login → create invoice,
  stock adjustment) via `integration_test`, run against a test mbe-api
  instance once available.
- Whenever mbe-api adds or changes endpoints relevant to a feature, that
  feature's plan MUST include: re-running codegen, updating the
  domain-entity mapping, and — if RBAC-relevant — updating the
  `SystemObject` table in `core/`.

## Governance

This constitution states the binding MUST/SHOULD rules derived from
DESIGN.md; DESIGN.md remains the narrative record of *why* each decision
was made and MAY be updated independently for rationale/context.

- **Amendments**: propose the change against the relevant DESIGN.md
  section first, then update this constitution and bump its version using
  semantic versioning:
  - **MAJOR**: backward-incompatible removal or redefinition of a principle.
  - **MINOR**: a new principle added, or an existing one materially expanded.
  - **PATCH**: wording, clarification, or non-semantic refinement.
- **Compliance**: `/speckit-plan`'s Constitution Check gate and code review
  MUST verify new feature plans against these principles. Any deviation
  MUST be recorded in the plan's Complexity Tracking table with a
  justification and a note on why a simpler alternative was rejected.

**Version**: 1.5.0 | **Ratified**: 2026-06-14 | **Last Amended**: 2026-07-05
