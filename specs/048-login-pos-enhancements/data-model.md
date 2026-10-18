# Data Model: Login & POS Sales Enhancements

**Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

These are client-side domain entities and state only. The app keeps nothing on the device (§VII).

## 1. `PasswordPolicy` (new): `features/auth/domain/entities/password_policy.dart`

| Field | Type | Interim (before #241) | After #241 |
|---|---|---|---|
| `minLength` | `int` | 6 | `GET /auth/password-policy.min_length` |
| `requireUpper` | `bool` | false | `.require_upper` |
| `requireLower` | `bool` | false | `.require_lower` |
| `requireDigit` | `bool` | false | `.require_digit` |
| `requireSymbol` | `bool` | false | `.require_symbol` |

- `enum PasswordRule { minLength, upper, lower, digit, symbol }`
- `List<PasswordRule> get rules`: `minLength` plus each enabled `require*`, in that order. The checklist shows them in this order.
- `Set<PasswordRule> unmet(String password)`: a pure function.
  - *upper*: at least one character for which `c != c.toLowerCase()`.
  - *lower*: the reverse of *upper*.
  - *digit*: matches `[0-9]`.
  - *symbol*: any character that is not a letter or a digit, so whitespace counts.
  - *minLength*: `password.length < minLength` (code units).
- `PasswordRule? ruleFromFieldError(FieldError)` (R3) maps a server 422 to a rule, and returns null when it can't.

## 2. Password form state (changed)

All three existing controllers gain the same two members:

| Controller | New state | New error |
|---|---|---|
| `ChangePasswordController` (`account_controller.dart`) | `confirmPassword: String` | mismatch, policy rule(s) |
| `RecoveryController` (`account_controller.dart`) | `confirmPassword: String` | mismatch, policy rule(s) |
| `UserFormController` (`users_controller.dart`, create mode only) | `confirmPassword: String` | `UserFormErrorCode.passwordMismatch`, policy rule(s) |

**Submit guard** (identical in each): the form submits only when all three hold:
- `newPassword == confirmPassword`;
- `policy.unmet(newPassword).isEmpty`, when the policy loaded;
- all other existing requirements (current password, recovery token) are met.

## 3. `User` (changed, **blocked on #240**): `core/access/user.dart`

| Field | Type | Source |
|---|---|---|
| `mustChangePassword` | `bool`, `@Default(false)` | `UserResponse.must_change_password` |

**State changes**:
- *Set*:
  - when `GET /auth/me` returns the flag as true at login or on reload;
  - when the interceptor sees `403 password_change_required` (FR-044).
- *Cleared*: by `AuthNotifier.reloadCurrentUser()` after a successful change.

## 4. `PosStepState` (changed): `pos_step_controller.dart`

| Field | Type | Meaning |
|---|---|---|
| `detail` | `bool`, default false | The workspace shows `PosSaleDetailView` instead of the step host |

`detail` is set once per sale id in `_syncStepTo`, using the R6 predicate. `reset()` (new sale) clears it. Nothing in the detail view sets it back to false: leaving the view means leaving the workspace.

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

## 5. `WarehouseStock` (changed, **mapping blocked on #242**): `domain/entities/product_lookup_result.dart`

| Field | Type | Source |
|---|---|---|
| `facilityId` | `int?` | `ProductStockResponse.facility` |
| `facilityName` | `String?` | `ProductStockResponse.facility_name` |

## 6. `OtherFacilityGroup` (new, presentation-local): `capture/other_facility_stock.dart`

| Field | Type |
|---|---|
| `facilityId` | `int?` (null means "other warehouses" while #242 is pending) |
| `facilityName` | `String?` |
| `warehouses` | `List<WarehouseStock>` (all with `available > 0`) |

`otherFacilityStock(stock, saleFacilityId, saleWarehouseIds) → List<OtherFacilityGroup>`:
- Groups are sorted by `facilityName`, and the null group goes last.
- Warehouses are sorted by `warehouseName`.

## 7. Existing entities read, unchanged

- `Sale`: `status`, `balanceOrZero`, `customer`, `date`, `salesperson`, `facility`, `lines`, totals.
- `SalePayment`: from `orderPaymentsControllerProvider`, with `amount`, `methodCode`, `changeAmount`, `paymentDate`, `cancelled`.
- `Destination` and `distributionFor` / `isFullyDistributed`, from `line_distribution.dart`.
