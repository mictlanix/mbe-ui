# Data Model: Payment Verification

**Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

No new domain entity. The feature reads and writes the existing `CustomerPayment` and adds one filter value object.

## 1. `CustomerPayment` (existing, `features/sales/domain/entities/customer_payment.dart`)

**Unchanged.** It is built from `CustomerPaymentResponse` by `CustomerPayment.fromResponse`, for the unverified list and for the verify and reject responses alike.

| Field | Used for |
|---|---|
| `customerPaymentId` | **Folio** in the queue, panel and dialogs (R2) |
| `facilityId` | Facility column. The name comes from `facilityDisplayNameProvider`, falling back to `#id` (R7) |
| `date` | Date column, newest first (server order) |
| `customerName` / `customerId` | Customer column (`PaymentCustomerName`) |
| `methodCode`, `paymentOptionId` | Method column (`PaymentMethodText`) |
| `reference` | Reference column, `—` when null |
| `amount`, `currency` | Amount column (`paymentAmountLabel`) |
| `type`, `unapplied`, `cashSessionId` | Read-only panel only (FR-005a) |
| `verifierId` | `null` on every queue row. On the payment view it decides whether Verificar and Rechazar show |

**State transition (server-owned):**
- **Verify:** `verifierId` goes from `null` to the current employee. It never returns to `null`, because there is no un-verify.
- **Reject:** changes no field (FR-012).

## 2. `PaymentVerificationFilter` (new, freezed, presentation)

| Field | Type | Default | URL facet |
|---|---|---|---|
| `facilityId` | `int?` | `null` (every facility) | `facility` |
| `dateFrom`, `dateTo` | `DateTime?` | `null` (any date), both or neither | `date-from`, `date-to` |
| `method` | `VerificationMethodFilter` | `.code(3)` (Transfer) | `method`: absent means Transfer, `all` means none, a number means that code |
| `pageIndex` | `int` | `0` | the `ListQuery` page |

`VerificationMethodFilter` is a small sealed type with two variants, `all` and `code(int)`. It keeps "no filter" and "default" apart, so `null` never has to mean both.

**Derived values:**
- `methodCode`: the code to send, or `null` for `all`.
- `activeFilterCount`: the facility, the date range and the method, each counted when set. The method counts whenever it isn't `all`, so the badge reads ① on open.
- `differsFromDefault`: facility or date set, or method other than Transfer. It controls "Quitar filtros" on the empty state.

**Validation in `fromQuery`:**
- A half-open date range is dropped, as in Pagos.
- An unparsable `method` is read as Transfer.
- An unparsable `facility` is dropped.

## 3. Queue page

`CatalogPage<CustomerPayment>`, built by `fetchClampedPage` with a page size of 20. `total` is the server's count, shown by the table's pagination footer ("1–20 de N", FR-004).

## 4. Write outcomes

`PaymentVerification.verify` and `.reject` return `AppError?`:

| Return | Meaning |
|---|---|
| `null` | done |
| `AppError` with code `payment.already_verified` | someone else verified it first |
| `NetworkError` / timeout | unknown result |
| any other `AppError` | shown through `localizeProblem` |

Reject's `reason` is trimmed by the dialog, required non-empty, and at most 500 characters (the server's `RejectionRequest`).
