# Contract: mbe-api Catalog Endpoints (Expenses, Vehicles, Vehicle Operators)

**Feature**: `013-catalog-logistics-payment-entities` | **Date**: 2026-07-19

All three endpoint families already exist in the committed generated client
(`lib/generated/openapi/`); this contract records the exact methods, DTOs, and
query params mbe-ui consumes. **No codegen re-run and no generated-file edits**
for the CRUD surface (research.md §2). A single upstream gap — the missing
`search` query param — is filed as mbe-api issues #82/#83/#84 and consumed once
each ships and the client is regenerated (research.md §8). All routes are under
`OAuth2PasswordBearer` (the shared `dio` auth interceptor attaches the token).

---

## 1. Expenses — `ExpensesApi` (RBAC `expenses(81)`)

| Op | Method | Returns |
|---|---|---|
| list | `listExpensesApiV1ExpensesGet({skip, limit})` — **`search` pending #82** | `ListResponseExpenseResponse` |
| get | `getExpenseApiV1ExpensesExpenseIdGet(expenseId)` | `ExpenseResponse` |
| create | `createExpenseApiV1ExpensesPost(expenseCreate)` | `ExpenseResponse` |
| update | `updateExpenseApiV1ExpensesExpenseIdPut(expenseId, expenseUpdate)` | `ExpenseResponse` |
| delete | `deleteExpenseApiV1ExpensesExpenseIdDelete(expenseId)` | `void` |

- `ExpenseResponse`: `expenseId, expense(String — the display name), comment?`.
  → domain `Expense.name = r.expense` (data-model.md §1).
- `ExpenseCreate`: `name` required; `comment` optional.
- `ExpenseUpdate`: `name?`, `comment?` — all optional.
- List currently has **only** `skip`/`limit` → search box wired to the pending
  `search` param (#82); **no** filter drawer.

## 2. Vehicles — `VehiclesApi` (RBAC `vehicle(88)`)

| Op | Method | Returns |
|---|---|---|
| list | `listVehiclesApiV1VehiclesGet({skip, limit})` — **`search` pending #83** | `ListResponseVehicleResponse` |
| get | `getVehicleApiV1VehiclesVehicleIdGet(vehicleId)` | `VehicleResponse` |
| create | `createVehicleApiV1VehiclesPost(vehicleCreate)` | `VehicleResponse` |
| update | `updateVehicleApiV1VehiclesVehicleIdPut(vehicleId, vehicleUpdate)` | `VehicleResponse` |
| delete | `deleteVehicleApiV1VehiclesVehicleIdDelete(vehicleId)` | `void` |

- `VehicleResponse`: `vehicleId, licensePlate, name, nickname,
  tonsCapacity(int), active(bool)`.
- `VehicleCreate`: `licensePlate`, `name`, `nickname`, `tonsCapacity` required;
  `active?` optional (default true UI-side).
- `VehicleUpdate`: all optional.
- List currently has **only** `skip`/`limit` → search box wired to the pending
  `search` param (#83); **no** filter drawer.

## 3. Vehicle Operators — `VehicleOperatorsApi` (RBAC `vehicleOperators(89)`)

| Op | Method | Returns |
|---|---|---|
| list | `listVehicleOperatorsApiV1VehicleOperatorsGet({employee, skip, limit})` — **`search` pending #84** | `ListResponseVehicleOperatorResponse` |
| get | `getVehicleOperatorApiV1VehicleOperatorsVehicleOperatorIdGet(vehicleOperatorId)` | `VehicleOperatorResponse` |
| create | `createVehicleOperatorApiV1VehicleOperatorsPost(vehicleOperatorCreate)` | `VehicleOperatorResponse` |
| update | `updateVehicleOperatorApiV1VehicleOperatorsVehicleOperatorIdPut(vehicleOperatorId, vehicleOperatorUpdate)` | `VehicleOperatorResponse` |
| delete | `deleteVehicleOperatorApiV1VehicleOperatorsVehicleOperatorIdDelete(vehicleOperatorId)` | `void` |

- `VehicleOperatorResponse`: `vehicleOperatorId, driver(EmployeeResponse —
  pre-expanded), licenseType, driverLicenseNumber, issueDate(Date),
  expirationDate(Date), issuingLocation, active(bool), daysUntilExpiry(int?)`
  (plus audit fields `creationTime`/`modificationTime`/`creator`/`updater`, not
  surfaced).
- `VehicleOperatorCreate`: `driver(int)`, `licenseType`, `driverLicenseNumber`,
  `issueDate(Date)`, `expirationDate(Date)`, `issuingLocation` required;
  `active?` optional.
- `VehicleOperatorUpdate`: all optional; `driver` is `int?`.
- List has an `employee` facet (→ domain `driverId`) beyond skip/limit → **ships
  a driver filter drawer** (research.md §6), plus the search box wired to the
  pending `search` param (#84).
- `driver` arrives **pre-expanded** as `EmployeeResponse` on list + detail — no
  N+1 lookup; render `firstName + lastName`, fallback label if unresolvable
  (FR-017).
- `Date`↔`DateTime` via `DateTimeToDate.toDate()` / `Date.toDateTime()`
  (research.md §5).

---

## 4. External dependency — the `search` query param (mbe-api #82/#83/#84)

Per constitution §III, mbe-ui MUST NOT edit mbe-api. The three list endpoints
lack a free-text `search` param that §VI requires the UI to expose. Issues filed
2026-07-19:

| Endpoint | Issue | Match semantics requested |
|---|---|---|
| `GET /api/v1/expenses` | [mictlanix/mbe-api#82](https://github.com/mictlanix/mbe-api/issues/82) | expense name |
| `GET /api/v1/vehicles` | [mictlanix/mbe-api#83](https://github.com/mictlanix/mbe-api/issues/83) | license plate / name / nickname |
| `GET /api/v1/vehicle-operators` | [mictlanix/mbe-api#84](https://github.com/mictlanix/mbe-api/issues/84) | driver name / license number |

Each mirrors the existing `search` on `customers`/`employees`/`suppliers`.
**mbe-ui consumption path once shipped**: re-run codegen → the generated `list…`
methods gain `String? search` → the repository impls already forward the
declared `search` argument → no screen/controller change. Until then, the
repository interface carries `search` and the impl forwards it to a client that
does not yet accept it (dropped/no-op), so the UI compiles and the box renders.

## 5. Not consumed / out of scope

- **Payment Method Options** (`PaymentMethodOptionsApi`, RBAC
  `paymentMethodOptions(84)`) — deferred (spec Clarifications). Its `store`
  filter, `paymentMethod` SAT enum, `commission` `AnyOf`, and the store/warehouse
  pickers are **not** built in this feature. No `StoresApi`/`WarehousesApi`
  consumption here.
- `VehicleOperatorResponse` audit fields (`creator`/`updater`/`creationTime`/
  `modificationTime`) — available but not surfaced by any FR.
