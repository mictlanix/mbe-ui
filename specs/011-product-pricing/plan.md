# Implementation Plan: Product Pricing (Price Lists, Product Prices & Exchange Rates)

**Branch**: `011-product-pricing` | **Date**: 2026-07-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/011-product-pricing/spec.md`

## Summary

Add a new `lib/features/pricing/` module delivering three surfaces against
mbe-api's pricing endpoints: a **price-lists catalog** (`/price-lists`, CRUD),
a **pricing tool** (`/pricing`, set a product's price per list), and an
**exchange-rates catalog** (`/exchange-rates`, CRUD). Each is gated by its own
existing `SystemObject` — `priceLists` (5), `pricing` (106), `exchangeRates`
(43).

Two planning decisions shape the work (recorded 2026-07-14):

1. **Prices do not go back on the product form.** Feature 007 removed them
   deliberately (its FR-012/FR-013, with labels taking that layout slot); this
   feature honors that and ships a standalone pricing tool instead — which also
   matches the RBAC split, since `Pricing` (106) is a different privilege
   surface from `Products` (0). See research.md §1.
2. **No codegen re-run.** `price_lists_api.dart`, `product_prices_api.dart`,
   `exchange_rates_api.dart` and their models are already committed under
   `lib/generated/openapi/` and are treated as current. See research.md §2.

Consequently this feature adds **no** RBAC plumbing (all three `SystemObject`s
already exist) and **no** new third-party dependency. The only shared addition
is a `Currency` enum in `core/domain/` — needed because mbe-api types exchange-rate
`base`/`target` as bare `int` with no published enum (research.md §6).

The pricing tool's defining behavior is a **client-side left join**: mbe-api
returns only price rows that exist, so the controller merges the full price-list
set with the product's prices to render every list — distinguishing "not set"
from `0.00` (FR-008, research.md §5).

## Technical Context

**Language/Version**: Dart `^3.10.3` (per `pubspec.yaml`), Flutter stable
channel matching that SDK constraint — same as specs/002-product-catalog.

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` /
`riverpod_generator`, `go_router`, `dio`, `freezed` / `freezed_annotation` +
`json_serializable`, `intl` (MXN currency + percent + date formatting),
`data_table_2`, `one_of` (already present — first *first-party* use, see Risks).
**No new dependency is introduced.**

**Storage**: N/A — no local database/cache (constitution §VII). Product
selection and form state are in-memory only.

**Testing**: `flutter_test` for unit/widget, `mocktail` for repository fakes,
`integration_test` for the create-list → price-product → record-rate golden path
against a local mbe-api (quickstart.md).

**Target Platform**: Web, Windows, macOS, Linux — Expanded (desktop/web) tier,
with the Compact tier inherited from spec 010's adaptive shell.

**Project Type**: Single Flutter project, feature-first — a **new**
`lib/features/pricing/` module (see Structure Decision).

**Performance Goals**: Selecting a product renders its full price grid within
one round-trip pair (`/price-lists` + `/product-prices?product=`); both are
paginated/bounded. Locating a day's rate in a year of daily rates is filter-driven,
not scroll-driven (SC-006).

**Constraints**: Deny-by-default RBAC on three distinct objects; client-side
gating only — server-side enforcement on pricing endpoints is unverified
(contracts/mbe-api-pricing.md **G4**, the same posture feature 002 recorded for
products). Money is `String` end-to-end; never parsed to `double`
(research.md §3). `GET /product-prices` defaults to `limit=20` — the pricing
screen must pass an explicit limit (**G5**).

**Scale/Scope**: 5 screens (price-lists list + detail, pricing tool,
exchange-rates list + detail), 3 repositories, ~4 controllers, 3 `freezed`
entities + 1 view-model row, 1 shared `Currency` enum, 3 router branches + 4
sub-routes, 3 nav destinations, ~9 new l10n keys.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | New `lib/features/pricing/{data,domain,presentation}`; `presentation` imports only `domain`; `data` implements `domain` repository interfaces. `Currency` goes to the `core/domain/` shared kernel because it is cross-feature (research.md §6), not redefined per feature. |
| II. Riverpod for State & DI | ✅ PASS | `PriceListsListController`, `PriceListFormController`, `PricingController`, `ExchangeRatesListController` as `Notifier`s; three repositories exposed as providers for test overrides. `AsyncValue` for all API-sourced state. |
| III. Contract-Driven API Integration | ✅ PASS | Consumes the already-generated `PriceListsApi`/`ProductPricesApi`/`ExchangeRatesApi` (contracts/mbe-api-pricing.md); **no hand-written DTOs**; generated files not edited. Errors map to the existing shared error types via `ErrorBanner`. No sibling-repo edits — the two upstream gaps (G1 currency enum, G4 server-side gating) are recorded as observations/candidate mbe-api issues, not patched here. `Currency` is a constant enum, **not** a DTO — see the note below. |
| IV. Deny-by-Default RBAC | ✅ PASS | Reuses `accessControlProvider.can(...)` with the three pre-existing `SystemObject`s; routes gated via `routeSystemObject`, nav via `navDestinationsProvider`'s filter, actions hidden (not disabled) without privilege (contracts/routes.md). |
| V. Material 3 White-Labeled Design System | ✅ PASS | No new theming. All money/percent/date rendering via `intl` (`es-MX`, MXN) — never manual string formatting (FR-013). New l10n keys added to `.arb`. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ PASS | Both catalog screens reuse the shared `DataTableView`, `CatalogPagination`, `CatalogFilterBar`/`CatalogSearchBar`, single Edit row action, row-click → read-only view, toolbar-only Create, delete-in-form-body; detail forms use `ResponsiveFormGrid`. Numeric/currency columns right-aligned. `/pricing` is a tool rather than a record catalog — see the deviation note below. |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No local persistence, no caching layer, no document generation. |

**On §III and the `Currency` enum**: §III forbids hand-written DTOs *for a
resource that already has a published schema*. mbe-api publishes **no** currency
schema (`base`/`target` are bare `int`s; contracts/mbe-api-pricing.md **G1**), so
there is nothing to generate from. `Currency` is a constant enum mirroring
`mbe/docs/constants.md` §CurrencyCode, with direct precedent in
`lib/core/access/system_object.dart` — which mirrors §SystemObjects in exactly
this shape. Not a deviation.

**On §VI and `/pricing`**: §VI's row-level contract (one Edit icon, whole-row
click → read-only detail) governs **catalog/list screens** whose rows are
navigable records. `/pricing`'s rows are inline-editable price values on a tool
screen, not records with detail pages — there is nothing for a row click to open
and nothing for an Edit icon to navigate to. The screen still honors every
applicable §VI rule (shared table, right-aligned numerics, hidden-when-
unprivileged controls, shared picker). The two genuine catalog screens
(`/price-lists`, `/exchange-rates`) follow §VI's row contract in full. Read as
scope, not deviation — no Complexity Tracking entry.

**Post-Phase 1 re-check**: ✅ still passing. Phase 1 introduced no new
dependency, no new RBAC plumbing, no generated-file edits, and no local
persistence.

## Project Structure

### Documentation (this feature)

```text
specs/011-product-pricing/
├── plan.md                       # This file
├── spec.md                       # Feature spec
├── research.md                   # Phase 0 output
├── data-model.md                 # Phase 1 output
├── quickstart.md                 # Phase 1 output
├── contracts/                    # Phase 1 output
│   ├── mbe-api-pricing.md        # endpoint/DTO contract + upstream gaps
│   └── routes.md                 # routes, nav, RBAC gating
├── checklists/
│   └── requirements.md           # spec quality checklist
└── tasks.md                      # Phase 2 output (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
lib/
├── app/
│   └── router/
│       └── app_router.dart              # MODIFIED: 3 shell branches + 4 sub-routes + routeSystemObject entries
├── core/
│   ├── domain/
│   │   └── currency.dart                # NEW: Currency enum (mxn/usd/eur), mirrors legacy CurrencyCode
│   ├── navigation/
│   │   └── nav_destinations.dart        # MODIFIED: 3 NavDestinations + 3 NavBranch indices (order MUST match router)
│   └── access/
│       └── system_object.dart           # UNCHANGED: priceLists(5), pricing(106), exchangeRates(43) already present
├── l10n/
│   └── app_*.arb                        # MODIFIED: nav titles, column headers, validation messages, empty states
└── features/
    └── pricing/                         # NEW MODULE
        ├── data/
        │   ├── price_list_repository_impl.dart      # wraps PriceListsApi
        │   ├── product_price_repository_impl.dart   # wraps ProductPricesApi (AnyOf write path)
        │   └── exchange_rate_repository_impl.dart   # wraps ExchangeRatesApi
        ├── domain/
        │   ├── entities/
        │   │   ├── price_list.dart                  # freezed (data-model.md §1)
        │   │   ├── product_price.dart               # freezed (data-model.md §2)
        │   │   └── exchange_rate.dart               # freezed (data-model.md §4)
        │   └── repositories/
        │       ├── price_list_repository.dart       # interface
        │       ├── product_price_repository.dart    # interface
        │       └── exchange_rate_repository.dart    # interface
        └── presentation/
            ├── price_lists_list_screen.dart
            ├── price_lists_list_controller.dart     # Notifier: search/pagination
            ├── price_list_detail_screen.dart        # create + view/edit modes
            ├── price_list_form_controller.dart      # Notifier: form state + validation
            ├── pricing_screen.dart                  # product picker + price grid
            ├── pricing_controller.dart              # Notifier: left join, create-vs-update save
            ├── product_price_row.dart               # view model (data-model.md §3)
            ├── exchange_rates_list_screen.dart
            ├── exchange_rates_list_controller.dart  # Notifier: date-range/currency filters + pagination
            ├── exchange_rate_detail_screen.dart     # create + view/edit modes
            └── exchange_rate_form_controller.dart   # Notifier: form state + validation

lib/generated/openapi/                   # UNCHANGED — pricing APIs/models already present (research.md §2)

test/
├── unit/features/pricing/               # mapping (nested price_list, Currency fallback), left join, validators, AnyOf round-trip
├── widget/features/pricing/             # 5 screens: read-only vs editable, not-set vs zero, empty states, RBAC hiding
└── integration/pricing_flow_test.dart   # create list → price product → record rate
```

**Structure Decision**: A **new `lib/features/pricing/` module** rather than
extending `lib/features/catalog/`. Constitution §I organizes by business
feature, and pricing is a distinct one: it sits behind its own RBAC objects
(5/106/43 vs. catalog's `products`/`labels`), and nothing in `catalog/` consumes
these entities — feature 007 removed the catalog's last price reference, so
there is no shared-kernel pull toward `catalog/`. `Currency` is the one
exception: it goes to `core/domain/` because it is genuinely cross-feature
(`Product.currency` is already a raw `int` that sales/invoicing will also need
to render). This feature modifies only `app_router.dart`, `nav_destinations.dart`,
and the `.arb` files; it reuses `core/network`, `core/errors`, `core/access`,
and `core/widgets/` unmodified, and does not touch `features/catalog/` at all.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| **`AnyOf` write path unproven** — the generated `Price`/`LowProfit`/`HighProfit` request wrappers are `anyOf: [number, string]`, and `grep` finds **no** existing `one_of` usage under `lib/features/` or `lib/core/`. This is the codebase's first construction site. | Prices silently fail to save or serialize as `null`/`0` — and a broken serializer can still look like a successful save in the UI. | Send the String arm: `Price((b) => b..anyOf = AnyOf2<num, String>(values: {1: '120.00'}))` (research.md §4). **Mandatory** repository round-trip test asserting the wire format, plus live verification per quickstart §3 — before the UI is trusted. Highest-risk item in the feature. |
| Generated client drifts from mbe-api | Building against a stale contract | Accepted by the no-codegen decision (research.md §2). Quickstart's live checks exercise every endpoint, so drift fails loudly. |
| `product-prices` `limit` defaults to 20 | Silent truncation for a product priced across >20 lists | Pass an explicit `limit` covering the price-list count; verify per quickstart §3 (G5). |
| `NavBranch` indices drift from router branch order | Wrong nav item highlighted | Add branches in the same order in both files; `nav_destinations.dart:10-11` already documents the invariant (contracts/routes.md). |
| Price-list deletion rule unverified upstream (G3) | US1 §6 may not be enforced server-side | UI surfaces any rejection and never pre-checks; if mbe-api does not enforce it, that's an upstream issue to file, not a UI workaround. |

## Follow-ups (not blocking)

- **Candidate mbe-api issue**: publish a currency enum for exchange-rate
  `base`/`target` (G1), so mbe-ui can drop the locally-mirrored `Currency`.
- **Candidate mbe-api issue**: confirm/implement server-side RBAC enforcement on
  the pricing endpoints (G4) — currently client-gated only, same as products.
- **Deferred**: retrofit `Product.currency` (raw `int`) onto the new `Currency`
  enum — a catalog change, out of this feature's scope.
- **Possible enhancement**: `/pricing?product=:id` deep link (contracts/routes.md).

## Complexity Tracking

*No constitution violations — this section is intentionally empty.* The two
notes under Constitution Check (`Currency` under §III, `/pricing` under §VI) are
scope clarifications with precedent, not deviations requiring justification.
