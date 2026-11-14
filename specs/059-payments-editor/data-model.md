# Data Model: Payments Editor (spec 059)

Client-side entities only. Nothing is persisted (§VII). Existing entities are listed for the fields this feature reads.

## Existing, read as-is

**CustomerPayment** (`domain/entities/customer_payment.dart`)
- Fields read: `customerPaymentId`, `customerId`, `customerName`, `amount`, `currency`, `methodCode`, `type`, `facilityId`, `unapplied`.
- `unapplied` is the server's: amount − live applications − their change (mbe-api spec 033). The client never recomputes it.
- "Aplicar a pedido" shows when `unapplied > 0.01`.

**PaymentApplication** (same file)
- Fields: `id` (application id, used by reverse), `saleId`, `amount`, `change`, `applierId`, `date`, `reversed`.
- A row can be reversed when `!reversed`.

**SalePayment** (`domain/entities/sale_payment.dart`)
- An application seen from the order side.
- Fields used: `id` (application id), `customerPayment` (payment id, for reverse and for the link), `cancelled`.

**PaymentType** (`domain/payment_type.dart`)
- The record form offers only `creditPayment` (2) and `paymentInAdvance` (3).

## New

**OutstandingOrder** (`domain/entities/outstanding_order.dart`, freezed)

| Field | Type | From |
|---|---|---|
| `id` | int | `sales_order_id` |
| `serial` | int? | `serial` (folio; may be null) |
| `date` | DateTime | `date` |
| `dueDate` | DateTime | `due_date` |
| `currency` | Currency | `currency` |
| `total` | Decimal | `total` |
| `balance` | Decimal | `balance` |

`OutstandingOrderPage { List<OutstandingOrder> items, int total }`.

**RecordPaymentDraft** (form state inside `RecordPaymentDialog`, not freezed unless the form needs it)

| Field | Rule |
|---|---|
| customer | required; not the walk-in customer (`isGenericCustomer`) |
| type | `creditPayment` or `paymentInAdvance`; default `creditPayment` |
| method + option | required; option is used when the facility has options |
| reference | ≤ 50 chars; required when the option has `requiresReference` |
| amount | Decimal > 0 |
| currency | tenant default; editable only with multi-currency on |
| (derived) needs session | `method == cash` → a valid current cash session is required |

**ApplyDraft** (inside the apply dialog)
- order: one `OutstandingOrder` in the payment's currency.
- amount: `0 < amount ≤ min(order.balance, payment.unapplied)`, defaulting to that min.
- change: always none.

## Repository changes (`CustomerPaymentRepository`)

| Method | Change |
|---|---|
| `createPayment(...)` | add `PaymentType type = PaymentType.immediate`, sent as `payment_type` |
| `listOutstandingOrders({required int customerId, String? search, int skip = 0, int limit = 20})` | new, returns `OutstandingOrderPage` |
| `applyPayment`, `reverseApplication`, `listForOrder`, `get`, `listApplications` | unchanged |

`CustomerRefundRepository.list(salesOrderId:, status: completed, limit: 1)` is reused for the refund warning.

## State transitions

```
Application: live ──reverse(reason)──▶ reversed     (terminal; stays listed)
Order paid flag: paid ──reverse puts balance > 0.01──▶ unpaid
                 unpaid ──apply brings balance ≤ 0.01──▶ paid       (server-owned)
Payment unapplied: += application.amount + change on reverse; −= amount on apply
```
