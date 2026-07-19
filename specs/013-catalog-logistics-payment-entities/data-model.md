# Phase 1 Data Model: Catalog Logistics Entities

**Feature**: `013-catalog-logistics-payment-entities` | **Date**: 2026-07-19

Three `freezed` domain entities plus their lightweight list-item projections,
each mapped from an already-generated OpenAPI response model. Field types are
taken verbatim from `lib/generated/openapi/lib/src/model/`. Money is not present
in any of these entities (the only money field, PMO's `commission`, is deferred).

Conventions (identical to spec 012):
- Domain entities are immutable `freezed` classes in
  `lib/features/catalog/domain/entities/`.
- Each has a `fromResponse(<X>Response)` factory mapping the generated DTO.
- List-item view models carry only the columns their list screen renders.
- Repositories return a `…ListResult { items, total }` for paginated lists.
- Write methods take primitives; the impl builds the generated `…Create`/
  `…Update` builders.

---

## §1 — Expense

**Generated models**: `ExpenseResponse { int expenseId, String expense,
String? comment }`, `ExpenseCreate { String name, String? comment }`,
`ExpenseUpdate { String? name, String? comment }`.

**Domain entity** `Expense` (`expense.dart`):

| Field | Type | Source | Notes |
|---|---|---|---|
| `expenseId` | `int` | `r.expenseId` | PK, system-assigned |
| `name` | `String` | `r.expense` | **Normalizes** the response's `expense` field to `name` for UI consistency with create/update |
| `comment` | `String?` | `r.comment` | optional |

**List-item** `ExpenseListItem` (`expense_list_item.dart`): `{ expenseId, name,
comment }` — the Expenses list renders name + comment (mirrors Labels).

**Validation** (form controller):
- `name` — required, non-empty (FR-011).
- `comment` — optional, free text.

**Repository** `ExpenseRepository`:
```
Future<ExpenseListResult> list({ String? search, int skip = 0, int limit = 20 });
Future<Expense> get({ required int expenseId });
Future<Expense> create({ required String name, String? comment });
Future<Expense> update({ required int expenseId, String? name, String? comment });
Future<void> delete({ required int expenseId });
```
`search` is declared now against the pending mbe-api#82 param (research.md §8).

---

## §2 — Vehicle

**Generated models**: `VehicleResponse { int vehicleId, String licensePlate,
String name, String nickname, int tonsCapacity, bool active }`,
`VehicleCreate { String licensePlate, String name, String nickname,
int tonsCapacity, bool? active }`, `VehicleUpdate { … all optional }`.

**Domain entity** `Vehicle` (`vehicle.dart`):

| Field | Type | Source | Notes |
|---|---|---|---|
| `vehicleId` | `int` | `r.vehicleId` | PK, system-assigned |
| `licensePlate` | `String` | `r.licensePlate` | required |
| `name` | `String` | `r.name` | required |
| `nickname` | `String` | `r.nickname` | required |
| `tonsCapacity` | `int` | `r.tonsCapacity` | required; whole tons |
| `active` | `bool` | `r.active` | active/inactive flag |

**List-item** `VehicleListItem` (`vehicle_list_item.dart`): `{ vehicleId,
licensePlate, name, nickname, active }` — list renders plate/name/nickname +
active badge (FR-014).

**Validation** (form controller):
- `licensePlate`, `name`, `nickname` — required, non-empty (FR-013).
- `tonsCapacity` — required, integer ≥ 0 (FR-013); parsed from a numeric text
  field, never a locale-formatted string.
- `active` — bool switch; defaults to `true` on create (create's `active?` is
  nullable → send `true` unless toggled off).

**Repository** `VehicleRepository`:
```
Future<VehicleListResult> list({ String? search, int skip = 0, int limit = 20 });
Future<Vehicle> get({ required int vehicleId });
Future<Vehicle> create({ required String licensePlate, required String name,
    required String nickname, required int tonsCapacity, bool? active });
Future<Vehicle> update({ required int vehicleId, String? licensePlate,
    String? name, String? nickname, int? tonsCapacity, bool? active });
Future<void> delete({ required int vehicleId });
```
`search` is declared now against the pending mbe-api#83 param.

---

## §3 — Vehicle Operator

**Generated models**:
- `VehicleOperatorResponse { int vehicleOperatorId, EmployeeResponse driver,
  String licenseType, String driverLicenseNumber, Date issueDate,
  Date expirationDate, String issuingLocation, DateTime creationTime,
  DateTime modificationTime, EmployeeResponse creator, EmployeeResponse updater,
  bool active, int? daysUntilExpiry }`
- `VehicleOperatorCreate { int driver, String licenseType,
  String driverLicenseNumber, Date issueDate, Date expirationDate,
  String issuingLocation, bool? active }`
- `VehicleOperatorUpdate { … all optional, driver is int? }`

**Domain entity** `VehicleOperator` (`vehicle_operator.dart`):

| Field | Type | Source | Notes |
|---|---|---|---|
| `vehicleOperatorId` | `int` | `r.vehicleOperatorId` | PK, system-assigned |
| `driverId` | `int` | `r.driver.employeeId` | FK to Employee |
| `driverName` | `String` | `'${r.driver.firstName} ${r.driver.lastName}'` | pre-expanded; fallback label if unresolvable (FR-017) |
| `licenseType` | `String` | `r.licenseType` | required |
| `driverLicenseNumber` | `String` | `r.driverLicenseNumber` | required |
| `issueDate` | `DateTime` | `r.issueDate.toDateTime()` | from generated `Date` |
| `expirationDate` | `DateTime` | `r.expirationDate.toDateTime()` | from generated `Date` |
| `issuingLocation` | `String` | `r.issuingLocation` | required |
| `active` | `bool` | `r.active` | active/inactive flag |
| `daysUntilExpiry` | `int?` | `r.daysUntilExpiry` | server-computed; UI derives fallback from `expirationDate` if null (research.md §7) |

Audit fields (`creationTime`/`modificationTime`/`creator`/`updater`) are
available on the response but not surfaced by any FR; omit from the domain
entity unless a later requirement needs them.

**List-item** `VehicleOperatorListItem` (`vehicle_operator_list_item.dart`):
`{ vehicleOperatorId, driverName, licenseType, driverLicenseNumber,
expirationDate, daysUntilExpiry, active }` — list renders driver name, license
type, license number, expiration + days-until-expiry, and active (US3
scenario 1, FR-019).

**Validation** (form controller):
- `driverId` — required; chosen via the driver `CatalogEntityPicker`
  (FR-016/FR-017).
- `licenseType`, `driverLicenseNumber`, `issuingLocation` — required, non-empty
  (FR-016).
- `issueDate`, `expirationDate` — required (FR-016); entered via `showDatePicker`.
  Soft rule: `expirationDate ≥ issueDate` — validate client-side and show a field
  error; the backend remains the source of truth.
- `active` — bool switch; defaults to `true` on create.

**Repository** `VehicleOperatorRepository`:
```
Future<VehicleOperatorListResult> list({ String? search, int? driverId,
    int skip = 0, int limit = 20 });         // driverId → endpoint's `employee` param
Future<VehicleOperator> get({ required int vehicleOperatorId });
Future<VehicleOperator> create({ required int driverId, required String licenseType,
    required String driverLicenseNumber, required DateTime issueDate,
    required DateTime expirationDate, required String issuingLocation, bool? active });
Future<VehicleOperator> update({ required int vehicleOperatorId, int? driverId,
    String? licenseType, String? driverLicenseNumber, DateTime? issueDate,
    DateTime? expirationDate, String? issuingLocation, bool? active });
Future<void> delete({ required int vehicleOperatorId });
```
`search` is declared now against the pending mbe-api#84 param; `driverId` maps
to the already-present `employee` query param (research.md §6).

**Date mapping** (impl): `issueDate`/`expirationDate` cross the generated `Date`
type via `..issueDate = issueDate.toDate()` on write and `r.issueDate.toDateTime()`
on read — the exact Employee `birthday`/`startJobDate` pattern (research.md §5).

---

## Relationships

- **Vehicle Operator → Employee** (`driverId`/`driver`): many operators may
  reference one employee as driver; the picker + `employee` filter both key on
  `employeeId`. Reuses spec-012 `Employee`/`EmployeeRepository`; no new employee
  code.
- Expenses and Vehicles are standalone — no FK to any other entity.
- **Vehicle Operator ↮ Vehicle**: *no relationship in the data model* — an
  operator carries a driver + license credentials only, not a vehicle reference
  (spec Assumptions). The two catalogs are independent despite the shared
  "logistics" grouping.

## State transitions

None. All three entities are flat CRUD records; `active` is a plain editable
flag, not a lifecycle state machine.
