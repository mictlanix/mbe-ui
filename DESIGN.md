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

**Decision**: mbe-api exposes JWT bearer token-based auth (common for Python
frameworks like FastAPI).

- Store tokens via `flutter_secure_storage` (mobile/desktop) — web storage
  has weaker security guarantees, so plan for short-lived access tokens +
  refresh tokens regardless of platform.
- A `dio` interceptor attaches the bearer token and triggers refresh-on-401.

### 3.3 Data models & serialization

**Decision**: mbe-api will publish an OpenAPI (Swagger) spec. mbe-ui will
generate its API client and DTOs from that spec using `openapi-generator`
with the `dio` generator, keeping client models in sync with the backend
automatically rather than hand-maintained.

Generated DTOs sit in `data/`; map them to immutable domain entities
(`freezed`) in `domain/` so presentation code isn't coupled to generated/
API-shaped classes, and spec changes don't ripple directly into the UI.

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

### 4.3 Shared component library

Build a small `core/widgets/` library early for things every module needs:
data tables with sorting/pagination, currency/quantity formatted fields, date
pickers, status badges (e.g. invoice status), and form field wrappers with
consistent validation-error display. This avoids four slightly-different
implementations across sales/inventory/invoicing/accounting.

### 4.4 Localization

Mictlanix operates in Mexico — plan for **es-MX** as a first-class locale
(likely the default), with the Flutter `flutter_localizations` + `intl`
pipeline (`.arb` files) from the start even if English isn't needed
immediately. Currency/number formatting (MXN) and date formats should use
`intl` rather than manual string formatting.

### 4.5 Theming

Light/dark mode support via Material 3's `ColorScheme.fromSeed`, with the
seed color matching Mictlanix branding. Keep the current scaffold's
placeholder theme (`Colors.deepPurple` seed) only as a temporary value.

---

## 5. Feature / Domain Modules

High-level boundaries for `lib/features/`:

- **auth** — login, session, user profile, permissions/roles.
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

- mbe-api OpenAPI spec — not yet published; codegen (§3.3) can't start until
  a draft spec exists.
- Direct ESC-POS/thermal receipt printer access from cashier stations (§3.6)
  — browser/desktop print dialogs can't drive thermal printers directly;
  needs its own investigation if required for launch.
