# Implementation Plan: Catalog Logistics Entities (Expenses, Vehicles, Vehicle Operators)

**Branch**: `013-catalog-logistics-payment-entities` | **Date**: 2026-07-19 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/013-catalog-logistics-payment-entities/spec.md`

## Summary

Deliver full CRUD catalog UIs for three logistics/accounting master-data
entities mbe-api already exposes with complete Create/Read/Update/Delete
endpoints but that mbe-ui does not consume at all today: **Expenses**,
**Vehicles**, and **Vehicle Operators**. Each entity gets a list screen
(paginated, with the shared search box and — for Vehicle Operators — a driver
filter) plus a create/view/edit detail screen, modeled directly on the
just-shipped spec-012 catalogs (`labels_list_screen.dart` /
`label_detail_screen.dart` for the trivial shape; `employees_list_screen.dart`
/ `employee_detail_screen.dart` for the picker + Date shape).

All work lands **inside the existing `lib/features/catalog/` module** — the
constitution's designated shared master-data module (§I) — extended with one
sub-tree per entity, exactly as spec 012 did for its five entities. This
mirrors spec 012's structure decision; the reasoning is identical (these are
catalog-native master-data entities), so it is not re-litigated here.

Planning decisions that shape the work:

1. **No new RBAC plumbing and no codegen for the CRUD surface.** All three
   `SystemObject`s already exist — `expenses(81)`, `vehicle(88)`,
   `vehicleOperators(89)` — and all three generated API clients (`ExpensesApi`,
   `VehiclesApi`, `VehicleOperatorsApi`) already ship full CRUD methods under
   `lib/generated/openapi/`. This feature adds no RBAC and no third-party
   dependency (research.md §1, §2).
2. **Expenses is a Label clone.** `ExpenseResponse` is `{expenseId, expense,
   comment?}` and its create/update take `{name, comment?}` — structurally
   identical to Label (`{labelId, name, comment?}`). The Expenses sub-tree is a
   near-verbatim copy of the Labels sub-tree, minus Labels' extra
   picker/filter consumers (research.md §3).
3. **Vehicle Operators reuses the spec-012 Employee picker.** The `driver`
   field is an `EmployeeResponse` FK; the form's driver picker is the exact
   `CatalogEntityPicker<EmployeeListItem>` construction the Customer form's
   salesperson field already uses, backed by the existing
   `employeeRepositoryProvider` (research.md §4). The list's driver filter maps
   to the endpoint's `employee` query param (research.md §6).
4. **Date fields reuse the proven `Date`↔`DateTime` path.** Vehicle Operator's
   `issueDate`/`expirationDate` are the generated `Date` value type, entered via
   `showDatePicker` and mapped with the existing `DateTimeToDate.toDate()` /
   `Date.toDateTime()` extensions and displayed via `PricingFormatters.date()` —
   the same call-site pattern the Employee form uses for `birthday`/
   `startJobDate` (research.md §5).
5. **`daysUntilExpiry` is server-computed; the UI displays it.**
   `VehicleOperatorResponse.daysUntilExpiry` (`int?`) arrives pre-computed on
   the response. The list/detail render it directly, deriving a fallback from
   `expirationDate` only if the server omits it — no client-side business logic
   of record (research.md §7).
6. **Search is now server-side (upstream dependency resolved).** The three list
   endpoints originally lacked a `search` query param; issues were filed
   (mictlanix/mbe-api#82 Expenses, #83 Vehicles, #84 Vehicle Operators). **mbe-api
   has since shipped `search` on all three and the generated client was
   regenerated to include it** — the `list…Get` methods now accept `String?
   search` (Vehicles/Expenses: `search, skip, limit`; Vehicle Operators:
   `search, employee, skip, limit`). The repository forwards `search` straight
   through; the search box is fully functional, consistent with the spec-012
   catalogs (research.md §8).

Consequently this feature modifies only `app_router.dart`,
`nav_destinations.dart`, and the `.arb` files; everything else is new files
under `lib/features/catalog/`. No shared-kernel additions are required (unlike
spec 012's `Gender` enum) — these three entities introduce no new constant enum.

## Technical Context

**Language/Version**: Dart `^3.10.3` (per `pubspec.yaml`), Flutter stable
channel matching that SDK constraint — same as specs/002/005/011/012.

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` /
`riverpod_generator`, `go_router`, `dio`, `freezed` / `freezed_annotation` +
`json_serializable`, `intl` (date formatting via `es-MX`), `data_table_2`.
**No new dependency is introduced.** (Unlike spec 012, no `one_of`/`AnyOf`
money path is needed — none of these three entities carry a money field; the
`commission` `AnyOf` lived only on the deferred Payment Method Options.)

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
(`skip`/`limit`, default 20) per fetch; the Vehicle Operator's `driver` FK
arrives pre-expanded as an `EmployeeResponse` on the list/detail response — no
N+1 per-row lookup (research.md §4). The driver picker debounces search at
300 ms via the shared `CatalogEntityPicker`.

**Constraints**: Deny-by-default RBAC on three distinct objects; client-side
gating only, consistent with the posture products/pricing/spec-012 already
record. Dates (Vehicle Operator `issueDate`/`expirationDate`) use the generated
`Date` value type and are entered via `showDatePicker` (research.md §5).
Free-text search on all three list screens is server-side via the `search` param
now present on every list endpoint (upstream dependency resolved and regenerated
into the client — research.md §8).

**Scale/Scope**: 6 screens (3 list + 3 detail), ~3 list controllers + 3 form
controllers + 1 filter controller (Vehicle Operators), 3 new repositories
(interfaces + impls) + 3 `freezed` entities + 3 list-item view models, 3 router
branches + 6 sub-routes, 3 nav destinations, ~60 new l10n keys. No shared-kernel
additions.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Feature-First Layered Architecture | ✅ PASS | Extends `lib/features/catalog/{data,domain,presentation}` with one sub-tree per entity; `presentation` imports only `domain`; `data` implements `domain` repository interfaces. No shared-kernel addition needed. |
| II. Riverpod for State & DI | ✅ PASS | Each entity gets `Notifier`-based list + form controllers exposing `AsyncValue`; Vehicle Operators adds a filter `Notifier`. All three repositories exposed as providers for test overrides. |
| III. Contract-Driven API Integration | ✅ PASS | Consumes the already-generated `Expenses`/`Vehicles`/`VehicleOperators` APIs; **no hand-written DTOs**; generated files not edited. Errors map to shared error types via `ErrorBanner`. The one former backend gap (missing `search` param) was handled per §III — filed as issues #82/#83/#84 against mbe-api rather than patched from this session — and has since shipped upstream and been regenerated into the client (research.md §8). |
| IV. Deny-by-Default RBAC | ✅ PASS | Reuses `accessControlProvider.can(...)` with the three pre-existing `SystemObject`s; routes gated via `_routeGate` in `app_router.dart`, nav via `navDestinationsProvider`'s filter, actions hidden (not disabled) without privilege. |
| V. Material 3 White-Labeled Design System | ✅ PASS | No new theming. Date rendering via `intl` (`es-MX`) through `PricingFormatters.date` — never manual formatting. New l10n keys added to both `.arb` files. |
| VI. Desktop/Web-First, Compact-Ready Layout | ✅ PASS | All three list screens reuse `DataTableView`, `CatalogPagination`, `CatalogFilterBar`/`CatalogSearchBar`; single Edit row action via `catalog_action_icons`; row-click → read-only view; toolbar `FilledButton` Create; delete-in-form-body. Detail forms use `ResponsiveFormGrid`. Vehicle Operators adds a `CatalogFilterSheet` driver drawer (it has a `driver` facet); Expenses and Vehicles are search-only (no backend facet) so ship no drawer — explicitly allowed by §VI. Every screen ships the search box (§VI's "MUST NOT ship search-less"), wired to the now-available server-side `search` param. `AppBar.actions` carries only the read-only→edit toggle. |
| VII. Online-Only, Server-Rendered Documents | ✅ PASS | No local persistence, no caching, no document generation. |

**On §VI and search**: §VI requires every catalog/list screen to ship a search
box and MUST NOT ship search-less. All three screens ship the box, wired to the
server-side `search` param now present on every list endpoint (mbe-api#82/#83/#84
shipped and regenerated into the client). No deviation and no longer a pending
dependency — the box is fully functional, consistent with the spec-012 catalogs
which the box is copied from.

**On §VI and the search-only catalogs**: Expenses and Vehicles expose no facet
(status/category/type) on their list endpoints, so they ship the required
search box and **no** filter drawer — the "even if the entity has no obvious
facets, it still ships search" reading, not a deviation. Vehicle Operators
exposes a `driver`/`employee` facet and therefore ships the drawer.

**Post-Phase 1 re-check**: ✅ still passing. Phase 1 introduced no new
dependency, no new RBAC plumbing, no generated-file edits, no local
persistence, and no shared-kernel addition.

## Project Structure

### Documentation (this feature)

```text
specs/013-catalog-logistics-payment-entities/
├── plan.md                       # This file
├── spec.md                       # Feature spec
├── research.md                   # Phase 0 output
├── data-model.md                 # Phase 1 output
├── quickstart.md                 # Phase 1 output
├── contracts/                    # Phase 1 output
│   ├── mbe-api-catalogs.md        # endpoint/DTO contract per entity + the (resolved) search-param dependency
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
│       └── app_router.dart              # MODIFIED: 3 shell branches + 6 sub-routes + _routeGate entries
├── core/
│   ├── navigation/
│   │   └── nav_destinations.dart        # MODIFIED: 3 NavDestinations + 3 NavBranch indices (order MUST match router)
│   └── access/
│       └── system_object.dart           # UNCHANGED: expenses(81)/vehicle(88)/vehicleOperators(89) already present
├── l10n/
│   └── app_*.arb                        # MODIFIED: nav titles, column headers, field labels, validation messages, empty states
└── features/
    └── catalog/                         # EXTENDED (existing module)
        ├── data/
        │   ├── expense_repository_impl.dart          # NEW: wraps ExpensesApi
        │   ├── vehicle_repository_impl.dart          # NEW: wraps VehiclesApi
        │   └── vehicle_operator_repository_impl.dart # NEW: wraps VehicleOperatorsApi (Date fields, driver FK)
        ├── domain/
        │   ├── entities/
        │   │   ├── expense.dart / expense_list_item.dart
        │   │   ├── vehicle.dart / vehicle_list_item.dart
        │   │   └── vehicle_operator.dart / vehicle_operator_list_item.dart
        │   └── repositories/
        │       ├── expense_repository.dart            # NEW interface
        │       ├── vehicle_repository.dart            # NEW interface
        │       └── vehicle_operator_repository.dart   # NEW interface
        └── presentation/
            ├── expenses_list_screen.dart + expenses_list_controller.dart
            ├── expense_detail_screen.dart + expense_form_controller.dart
            ├── vehicles_list_screen.dart + vehicles_list_controller.dart
            ├── vehicle_detail_screen.dart + vehicle_form_controller.dart
            ├── vehicle_operators_list_screen.dart + vehicle_operators_list_controller.dart (+ filter controller)
            └── vehicle_operator_detail_screen.dart + vehicle_operator_form_controller.dart

lib/generated/openapi/                   # REGENERATED — #82/#83/#84 added `search` to all three list endpoints (research.md §8); not hand-edited

test/
├── unit/features/catalog/               # mapping (driver FK expansion, Date round-trip, daysUntilExpiry fallback), validators
├── widget/features/catalog/             # 6 screens: read-only vs editable, driver filter drawer, empty states, RBAC hiding
└── integration/catalog_logistics_flow_test.dart # create expense → create vehicle → create vehicle operator picking an employee as driver
```

**Structure Decision**: **Extend the existing `lib/features/catalog/` module**,
identical to spec 012's decision and for the same reason: constitution §I
designates `catalog` as the shared master-data module, and Expenses/Vehicles/
Vehicle Operators are master-data catalogs of exactly the same kind as spec
012's five. The feature modifies `app_router.dart`, `nav_destinations.dart`, and
the `.arb` files; it reuses `core/network`, `core/errors`, `core/access`, and
every `core/widgets/` component (including the spec-012 `CatalogEntityPicker`
and `employeeRepositoryProvider`) unmodified.

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| **`search` param upstream** *(RESOLVED 2026-07-19)* — all three list endpoints originally lacked a `search` query param. | None remaining. Was: weakened findability until the backend shipped. | Handled per §III: issues filed on mbe-api (#82 Expenses, #83 Vehicles, #84 Vehicle Operators) rather than patched from this session; mbe-api has since shipped `search` on all three and the client was regenerated to include it, so the search box is fully functional with no UI rework (research.md §8, contracts/mbe-api-catalogs.md). |
| **Driver FK-expansion assumption** — Vehicle Operator list/detail render the driver by name, assuming the response pre-expands `driver` as an `EmployeeResponse`. | If the field returned a bare id, the screen would show a raw number or fail. | The generated `VehicleOperatorResponse` types `driver` as `EmployeeResponse` — confirmed expanded (research.md §4). An unresolvable/orphaned driver renders a fallback label, never crashes (spec FR-017, Edge Cases). |
| **`daysUntilExpiry` nullability** — the field is `int?`; a null would blank the expiry indicator. | A missing indicator hides an expired-license signal. | Display the server value when present; otherwise derive `expirationDate − today` client-side as a fallback so the indicator is always shown (research.md §7, spec SC-003). |
| **Date `Date`↔`DateTime` mapping** — issue/expiration dates cross the generated `Date` value type. | A wrong conversion could off-by-one or drop a date. | Reuse the exact `DateTimeToDate.toDate()` / `Date.toDateTime()` extensions and `showDatePicker` call-site the Employee form already uses; unit-test the round-trip (research.md §5). |
| `NavBranch` indices drift from router branch order | Wrong nav item highlighted | Add branches in the same order in both `nav_destinations.dart` and `app_router.dart`; the invariant is already documented at `nav_destinations.dart` and was honored by spec 012 (contracts/routes.md). |
| Deletion-while-referenced rules unverified upstream | A delete may be rejected server-side (a vehicle operator referenced by a service order, an expense used by a posted expense ticket) | UI surfaces any rejection via `ErrorBanner` and never pre-blocks the attempt (spec Edge Cases). If mbe-api does not enforce a rule, that is an upstream issue to file, not a UI workaround (§III). |

## Follow-ups (not blocking)

- **External dependency (RESOLVED 2026-07-19)**: mictlanix/mbe-api#82, #83, #84 —
  add a `search` query param to `GET /api/v1/expenses`, `GET /api/v1/vehicles`,
  and `GET /api/v1/vehicle-operators` respectively, matching the semantics of
  the existing `search` on customers/employees/suppliers. **Shipped upstream and
  regenerated into the client** — the `list…Get` methods now accept `String?
  search`; no further action needed. (The three GitHub issues can be closed.)
- **Deferred (explicitly out of scope)**: the **Payment Method Options**
  catalog (originally User Story 4) — deferred because its required store and
  warehouse pickers may be invalidated by an upcoming broader "facilities" API
  upstream, and per the user that catalog must be built from the ground up when
  picked up. When specified later it will bring the payment-method SAT enum, a
  money-shaped `commission` (`AnyOf`, reusing the specs/011/012 path), and
  store/warehouse (or facilities) pickers (spec Clarifications / Assumptions).
- **Possible enhancement**: a cross-link from a Vehicle Operator's driver to
  that employee's detail screen (spec 012 shipped the Employee catalog), as an
  `at most one additional row action` per §VI — deferred, not required by any FR.

## Complexity Tracking

*No constitution violations — this section is intentionally empty.* The two
notes under Constitution Check (search and search-only catalogs under §VI) are
scope clarifications with precedent from spec 012, not deviations requiring
justification. The former missing `search` param was an external dependency
recorded per §III (now resolved upstream), not a complexity deviation.
