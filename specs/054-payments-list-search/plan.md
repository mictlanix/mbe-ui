# Implementation Plan: Payments List and Search

**Branch**: `054-payments-list-search` | **Date**: 2026-10-27 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/054-payments-list-search/spec.md`

Roadmap: Closes mictlanix/mbe-roadmap#25 · Soft dependency: mbe-api#270

## Summary

Add a read-only **Pagos** screen to the sales section.

- **List:** a paginated list of the facility's customer payments, with five facets: customer, date range, method, a tri-state verified filter, and cash session.
- **"Todas las sucursales" mode:** for Payments Editor readers, a cross-facility search by reference.
- **Payment view:** a full detail screen showing every field, the Importe · Aplicado · Sin aplicar summary, and the applications. Reversed applications appear muted. Order and cash-session numbers link to their screens when the user can read them.

**Technical approach:**
- Four methods on the existing `CustomerPaymentRepository`, each wrapping a generated operation that already exists, so no codegen is needed.
- New freezed entities `CustomerPayment` and `PaymentApplication`, plus a URL-backed `PaymentsFilter`.
- The standard list layout (`CatalogFilterBar`, `CatalogListStateView`, `DataTableView`).
- Per-id display-name providers for customer, payment option and cash session, the same pattern as the existing ones.
- Two client-side guards for server gaps: the list always sends the user's facility, and the detail screen shows not-found for another facility's payment unless the user is a Payments Editor (R4).

## Technical Context

**Language/Version**: Dart `^3.10.3`, Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**: Riverpod 3 (`riverpod_annotation` / riverpod_generator 4), freezed 4, `go_router`, `data_table_2`, `decimal`, the generated `mbe_api_client`. No new packages.

**Storage**: N/A (online-only, §VII)

**Testing**:
- `flutter_test` + `mocktail` with `ProviderScope` overrides. The cash-sessions and sales-orders list tests are the template.
- One live repository test in `test/integration/`, with runtime fixture discovery (R13).

**Target Platform**: Web/desktop first (the Expanded tier). On the compact tier, tables scroll horizontally because `DataTableView` has no card mode yet. No columns are dropped (wireframe Open Question 3).

**Project Type**: Flutter client application, feature-first layered

**Performance Goals**:
- One list request per page.
- Name lookups are deduped per id by provider families: at most one per distinct customer, option and facility per session.
- The detail view makes 2 requests, plus one per distinct application order (R8).

**Constraints**:
- Read-only: no mutation calls (FR-003).
- The facility-scoped list must always send the user's facility (R4).
- Amounts go through `formattersProvider` plus a currency code (R9). All strings are in `.arb` files. Spacing comes only from tokens.
- No change to `core/widgets/`, `core/formatting/` or generated code.
- Format only the changed files. Never run `dart format` over the whole repo.

**Scale/Scope**:

| | Files |
|---|---|
| **New (≈9 source files, plus tests)** | `entities/customer_payment.dart` (both entities), `domain/payment_type.dart`, `presentation/payments/{payments_list_screen, payments_list_controller, payments_filter, payment_detail_screen, payment_detail_controller, payment_link_providers}.dart` |
| **Edited (≈11 source files)** | `customer_payment_repository.dart` + impl, `cash_session_repository.dart` + impl, the `cash_session.dart` entity, `sale_payment.dart` (uses the promoted helper), `core/domain/payment_method.dart`, `core/domain/currency.dart`, `customer_repository_impl.dart` (name provider), `payment_method_option_repository_impl.dart` (name provider), `app_router.dart`, `app_navigation.dart`, `nav_destinations.dart` |
| **Edited, l10n** | both `.arb` files (≈55 keys, C5) and the regenerated `app_localizations*.dart` |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

These verdicts are against **v1.14.0**.

| Principle | Verdict | How |
|---|---|---|
| **I. Feature-first layering** | Pass | All new code is in `features/sales/{domain,data,presentation}`. The two `core/domain` additions are tiny enum helpers beside their existing siblings. Presentation reaches data only through providers. |
| **II. Riverpod** | Pass | `@riverpod` controllers for the list, the detail and the applications. Families for names and order links. The URL is the list's state (`ListQuery`), so there is no extra notifier. |
| **III. Contract-driven API** | Pass | Only generated operations and models, mapped to freezed entities. Unknown enum values raise `AppError.server()`. The server gaps (no customer name, unchecked facility on detail) are tracked upstream: #270 is filed, and the facility check is mbe-api#271 (R4). |
| **IV. Deny-by-default RBAC** | Pass | Route and nav are gated by `customerPayments` (8) read. The mode switch by `paymentsEditor` (100) read. The cash-session facet and link by `pos` (44) read, matching the server. Order links by `pos` (44) or `salesOrders` (7) read. Anything the user can't use is hidden, never disabled. Routes document their objects (C1). |
| **V. Material 3 / one formatting surface** | Pass | `fmt.display.*` plus `currencyCodeLabel`. No `NumberFormat` in widgets. Shared components only: `CatalogFilterBar`, `CatalogSearchBar`, `showCatalogFilterSheet`, `CatalogEntityPicker`, `DateRangeFilterChip`, `CatalogListStateView`, `DataTableView`, `StatusChip`, `ResponsiveFormGrid`, `ErrorBanner`. |
| **VI. List screen rules** | Pass | Each screen is a filter row, a list and pagination. Facets live in the drawer, and the search slot is omitted in the mode with no free-text search. Pagination is the shared component. The applications table is unpaginated because a payment's applications are a provably bounded set. **Horizontal scrolling:** at Expanded width both tables must fit with no horizontal scroll; only text columns (Cliente, Referencia, Sucursal) are ellipsized, and amounts and chips never are (T043 asserts this). On phone widths the tables scroll sideways, which is the existing `DataTableView` limitation every list shares, since it has no card mode yet (wireframe Open Question 3). |
| **VI. Record surface** | Pass | A payment owns a child collection (its applications) and needs a per-record URL, so it gets a full detail screen titled "Ver pago". The row tap opens it read-only. There is no Edit, because nothing is editable. **No row Edit icon:** §VI makes Edit every list row's primary action, but a payment row has none, because this feature is read-only (FR-003). The cash-sessions list is the precedent: its rows have no action icons either, because a session is never edited, and the row tap is the only affordance. |
| **VII. Online-only** | Pass | Nothing is persisted locally. |
| **Quality gates** | Pass | Unit, widget and live tests are listed in R13. Every FR maps to a test in tasks. `flutter analyze` must be clean. |

**Post-design re-check** (after Phase 1): still passing. The design added no core-widget change, no `AppError` variant (`notFound` already exists) and no codegen.

- **`SegmentedButton` in `CatalogFilterBar.actions`:** that slot is documented for "entity actions", and a scope switch is a mild stretch of it. It isn't a violation, because §VI forbids only facet controls inline, and the scope is not a facet (it changes which facets exist). It's recorded here so a reviewer doesn't have to rediscover it.

## Project Structure

### Documentation (this feature)

```text
specs/054-payments-list-search/
├── spec.md              # /speckit-specify + /speckit-clarify (2026-10-27)
├── wireframes.md        # /speckit-wireframes-draft
├── plan.md              # This file
├── research.md          # Phase 0 (R1–R13)
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/
│   └── ui-contracts.md  # Phase 1 (C1–C6)
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── core/domain/
│   ├── payment_method.dart                       # + paymentMethodCodeFromApi (moved, R10)
│   └── currency.dart                             # + currencyCodeLabel (R9)
├── core/navigation/nav_destinations.dart         # + Pagos after cash-sessions (C1)
├── core/widgets/app_navigation.dart              # + NavBranch.salesPayments (appended)
├── app/router/app_router.dart                    # + shell branch, detail route, _routeGate
├── features/catalog/data/
│   ├── customer_repository_impl.dart             # + customerDisplayNameProvider (R2)
│   └── payment_method_option_repository_impl.dart # + paymentMethodOptionNameProvider (R3)
├── features/sales/
│   ├── domain/
│   │   ├── entities/customer_payment.dart        # NEW: CustomerPayment, PaymentApplication
│   │   ├── entities/cash_session.dart            # + cashDrawerFacilityId (R7)
│   │   ├── entities/sale_payment.dart            # uses the promoted helper
│   │   ├── payment_type.dart                     # NEW (R10)
│   │   └── repositories/
│   │       ├── customer_payment_repository.dart  # + list/searchAcrossFacilities/get/listApplications
│   │       └── cash_session_repository.dart      # + facilityId
│   ├── data/
│   │   ├── customer_payment_repository_impl.dart
│   │   └── cash_session_repository_impl.dart
│   └── presentation/payments/                    # NEW
│       ├── payments_filter.dart
│       ├── payments_list_controller.dart
│       ├── payments_list_screen.dart
│       ├── payment_detail_controller.dart        # detail + applications controllers
│       ├── payment_detail_screen.dart
│       └── payment_link_providers.dart           # orderLinkTarget, cashSessionLabel
└── l10n/app_en.arb, app_es.arb                   # + keys (C5)

test/
├── unit/features/sales/      # payments_filter, payments_list_controller, payment_detail_controller,
│                             # customer_payment_repository_impl (extended), payment_type, order link
├── widget/features/sales/    # payments_list_screen, payments_filters, payment_detail_screen,
│                             # cash_session_facet
└── integration/payments_list_live_test.dart   # NEW
```

**Structure Decision**: a single Flutter project with feature-first layering. Payments live in `features/sales` beside the cash sessions and orders they link to, and reuse the catalog features' name providers.

## Complexity Tracking

There are no violations to justify.

## Follow-ups (not in this delivery)

- **mbe-api#270 ships:** regenerate the client, map `customerDisplayName` and prefer it over the provider (R2, C6).
- **mbe-api#271** (filed 2026-10-27): enforce facility access on `GET /customer-payments/{id}`, `/{id}/applications` and the `facility` parameter of the list (R4). Once it ships, the client guards stay as defence in depth.
- **Possible mbe-api enhancement:** carry `origin` on `ApplicationResponse`, removing the per-order fetch (R8).
- **#26 and #27:** add their actions (reverse, move, verify, reject) to `PaymentDetailScreen`.
