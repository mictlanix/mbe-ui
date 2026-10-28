# Data Model: Customer Refunds

Client-side entities, mapped from the generated `mbe_api_client` models in `features/sales/domain/entities/`. Amounts and quantities stay as server strings and go through `money.dart` and `formattersProvider`. The client never computes totals (FR-006).

## CustomerRefund (`customer_refund.dart`, freezed)

From `CustomerRefundResponse`.

| Field | Type | Source | Notes |
|---|---|---|---|
| id | int | `customerRefundId` | |
| salesOrderId | int | `salesOrder` | Links to the order (FR-015) |
| customerId | int? | `customer` | Null means no customer. Payout lookup is not possible then (R6) |
| salesPersonId | int | `salesPerson` | |
| facilityId | int | `facility` | Scopes the warehouse picker (R4) |
| serial | int? | `serial` | Folio. Null until confirmed |
| date | DateTime? | `date` | Set on confirm |
| currency | CurrencyCode | `currency` | |
| status | RefundStatus | `status` | See below |
| lines | List\<RefundLine\> | `lines` | |
| subtotal, taxTotal, total | String | same | Server figures |

Derived getters:
- `isDraft` is true when the status is draft.
- `hasReturn` is true when any line's quantity is above zero. It gates confirm (FR-008).

## RefundLine (freezed)

From `CustomerRefundLineResponse`.

| Field | Type | Source |
|---|---|---|
| id | int | `customerRefundDetailId` |
| salesOrderLineId | int | `salesOrderDetail` |
| productId, productCode, productName | int, String, String | same |
| quantity | String | the return quantity |
| refundableQuantity | String | the stepper's max (FR-007) |
| price, discount, taxRate | String | from the order line |
| taxIncluded | bool | |
| warehouseId | int? | the return-to warehouse |
| subtotal, taxTotal, total | String | server figures |

## CustomerRefundSummary (list row)

From `CustomerRefundSummary`: `id`, `salesOrderId`, `customerId?`, `serial?`, `date?`, `currency`, `status`, `total`. When mbe-api#284 ships it gains `customerName?`.

## RefundStatus (enum)

`draft` | `completed` | `cancelled`, mapped from `api.DocumentStatus`. `paid` never occurs on a refund. If it does, the mapper treats it as `completed`.

```text
draft ──confirm(payout)──▶ completed   (folio, date assigned; read-only)
  │
  └──cancel──▶ cancelled                (read-only)
```

## RefundPayout (enum)

`cash` | `creditNote`, sent as `api.RefundPayout`. It has no default value (FR-008).

## RefundOutcome (presentation state, freezed)

What a completed refund shows about its payout (R6). It is interim until mbe-api#286.

| Variant | Shown as |
|---|---|
| `cash` | "Pagada en efectivo" |
| `creditNote(CreditNote note)` | "Nota de crédito Nº {note.customerPaymentId}", linked to the note |
| `unknown` | "Forma de pago no disponible" (refund has no customer, or the lookup failed) |

## RefundRefusal (enum, presentation)

Reasons a refund can't be opened, derived on the client (R3): `orderNotFound`, `notCompleted`, `notPaid`, `nothingToReturn`. `nothingToReturn` also carries the server detail, which names the invoice when invoiced units are the cause.

## RefundsFilter (freezed)

`status: RefundStatus?`, `customerId: int?`, `salesOrderId: int?`, `pageIndex: int`. It round-trips through the `ListQuery` facets `status`, `customer` and `order`.
