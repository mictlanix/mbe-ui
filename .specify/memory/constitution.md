<!--
Sync Impact Report
Version change: 1.0.0 → 1.3.1
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
    [1.3.1]
Added sections: none (expansion of existing principle, not a new principle)
Removed sections: none
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ (Constitution Check gate is
    generic/derived from this file; no edits needed)
  - .specify/templates/spec-template.md ✅ (no changes needed)
  - .specify/templates/tasks-template.md ✅ (no changes needed)
Follow-up TODOs: none
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
- Every catalog/list screen MUST expose its supported actions (Create,
  View [the same form as Edit, rendered read-only], Edit, Delete/
  soft-delete) as row/toolbar actions using one fixed icon **and** one
  fixed left-to-right order per action across the whole app, sourced from
  `core/widgets/`. A module MUST NOT invent its own icon for an action
  another module already represents differently, and MUST NOT reorder
  the action icons relative to other modules. A module MUST NOT render an
  action a user lacks the RBAC privilege for (see Principle IV) rather
  than disabling/hiding it inconsistently.
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

**Version**: 1.3.1 | **Ratified**: 2026-06-14 | **Last Amended**: 2026-06-20
