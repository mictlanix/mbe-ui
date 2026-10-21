# Data Model: Login & POS Sales Enhancements

**Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

These are client-side domain entities and state only. The app keeps nothing on the device (§VII). All backend fields below exist in the regenerated client (R9).

## 1. `PasswordPolicy` (new): `features/auth/domain/entities/password_policy.dart`

| Field | Type | Source (`PasswordPolicyResponse`) | Server default |
|---|---|---|---|
| `minLength` | `int` | `minLength` (`min_length`) | 8 |
| `requireUpper` | `bool` | `requireUpper` | true |
| `requireLower` | `bool` | `requireLower` | true |
| `requireDigit` | `bool` | `requireDigit` | true |
| `requireSymbol` | `bool` | `requireSymbol` | false |

- `enum PasswordRule { minLength, upper, lower, digit, symbol }`, each with its server name: `min_length`, `require_upper`, `require_lower`, `require_digit`, `require_symbol`.
- `List<PasswordRule> get rules`: `minLength` plus each enabled `require*`, in that order. The checklist shows them in this order.
- `Set<PasswordRule> unmet(String password)` is a pure function:
  - *upper*: at least one character for which `c != c.toLowerCase()`;
  - *lower*: the reverse;
  - *digit*: matches `[0-9]`;
  - *symbol*: any character that is not a letter, not a digit and not whitespace, matching the server;
  - *minLength*: `password.length < minLength`.
- `Set<PasswordRule> rulesFromFieldError(FieldError)` (R3) reads the rules named in `failedRules` when `type == 'password_policy'`, and returns an empty set otherwise.

There is no client-side fallback policy. If loading the policy fails, the checklist shows "unavailable", and the client doesn't block (R2).

## 2. `FieldError` (changed): `core/errors/app_error.dart`

| Field | Type | Source |
|---|---|---|
| `failedRules` | `List<String>`, default empty | 422 `detail[].ctx.failed`, when it is a list of strings |

It is filled in `_fieldErrorsFrom` (`core/network/auth_interceptor.dart`). `ctx` is otherwise ignored, and `input` is never read.

## 3. Password form state (changed)

All three existing controllers gain the same two members:

| Controller | New state | New error |
|---|---|---|
| `ChangePasswordController` (`account_controller.dart`) | `confirmPassword: String` | mismatch, policy rule(s) |
| `RecoveryController` (`account_controller.dart`) | `confirmPassword: String` | mismatch, policy rule(s) |
| `UserFormController` (`users_controller.dart`, create mode only) | `confirmPassword: String` | `UserFormErrorCode.passwordMismatch`, policy rule(s) |

**Submit guard**, the same in each. The form submits only when:
- `newPassword == confirmPassword`;
- `policy.unmet(newPassword).isEmpty`, when the policy loaded;
- the form's other existing requirements (current password, recovery token) are met.

## 4. `User` (changed): `core/access/user.dart`

| Field | Type | Source |
|---|---|---|
| `mustChangePassword` | `bool`, `@Default(false)` | `UserResponse.mustChangePassword` (nullable; `null` → false) |

**State changes**:
- *Set*:
  - when `GET /auth/me` returns the flag true at login or on reload;
  - when the interceptor sees `403 password_change_required` (FR-044).
- *Cleared*: by `AuthNotifier.reloadCurrentUser()` after a successful change. The server clears the flag on change-password.

## 5. `PosStepState` (changed): `pos_step_controller.dart`

| Field | Type | Meaning |
|---|---|---|
| `detail` | `bool`, default false | The workspace shows `PosSaleDetailView` instead of the step host |

`_syncStepTo` sets `detail` once per sale id, using the R6 predicate. `reset()` (new sale) clears it. Nothing in the detail view sets it back to false: leaving the view means leaving the workspace.

**Predicate** (R6): `opensAsReadOnlyDetail(sale, isDelivery, destinations)`

| Status | Balance | Delivery? | Destinations | Result |
|---|---|---|---|---|
| paid | 0 | no | n/a | **detail** |
| paid | 0 | yes | all lines fully distributed | **detail** |
| paid | 0 | yes | some line pending | Entrega (unchanged) |
| paid | 0 | yes | null (loading/failed) | Entrega (unchanged) |
| completed | > 0 | any | any | Cobro (unchanged) |
| draft | any | any | any | Venta (unchanged) |
| cancelled | any | any | any | unreachable notice (unchanged) |

## 6. `WarehouseStock` (changed): `domain/entities/product_lookup_result.dart`

| Field | Type | Source |
|---|---|---|
| `facilityId` | `int?` | `ProductStockResponse.facility` |
| `facilityName` | `String?` | `ProductStockResponse.facilityName` |

## 7. `OtherFacilityGroup` (new, presentation-local): `capture/other_facility_stock.dart`

| Field | Type |
|---|---|
| `facilityId` | `int` |
| `facilityName` | `String` (falls back to `#<facilityId>` if the row has no name) |
| `warehouses` | `List<WarehouseStock>` |

`otherFacilityStock(stock, saleFacilityId, saleWarehouseIds, currentWarehouse) → List<OtherFacilityGroup>`:
- **Kept rows**: other-facility rows with `available > 0`, plus the row for `currentWarehouse` whatever its stock. Rows without a `facilityId` are skipped.
- **Sorting**: groups sort by `facilityName`. Warehouses sort by `warehouseName`.

`lineWarehouseLabel(warehouseId, facilityWarehouses, stock) → String` (FR-025) tries each source in order:
1. the facility list's name;
2. the stock row's `"<warehouseName> · <facilityName>"`;
3. `#<id>`.

It never returns an empty string.

## 8. Existing entities read, unchanged

- `Sale`: `status`, `balanceOrZero`, `customer`, `date`, `salesperson`, `facility`, `lines`, totals.
- `SalePayment`: from `orderPaymentsControllerProvider`, with `amount`, `methodCode`, `changeAmount`, `paymentDate`, `cancelled`.
- `Destination` and `distributionFor` / `isFullyDistributed`, from `line_distribution.dart`.
- `StockGate` / `evaluateLines`: already keyed by warehouse id, so other-facility lines are checked the same way.
