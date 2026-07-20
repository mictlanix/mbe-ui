# Phase 0 Research: Catalog Logistics Entities

**Feature**: `013-catalog-logistics-payment-entities` | **Date**: 2026-07-19

All unknowns from the Technical Context are resolved below. Each item records
the Decision, Rationale, and Alternatives considered. Ground truth is the
generated client under `lib/generated/openapi/` and the shipped spec-012
catalog module.

## §1 — RBAC: no new plumbing

**Decision**: Reuse the three pre-existing `SystemObject`s and gate exactly as
spec 012 does.

**Rationale**: `lib/core/access/system_object.dart` already defines
`expenses(81)`, `vehicle(88)`, and `vehicleOperators(89)`. Routes gate through
`_routeGate` in `app_router.dart`; nav through `navDestinationsProvider`;
actions through `accessControlProvider.can(object, right)`. No enum edit, no new
privilege.

**Alternatives considered**: Introducing a coarser "logistics" object —
rejected; the backend already models these as three distinct objects and the
UI must mirror server enforcement (§IV).

## §2 — Generated clients: full CRUD already present

**Decision**: Consume `ExpensesApi`, `VehiclesApi`, `VehicleOperatorsApi`
as-is; write no DTOs.

**Rationale**: Each API ships the five methods (verified in
`lib/generated/openapi/lib/src/api/`):

- Expenses: `listExpenses…Get`, `createExpense…Post`, `getExpense…Get`,
  `updateExpense…Put`, `deleteExpense…Delete`.
- Vehicles: `listVehicles…Get`, `createVehicle…Post`, `getVehicle…Get`,
  `updateVehicle…Put`, `deleteVehicle…Delete`.
- Vehicle Operators: `listVehicleOperators…Get`, `createVehicleOperator…Post`,
  `getVehicleOperator…Get`, `updateVehicleOperator…Put`,
  `deleteVehicleOperator…Delete`.

Response/create/update models (`ExpenseResponse`/`ExpenseCreate`/
`ExpenseUpdate`, and the Vehicle/VehicleOperator equivalents) all exist under
`lib/generated/openapi/lib/src/model/`.

**Alternatives considered**: none — §III mandates generated clients.

## §3 — Expenses is a Label clone

**Decision**: Copy the Labels sub-tree (entity, list-item, repository
interface + impl, list/detail screens, controllers) and rename to Expense.

**Rationale**: The shapes line up field-for-field:

| Concern | Label | Expense |
|---|---|---|
| Response | `{labelId, name, comment?}` | `{expenseId, expense, comment?}` |
| Create | `{name, comment?}` | `{name, comment?}` |
| Update | `{name?, comment?}` | `{name?, comment?}` |

The only wrinkle: `ExpenseResponse`'s display field is named `expense` (not
`name`), while create/update use `name`. The domain `Expense` entity normalizes
this to a single `name` getter in its `fromResponse` mapper (`name: r.expense`),
so the rest of the UI is identical to Labels. Expenses has **no** extra
picker/filter consumers (Labels feeds the product form's multi-picker and the
products-list filter), so it is strictly simpler — no `listDetailed`
vs. `list` split is needed; one `list` projection suffices.

**Alternatives considered**: A generic "simple named catalog" abstraction over
Label + Expense — rejected as premature; two near-identical copies are cheaper
to read and maintain than one indirection, and matches how spec 012 kept each
entity's sub-tree explicit.

## §4 — Vehicle Operators reuses the Employee picker

**Decision**: The driver field is a `CatalogEntityPicker<EmployeeListItem>`
backed by the existing `employeeRepositoryProvider`, identical to the Customer
form's salesperson picker.

**Rationale**: `VehicleOperatorResponse.driver` is typed `EmployeeResponse`
(pre-expanded), and `VehicleOperatorCreate/Update.driver` is a bare `int`
employee id. The Customer form already wires this exact pattern
(`customer_detail_screen.dart`): `CatalogEntityPicker<EmployeeListItem>` with
`optionsBuilder` calling `employeeRepo.list(search: query)` and `onSelected`
storing `(employeeId, fullName)`. The Vehicle Operator form copies it verbatim,
storing the selected `employeeId` for the create/update payload and the
`fullName` for display. Because `driver` arrives pre-expanded on list/detail
responses, there is no N+1 lookup — the name is read straight off the response.

**Alternatives considered**: A bespoke driver picker — rejected; the shared
`CatalogEntityPicker` + `EmployeeRepository.list` already cover it and reusing
them guarantees the debounce/empty-state behavior stays consistent (SC-005).

## §5 — Date fields (`issueDate`/`expirationDate`)

**Decision**: Enter via `showDatePicker`, store as `DateTime` in form state,
map to the generated `Date` value type with `DateTimeToDate.toDate()` on write
and `Date.toDateTime()` on read, and display via `PricingFormatters.date()`.

**Rationale**: `VehicleOperatorResponse.issueDate`/`expirationDate` are the
generated `Date` type (year/month/day), and create/update take `Date`. The
Employee form (`employee_detail_screen.dart`) already establishes the exact
call-site: a read-only field whose `onTap` opens `showDatePicker`, storing the
picked `DateTime`; the repository impl maps with `..issueDate = issueDate.toDate()`
(mirroring `..birthday = birthday.toDate()`). The `DateTimeToDate` extension
lives in `lib/generated/openapi/lib/src/model/date.dart`. Display reuses
`PricingFormatters.date`, already used for employee `birthday`.

**Alternatives considered**: A new shared date-field widget — deferred; the
existing call-site pattern is small and already duplicated across spec-011/012
date fields, so extracting a widget is an orthogonal cleanup, not this feature's
job.

## §6 — Vehicle Operators driver filter

**Decision**: The list's driver filter maps to the endpoint's `employee` query
param, surfaced via a `CatalogFilterSheet` drawer holding a single driver
`CatalogEntityPicker`.

**Rationale**: `listVehicleOperators…Get` accepts `int? employee` alongside
`skip`/`limit`. The filter controller holds the selected `employeeId` (nullable)
and passes it as `employee:` to the repository `list`. The drawer reuses the
same `CatalogEntityPicker<EmployeeListItem>` as the form's driver field, so
"filter by driver" and "pick a driver" share one control. This is the only
backend facet among the three entities.

**Alternatives considered**: A free-text driver-name filter — rejected; the
backend keys the filter on `employee` id, so a picker (id-backed) is the
faithful mapping, matching how spec-012 filters mapped to their id-based facets.

## §7 — `daysUntilExpiry`: server-computed, UI-displayed

**Decision**: Render `VehicleOperatorResponse.daysUntilExpiry` when present;
fall back to a client-side `expirationDate − today` computation only when the
server returns null, so the indicator is always shown.

**Rationale**: The field is typed `int?`. It is a derived convenience the
backend computes; the UI is a pure consumer (constitution keeps business rules
server-side, §III/§VII). Displaying it needs an l10n-formatted "expires in N
days" / "expired N days ago" label. The fallback keeps SC-003 (100% of records
show the indicator) true even if the server omits the field for some rows.

**Alternatives considered**: Always compute client-side and ignore the server
field — rejected; the server value is authoritative and may account for
business calendar rules the client does not know. Never compute a fallback —
rejected; would blank the indicator on null and fail SC-003.

## §8 — Search: external dependency on mbe-api *(RESOLVED)*

**Decision**: File mbe-api issues for a `search` param on all three endpoints,
build the UI against that expected param, and ship the search box now. **Status:
resolved — mbe-api shipped the param and the client was regenerated.**

**Rationale**: Originally none of `listExpenses…Get`, `listVehicles…Get`,
`listVehicleOperators…Get` accepted a `search` query param (only `skip`/`limit`,
plus `employee` on Vehicle Operators and `store` on the deferred PMO). The
spec-012 catalogs (`customers`/`employees`/`suppliers`) each expose `search`,
establishing both the precedent and the contract. Per §III, mbe-ui did NOT patch
mbe-api; issues were filed:

- **mictlanix/mbe-api#82** — `search` on `GET /api/v1/expenses` (matches expense name)
- **mictlanix/mbe-api#83** — `search` on `GET /api/v1/vehicles` (matches plate/name/nickname)
- **mictlanix/mbe-api#84** — `search` on `GET /api/v1/vehicle-operators` (matches driver name/license number)

**Update 2026-07-19**: mbe-api has shipped `search` on all three endpoints and
the generated client was regenerated. Verified in
`lib/generated/openapi/lib/src/api/`:

- `listExpensesApiV1ExpensesGet({String? search, int? skip, int? limit})`
- `listVehiclesApiV1VehiclesGet({String? search, int? skip, int? limit})`
- `listVehicleOperatorsApiV1VehicleOperatorsGet({String? search, int? employee, int? skip, int? limit})`

The repository interfaces declare `String? search`; the impls forward it straight
to these methods. The search box is fully functional server-side with zero UI
change from the original design. The three GitHub issues can be closed.

**Alternatives considered**:
- *Client-side contains-filter over the loaded page* — rejected as the primary
  mechanism; it only filters the current page and misleads users into thinking
  it searched the whole catalog. (May still be layered later, but the real fix
  is server-side.)
- *Ship facet-only / no search box* — rejected; violates §VI outright.
- *Block the whole feature until the backend ships* — rejected; the CRUD surface
  is fully functional today, and gating three otherwise-complete catalogs on one
  additive query param is disproportionate. The box ships; its results improve
  when the dependency lands.

## §9 — No shared-kernel additions

**Decision**: This feature adds nothing to `core/domain/`.

**Rationale**: Unlike spec 012 (which mirrored a `Gender` constant enum), none
of the three entities carry an un-schema'd constant. Vehicle `tonsCapacity` is a
plain `int`; the active/enabled flags are plain `bool`s; there is no
payment-method enum here (that lived on the deferred PMO). The Employee entity
the driver picker needs already exists in `catalog/domain/` from spec 012.

**Alternatives considered**: none needed.
