# Phase 1 Data Model: Point of Sale — Sale Capture

**Feature**: `020-point-of-sale` | **Spec**: [spec.md](./spec.md) | **Research**: [research.md](./research.md)

All entities are immutable `freezed` classes in
`lib/features/sales/domain/entities/`, mapped from generated DTOs in the `data`
layer (constitution §III). Master-data entities (Customer, Product, Warehouse,
Address, PriceList) are **not** redefined here — they are imported from
`features/catalog/domain` (research §14).

Monetary and quantity values are carried as `String` end to end, matching the
generated DTOs and the convention spec 011 established; they are converted to
`Decimal` only inside `domain/money.dart` where arithmetic is unavoidable
(research §8).

---

## 1. Sale

The whole point of the screen. One per transaction, created when the screen
opens (FR-002).

| Field | Type | Source | Notes |
|---|---|---|---|
| `id` | `int` | `SalesOrderResponse.salesOrderId` | The provisional reference before confirmation (FR-040) |
| `serial` | `int?` | `.serial` | The folio. Null until confirmed |
| `facility` | `int` | `.facility` | |
| `pointSale` | `int` | `.pointSale` | |
| `salesperson` | `int` | `.salesperson` | |
| `customer` | `int` | `.customer` | |
| `customerName` | `String?` | `.customerName` | |
| `paymentTerms` | `PaymentTerms` | `.paymentTerms` | `immediate` \| `netD` |
| `currency` | `CurrencyCode` | `.currency` | |
| `exchangeRate` | `String` | `.exchangeRate` | |
| `shipTo` | `int?` | `.shipTo` | Carries the fulfilment mode (research §4) |
| `promiseDate` | `DateTime` | `.promiseDate` | Fixed at creation (A-008) |
| `status` | `SaleStatus` | `.status` | See §1.1 |
| `lines` | `List<SaleLine>` | `.lines` | |
| `subtotal`, `taxTotal`, `total`, `balance` | `String` | derived server-side | Never computed client-side (FR-008) |

**Derived in the client** (not stored):

- `lineCount`, `unitCount` — for the totals bar (FR-028).
- `isEditable` — `status == draft`.
- `isPaid` — `balance` is zero.

### 1.1 SaleStatus and its transitions

```text
draft ──confirm──> completed ──payments cover total──> paid
  │                    │
  └──cancel──> cancelled <──cancel──┘
```

| State | Reached by | What the screen allows |
|---|---|---|
| `draft` | Screen opened / sale selected | Capture: lines, customer, mode, terms, currency (FR-007) |
| `completed` | `POST .../confirm` at "Continuar al cobro" | Payment only; lines read-only (FR-041) |
| `paid` | Applications cover the total | The delivery step, or the end of the workflow |
| `cancelled` | Abandoned empty sale (FR — US3 scenario 6) | Nothing; not selectable |

Cancellation of a confirmed sale is out of scope (spec Out of Scope) and is done
from the sales-order screens.

---

## 2. SaleLine

| Field | Type | Source | Validation |
|---|---|---|---|
| `id` | `int` | `.salesOrderDetailId` | |
| `product` | `int` | `.product` | |
| `productCode`, `productName` | `String` | | Never ellipsized past readability (FR-022) |
| `quantity` | `String` | `.quantity` | `> 0`; `>= product.minOrderQty` — server-enforced, surfaced on the field |
| `price` | `String` | `.price` | `>= 0`; may be refused for margin (research §2) |
| `discountRate` | `String` | `.discountRate` | `0 ≤ r ≤ 1`; displayed as a percentage |
| `taxRate` | `String` | `.taxRate` | **Read-only** — not writable by any endpoint (research §12) |
| `taxIncluded` | `bool` | `.taxIncluded` | Display only |
| `warehouse` | `int?` | `.warehouse` | Defaults to the point of sale's warehouse (FR-024) |
| `subtotal`, `taxTotal`, `total` | `String` | derived server-side | |

**Joined for display, not stored on the line**: `availability` — the chosen
warehouse's `available` figure from the most recent product lookup, used for the
shortfall warning (FR-025, FR-026). It is advisory; the authoritative check
happens at confirmation.

---

## 3. ProductLookupResult

From `GET /sales-orders/product-lookup`. Backs both the scan and the search path
(FR-020, FR-021).

| Field | Type | Notes |
|---|---|---|
| `product` | `int` | |
| `code`, `name` | `String` | |
| `sku`, `brand`, `model`, `barCode` | `String?` | |
| `price` | `String` | Already resolved for this customer's price list |
| `taxRate`, `taxIncluded` | `String`, `bool` | |
| `minOrderQty` | `int` | Pre-fills quantity when adding |
| `stockRequired`, `stockable` | `bool` | A non-stockable product never warns about stock |
| `stock` | `List<WarehouseStock>` | Per warehouse: `warehouse`, `warehouseName`, `onHand`, `available` |

`available` — not `onHand` — is what the shortfall warning compares against: it
is what confirmation itself checks, so it is the figure that predicts whether the
sale will go through.

---

## 4. FulfillmentMode

A client-side enum: `counterPickup`, `delivery`, `mixed`.

**Persistence** (research §4): not a stored field. Encoded in `Sale.shipTo`:

| `shipTo` | Meaning on resume |
|---|---|
| the facility's own address | counter pickup — no delivery step |
| any other address | a delivery step is owed |
| null | not yet chosen; treat as counter pickup |

`mixed` is deliberately not distinguishable from `delivery` after a reload: the
distinction only gates whether an undistributed remainder blocks closing
(FR-035), and a resumed sale asks the cashier about the remainder rather than
guessing.

---

## 5. Destination

A delivery order, in the vocabulary of the step. Created as soon as its address
is chosen (FR-030).

| Field | Type | Source | Notes |
|---|---|---|---|
| `id` | `int` | `DeliveryOrderResponse.deliveryOrderId` | |
| `fulfillmentType` | `FulfillmentType` | `.fulfillmentType` | Immutable after creation (research §3) |
| `shipTo` | `int?` | `.shipTo` | The destination address |
| `addressSummary` | `String` | joined from the catalog Address | Display |
| `contactName`, `contactPhone` | `String?` | encoded in `.comment` | Stopgap until a contacts API exists (research §10) |
| `date` | `DateTime?` | `.date` | This destination's delivery date |
| `status` | `DeliveryOrderStatus` | `.status` | Always `draft` while the step is open |
| `lines` | `List<DestinationLine>` | `.lines` | |

**Derived**: `lineCount`, `unitCount` for the card header (FR-029).

### 5.1 DestinationLine

| Field | Type | Source |
|---|---|---|
| `id` | `int` | `.deliveryOrderDetailId` |
| `salesOrderDetail` | `int?` | `.salesOrderDetail` — the link back to the sale line |
| `product`, `productCode`, `productName` | | |
| `quantity` | `String` | What this destination takes |
| `warehouse` | `int` | |

---

## 6. LineDistribution (view model, not persisted)

What the distribution panel renders (FR-033), computed from the sale's lines and
every destination's lines:

| Field | Type | Meaning |
|---|---|---|
| `saleLineId` | `int` | |
| `ordered` | `String` | The sale line's quantity |
| `perDestination` | `Map<int, String>` | destination id → quantity |
| `atCounter` | `String` | `ordered` − Σ`perDestination` |
| `isComplete` | `bool` | `atCounter == 0`, or the mode is mixed |

Invariant (SC-005): Σ`perDestination` + `atCounter` == `ordered`, for every line,
always. The unit tests in `test/unit/sales/destination_split_test.dart` assert it
after every operation the step can perform.

---

## 7. SalePayment

| Field | Type | Source | Notes |
|---|---|---|---|
| `id` | `int` | `CustomerPaymentResponse.customerPaymentId` | |
| `amount` | `String` | `.amount` | The tender |
| `method` | `PaymentMethod` | `.method` | |
| `paymentChargeId` | `int?` | `.paymentCharge` | The chosen payment method option |
| `methodLabel` | `String` | joined from the option | Facility's own wording (research §6) |
| `currency` | `CurrencyCode` | `.currency` | Must match the sale's |
| `reference` | `String?` | `.reference` | Required for card / transfer / cheque |
| `verifier` | `int?` | `.verifier` | Null ⇒ "pending validation" (display only) |
| `appliedAmount` | `String` | from the application | What went to this sale |
| `changeAmount` | `String` | `.amountChange` on the application | Excess handed back (FR-047) |

**Session-scoped** (research §11): a sale's payments cannot be read back from the
server. The controller holds those taken in this session; a resumed sale shows
the balance with an explicit note instead of an empty list.

---

## 8. OpenSale (selector row)

From `GET /sales-orders` (research §5).

| Field | Type | Source |
|---|---|---|
| `id` | `int` | `.salesOrderId` |
| `serial` | `int?` | `.serial` |
| `customerName` | `String?` | `.customerName` |
| `total`, `balance` | `String` | |
| `status` | `SaleStatus` | Drives which step a selected sale resumes at (US3 scenarios 4, 5) |
| `date` | `DateTime` | Sorted newest first |

---

## 9. Validation rules, traced

| Rule | Where enforced | Requirement |
|---|---|---|
| Quantity `> 0` and `>= minOrderQty` | Server; surfaced on the field | FR-023, Edge Cases |
| Price within the margin band | Server (`assert_margin_in_range`); previous value restored on refusal | FR-009, Edge Cases |
| Discount rate `0 ≤ r ≤ 1` | Client input mask + server | FR-023 |
| At least one line before confirming | Client (button state) + server | FR-038 |
| No zero-priced line at confirmation | Server; offending lines identified | FR-039 |
| Sufficient stock at confirmation | Server; offending lines identified, sale stays editable | FR-039 |
| Credit terms need an available credit line | Server (`_assert_credit_allowed`) | FR-016 |
| Payment currency == sale currency | Server (`assert_same_currency`); prevented client-side | Edge Cases |
| Payment applied ≤ outstanding, excess is change | Client computes the split; server validates unapplied | FR-047 |
| Reference required for card / transfer / cheque | Client (`payment_method_rules.dart`) | FR-045 |
| Balance zero before leaving the payment step | Client gate on `Sale.balance`, unless `paymentTerms == netD` | FR-049, FR-051 |
| Every unit distributed before closing a delivery sale | Client (`LineDistribution.isComplete`) | FR-035 |
| Destination quantity ≤ remaining undistributed | Client, before the write | FR-032 |
