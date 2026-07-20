# Contract: mbe-api Catalog Endpoints (Expenses, Vehicles, Vehicle Operators)

**Feature**: `013-catalog-logistics-payment-entities` | **Date**: 2026-07-19

All three endpoint families already exist in the committed generated client
(`lib/generated/openapi/`); this contract records the exact methods, DTOs, and
query params mbe-ui consumes. **No generated-file edits** (research.md §2). The
one former gap — the missing `search` query param — was filed as mbe-api issues
#82/#83/#84 and has since **shipped upstream and been regenerated into the
client**, so `search` is now present on all three list methods (research.md §8).
All routes are under `OAuth2PasswordBearer` (the shared `dio` auth interceptor
attaches the token).

---

## 1. Expenses — `ExpensesApi` (RBAC `expenses(81)`)

| Op | Method | Returns |
|---|---|---|
| list | `listExpensesApiV1ExpensesGet({search, skip, limit})` — **`search` shipped (#82)** | `ListResponseExpenseResponse` |
| get | `getExpenseApiV1ExpensesExpenseIdGet(expenseId)` | `ExpenseResponse` |
| create | `createExpenseApiV1ExpensesPost(expenseCreate)` | `ExpenseResponse` |
| update | `updateExpenseApiV1ExpensesExpenseIdPut(expenseId, expenseUpdate)` | `ExpenseResponse` |
| delete | `deleteExpenseApiV1ExpensesExpenseIdDelete(expenseId)` | `void` |

- `ExpenseResponse`: `expenseId, expense(String — the display name), comment?`.
  → domain `Expense.name = r.expense` (data-model.md §1).
- `ExpenseCreate`: `name` required; `comment` optional.
- `ExpenseUpdate`: `name?`, `comment?` — all optional.
- List exposes `search` + `skip`/`limit` → search box wired to the server-side
  `search` param (#82, shipped); **no** filter drawer.

## 2. Vehicles — `VehiclesApi` (RBAC `vehicle(88)`)

| Op | Method | Returns |
|---|---|---|
| list | `listVehiclesApiV1VehiclesGet({search, skip, limit})` — **`search` shipped (#83)** | `ListResponseVehicleResponse` |
| get | `getVehicleApiV1VehiclesVehicleIdGet(vehicleId)` | `VehicleResponse` |
| create | `createVehicleApiV1VehiclesPost(vehicleCreate)` | `VehicleResponse` |
| update | `updateVehicleApiV1VehiclesVehicleIdPut(vehicleId, vehicleUpdate)` | `VehicleResponse` |
| delete | `deleteVehicleApiV1VehiclesVehicleIdDelete(vehicleId)` | `void` |

- `VehicleResponse`: `vehicleId, licensePlate, name, nickname,
  tonsCapacity(int), active(bool)`.
- `VehicleCreate`: `licensePlate`, `name`, `nickname`, `tonsCapacity` required;
  `active?` optional (default true UI-side).
- `VehicleUpdate`: all optional.
- List exposes `search` + `skip`/`limit` → search box wired to the server-side
  `search` param (#83, shipped); **no** filter drawer.

## 3. Vehicle Operators — `VehicleOperatorsApi` (RBAC `vehicleOperators(89)`)

| Op | Method | Returns |
|---|---|---|
| list | `listVehicleOperatorsApiV1VehicleOperatorsGet({search, employee, skip, limit})` — **`search` shipped (#84)** | `ListResponseVehicleOperatorResponse` |
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
- List has an `employee` facet (→ domain `driverId`) plus `search` beyond
  skip/limit → **ships a driver filter drawer** (research.md §6) and the search
  box wired to the server-side `search` param (#84, shipped).
- `driver` arrives **pre-expanded** as `EmployeeResponse` on list + detail — no
  N+1 lookup; render `firstName + lastName`, fallback label if unresolvable
  (FR-017).
- `Date`↔`DateTime` via `DateTimeToDate.toDate()` / `Date.toDateTime()`
  (research.md §5).

---

## 4. External dependency — the `search` query param (mbe-api #82/#83/#84) *(RESOLVED)*

Per constitution §III, mbe-ui MUST NOT edit mbe-api. The three list endpoints
originally lacked the free-text `search` param that §VI requires the UI to
expose, so issues were filed 2026-07-19:

| Endpoint | Issue | Match semantics | Status |
|---|---|---|---|
| `GET /api/v1/expenses` | [mictlanix/mbe-api#82](https://github.com/mictlanix/mbe-api/issues/82) | expense name | ✅ shipped |
| `GET /api/v1/vehicles` | [mictlanix/mbe-api#83](https://github.com/mictlanix/mbe-api/issues/83) | license plate / name / nickname | ✅ shipped |
| `GET /api/v1/vehicle-operators` | [mictlanix/mbe-api#84](https://github.com/mictlanix/mbe-api/issues/84) | driver name / license number | ✅ shipped |

Each mirrors the existing `search` on `customers`/`employees`/`suppliers`.
**Resolved**: mbe-api shipped all three and codegen was re-run — the generated
`list…` methods now carry `String? search`, and the repository impls forward the
declared `search` argument straight through, with no screen/controller change
from the original design. The GitHub issues can be closed.

## 5. Not consumed / out of scope

- **Payment Method Options** (`PaymentMethodOptionsApi`, RBAC
  `paymentMethodOptions(84)`) — deferred (spec Clarifications). Its `store`
  filter, `paymentMethod` SAT enum, `commission` `AnyOf`, and the store/warehouse
  pickers are **not** built in this feature. No `StoresApi`/`WarehousesApi`
  consumption here.
- `VehicleOperatorResponse` audit fields (`creator`/`updater`/`creationTime`/
  `modificationTime`) — available but not surfaced by any FR.
