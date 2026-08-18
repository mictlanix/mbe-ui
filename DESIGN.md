# MBE-UI Design Document

## 1. Overview

**mbe-ui** is the Flutter frontend for Mictlanix Business Essentials (MBE) —
sales, inventory control, invoicing, and accounting. It is part of a
ground-up rewrite that splits the legacy monolith (`mbe`) into:

- **mbe-api** — backend service (Python), built from scratch
- **mbe-ui** — this project, a Flutter client consuming mbe-api

### Target platforms

The Flutter project scaffold already includes `android`, `ios`, `web`,
`windows`, `macos`, and `linux`.

**Decision**: the first delivery targets desktop/web (`web`, `windows`,
`macos`, `linux`), with a desktop/web-oriented layout (§4.2). Mobile
(`android`, `ios`) remains scaffold-only for now — future mobile-specific
layouts may be developed for particular users/use cases (e.g. inventory
management on the warehouse floor).

---

## 2. Architecture

### 2.1 Layering

**Decision**: a simple three-layer split per feature, avoiding
over-engineering for a project this size.

```
presentation/   widgets, screens, view-models (state)
domain/         entities, business rules, repository interfaces
data/           DTOs, API clients, repository implementations
```

- **presentation** depends on **domain** only (never directly on `data`).
- **data** implements interfaces defined in **domain**.
- Keeps business modules (sales, inventory, invoicing, accounting)
  testable without spinning up the API.

### 2.2 Project structure — feature-first

**Decision**: organize by business feature/module rather than by technical
layer at the top level, since MBE's domains (sales, inventory, invoicing,
accounting) map cleanly to how the team will divide work.

```
lib/
  app/                  # app bootstrap, routing, theme, DI setup
  core/                 # shared utilities, networking, error types, widgets
  features/
    auth/
      data/
      domain/
      presentation/
    sales/
    inventory/
    invoicing/
    accounting/
  main.dart
```

**Alternative**: layer-first (`lib/presentation`, `lib/domain`, `lib/data`
each containing all features). Simpler for very small teams, but tends to
create merge conflicts and makes ownership boundaries fuzzier as modules
grow. Feature-first is recommended given the four distinct business domains.

### 2.3 State management

| Option | Recommendation | Notes |
|---|---|---|
| **Riverpod** | ✅ Decision | Compile-safe DI + state, testable without `BuildContext`, good fit for feature-first structure, async data (`AsyncValue`) maps naturally onto API calls. |
| Bloc/Cubit | Alternative | More boilerplate, but very explicit event/state contracts — useful if the team wants strict auditability of state transitions (relevant for accounting flows). |
| Provider only | Not recommended | Lighter-weight but less ergonomic for async/error states; Riverpod supersedes it. |

**Decision**: **Riverpod**, with `AsyncNotifier`/`Notifier` per feature for
data that comes from mbe-api, and plain `Notifier`/`StateProvider` for local
UI state (form state, filters, selections).

### 2.4 Navigation

**Decision**: **go_router**.

- Declarative routes map well to deep-linking on web (e.g.
  `/sales/invoices/123`).
- Supports nested navigation/shells — useful for a desktop/web layout with a
  persistent side nav plus per-module sub-routes.
- Integrates with Riverpod for auth-based redirect guards (e.g. redirect to
  login if no valid session).

Route structure should mirror the feature folders:
`/sales/...`, `/inventory/...`, `/invoicing/...`, `/accounting/...`,
`/auth/...`.

### 2.5 Dependency injection

Riverpod's provider graph doubles as DI: repositories, API clients, and
services are exposed as providers and overridden in tests with fakes/mocks.
No separate DI framework (e.g. `get_it`) needed unless Riverpod is rejected.

---

## 3. Backend Integration (mbe-api)

Since mbe-api is also being built from scratch, the UI and API contracts can
co-evolve — but the UI should be designed against a stable contract
(OpenAPI/JSON Schema) rather than ad-hoc shapes, to avoid churn.

### 3.1 HTTP client

| Option | Recommendation |
|---|---|
| **dio** | ✅ Decision — interceptors for auth headers, retry, logging; widely used with Riverpod. |
| `http` package | Alternative — minimal, but requires hand-rolled interceptor logic for auth refresh and error mapping. |

### 3.2 Auth

**Status**: implemented in a first version on mbe-api (`/api/v1/auth/*`,
`/api/v1/users/*`), per the published OpenAPI spec (§3.3).

- **Login**: `POST /api/v1/auth/login` — OAuth2 "password" grant
  (`application/x-www-form-urlencoded`, fields `username`/`password`),
  matching `dio`'s/`openapi-generator`'s standard `OAuth2PasswordBearer`
  client. Returns `{ access_token, token_type: "bearer" }`.
- **Token**: HS256 JWT, 8-hour expiry (`exp`), carrying `sub` (user_id),
  `session_version`, `administrator`, and `store_id`. There is **no refresh
  endpoint** — see open question in §7. An 8-hour token is workable for a
  single workday; plan for re-login rather than silent refresh for now.
- **Session invalidation**: every request is validated against
  `user.session_version` in the DB (incremented whenever an admin edits the
  user). A mismatch invalidates the token server-side even before `exp`.
  A `dio` interceptor should treat any 401 as "session no longer valid" and
  redirect to `/auth/login` — there's nothing to retry.
- **Current user / privileges**: decode `sub` (user_id) from the stored JWT,
  then `GET /api/v1/users/{user_id}` to fetch the full profile — `settings`
  (default store/POS/cash drawer) and `privileges` (per-module RBAC, §3.7).
  Cache this in a Riverpod `AuthNotifier`/session provider after login.
- **Password change/recovery**:
  `POST /api/v1/auth/change-password` (self-service, requires old password),
  `POST /api/v1/auth/recover` (consumes a signed recovery token),
  `POST /api/v1/users/{user_id}/recover-password` (admin-triggered, returns a
  signed time-limited recovery token — admin must relay it to the user).
- Store the access token via `flutter_secure_storage` (mobile/desktop); web
  storage has weaker guarantees but is acceptable for an 8-hour token with
  server-side `session_version` revocation as a backstop.
- A `dio` interceptor attaches the bearer token and redirects to login on 401
  (see above — no refresh-on-401 until mbe-api adds a refresh endpoint).

> Note: mbe-api currently stores passwords as SHA1 (matching the legacy `mbe`
> scheme) — a bcrypt/argon2 migration is planned per the migration spec
> (`mbe/docs/specs/12-users.md` §"Password Storage Migration") but not yet
> implemented. No action needed in mbe-ui; the hashing scheme is server-side.

### 3.3 Data models & serialization

**Decision**: mbe-api publishes an OpenAPI (Swagger) spec
(`GET /openapi.json`, currently `v0.1.0`). mbe-ui will generate its API
client and DTOs from that spec using `openapi-generator` with the `dio`
generator, keeping client models in sync with the backend automatically
rather than hand-maintained.

**Status**: the spec currently covers `health`, `auth`, and `users` (incl.
`UserResponse`, `PrivilegeResponse`, `UserSettingsResponse`, etc. — see §3.7).
Codegen for the `auth`/`users` feature modules can be bootstrapped now; the
spec will grow incrementally as mbe-api implements master data, sales,
inventory, invoicing, and accounting endpoints. Re-run codegen as the spec
expands rather than waiting for full coverage.

Generated DTOs sit in `data/`; map them to immutable domain entities
(`freezed`) in `domain/` so presentation code isn't coupled to generated/
API-shaped classes, and spec changes don't ripple directly into the UI.

**Repo boundary**: "co-evolve" means mbe-ui adapts to mbe-api's published
contract, not that an mbe-ui session edits mbe-api's source directly — even
though both are commonly checked out side by side locally, they're
independently owned and released. When a feature needs a backend change
that doesn't exist yet (a new endpoint, a schema/projection field, etc.),
file an issue against mbe-api describing the exact change and record it as
an external dependency in the feature's plan; implement the mbe-ui-side
consumption once it ships and the client is regenerated. (Prompted by
`specs/008-merge-products`, where a suggestion-row field the merge picker
needed — `sku` on the products-list projection — didn't exist yet.)

**File uploads (`multipart/form-data`)**: the `dio` generator has repeatedly
emitted `String`-typed parameters for endpoints whose OpenAPI schema marks a
field `format: binary` — the generated wrapper then sends the value as a
plain form field (`FormData.fromMap`/`encodeFormParameter`), not a real file
part. The server (FastAPI `UploadFile`) rejects that with `"Expected
UploadFile, received: <class ...>"`; a base64-encoded string is not an
acceptable substitute. Confirmed twice: `ProductRepositoryImpl.uploadPhoto`
(spec 004) and `TaxpayerCertificateRepositoryImpl.upload` (spec 015 — the
generated method originally shipped with `String certificate`/`String key`
params and base64-encoded bytes, which the live server rejected on first
real use). For any new binary-upload endpoint, verify the generated
signature against a live upload before trusting it; if it's `String`-typed,
bypass the generated wrapper and call `dio.post(path, data:
FormData.fromMap({..., 'field': MultipartFile.fromBytes(bytes, filename:
...)}))` directly, deserializing the response with
`standardSerializers.deserialize` the same way the generated method would.

### 3.4 Error handling

- Map API errors (validation errors, 4xx/5xx) to a small set of domain error
  types (`ValidationError`, `NotFoundError`, `AuthError`, `ServerError`,
  `NetworkError`).
- Surface these consistently in the UI via a shared error-display widget
  (snackbar/banner), rather than each screen handling raw exceptions.

### 3.5 Offline / caching

**Decision**: the app is 100% online — no offline support. All reads and
writes go directly to mbe-api; no local persistence/sync layer is needed.

### 3.6 Document generation (PDF)

**Decision**: mbe-api generates PDFs server-side — both CFDI invoice
representations and POS sale tickets — replacing the legacy `mbe` pipeline
(jsreport + PhantomJS). mbe-ui does not generate PDFs; it fetches the
rendered bytes (e.g. `GET /invoices/{id}/pdf`) and uses the
[`printing`](https://pub.dev/packages/printing) package to preview, print,
download, or share them.

- CFDI representation PDFs are built by mbe-api from the stamped CFDI data
  (UUID, sello digital, QR), not relied upon from the PAC — mbe-api owns the
  full representation, consistent with the official format (per the attached
  sample).
- POS tickets follow a fixed-width template (per the attached sample),
  rendered by mbe-api the same way.
- mbe-api's templating/rendering library (e.g. WeasyPrint for HTML/CSS
  templates closest to the old jsreport approach, vs. ReportLab/fpdf2 for
  programmatic layouts) is an mbe-api implementation detail, out of scope for
  this document.

### 3.7 Authorization / permissions model

mbe-api carries over the legacy `mbe` RBAC model wholesale (see
`mbe/docs/specs/12-users.md` and `mbe/docs/constants.md` §`SystemObjects`/
§`AccessRight`):

- **`SystemObjects`**: a flat enum of ~114 integer codes, one per
  module/sub-feature/report (e.g. `0 = Products`, `7 = SalesOrders`,
  `92 = Users`, `44 = POS`, ...). This is effectively the permission gate
  catalog for every screen and action across sales, inventory, invoicing,
  and accounting.
- **`AccessRight`**: a `[Flags]` bitmask per `(user, SystemObject)` pair —
  `Create=1`, `Read=2`, `Update=4`, `Delete=8` (combine by OR; `15` = full
  access).
- `UserResponse.privileges` (from `GET /api/v1/users/{user_id}`) returns one
  `PrivilegeResponse` per `SystemObject` the user has a row for, each with
  the raw bitmask plus precomputed `allow_create`/`allow_read`/
  `allow_update`/`allow_delete` booleans.
- `administrator = true` bypasses all privilege checks (both server- and
  client-side equivalents should mirror this).
- Missing privilege row = no access (deny by default).

**Implications for mbe-ui**:

- Define a `SystemObject` enum/constant table in `core/` mirroring mbe-api's
  integer codes — generate or hand-maintain it alongside the OpenAPI client
  so values stay in sync as mbe-api adds modules.
- A session-scoped Riverpod provider (populated from `UserResponse` at login,
  §3.2) exposes `bool can(SystemObject, AccessRight)`, short-circuiting to
  `true` when `administrator`.
- **Navigation**: go_router redirects/guards and the side nav (§4.2) use
  `can(object, Read)` to hide/block routes the user has no access to —
  mirroring the legacy "menu item only visible if `AllowRead`" pattern.
- **Widgets**: shared list/detail screens (§4.3) use `can(object, Create|Update|Delete)`
  to show/hide action buttons (new, edit, delete) per screen, rather than
  each feature re-implementing the check.
- Each feature module's routes/screens should document which `SystemObject`
  code(s) they correspond to (most map 1:1, but some — e.g. `11 Addresses`,
  `12 Contacts` — gate inline sub-panels rather than top-level routes).

---

## 4. UI/UX Guidelines

### 4.1 Design system

**Decision**: mbe-ui adheres to **Material Design** (Material 3, Flutter's
default) — no platform-specific (Cupertino) UI branches. Material 3 gives
good defaults across all six target platforms and has built-in support for
adaptive layouts.

**White-labeling**: MBE is open source and deployed for multiple customers,
so branding (seed color, logo, app name, typography) must be configurable per
deployment rather than hardcoded:

- A `ThemeData` is built from Material 3's `ColorScheme.fromSeed`, but the
  seed color (and other brand tokens — logo asset, app display name) is read
  from a per-deployment configuration rather than a constant in `app/theme/`.
- **Decision**: configuration source is build-time **Flutter flavors**
  (`--dart-define`/flavor-specific entry points producing per-customer
  builds), not a runtime tenant config fetched from mbe-api.
- All UI stays within Material 3 component shapes/structure regardless of
  theme — customization is limited to color scheme, typography, and branding
  assets, not layout/structure, to keep the design system consistent across
  customers.

**Light/dark mode**: Generate both a light and dark `ColorScheme` from the
same per-customer seed color (`ColorScheme.fromSeed(seedColor: ..., brightness: Brightness.light/.dark)`),
and let the end user choose Light / Dark / System in app settings via
`MaterialApp.themeMode`, persisted locally (e.g. `shared_preferences`) per
user/device.

### 4.2 Responsive / adaptive layout

**Decision**: the first delivery targets the **Expanded** (desktop/web) tier
only — persistent side navigation rail/drawer, multi-pane layouts (e.g. list
+ detail), data tables and multi-column forms.

A **Compact** (phone) tier — single-column, bottom nav or drawer — is
deferred until a mobile-specific use case is scoped (e.g. inventory
management on the warehouse floor, per §1).

Even so, centralize `LayoutBuilder`/`MediaQuery` breakpoints in `core/` from
the start, so adding the Compact tier later doesn't require each feature to
retrofit its own breakpoints.

### 4.2.1 Catalog/list row actions — Edit-only, click-to-view

**Decision** (constitution §VI, amended 2026-07-05 per specs/007-catalog-ui-improvements-2):
every catalog/list screen's row exposes exactly one row-level icon action,
**Edit** — no per-row View or Delete icon. Clicking anywhere else on the row
opens the same detail screen **read-only** (titled as a "View" screen, not
"Edit"); from there, a user holding the update privilege gets an explicit
control, in the record's shared action area (§4.2.2, §4.3), to switch to the
editable form. Create stays toolbar-only. Delete/soft-delete moves off the
list entirely onto the record's own detail screen — typically a
warning-styled button in the form body, though a module may keep it as a
detail-screen app-bar action if a form-body button doesn't fit (the Users
admin screen does this).

**Rationale**: an earlier version of this rule (through constitution v1.4.0)
put View, Edit, and Delete all on the row as three separate icons. Usage
feedback showed this added visual noise without reducing risk: a stray click
anywhere on the row still opened the *editable* form, so "safe browsing" was
never actually the default. Defaulting row-click to read-only, and shrinking
the row's icon surface to just Edit, makes the safe path the path of least
resistance while keeping editing and deletion one deliberate step away.

### 4.2.2 Screen-level actions — buttons in the body, not AppBar icons

**Decision** (constitution §VI, amended 2026-07-19, **superseded**
2026-07-25 per specs/017-ui-consistency-filters — see below): `AppBar.actions`
was reserved for exactly one thing — the read-only-to-edit toggle from
§4.2.1 (and, optionally, a detail screen's own delete action, per the Users
admin screen precedent). Every other screen-level action — Create, a bulk
operation like Merge, or a shortcut into a related feature's own screen —
is a `FilledButton`/`OutlinedButton` in the screen body: beside the search
bar via `CatalogFilterBar`'s `actions` slot on list screens (as
`products_list_screen.dart` already does for Create and Merge), or in the
form body on detail screens.

**Rationale**: specs/011-product-pricing initially added a "view pricing"
shortcut to the product detail screen's `AppBar.actions` before it was
corrected to a products-list row action instead. Without a codified rule,
each new cross-feature shortcut risked landing back on the AppBar by default
since that's where the one legitimate icon action already lives. Naming the
AppBar as reserved, and the button-in-body placement as the default for
everything else, avoids re-litigating this per feature.

**Superseding decision** (constitution §VI, amended 2026-07-25 per
specs/017-ui-consistency-filters): the read-only-to-edit toggle **also**
moves out of `AppBar.actions`, into the record's own form body, as a labeled
`OutlinedButton` sitting alongside Save and Delete rather than as an
unlabeled app-bar icon separated from the actions it precedes. A record
detail screen's `AppBar.actions` is now empty by default; the previously-
allowed app-bar delete exception (Users admin screen precedent) is retained
verbatim for a module whose body genuinely cannot fit a delete button, but
no module uses it today.

This is implemented once, in `core/widgets/record_form_actions.dart`
(`RecordFormActions`, §4.3), and adopted by every one of the 18 record
detail screens — not reimplemented per screen. `RecordFormActions` renders,
in fixed left-to-right order: `[ Delete ]` (only while editing, only with
the delete privilege) then either `[ Edit ]` (read-only, only with the
update privilege) or `[ Save ]` (editable/create), so the same action area
holds the record's entire command surface across all three states, in the
same on-screen position, rather than splitting Edit into the app bar and
Save/Delete into the form. `Edit` renders as an `OutlinedButton` — visually
a lighter sibling of the `FilledButton` Save, ranking it correctly as a mode
switch rather than a commit. `Delete` also became `OutlinedButton`-styled in
the error color, rather than a filled error block, so the destructive action
reads as unmistakable without being the loudest thing on an otherwise
read-only-looking form.

**Rationale for the reversal**: user feedback found the split itself to be
the friction — the one control a user needs to *start* acting on a record
sat in a different visual location (an unlabeled top-right icon) from the
controls that appear the moment they do (bottom-of-form buttons), forcing
the user to learn two places for one continuous task. Centralizing the
whole action set in `RecordFormActions` also converts "move the affordance"
from an 18-screen edit into a one-component edit, the same lesson the
2026-07-19 amendment itself was trying to teach — it just drew the reserved
boundary one iteration too early, around the app bar, rather than around a
shared component. See specs/017-ui-consistency-filters/research.md §2 and §7
for the full before/after comparison and the amendment sequencing (the rule
change lands with the first converted screen, so no shipped screen is ever
mid-flight between the two rules).

### 4.3 Shared component library

Build a small `core/widgets/` library early for things every module needs:
data tables with sorting/pagination, currency/quantity formatted fields, date
pickers, status badges (e.g. invoice status), and form field wrappers with
consistent validation-error display. This avoids four slightly-different
implementations across sales/inventory/invoicing/accounting.

**Record action area** (`core/widgets/record_form_actions.dart`,
`RecordFormActions`, added specs/017-ui-consistency-filters per §4.2.2):
the Edit/Save/Delete action set every record detail screen offers, plus the
delete confirmation dialog, defined once instead of hand-copied per screen.
Takes the screen's RBAC-derived callbacks (`null` ⇒ that action is absent,
never disabled) and its current `RecordFormMode` (`create`/`view`/`edit`),
and renders the mode-appropriate subset in fixed order, right-aligned and
content-sized rather than stretched across the form.

**Responsive forms — use space, don't waste it**: multi-field create/edit/
detail forms MUST NOT stretch single-column, full-width fields across a wide
desktop display — that leaves large empty gutters and long eye-travel. Instead
use the shared responsive form-grid widget (`core/widgets/responsive_form_grid.dart`,
`ResponsiveFormGrid`), which lays fields into a centered, max-width column grid:
one column on Compact, two on wider tiers, capped per screen via `maxColumns`
(most forms prefer **two** columns even on the widest tier — paired fields read
better than three narrow ones). Constitution §VI makes this binding.

Within a form, group related content and separate logical sections to aid
scanning:

- **Section dividers**: delimit distinct blocks (e.g. an attribute/toggle
  group, a labels section) with the standard Material 3
  `Divider` when it improves scanability or reclaims wasted vertical space —
  dividers are M3's idiomatic group separator.
- **Side-by-side grouping**: pair naturally related blocks into a two-column
  band on wide tiers (e.g. boolean attribute switches on the left, the labels
  picker on the right) rather than stacking each full-width; collapse to a
  vertical stack on Compact.

The product catalog detail screen (`features/catalog/presentation/product_detail_screen.dart`)
is the reference implementation of all three (two-column field grid, section
dividers, switches|labels two-column band).

**One formatting surface** — *in force since spec 028.*
specs/027-app-user-settings specified this and then **descoped it** (2026-08-16)
into a future spec, because the migration is ≈76 call sites across ~28 files
and is indivisible: the guard test could not land until the last call site
moved. specs/028-presentation-consistency built it, carrying the finished
design forward into its own `contracts/formatting-surface.md` and
`research.md` R1–R8, with two corrections found during that migration:
the default date is **ISO 8601** (`yyyy-MM-dd`), not the locale-derived
rendering the app used before — a deliberate choice, so one deployment
serving multiple locales still shows one unambiguous date everywhere; and the
guard's allowlist covers `lib/l10n/` (generated localizations), not
`lib/generated/` (the OpenAPI client) as first assumed.

Dates, date-times, currency, percentages and quantities render through a
single shared formatting component, `formattersProvider`
(`lib/core/formatting/`), driven by deployment-level app settings
(`DATE_FORMAT`, `DATE_TIME_FORMAT`, `CURRENCY_SYMBOL`, `CURRENCY_CODE`,
`CURRENCY_DECIMAL_DIGITS`, `PERCENT_DECIMAL_DIGITS`, `QUANTITY_DECIMAL_DIGITS`
— see `.env.template`) plus the active locale. This is not a style preference
— the app had drifted into three parallel paths (`core/widgets/money_formatters.dart`
with a hard-coded `$` and an `'es_MX'` default; the display helpers in
`features/sales/domain/money.dart` doing `Decimal.toStringAsFixed` and
hand-building `"16.00 %"`; and `taxpayer_certificates_section.dart` building
its own `DateFormat.yMd()` inline — all three now deleted), so the same kind
of value read differently depending on which screen rendered it. The surface
distinguishes *read-only display* formatting (`fmt.display.*`) from
*editable-field* formatting (`fmt.field.*` — a field the user types into
carries no `$`, and round-trips back to the stored value), and renders one
placeholder, `—`, for absent/unparseable input everywhere. Call sites do not
pass a locale by hand — the repeated
`Localizations.localeOf(context).toString()` boilerplate was itself a source
of drift, and dropped the country subtag Flutter's own locale resolution
discards, which surfaced as a real bug: the two screens that called it
directly (`cash_sessions_screen.dart`, `pos_sales_list_screen.dart`) were
rendering Spain-style numbers (`"3.240,00 $"`) instead of Mexican ones
(`"$3,240.00"`) without anyone noticing. `test/unit/core/formatting_guard_test.dart`
fails the suite when a raw formatter is introduced outside the surface,
naming the offending file and line.

**List-screen structure** (specs/027-app-user-settings): a list screen is a
filter row, a list, and pagination. Facet filters belong behind the shared
badged filters button and its right-hand drawer (`CatalogFilterBar` +
`showCatalogFilterSheet`) — not inline in the filter row as chips, menus or
date pickers, which is what `pos_sales_list_screen.dart` had grown. A form
does not belong stacked above a list: `cash_sessions_screen.dart` had an
open-shift form there, and it moves into a sheet launched from a toolbar
action, with that action carrying the shift state the inline panel used to
show. Where a screen's endpoint has no free-text search, the shared filter row
omits the search control rather than each screen passing an empty placeholder.

**Alignment and symmetry** (specs/027-app-user-settings): within a row or
card, vertical padding is symmetric — the space above the content equals the
space below it — and controls sharing a horizontal band share a text baseline.
Padding and margin values come from the spec 022 design tokens
(`core/design/spacing.dart`), never ad-hoc literals. The POS sale line is the
worked example: getting its several control types to agree on one height
*and* one baseline took many iterations (see the derivation in
`features/sales/presentation/capture/sale_line_layout.dart`), and the
bottom-heavy, baseline-mismatched rendering reported for this feature was
re-investigated under the app's real `InputDecorationTheme` and did not
reproduce — a bare-`MaterialApp` test harness had been masking the real
decoration insets during the original diagnosis, and the mismatch itself was
already gone (most likely fixed incidentally by an earlier spec's change to
this file). What this feature actually changed is: the layout's fixed
constants became functions of the app's text-size level so scaling still
lands on-baseline at every level (§4.4 below), and the no-mismatch state is
now pinned by `sale_line_symmetry_test.dart` — measuring real insets and
baselines across all four text-size levels — rather than left to be
rediscovered by eye. Because this kind of alignment is hard to eyeball and
easy to regress, any screen with a comparable control band MUST assert it the
same way, per Constitution VI.

### 4.4 Localization

Mictlanix operates in Mexico — plan for **es-MX** as a first-class locale
(likely the default), with the Flutter `flutter_localizations` + `intl`
pipeline (`.arb` files) from the start even if English isn't needed
immediately. Currency/number formatting (MXN) and date formats should use
`intl` rather than manual string formatting.

**Two levels of configuration** (specs/027-app-user-settings). The app now
distinguishes them, and they must not be conflated:

- **App settings** are *deployment* configuration — the deployment's default
  locale, endpoints, brand tokens and POS defaults (plus, once the formatting
  surface above exists, its formatting options; those keys were descoped with
  it rather than shipped with no consumer). They resolve once at startup from build-time
  values supplied via `--dart-define-from-file=.env`, the mechanism
  `brand_config.dart`, `dio_client.dart`, `photo_url.dart` and
  `pos_defaults.dart` already use individually and which this consolidates
  into one documented place, with `.env.template` as the single source of
  that documentation. They are never reachable or mutable from the UI, and a
  malformed or absent value falls back to a documented default rather than
  breaking startup. Runtime-parsed config files were rejected: they would
  contradict §4.1's build-time brand rule, ship the file to the browser on
  web anyway, and add a dependency for no gain in this deployment model.
- **User display preferences** are *personal* and *device-local* — appearance
  (Light/Dark/System), one of four overall text-size levels for accessibility,
  and a language override among the supported locales (or follow-system).
  They persist via `shared_preferences` through a single
  `UserDisplayPreferencesController` (replacing the old, theme-only
  `ThemeModeController`, whose `theme_mode` storage key it reuses verbatim so
  existing installs keep their choice), and apply immediately with no
  restart. They are
  deliberately **not** synced through mbe-api: `UserSettingsResponse` carries
  the user's cash drawer and point of sale, which are operational assignments,
  not display taste — the two must stay distinguishable in naming and in
  storage. The consequence, accepted: preferences do not follow a user to
  another machine.

The deployment default applies to any user who has expressed no preference.

### 4.5 Theming

Light/dark mode support via Material 3's `ColorScheme.fromSeed`, with the
seed color matching Mictlanix branding. Keep the current scaffold's
placeholder theme (`Colors.deepPurple` seed) only as a temporary value.

The user's appearance choice, their text-size level and their language
override are surfaced together on a **user settings screen** reached from the
user menu (`core/widgets/user_menu_button.dart`), beside the existing
change-password entry (specs/027-app-user-settings). No RBAC gate applies —
display preferences are personal, available to every signed-in user. Text size
is the constraint to watch: it scales the whole app, and screens with a fixed
column budget (the POS capture surface above all, whose widths were tuned
against specific text sizes) must be verified at the largest level rather than
assumed to absorb it.

---

## 5. Feature / Domain Modules

High-level boundaries for `lib/features/`:

- **auth** — login, session, user profile, password change/recovery, and the
  admin-only **Users** screen (account CRUD + per-`SystemObject` privilege
  grid, §3.7). Backed by mbe-api's `auth`/`users` endpoints — the first
  modules with a published OpenAPI spec (§3.3), so this is the natural module
  to bootstrap codegen, the Riverpod session provider, and go_router auth
  guards against.
- **sales** — customers, sales orders, quotes.
- **inventory** — products, warehouses, stock levels, stock movements.
- **invoicing** — invoices, payments, CFDI/electronic invoicing
  considerations (relevant for Mexico).
- **accounting** — ledgers, accounts, financial reports.

Each module owns its `data/domain/presentation` layers and routes. Shared
entities (e.g. "Product" used by both inventory and invoicing) live in
`core/domain` or a shared `catalog` module to avoid duplication —
**this boundary should be settled with mbe-api's data model once defined**,
since duplicating entity definitions across modules vs. a shared kernel is
easier to get right when both UI and API are designed together.

**Signal from the legacy schema**: `mbe/docs/specs/01-master-data.md` groups
Products, Price Lists, Customers, Suppliers, Employees, Warehouses, Stores,
Points of Sale, Cash Drawers, Exchange Rates, and Vehicles under a single
"Master Data" area, all referenced by `SystemObjects` codes 0–13/29/43/88-89.
These are the entities shared across sales/inventory/invoicing/accounting.
Once mbe-api exposes these endpoints, a dedicated `master_data` (or
`catalog`) feature module — owning Product, Customer, Supplier, Warehouse,
PriceList, Store, etc. — is likely the right shared kernel, with
sales/inventory/invoicing/accounting depending on it rather than each
re-defining these entities.

---

## 6. Testing Strategy

- **Unit tests**: domain logic and repositories (mock API client).
- **Widget tests**: key shared components (`core/widgets`) and critical
  screens per module.
- **Integration tests**: golden-path flows (login → create invoice, stock
  adjustment, etc.) using `integration_test`, run against a test instance of
  mbe-api once available.

---

## 7. Open Questions

- ~~mbe-api OpenAPI spec — not yet published~~ **Resolved**: a draft spec is
  live (`auth`, `users`, `health`). Codegen (§3.3) can be bootstrapped for
  these now; revisit as mbe-api adds master data, sales, inventory,
  invoicing, and accounting endpoints.
- **Refresh tokens**: §3.2 originally assumed short-lived access + refresh
  tokens, but the current `auth` implementation issues only an 8-hour JWT via
  `/auth/login` with no refresh endpoint, relying on `session_version` for
  server-side revocation. Decide whether this is sufficient long-term (simple
  re-login on expiry/401) or whether mbe-api should add a refresh-token
  endpoint before other modules build on the same `dio` interceptor pattern.
- ~~**RBAC integration details** (§3.7): the "decode JWT `sub` →
  `GET /users/{user_id}` for `privileges`" pattern does not work for
  non-administrators~~ **Resolved**: `mictlanix/mbe-api#1` shipped
  `GET /api/v1/auth/me` → `UserResponse`, gated only by `get_current_user`
  (works for non-administrators). mbe-ui's session provider consumes
  `/auth/me` for bootstrap (see
  [contracts/mbe-api-auth-users.md](specs/001-user-authentication/contracts/mbe-api-auth-users.md)).
- Direct ESC-POS/thermal receipt printer access from cashier stations (§3.6)
  — browser/desktop print dialogs can't drive thermal printers directly;
  needs its own investigation if required for launch.
