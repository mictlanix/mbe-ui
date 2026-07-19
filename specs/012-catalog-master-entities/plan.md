# Implementation Plan: Catalog Master Entities (Customers, Employees, Suppliers, Labels, Taxpayer Recipients)

**Branch**: `012-catalog-master-entities` | **Date**: 2026-07-19 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/012-catalog-master-entities/spec.md`

## Summary

Deliver full CRUD catalog UIs for five master-data entities mbe-api already
exposes with complete Create/Read/Update/Delete endpoints but that mbe-ui
either consumes read-only today (Suppliers, Labels — currently `list()`-only
pickers) or does not consume at all (Customers, Employees, Taxpayer
Recipients). Each entity gets a list screen (paginated, searchable, and — where
the list endpoint exposes facets — a filter drawer) plus a create/view/edit
detail screen, modeled directly on the Products catalog
(`products_list_screen.dart` / `product_detail_screen.dart`) and the
price-lists catalog (`price_lists_list_screen.dart` /
`price_list_detail_screen.dart`).

All work lands **inside the existing `lib/features/catalog/` module** — the
constitution's designated shared master-data module (§I) — extended with one
sub-tree per entity, mirroring how `catalog/` already organizes
products/suppliers/labels/sat-catalog. This is unlike specs/011-product-pricing,
which got its own top-level module because it sat behind distinct RBAC surfaces
and nothing in `catalog/` consumed it; that reasoning does not apply here since
these five are exactly catalog/master-data entities (Structure Decision below).

Planning decisions that shape the work:

1. **No new RBAC plumbing and no codegen.** All five `SystemObject`s already
   exist — `labels(1)`, `customers(2)`, `suppliers(3)`, `employees(6)`,
   `taxpayerRecipients(54)` — and all five generated API clients
   (`CustomersApi`, `EmployeesApi`, `TaxpayerRecipientsApi`, `SuppliersApi`,
   `LabelsApi`) already ship full CRUD methods under `lib/generated/openapi/`.
   This feature adds no RBAC and no third-party dependency (research.md §1, §2).
2. **Promote, don't replace, the existing Suppliers/Labels lookups.** The
   product form's supplier picker and label multi-picker, and the products
   list's label filter, keep consuming `SupplierRepository.list()` /
   `LabelRepository.list()` unchanged. This feature *adds* `get`/`create`/
   `update`/`delete` to those two repository interfaces and their impls — a
   superset, so existing read-only consumers are untouched (research.md §3).
3. **`AnyOf` money fields reuse the proven construction.** Supplier and
   Customer `creditLimit` are `anyOf: [number, string]` wrappers
   (`CreditLimit`/`CreditLimit1`), the exact shape specs/011 already solved for
   `Price`/`LowProfitMargin` — always the String arm via
   `AnyOf2<String, num>(values: {0: value})`, and separate create-vs-update
   wrapper classes. No new construction risk (research.md §4).
4. **Two picker methods added to the existing `SatCatalogRepository`.**
   TaxpayerRecipient's `postalCode`/`regime` fields need `listPostalCodes` and
   `listTaxRegimes`, backed by mbe-api's already-present
   `GET /api/v1/sat/postal-codes` and `GET /api/v1/sat/tax-regimes` (same
   `SatCatalogResponse` shape as the existing `listUnitsOfMeasurement`/
   `listProductServices`). Purely a client-side extension — no upstream gap
   (research.md §5).
5. **A `Gender` constant enum goes to `core/domain/`.** Employee `gender` is a
   bare `int` with no published schema (like exchange-rate `Currency` in
   specs/011); it is mirrored from legacy `mbe/docs/constants.md §GenderEnum`
   (0 = Female, 1 = Male) as a constant enum in the shared kernel, with direct
   precedent in `Currency`/`SystemObject` (research.md §6).

Consequently this feature modifies only `app_router.dart`,
`nav_destinations.dart`, the two existing repository interfaces/impls for
suppliers and labels, `sat_catalog_repository.dart`/`_impl.dart`, and the
`.arb` files; everything else is new files under `lib/features/catalog/`.

## Technical Context

**Language/Version**: Dart `^3.10.3` (per `pubspec.yaml`), Flutter stable
channel matching that SDK constraint — same as specs/002/005/011.

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` /
`riverpod_generator`, `go_router`, `dio`, `freezed` / `freezed_annotation` +
`json_serializable`, `intl` (MXN currency + date formatting via `es-MX`),
`data_table_2`, `one_of` (for the `AnyOf` creditLimit write path, already a
first-party dependency since specs/011). **No new dependency is introduced.**

**Storage**: N/A — no local database/cache (constitution §VII). All list/form
state is in-memory only.

**Testing**: `flutter_test` for unit/widget, `mocktail` for repository fakes,
`integration_test` for the golden-path CRUD flows against a local mbe-api
(quickstart.md).

**Target Platform**: Web, Windows, macOS, Linux — Expanded (desktop/web) tier,
Compact tier inherited from spec 010's adaptive shell.

**Project Type**: Single Flutter project, feature-first — **extends** the
existing `lib/features/catalog/` module (see Structure Decision).

**Performance Goals**: Each list screen renders one paginated page
(`skip`/`limit`, default 20) per fetch; FK-expanded fields (customer
salesperson/price-list, taxpayer postal-code/regime) arrive pre-expanded on the
list/detail response — no N+1 per-row lookup (research.md §7). Pickers debounce
search at 300 ms via the shared `CatalogEntityPicker`.

**Constraints**: Deny-by-default RBAC on five distinct objects; client-side
gating only, consistent with the posture products/pricing already record. Money
(`creditLimit`) is `String` end-to-end, never parsed to `double`
(research.md §4). Dates (employee `birthday`/`startJobDate`) use the generated
`Date` value type (year/month/day) and are entered via Flutter's built-in
`showDatePicker`, the same call-site pattern specs/011 uses for exchange-rate
dates (research.md §8). TaxpayerRecipient's `taxpayerRecipientId` is a
client-supplied **String** primary key, immutable after create — the same
"user supplies the id" shape as the Users admin screen's `user_id_field`
(research.md §9).

**Scale/Scope**: 10 screens (5 list + 5 detail), ~5 list controllers + 5 form
controllers + 2 filter controllers (Customers, Employees), 5 repositories (2
extended, 3 new) + 2 `SatCatalogRepository` methods, ~8 `freezed` entities +
list-item view models, 1 shared `Gender` enum, 5 router branches + 10
sub-routes, 5 nav destinations, ~120 new l10n keys.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | Extends `lib/features/catalog/{data,domain,presentation}` with one sub-tree per entity; `presentation` imports only `domain`; `data` implements `domain` repository interfaces. `Gender` goes to the `core/domain/` shared kernel because Employee (and legacy Customer) both reference it — cross-feature, not redefined per entity (research.md §6). |
| II. Riverpod for State & DI | ✅ PASS | Each entity gets `Notifier`-based list + form controllers exposing `AsyncValue`; Customers/Employees add a filter `Notifier`. All five repositories exposed as providers for test overrides. |
| III. Contract-Driven API Integration | ✅ PASS | Consumes the already-generated `Customers`/`Employees`/`TaxpayerRecipients`/`Suppliers`/`Labels` APIs; **no hand-written DTOs**; generated files not edited. Errors map to shared error types via `ErrorBanner`. No sibling-repo edits — the `Gender` enum mirrors a legacy constant with no published schema (constant, **not** a DTO — see note below). |
| IV. Deny-by-Default RBAC | ✅ PASS | Reuses `accessControlProvider.can(...)` with the five pre-existing `SystemObject`s; routes gated via `_routeGate` in `app_router.dart`, nav via `navDestinationsProvider`'s filter, actions hidden (not disabled) without privilege. |
| V. Material 3 White-Labeled Design System | ✅ PASS | No new theming. Money/date rendering via `intl` (`es-MX`, MXN) — never manual formatting. Gender rendered via localized labels. New l10n keys added to both `.arb` files. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ PASS | All five list screens reuse `DataTableView`, `CatalogPagination`, `CatalogFilterBar`/`CatalogSearchBar`; single Edit row action via `buildCatalogRowActions`; row-click → read-only view; toolbar `FilledButton` Create; delete-in-form-body. Detail forms use `ResponsiveFormGrid`. Customers/Employees add `CatalogFilterSheet` drawers (they have list facets); Suppliers/Labels/TaxpayerRecipients are search-only (no obvious facets) so ship no drawer — explicitly allowed by §VI. `AppBar.actions` carries only the read-only→edit toggle, per the v1.8.0 amendment this feature's spec prompted. |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No local persistence, no caching, no document generation. |

**On §III and the `Gender` enum**: §III forbids hand-written DTOs *for a
resource that already has a published schema*. mbe-api types Employee `gender`
as a bare `int` with no enum schema, so there is nothing to generate from.
`Gender` is a constant enum mirroring `mbe/docs/constants.md §GenderEnum`, with
direct precedent in `lib/core/domain/currency.dart` (specs/011) and
`lib/core/access/system_object.dart`. Not a deviation.

**On §VI and the search-only catalogs**: §VI requires every catalog/list screen
to ship *filtering* — "a search box and, if the entity has obvious facets …
corresponding filter controls." Suppliers, Labels, and Taxpayer Recipients
expose only `search` on their list endpoints (no status/category/type facet),
so they ship the required search box and **no** filter drawer — exactly the
"even if the entity has no obvious facets, it still ships search" reading, not a
deviation. Customers (disabled/priceList/salesperson) and Employees
(active/salesPerson) do expose facets and therefore ship the drawer.

**Post-Phase 1 re-check**: ✅ still passing. Phase 1 introduced no new
dependency, no new RBAC plumbing, no generated-file edits, and no local
persistence. The only shared-kernel addition is the `Gender` constant enum,
justified above.

## Project Structure

### Documentation (this feature)

```text
specs/012-catalog-master-entities/
├── plan.md                       # This file
├── spec.md                       # Feature spec
├── research.md                   # Phase 0 output
├── data-model.md                 # Phase 1 output
├── quickstart.md                 # Phase 1 output
├── contracts/                    # Phase 1 output
│   ├── mbe-api-catalogs.md        # endpoint/DTO contract per entity
│   └── routes.md                  # routes, nav, RBAC gating
├── checklists/
│   └── requirements.md           # spec quality checklist (already created)
└── tasks.md                      # Phase 2 output (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
lib/
├── app/
│   └── router/
│       └── app_router.dart              # MODIFIED: 5 shell branches + 10 sub-routes + _routeGate entries
├── core/
│   ├── domain/
│   │   ├── currency.dart                # UNCHANGED (specs/011)
│   │   └── gender.dart                  # NEW: Gender enum (female=0, male=1), mirrors legacy GenderEnum
│   ├── navigation/
│   │   └── nav_destinations.dart        # MODIFIED: 5 NavDestinations + 5 NavBranch indices (order MUST match router)
│   └── access/
│       └── system_object.dart           # UNCHANGED: labels(1)/customers(2)/suppliers(3)/employees(6)/taxpayerRecipients(54) already present
├── l10n/
│   └── app_*.arb                        # MODIFIED: nav titles, column headers, field labels, validation messages, empty states
└── features/
    └── catalog/                         # EXTENDED (existing module)
        ├── data/
        │   ├── supplier_repository_impl.dart      # MODIFIED: add get/create/update/delete (keep list)
        │   ├── label_repository_impl.dart         # MODIFIED: add get/create/update/delete (keep list)
        │   ├── sat_catalog_repository_impl.dart   # MODIFIED: add listPostalCodes + listTaxRegimes
        │   ├── customer_repository_impl.dart       # NEW: wraps CustomersApi (creditLimit AnyOf write path)
        │   ├── employee_repository_impl.dart       # NEW: wraps EmployeesApi (Date fields)
        │   └── taxpayer_recipient_repository_impl.dart # NEW: wraps TaxpayerRecipientsApi (String PK)
        ├── domain/
        │   ├── entities/
        │   │   ├── supplier.dart                   # NEW: full freezed entity (get/detail); SupplierListItem stays for picker
        │   │   ├── label_item.dart                 # UNCHANGED picker item; label detail reuses it + comment
        │   │   ├── customer.dart / customer_list_item.dart
        │   │   ├── employee.dart / employee_list_item.dart
        │   │   └── taxpayer_recipient.dart / taxpayer_recipient_list_item.dart
        │   └── repositories/
        │       ├── supplier_repository.dart        # MODIFIED: add get/create/update/delete
        │       ├── label_repository.dart           # MODIFIED: add get/create/update/delete
        │       ├── sat_catalog_repository.dart      # MODIFIED: add listPostalCodes + listTaxRegimes
        │       ├── customer_repository.dart          # NEW interface
        │       ├── employee_repository.dart          # NEW interface
        │       └── taxpayer_recipient_repository.dart # NEW interface
        └── presentation/
            ├── suppliers_list_screen.dart + suppliers_list_controller.dart
            ├── supplier_detail_screen.dart + supplier_form_controller.dart
            ├── labels_list_screen.dart + labels_list_controller.dart
            ├── label_detail_screen.dart + label_form_controller.dart
            ├── employees_list_screen.dart + employees_list_controller.dart (+ filter controller)
            ├── employee_detail_screen.dart + employee_form_controller.dart
            ├── customers_list_screen.dart + customers_list_controller.dart (+ filter controller)
            ├── customer_detail_screen.dart + customer_form_controller.dart
            ├── taxpayer_recipients_list_screen.dart + taxpayer_recipients_list_controller.dart
            └── taxpayer_recipient_detail_screen.dart + taxpayer_recipient_form_controller.dart

lib/generated/openapi/                   # UNCHANGED — all five APIs/models already present (research.md §2)

test/
├── unit/features/catalog/               # mapping (FK expansion, creditLimit AnyOf round-trip, Gender fallback, Date), validators
├── widget/features/catalog/             # 10 screens: read-only vs editable, filter drawers, empty states, RBAC hiding, string-PK create
└── integration/catalog_master_flow_test.dart # create employee → create customer picking that employee → create taxpayer recipient
```

**Structure Decision**: **Extend the existing `lib/features/catalog/` module**
rather than create a new top-level module. Constitution §I explicitly
designates `catalog` as "a shared `master_data`/`catalog` module for entities
used across features," and all five entities are master-data catalogs. Two of
them (Suppliers, Labels) already live in `catalog/` as read-only lookups, and
Customers/Employees/TaxpayerRecipients are the same kind of entity. This is the
deliberate inverse of specs/011's decision to give pricing its own module:
pricing sat behind three *distinct* RBAC surfaces with no `catalog/` consumer,
whereas these five are catalog-native and two are already consumed from within
`catalog/`. The feature modifies `app_router.dart`, `nav_destinations.dart`, the
suppliers/labels/sat-catalog repositories, and the `.arb` files; it reuses
`core/network`, `core/errors`, `core/access`, and every `core/widgets/`
component unmodified.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| **`creditLimit` `AnyOf` write path** — Supplier/Customer `creditLimit` is `anyOf: [number, string]` (`CreditLimit`/`CreditLimit1`), the same wrapper family specs/011 fought with. | A wrong construction serializes as `null`/throws `RangeError`, and a broken serializer can still look like a successful save. | Reuse the **proven** `AnyOf2<String, num>(values: {0: value})` form and separate create/update helpers, exactly as `product_price_repository_impl.dart`/`price_list_repository_impl.dart` do. Mandatory repository round-trip unit test per specs/011's precedent (research.md §4). |
| **FK-expansion assumption** — Customer list/detail rendering salesperson/price-list by name, and TaxpayerRecipient postal-code/regime by description, assumes the response pre-expands these FKs. | If a field returns a bare id instead of an expanded object, the screen shows a raw number or fails. | The generated `CustomerResponse`/`CustomerListItem` type `priceList`/`salesperson` as `PriceListResponse`/`EmployeeResponse`, and `TaxpayerRecipientResponse` types `postalCode`/`regime` as `SatCatalogResponse` — confirmed expanded (research.md §7). Orphaned/unresolvable FKs render a fallback label, never crash (spec Edge Cases, FR-021/FR-026-equivalent). |
| **Gender code drift** — `Gender` enum mirrors legacy constants (0=Female,1=Male) with no upstream schema to validate against. | A wrong mapping mislabels every employee's gender. | Values copied verbatim from `mbe/docs/constants.md §GenderEnum`; `Gender.fromValue` falls back gracefully for an unknown int (renders raw/"unknown"), same posture as `SystemObject.fromValue` (research.md §6). Candidate mbe-api follow-up to publish the enum. |
| **String primary key create semantics** — TaxpayerRecipient id is client-supplied and must reject duplicates. | A duplicate id could overwrite or 500 opaquely. | The create form supplies the id in a field (immutable on edit), and surfaces the backend's rejection via the shared error path (FR-027). UI never pre-checks existence (research.md §9). |
| `NavBranch` indices drift from router branch order | Wrong nav item highlighted | Add branches in the same order in both `nav_destinations.dart` and `app_router.dart`; the invariant is already documented at `nav_destinations.dart:10-11` (contracts/routes.md). |
| Deletion-while-referenced rules unverified upstream | A delete may be rejected server-side (supplier on a product, employee as salesperson) | UI surfaces any rejection via `ErrorBanner` and never pre-blocks the attempt (spec Edge Cases). If mbe-api does not enforce a rule, that is an upstream issue to file, not a UI workaround (§III). |

## Follow-ups (not blocking)

- **Deferred (explicitly out of scope)**: retrofit the Users admin screen's raw
  numeric `employee_id_field` (`user_detail_screen.dart`) into an
  `Employee` picker now that this feature ships the Employees catalog — a small
  auth-module change for a later feature.
- **Candidate mbe-api issue**: publish a `gender` enum schema so mbe-ui can drop
  the locally-mirrored `Gender` constant (parallels the `Currency` follow-up
  from specs/011).
- **Possible enhancement**: retrofit the product form's supplier picker to link
  into the new Supplier detail screen once both exist.

## Complexity Tracking

*No constitution violations — this section is intentionally empty.* The two
notes under Constitution Check (`Gender` under §III, search-only catalogs under
§VI) are scope clarifications with precedent, not deviations requiring
justification.
