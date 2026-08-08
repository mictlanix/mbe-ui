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
(research §8) — the same file 021-cash-sessions already created in this
module, extended rather than duplicated.

**Revised 2026-08-05**: this document originally described three stopgaps —
a read-only `SaleLine.taxRate`, a comment-encoded destination contact, and a
session-scoped `SalePayment` list — each driven by a backend gap that has
since shipped (research.md §9–§12, §17, all RESOLVED). Every entity below
reflects the shipped shape; the stopgaps are removed, not merely noted as
superseded. A new precondition entity, `CashSession`, is added — reused
directly from `lib/features/sales/domain/entities/current_session.dart`
(021-cash-sessions), not redefined here (research §18).

---

## 0. CashSession precondition (reused, not redefined)

Before `Sale` can exist at all, the screen resolves
`currentSessionControllerProvider` → `CurrentSession { state, session }`
(`lib/features/sales/domain/entities/current_session.dart`, 021-cash-sessions).
This feature adds no new fields, no new mapping — it reads:

| `CurrentSession.state` | Screen behavior |
|---|---|
| `none` | Block. No `POST /sales-orders` call is made. Show the gate (contracts/pos-screen.md §0). |
| `open` | Proceed normally. |
| `stale` | Proceed, with a non-blocking banner (research §18). |

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
| `taxRate` | `String` | `.taxRate` | Editable in place. `0 ≤ r ≤ 1`; omitted on add ⇒ the product's own rate (research §12, resolved) |
| `taxIncluded` | `bool` | `.taxIncluded` | Display only — not part of mbe-api#135's change |
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

A delivery order, in the vocabulary of the step. Created **with its full line
distribution in one call** (research §3, resolved) — not created bare and
trimmed afterward.

| Field | Type | Source | Notes |
|---|---|---|---|
| `id` | `int` | `DeliveryOrderResponse.deliveryOrderId` | |
| `fulfillmentType` | `FulfillmentType` | `.fulfillmentType` | Immutable after creation |
| `shipTo` | `int?` | `.shipTo` | The destination address, from `Customer.addresses` (research §9) or created inline |
| `addressSummary` | `String` | joined from the catalog Address | Display |
| `contact` | `int?` | `.contact` | A real `Contact` id (research §10, resolved) — from `Customer.contacts` or created inline |
| `contactName`, `contactPhone` | `String?` | joined from `Contact` | Display only; the source of truth is the linked `Contact` record, not a local copy |
| `date` | `DateTime?` | `.date` | This destination's delivery date |
| `comment` | `String?` | `.comment` | Genuine free-text delivery instructions (FR-029) — no longer doubles as a contact-info stopgap |
| `status` | `DeliveryOrderStatus` | `.status` | Always `draft` while the step is open |
| `lines` | `List<DestinationLine>` | `.lines` | |

**Derived**: `lineCount`, `unitCount` for the card header (FR-029).

**Creation** (`DeliveryOrderCreate`): `{sales_order, fulfillment_type,
ship_to, contact, date, comment, lines: [{sales_order_detail, quantity}, ...]}`
— the whole destination in one request, validated server-side against the same
"still undelivered" figure the counter-pickup sweep uses. `lines` omitted (the
counter-pickup remainder only) means "everything left."

### 5.1 DestinationLine

| Field | Type | Source |
|---|---|---|
| `id` | `int` | `.deliveryOrderDetailId` |
| `salesOrderDetail` | `int?` | `.salesOrderDetail` — the link back to the sale line |
| `product`, `productCode`, `productName` | | |
| `quantity` | `String` | What this destination takes |
| `warehouse` | `int` | |

### 5.2 Contact (catalog entity, new to this feature — research §10)

Not a POS-specific entity; belongs in `features/catalog/domain/entities/` per
constitution §I, alongside `AddressListItem`. Included here because this is
the feature that first needs it.

| Field | Type | Source |
|---|---|---|
| `id` | `int` | `ContactResponse.contactId` |
| `name` | `String` | `.name` |
| `phone` | `String` | `.phone` — `''` default, not nullable, matching the column |
| `mobile` | `String` | `.mobile` — same |
| `email` | `String?` | `.email` |

Reached two ways: `Customer.contacts` (embedded, research §9) for an existing
one, or created inline via a new `ContactRepository.create()` mirroring
`AddressRepository.create()` — then linked to the customer via
`CustomerRepository.update(contacts: [...existing, newId])`.

---

## 6. LineDistribution (view model, not persisted, in-progress draft only)

**Revised 2026-08-05**: this was originally computed by querying every
already-created `Destination`'s lines and reconciling against the sale — the
client-side half of the create-then-trim workaround (research §3). Now that a
destination is created with its full distribution in one call, this view model
is only ever tracking the **destination currently being edited**, before it is
submitted — not reconstructed from server state after the fact. What the
distribution panel renders (FR-033), computed from the sale's lines, every
*already-created* destination's lines (from their own responses, no
re-derivation needed — each `Destination.lines` is exactly what was
requested), and the in-progress draft:

| Field | Type | Meaning |
|---|---|---|
| `saleLineId` | `int` | |
| `ordered` | `String` | The sale line's quantity |
| `perDestination` | `Map<int, String>` | destination id → quantity, read directly from each `Destination.lines` |
| `draftQuantity` | `String` | What the destination being edited (not yet submitted) currently claims for this line |
| `atCounter` | `String` | `ordered` − Σ`perDestination` − `draftQuantity` |
| `isComplete` | `bool` | `atCounter == 0`, or the mode is mixed |

Invariant (SC-005): Σ`perDestination` + `draftQuantity` + `atCounter` ==
`ordered`, for every line, always — now enforced primarily by the server's own
`422` refusal (over-claiming a line is rejected outright, research §3), with a
client-side pre-check only to avoid a round trip for an request already known
to be invalid. The unit test in `test/unit/features/sales/line_distribution_test.dart`
asserts the arithmetic, not a multi-call sequencing property — there is no
sequencing left to get wrong.

---

## 7. SalePayment

| Field | Type | Source | Notes |
|---|---|---|---|
| `id` | `int` | `OrderApplicationResponse.salesOrderPaymentId` | |
| `amount` | `String` | `.amount` | The tender |
| `method` | `PaymentMethod` | `.method` | Reuse `core/domain/payment_method.dart` (research §14), not a POS-local enum |
| `paymentChargeId` | `int?` | `.paymentCharge` | The chosen payment method option |
| `methodLabel` | `String` | joined from the option | Facility's own wording (research §6) |
| `currency` | `CurrencyCode` | `.currency` | Must match the sale's |
| `reference` | `String?` | `.reference` | Required for card / transfer / cheque — `PaymentMethodOptionResponse.requiresReference` decides which (research §6, resolved) |
| `verifier` | `int?` | `.verifier` | Null ⇒ "pending validation" (display only) |
| `appliedAmount` | `String` | `.amount` (same field, the application's own) | What went to this sale |
| `changeAmount` | `String` | `.amountChange` | Excess handed back (FR-047) |
| `cancelled` | `bool` | `.cancelled` | A reversed application stays visible (research §11) |
| `paymentDate` | `DateTime` | `.paymentDate` | Distinct from `.date` (the application's own timestamp) whenever money is applied later than it was taken |

**Revised 2026-08-05**: no longer session-scoped. `GET /sales-orders/{id}/payments`
(research §11, resolved) returns every application against the sale, including
cancelled ones, each with its payment's fields already flattened on — this list
loads on every load of the payment step, resumed or not, with no
session-controller fallback and no explanatory note about missing history.

---

## 8. OpenSale (selector row)

From `GET /sales-orders?point_sale=<id>` (research §5, resolved — was
`facility` + `mine=true`, now scoped to the actual register).

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
| An open cash session exists | Client (`CurrentSession.state != none`), before `POST /sales-orders` is ever called | FR-002a (new, research §18) |
| Quantity `> 0` and `>= minOrderQty` | Server; surfaced on the field | FR-023, Edge Cases |
| Price within the margin band | Server (`assert_margin_in_range`); previous value restored on refusal | FR-009, Edge Cases |
| Discount rate `0 ≤ r ≤ 1` | Client input mask + server | FR-023 |
| Tax rate `0 ≤ r ≤ 1` | Client input mask + server | FR-023 (resolved, research §12) |
| At least one line before confirming | Client (button state) + server | FR-038 |
| No zero-priced line at confirmation | Server; offending lines identified | FR-039 |
| Sufficient stock at confirmation | Server; offending lines identified, sale stays editable | FR-039 |
| Credit terms need an available credit line | Server (`_assert_credit_allowed`) | FR-016 |
| Payment currency == sale currency | Server (`assert_same_currency`); prevented client-side | Edge Cases |
| Payment applied ≤ outstanding, excess is change | Client computes the split; server validates unapplied | FR-047 |
| Reference required for card / transfer / cheque | Server-computed (`PaymentMethodOptionResponse.requiresReference`), read directly — no client table (FR-045, research §6 resolved) | FR-045 |
| Balance zero before leaving the payment step | Client gate on `Sale.balance`, unless `paymentTerms == netD` | FR-049, FR-051 |
| Every unit distributed before closing a delivery sale | Client (`LineDistribution.isComplete`) | FR-035 |
| Destination line quantity ≤ still-undelivered | Server (`narrow_to_requested`, `422` naming the line and shortfall); client pre-check avoids an avoidable round trip | FR-032 |
| No line requested twice in one destination create | Server (`422`); client pre-check | FR-032 |
