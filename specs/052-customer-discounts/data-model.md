# Data Model: Customer Discounts

**Feature**: [spec.md](./spec.md) · **Research**: [research.md](./research.md)

## CustomerDiscount (new domain entity)

`lib/features/catalog/domain/entities/customer_discount.dart` is a freezed entity mapped from the generated `CustomerDiscountResponse`.

| Field | Type | From | Notes |
|---|---|---|---|
| `customerDiscountId` | `int` | `customer_discount_id` | Identity, used in PUT/DELETE paths |
| `customerId` | `int` | `customer` | Owning customer |
| `productId` | `int` | `product.product_id` | Fixed after create |
| `productCode` | `String` | `product.code` | Shown in the list and the edit dialog |
| `productName` | `String` | `product.name` | Shown in the list and the edit dialog |
| `discount` | `String` | `discount` | Decimal **fraction** `0 ≤ d ≤ 1`, up to 8 places, kept as the wire string (R3) |

**Rules**
- At most one per `(customerId, productId)`. The server enforces this with a 409, and the add picker excludes taken products.
- `productId` never changes. PUT sends only `discount`.
- Ordering is the server's: by product code. The UI keeps it.

## Repository additions: `CustomerRepository`

| Method | Endpoint | Returns / throws |
|---|---|---|
| `listDiscounts({required int customerId})` | `GET /customers/{id}/discounts` | `List<CustomerDiscount>` in server order. `NotFoundError` if the customer is gone |
| `createDiscount({required int customerId, required int productId, required String discount})` | `POST /customers/{id}/discounts` | `CustomerDiscount`. `ServerError(409)` on a repeat. `ValidationError` on 422 (unknown product, or field errors) |
| `updateDiscount({required int customerId, required int customerDiscountId, required String discount})` | `PUT /customers/{id}/discounts/{did}` | `CustomerDiscount`. `NotFoundError` on 404 |
| `deleteDiscount({required int customerId, required int customerDiscountId})` | `DELETE /customers/{id}/discounts/{did}` | `void`. `NotFoundError` on 404 |

`discount` is always the **fraction** string. Converting from and to a percentage is presentation's job (R3).

## Presentation state

### `CustomerDiscountsController` (family `int customerId`)

`AsyncValue<List<CustomerDiscount>>`, loaded from `listDiscounts`. It is invalidated by the dialog controller (R7).

### `CustomerDiscountDialogState` (freezed), controller family `(int customerId, CustomerDiscount? existing)`

| Field | Type | Notes |
|---|---|---|
| `product` | `ProductListItem?` | Add mode only. `null` until picked |
| `percent` | `String` | Field text. Seeded with `fmt.field.rate(existing.discount)` in edit mode |
| `percentDirty` | `bool` | `false` until the user edits. An untouched edit sends `existing.discount` as-is (R3) |
| `submitting` | `bool` | |
| `done` | `bool` | Closes the dialog |
| `error` | `String?` | A `CustomerDiscountDialogErrorCode` (R6) |
| `errorDetail` | `String?` | The server message for the generic codes |
| `fieldErrors` | `Map<String, String>` | Server 422 field errors |

**Derived**
- `percentError`, the first failing rule, as a code localized in the UI:
  - `percentRequired` when the field is empty.
  - `percentInvalid` when the text doesn't parse.
  - `percentOutOfRange` when the value is below 0 or above 100.
  - `percentTooPrecise` when it has more than 6 decimal places.
- `canSubmit`: `(existing != null || product != null) && percentError == null && !submitting`.

**Error codes** (`CustomerDiscountDialogErrorCode`)
- `duplicateProduct` (409)
- `productMissing` (422, plain detail)
- `discountMissing` (404)
- `saveFailed`
- `deleteFailed`

## Changed state: `CustomerFormController`

- `build()` becomes `build(int? customerId)`. The state is unchanged. Each customer screen, and each create, gets its own instance (R8, mbe-ui#207).
- The create path already sets `customerId: created.customerId` with `saved: true`. That id now drives `onCreated`.
