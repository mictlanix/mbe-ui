<!--
Sync Impact Report
Version change: 1.0.0 → 1.13.0
Modified principles:
  - V. Material 3, White-Labeled Design System — materially expanded with
    two rules [1.11.0]: (a) **two levels of configuration, kept distinct** —
    deployment configuration resolves once at startup from build-time
    `--dart-define-from-file=.env` values and is never UI-mutable, while
    personal display preferences are device-local and never synced through
    mbe-api; (b) **accessibility text size** — four app-wide levels beside
    appearance and language on a user settings screen, with the largest
    level verified against fixed-column-budget screens rather than assumed
    to fit. Rule (a) widens, rather than contradicts, the existing "Users
    MUST be able to choose Light/Dark/System, persisted per device"
    sentence. Prompted by specs/027-app-user-settings.
    A third rule — **one formatting surface** — was drafted for this
    amendment and **withheld** when that feature descoped the surface
    itself: a rule requiring every screen to use a component that does not
    exist yet cannot be complied with, and this constitution's practice is
    to land a rule with the first code that satisfies it. The drift it
    targets is real and measured (three parallel paths, ≈78 call sites:
    `core/widgets/money_formatters.dart` with a hard-coded `$` and an
    `'es_MX'` default, the display helpers in
    `features/sales/domain/money.dart` doing `Decimal.toStringAsFixed` and
    hand-building `"16.00 %"`, and an inline `DateFormat.yMd()` in
    `features/catalog/presentation/taxpayer_certificates_section.dart`); the
    rule amends in with the future spec that builds the surface [1.11.0]
  - III. Contract-Driven API Integration — materially expanded with a rule
    on binary file uploads (`multipart/form-data`): the dio generator has
    repeatedly emitted `String`-typed parameters for OpenAPI fields marked
    `format: binary`, sending them as plain form fields instead of real
    file parts, which the server rejects with "Expected UploadFile". The
    generated wrapper's signature MUST be verified against a live upload
    before being trusted, and bypassed in favor of a direct `dio.post` with
    `FormData`/`MultipartFile.fromBytes` when the gap is confirmed.
    Prompted by specs/015-fiscal-catalogs, where
    `TaxpayerCertificateRepositoryImpl.upload` shipped base64-encoding raw
    bytes into the generated method's string fields (mirroring an
    assumption never actually confirmed against a live server) and was
    rejected on first real use; corrected to match the already-existing
    `ProductRepositoryImpl.uploadPhoto` (spec 004) pattern of posting real
    multipart file parts directly [1.9.0]
  - III. Contract-Driven API Integration — materially expanded with an
    explicit repo-boundary rule: mbe-ui MUST NOT directly edit mbe-api's (or
    any sibling repo's) source, even when both are checked out locally in
    the same working session; a needed backend change MUST be filed as an
    mbe-api issue and recorded as an external dependency in the feature's
    plan instead. Prompted by specs/008-merge-products, where an agent
    working across both repos patched mbe-api directly to unblock a UI
    requirement (SKU on the products-list projection) before being
    corrected — codifying the correction so it doesn't have to be
    re-taught per session [1.6.0]
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
    should default to safe (read-only), not to a mutable form [1.5.0], then
    the "exactly one row action, Edit" rule was relaxed to allow **at most
    one** additional direct-icon row action beyond Edit (e.g. a shortcut
    into a related record), with any further actions required to collapse
    into a single overflow/kebab menu rather than stacking more row icons —
    prompted by a genuine need for a cross-feature shortcut (products list
    row → that product's pricing screen) that the strict single-action rule
    had no room for [1.7.0], then further expanded to restrict `AppBar.actions`
    to just the already-codified read-only-to-edit toggle (plus the optional
    detail-screen delete action): every other screen-level action — including
    a shortcut into a related feature's own screen — MUST be a
    `FilledButton`/`OutlinedButton` in the screen body instead, matching the
    toolbar pattern already used for Create/Merge on
    `products_list_screen.dart` — prompted by specs/011-product-pricing
    initially placing a "view pricing" shortcut as a product-detail AppBar
    icon before it was corrected to a products-list row action [1.8.0], then
    the v1.8.0 `AppBar.actions` reservation for the read-only-to-edit toggle
    was **reversed**: a record detail screen's `AppBar.actions` MUST now be
    empty by default, and that toggle moves into the record's shared,
    fixed-order action area alongside Save and Delete
    (`core/widgets/record_form_actions.dart`, `RecordFormActions`), rendered
    as a labeled `OutlinedButton` rather than an unlabeled app-bar icon —
    prompted by specs/017-ui-consistency-filters, where user feedback found
    that splitting one continuous task (view → edit → save/delete) across
    two screen regions was itself the friction the v1.8.0 rule hadn't
    addressed; the previously-allowed app-bar delete exception (Users admin
    screen precedent) is retained verbatim [1.10.0], then further expanded
    with three structural rules [1.11.0]: (a) **facet filters live behind
    the shared drawer** — every list screen presents its facets through the
    badged filters icon button and `showCatalogFilterSheet`, never inline
    chips/menus/date pickers in the filter row, and a screen whose endpoint
    has no free-text search omits the search control rather than passing an
    empty placeholder; (b) **no form stacked above a list** — a list route
    is a filter row, a list and pagination, with any form moved to its own
    route or to a dialog/sheet whose launching toolbar action carries the
    state the inline form used to show; (c) **symmetry and baseline
    alignment** — vertical padding within a row/card is symmetric, controls
    sharing a horizontal band share a text baseline, values come from the
    spec 022 design tokens, and compliance is asserted by widget tests
    measuring real insets and baselines. Prompted by user-reported feedback
    on three screens: `pos_sales_list_screen.dart` (inline date-range and
    status chips where every catalog screen used the drawer),
    `cash_sessions_screen.dart` (an open-shift form stacked above the
    history list, plus an empty `search:` placeholder), and the POS sale
    lines, which read bottom-heavy because the control band sits off the
    line-total's baseline — an alignment that took many iterations to land
    the first time (see the derivation comments in
    `features/sales/presentation/capture/sale_line_layout.dart`), which is
    why rule (c) requires a measuring test rather than trusting the eye
    [1.11.0]
Added sections: none (two existing principles materially expanded, no new
  principle and no removal)
Removed sections: none
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ (Constitution Check gate is
    generic/derived from this file; no edits needed)
  - .specify/templates/spec-template.md ✅ (no changes needed)
  - .specify/templates/tasks-template.md ✅ (no changes needed)
  - DESIGN.md §3.3 ✅ updated with the same repo-boundary note ahead of this
    constitution amendment, per the Governance section's amendment process.
  - DESIGN.md §3.3 ✅ (1.9.0) updated with the multipart file-upload
    codegen-gap note ahead of this amendment.
  - DESIGN.md §4.2.2/§4.3 ✅ (1.10.0) updated with the record action area
    reversal and the new `RecordFormActions` shared component ahead of this
    amendment, landing in the same change as the first converted detail
    screen (specs/017-ui-consistency-filters plan.md Phase 3) so no shipped
    screen is ever mid-flight between the two rules.
  - DESIGN.md §4.3/§4.4/§4.5 ✅ (1.11.0) updated ahead of this amendment,
    per Governance: §4.3 gained the list-screen-structure and
    alignment/symmetry notes, plus the formatting-surface decision recorded
    as design intent explicitly **not yet in force**; §4.4 gained the
    app-settings vs. user-preferences split and why runtime-parsed config
    was rejected; §4.5 gained the user settings screen and the text-size
    constraint. specs/027-app-user-settings is the feature landing the first
    compliant code — app/user settings, the POS sales list drawer
    conversion, the cash-sessions shift sheet, and the POS sale-line
    symmetry fix. Value formatting was descoped from it on 2026-08-16 and
    carries its finished design forward to a future spec.
  - DESIGN.md §4.2.3 ✅ (1.13.0, new section) added ahead of this amendment,
    per Governance: names the "record surface" concept (full screen vs.
    shared side panel), which entities use which, and why §4.2.1/§4.2.2's
    existing rules already held for both without needing a parallel
    panel-specific rule set. specs/035-crud-ui-refinements is the feature
    landing the fourteen entity conversions this section documents.
Follow-up TODOs: none — DESIGN.md §4.3's "switches|prices" reference was
  updated to "switches|labels" once specs/007-catalog-ui-improvements-2
  shipped the labels-in-place-of-prices change. specs/008-merge-products'
  mbe-api dependency (mictlanix/mbe-api#76, sku on ProductListItem) remains
  open and unaffected by this amendment. specs/017-ui-consistency-filters'
  remaining 17 detail-screen conversions are tracked in that feature's own
  tasks.md, not here. Likewise, the one screen still violating the v1.11.0
  filter-drawer rule beyond the two named ones
  (`features/pricing/presentation/exchange_rates_list_screen.dart`) is
  inventoried in specs/027-app-user-settings' research.md R8 for correction
  when next touched, not tracked here.
  - V. Material 3, White-Labeled Design System — the **one formatting
    surface** rule drafted for v1.11.0 and withheld there now lands:
    `formattersProvider` (`lib/core/formatting/`) is the single path every
    screen MUST use to render a date, date-time, currency amount, percentage
    or quantity; no widget MAY construct a `DateFormat`/`NumberFormat` or
    call `toStringAsFixed` for display, enforced by
    `test/unit/core/formatting_guard_test.dart`. Formatting configuration
    (date/date-time patterns, currency symbol/code, decimal-digit counts)
    is deployment-level only — the same build-time, never-UI-mutable level
    as the rest of app settings — with **no per-user override**, keeping
    v1.11.0's two-configuration-levels split intact. The date default is
    **ISO 8601** (`yyyy-MM-dd`), a deliberate change from the locale-derived
    rendering the app used before, made so one deployment serving multiple
    locales still shows one unambiguous date everywhere; a deployment
    preferring a local rendering sets `DATE_FORMAT` explicitly. Prompted by
    specs/028-presentation-consistency, which also found that the two
    screens computing their own locale via
    `Localizations.localeOf(context).toString()` were silently rendering
    Spain-style numbers instead of Mexican ones — Flutter's locale
    resolution drops the country subtag that `formattersProvider` (via
    `resolvedLocaleProvider`, v1.11.0) deliberately preserves — a live bug
    this migration fixed as a side effect [1.12.0]
  - VI. Desktop/Web-First, Compact-Ready Layout — the row-click,
    read-only-label/edit-toggle, and delete-placement rules are
    re-expressed in terms of a record's own **surface** — a full detail
    screen (its own route) or the shared responsive side panel opened over
    the entity's list screen (`core/widgets/record_sheet.dart`,
    `showRecordSheet`) — rather than assuming every record has its own
    route. A new sentence names which entities use which surface: the
    panel for Labels, Suppliers, Employees, Customers, Taxpayer
    Recipients, Expenses, Vehicles, Vehicle Operators, Warehouses, Points
    of Sale, Cash Drawers, Price Lists, Exchange Rates, and Payment Method
    Options; a full detail screen for Products, Facilities, Taxpayer
    Issuers, Users, User Profiles, and any other entity with nested child
    collections. Both surfaces render the identical form and MUST satisfy
    every rule in this principle identically; a panel surface has no
    `AppBar` of its own, so its read-only-to-edit toggle and Delete action
    live entirely within the shared `RecordFormActions` body area — this
    is not an exception to the `AppBar.actions`-empty rule, just that rule
    trivially satisfied by a surface with no app bar at all. Prompted by
    specs/035-crud-ui-refinements, which converted the fourteen named
    catalogs from a pushed full-screen route to the panel — a deliberate,
    accepted loss of deep-linkable per-record URLs for those entities in
    exchange for a lighter-weight create/view/edit flow that does not leave
    the list screen [1.13.0]
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
- For any endpoint accepting a binary file (`multipart/form-data`), the
  generated wrapper method's signature MUST be verified against a live
  upload before being trusted: the dio generator has repeatedly emitted
  `String`-typed parameters (sent as plain form fields via
  `FormData.fromMap`/`encodeFormParameter`) for fields the server actually
  requires as real file parts (FastAPI `UploadFile`), which the server
  rejects with a "Expected UploadFile, received: ..." error. When this gap
  is confirmed, bypass the generated wrapper for that call and post the
  bytes directly via `dio.post(path, data: FormData.fromMap({...,
  'field': MultipartFile.fromBytes(bytes, filename: ...)}))`, deserializing
  the raw response with `standardSerializers.deserialize` the same way the
  generated method would have (see `ProductRepositoryImpl.uploadPhoto` and
  `TaxpayerCertificateRepositoryImpl.upload` for the pattern). Do not assume
  a base64-encoded string field is an acceptable substitute without
  confirming it against the real server first.
- mbe-ui MUST NOT directly modify mbe-api's source (or any other sibling
  repository), even when a local checkout makes this technically possible
  within the same working session. When a feature needs a backend change —
  a new/changed endpoint, a schema or response-projection field, anything
  on the mbe-api side — the feature's plan MUST record it as an external
  dependency (Complexity Tracking or an Assumptions/research entry) and a
  corresponding issue MUST be filed against mbe-api describing the exact
  change needed, instead of patching it in place from an mbe-ui session.
  The mbe-ui-side consumption (codegen + domain-entity mapping) proceeds
  once that change ships upstream and the client is regenerated.

**Rationale**: keeps client models in sync with a backend under active
development and gives consistent error UX across modules (DESIGN.md §3.1-§3.4).
The repo-boundary rule keeps mbe-api's own review/release process intact —
a cross-repo edit made from an mbe-ui session bypasses whatever process
mbe-api's own maintainers use to accept changes, and generated files edited
that way would be silently overwritten by the next real regeneration anyway.

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
- **One formatting surface.** Every date, date-time, currency amount,
  percentage and quantity a screen displays MUST be reached through
  `formattersProvider` (`lib/core/formatting/`) — no widget MAY construct a
  `DateFormat`/`NumberFormat` or call `toStringAsFixed` for display, a rule
  enforced by an automated guard (`test/unit/core/formatting_guard_test.dart`)
  that fails the suite and names the offending file/line, not left to review.
  No call site MAY resolve its own locale (e.g.
  `Localizations.localeOf(context).toString()`) for this purpose — the
  provider owns the locale so the interface language and every formatted
  value can never disagree. The surface MUST distinguish read-only display
  formatting from editable-field formatting (a field the user types into
  carries no currency symbol and MUST round-trip to the stored value), and
  MUST render one placeholder for absent/unparseable input everywhere,
  never a screen-specific improvisation.
- Deployment configuration and personal preference are two distinct levels
  and MUST NOT be conflated:
  - **App settings** (formatting options, default locale, endpoints, brand
    tokens, POS defaults) MUST resolve once at startup from build-time
    values supplied via `--dart-define-from-file=.env`, MUST be listed with
    their defaults in `.env.template`, MUST fall back to a documented
    default on a malformed or absent value rather than failing startup, and
    MUST NOT be reachable or mutable from the UI. Formatting options
    (date/date-time patterns, currency symbol/code, decimal-digit counts)
    are app settings, not user display preferences — there is no per-user
    override, keeping this split unblurred.
  - **User display preferences** (appearance, text size, language) MUST be
    device-local via `shared_preferences`, MUST apply immediately with no
    restart or re-login, and MUST NOT be synced through mbe-api. They are
    distinct from the server-side `UserSettings` carrying the user's cash
    drawer and point of sale — operational assignments, not display taste —
    and naming MUST keep the two distinguishable.
- The app MUST offer exactly **four** overall text-size levels, applied
  app-wide, alongside the appearance and language choices on a user settings
  screen reachable from the user menu. No RBAC gate applies — display
  preferences are personal and available to every signed-in user. At the
  largest level, no screen at supported desktop widths MAY clip, overflow or
  hide content; a screen with a fixed column budget (the POS capture surface
  above all) MUST be verified at that level, never assumed to absorb it.

**Rationale**: MBE is open source and deployed for multiple customers from
one codebase — consistent structure with swappable branding avoids
per-customer forks (DESIGN.md §4.1, §4.4, §4.5). Splitting deployment
configuration from personal preference (v1.11.0) keeps the white-label seam
— §V's whole premise — from being blurred by user-facing controls, and keeps
a personal taste setting from acquiring a backend dependency it does not
need. The **single-formatting-surface** rule was drafted for v1.11.0 and
deliberately withheld then, because specs/027-app-user-settings descoped the
surface itself (≈78 call sites across three divergent paths — see that
feature's research.md R3/R4/R8 and contracts/formatting-surface.md) and a
rule requiring every screen to use a component that did not exist yet was
unsatisfiable. specs/028-presentation-consistency built the surface and
migrated every call site (≈76, re-verified — the count drifted slightly once
comment-only mentions were excluded from the naive grep), so the rule lands
now, with the code that satisfies it, per this constitution's own practice.

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
- Those facet filters MUST be presented through the shared badged filters
  icon button opening the shared filter drawer (`CatalogFilterBar` +
  `showCatalogFilterSheet`). Facet controls — chips, popup menus, date-range
  pickers — MUST NOT be placed inline in the filter row, which reserves that
  row for the search box and the screen's entity actions. Where a screen's
  endpoint genuinely has no free-text search, the shared filter row MUST
  omit the search control; a screen MUST NOT pass an empty placeholder
  widget to reserve space for one that does not exist.
- A list screen MUST be a filter row, a list, and pagination. A form MUST
  NOT be embedded above the list on a list route: it belongs on its own
  route, or in a dialog/sheet launched from a toolbar action in the filter
  row. When a form moves into such a sheet, the toolbar action that launches
  it MUST communicate the state the inline form used to show, so that
  relocating it does not hide state the user relied on seeing at a glance.
- Within a row or card, vertical padding MUST be symmetric — the space above
  the content equals the space below it — and controls and text sharing a
  horizontal band MUST share a text baseline. Padding and margin values MUST
  come from the shared design tokens (`core/design/spacing.dart`, spec 022),
  never ad-hoc literals. Because this kind of alignment is hard to eyeball
  and easy to regress, a screen with a non-trivial control band MUST assert
  it with widget tests measuring real insets and baselines, not by
  inspection.
- Every catalog/list screen's row MUST expose Edit as its primary
  row-level action, using one fixed icon sourced from `core/widgets/`. A
  module MUST NOT invent its own icon for Edit, and MUST NOT render the
  Edit icon for a user lacking the RBAC update privilege (see Principle
  IV) rather than disabling/hiding it inconsistently.
- A row MAY expose **at most one** additional row-level action beyond
  Edit, rendered as its own direct icon — e.g. a shortcut into a related
  record's own screen. This is not a loophole for a per-row View or
  Delete icon: those remain banned outright, governed by the read-only
  row-click and detail-screen-delete rules below. If a screen has a
  genuine need for more than one additional action, those additional
  actions MUST be collapsed behind a single overflow ("kebab") menu icon
  instead of adding more direct row icons — a row MUST show at most two
  icons total (Edit, plus either one direct action or one overflow menu).
  This action set MUST be built with the shared `core/widgets/`
  row-actions component, not reimplemented per module.
- A record's own **surface** is either a full detail screen (its own
  route) or the shared responsive side panel opened over the entity's
  list screen (`core/widgets/record_sheet.dart`, `showRecordSheet`).
  Which surface an entity uses is a per-entity choice, not a per-screen
  one: a full detail screen for Products, Facilities, Taxpayer Issuers,
  Users, User Profiles, and any other entity with nested child
  collections; the shared panel for every other catalog/list entity
  (Labels, Suppliers, Employees, Customers, Taxpayer Recipients,
  Expenses, Vehicles, Vehicle Operators, Warehouses, Points of Sale, Cash
  Drawers, Price Lists, Exchange Rates, and Payment Method Options). Both
  surfaces render the identical form and MUST satisfy every rule below
  identically.
- Clicking anywhere on a row (outside the Edit icon) MUST open that
  record's own surface in **read-only** mode — the same form Edit opens,
  rendered non-editable — never the editable form. This is the row's
  sole non-icon affordance and MUST behave identically across modules; a
  stray click MUST NOT risk an unintended edit.
- The read-only surface MUST label itself as a "View" (an AppBar title
  on a full detail screen, a panel header on the shared panel — never an
  "Edit" title/header) and, when the current user holds the update
  privilege, MUST offer an explicit control to switch to the editable
  form for the same record, in place, without navigating away or
  re-opening the surface; a user lacking that privilege MUST NOT be shown
  that control.
- Create remains a toolbar-only action (never a row action). Delete/
  soft-delete MUST be surfaced on the record's own surface (e.g. a
  warning-styled button in the form body for catalog records), not as a
  row/app-bar icon on the list — a module MAY additionally keep a
  delete affordance on its detail screen's app bar if a form-body warning
  button does not fit that module's layout, but MUST NOT place it back on
  the list row; a panel surface has no app bar to fall back to, so its
  delete action MUST live in the shared form-body action area. A module
  MUST NOT render a delete action a user lacks the RBAC delete privilege
  for (see Principle IV) rather than hiding it.
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
- A record detail screen's `AppBar.actions` MUST be empty by default.
  Every screen-level action — creating a record, the read-only-to-edit
  toggle, Save, Delete, a shortcut into a related record's own screen, a
  bulk operation, or any other entity-level command — MUST be rendered as a
  `FilledButton`/`OutlinedButton` (with `.icon` where a leading icon helps)
  placed in the screen body: beside the search bar via `CatalogFilterBar`'s
  `actions` slot on list screens, or in the record's shared action area
  (below) on detail screens. A module MUST NOT add a new `AppBar` icon
  action as a shortcut to another feature's screen. The one allowed
  exception is a detail screen's own delete action, where a module's layout
  genuinely cannot accommodate a form-body delete button (the Users admin
  screen precedent) — no module MUST place the read-only-to-edit toggle
  itself back in the app bar.
- A record detail screen's Edit, Save, and Delete actions MUST be rendered
  by one shared component (`core/widgets/record_form_actions.dart`,
  `RecordFormActions`), not reimplemented per screen, in one fixed
  left-to-right order — Delete, then Edit-or-Save — regardless of module.
  The read-only-to-edit toggle MUST render as a labeled control of lighter
  visual weight than Save (e.g. an outlined button beside a filled one),
  never as an unlabeled icon separated from the rest of the record's
  actions. As with every other RBAC-gated action in this principle, an
  action the current user lacks the privilege for MUST be absent from this
  area, never shown disabled.

**Rationale**: avoids four slightly-different implementations across
sales/inventory/invoicing/accounting and keeps a future mobile tier viable
(DESIGN.md §4.2-§4.3). Added after the Users catalog screen shipped without
filtering or pagination, diverging from other list screens — this
codifies the shared table contract so future features inherit it by
construction instead of
each one being corrected after the fact. The truncation rule follows
standard ellipsis UX guidance: always give users a way to recover the full
text, and never hide information they need to act. The `AppBar.actions` rule
was added (v1.8.0) after specs/011-product-pricing initially placed a "view
pricing" shortcut as a product-detail-screen AppBar icon before it was
corrected to a products-list row action — codifying the correction (matching
how the `FilledButton`/`OutlinedButton` toolbar pattern was already used for
Create/Merge on `products_list_screen.dart`) so the same mistake isn't
repeated per module. That rule reserved the app bar for the read-only-to-edit
toggle specifically; v1.10.0 (specs/017-ui-consistency-filters) moved the
toggle itself out of the app bar too, into the same shared, fixed-order
action area as Save and Delete — user feedback found that splitting one
continuous task (view → edit → save/delete) across two screen regions (an
app-bar icon, then form-body buttons) was itself the friction the v1.8.0 rule
hadn't addressed. Centralizing all three actions in one component
(`RecordFormActions`) also means the next such change is a one-file edit
across all 18 record screens, not an 18-screen edit. The three structural
rules added in v1.11.0 come from user-reported feedback on specific screens:
`pos_sales_list_screen.dart` had grown a date-range chip and a status
popup-menu chip inline while every catalog screen used the drawer;
`cash_sessions_screen.dart` stacked an open-shift form above its history
list and passed an empty `search:` placeholder because its endpoint has no
search parameter; and the POS sale lines read bottom-heavy because the
control band sits off the line-total's baseline. The measuring-test
requirement exists because that same band's shared height and baseline took
many iterations to land the first time — the derivation is recorded in
`features/sales/presentation/capture/sale_line_layout.dart`, and an
alignment that expensive to get right must not be left to the eye to keep.
The v1.13.0 "record surface" re-expression comes from
specs/035-crud-ui-refinements, which converted fourteen catalogs' create/
view/edit presentation from a pushed full-screen route to the shared
side panel (`showRecordSheet`) opened over the entity's own list screen —
a lighter-weight flow for records that don't need a deep-linkable URL or
nested child collections, accepted in exchange for losing that
deep link. Every rule this principle stated in terms of a "detail
screen" already held for the panel too (both render the same form via
the same `RecordFormActions`), so this amendment names the shared
concept — a record's own **surface** — rather than adding a parallel set
of panel-specific rules that would drift from the screen rules over
time.

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
- Whenever a feature *needs* an mbe-api change that doesn't exist yet, file
  an mbe-api issue and record it as a plan dependency — never patch
  mbe-api's source directly from an mbe-ui session (§III).

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

**Version**: 1.13.0 | **Ratified**: 2026-06-14 | **Last Amended**: 2026-08-30
