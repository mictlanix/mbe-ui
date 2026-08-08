# Contract: mbe-api calls consumed by the Point of Sale

**Feature**: `020-point-of-sale` | **Client**: `lib/generated/openapi` |
**Revised**: 2026-08-05 — regenerated after mbe-api PR #139 shipped all 8 gaps
this document originally tracked (§5). Every call below was re-verified
directly against the current generated client, not assumed from the prior
revision.

Every call below is present in the checked-in generated client. The
preconditions are enforced server-side; the screen must respect them because
violating one returns a 409/422 the cashier cannot act on.

---

## 0. Cash session — `CashSessionsApi` (021-cash-sessions, reused)

### `GET /api/v1/cash-sessions/current` — the precondition for everything below

- **Returns**: `CurrentSessionResponse { state: 'none'|'open'|'stale', session: CashSessionResponse? }`.
- **Called**: before anything else, on entering `/sales/pos` (research §18).
- **`state == 'none'`**: no sale is opened. The screen shows the gate instead.
- **RBAC**: `pos:read`.
- This feature adds no new calls here — `lib/features/sales/domain/repositories/cash_session_repository.dart`
  and `currentSessionControllerProvider` (021) are reused directly.

---

## 1. Sales order — `SalesOrdersApi`

### `POST /api/v1/sales-orders` — open a sale

- **Precondition**: a current cash session exists (§0) — enforced client-side,
  not by this endpoint itself.
- **Body**: `SalesOrderCreate`. **Every field is optional**; an empty body opens
  a draft on the caller's configured defaults (point of sale, facility,
  salesperson, default customer, currency, payment terms).
- **Returns**: `SalesOrderResponse` (status `draft`, `serial` null).
- **Called**: on entering the screen with no sale selected, once §0 passes (FR-002).
- **RBAC**: `pos:create` (research §14/§18 — not `salesOrders:create`; this is
  the screen-level "open a register sale" action, matching legacy's own `POS`
  (44) module privilege and 021's precedent for gating a POS-adjacent open
  action).

### `PUT /api/v1/sales-orders/{id}` — header changes

- **Body**: `SalesOrderUpdate` — `customer`, `salesperson`, `paymentTerms`,
  `currency`, `promiseDate`, `contact`, `shipTo`, `recipient`, `customerName`,
  `priority`, `comment`.
- **Precondition**: draft. After confirmation **only `priority` is accepted**;
  anything else is refused.
- **Failure modes**: `422` when credit terms are chosen for a customer without
  an available credit line; `404` for an unknown customer.
- **Used for**: customer change (FR-012), payment terms (FR-016), currency, and
  `shipTo` — which is how the fulfilment mode is persisted (research §4).
- **Repricing (resolved, research §17)**: when `customer` actually changes
  (not merely echoed back unchanged), every existing line is unconditionally
  re-priced against the new customer's price list, in the same response — no
  separate call, no client-side arithmetic, no notice needed (FR-015).
- **RBAC**: `salesOrders:update`.

### `POST /api/v1/sales-orders/{id}/lines` — add a line

- **Body**: `SalesOrderLineCreate` — `product` (required), `quantity`, `price`,
  `discountRate`, `taxRate`, `warehouse`, `comment`.
- **Omit `price`** to take the customer's price-list price; omit `quantity` to
  take the product's minimum order quantity; **omit `taxRate`** to take the
  product's own rate (resolved, research §12).
- **Returns**: the **whole** `SalesOrderResponse` — this is what lets one
  notifier own the sale (research §1).
- **Failure modes**: `422` margin violation on a manual price; `422` quantity
  below the minimum; `404` unknown product; `409` order not editable.
- **RBAC**: `salesOrders:update`.

### `PUT /api/v1/sales-orders/{id}/lines/{lineId}` — edit a line

- **Body**: `SalesOrderLineUpdate` — `quantity`, `price`, `discountRate`,
  `taxRate`, `warehouse`, `comment`. `taxRate` bounded `0–1`.
- **Returns**: the whole order.

### `DELETE /api/v1/sales-orders/{id}/lines/{lineId}` — remove a line

- **Returns**: the whole order. **Precondition**: draft.

### `POST /api/v1/sales-orders/{id}/confirm` — end capture

- **Assigns the folio, commits stock, freezes the document — one transaction.**
- **Failure modes** that the capture step must render on the offending lines:
  - `409 {message: "Order has lines priced at zero", lines: [...]}`
  - `409 {message: "Insufficient stock", lines: [...]}`
  - `409` "Cannot confirm an order with no lines"
- **Called**: on "Continuar al cobro" (FR-038, FR-039).

### `GET /api/v1/sales-orders/product-lookup` — scan and search

- **Query**: `pattern` (required, min length 1), `customer` (required),
  `warehouse` (optional).
- **Returns**: `List<ProductLookupResponse>` with per-warehouse `onHand` and
  `available`.
- **Called**: on every scan and search (FR-020, FR-021), and to refresh a line's
  availability indicator.

### `GET /api/v1/sales-orders` — the open-sales selector

- **Query used**: `pointSale=<id>`, `status`, `skip`, `limit`. Facility scoping
  is automatic.
- **Revised (resolved, research §5)**: was `facility` + `mine=true`, an
  approximation of "sales at this register." `pointSale` now scopes exactly.
- **Called**: three times — `status=draft`, `status=completed`, `status=paid`
  (the last client-filtered to an incomplete `LineDistribution`) — to build the
  selector (US3, FR-058).

### `GET /api/v1/sales-orders/{id}` — resume

- **Returns**: the full order with lines and derived totals. The screen decides
  which step to open from `status` and `shipTo` (research §4).

### `GET /api/v1/sales-orders/{id}/payments` — resume's applied-payments panel

- **Returns**: `List<OrderApplicationResponse>` — every application against
  the order, cancelled ones included, each with its payment's `method`,
  `currency`, `reference`, `paymentDate`, `paymentType`, `verifier` already
  joined on.
- **New, resolved (research §11)**: was unavailable; the payment step
  session-scoped its own list as a stopgap. **That stopgap is deleted.** This
  call loads on every payment-step entry, resumed or not.
- **RBAC**: `customerPayments:read` — payment data, not `salesOrders`.

---

## 2. Delivery orders — `DeliveryOrdersApi`

### `POST /api/v1/delivery-orders` — create a destination, complete, in one call

- **Body**: `DeliveryOrderCreate` — `salesOrder` (required), `fulfillmentType`
  (`DELIVERY` for an address, `COUNTER_PICKUP` for the remainder), `shipTo`,
  `contact`, `date`, `comment`, and **`lines: [{salesOrderDetail, quantity}, ...]`**.
- **Resolved (research §3)**: `lines` **omitted** claims every quantity not
  yet covered by another delivery order for the sale — this is what the
  counter-pickup remainder create still relies on, unchanged. `lines`
  **supplied** claims exactly that named subset — this is new, and it is what
  every addressed destination now uses. **No trim step. No serialization
  constraint.** Destination *n+1* can be created immediately after
  destination *n*, in parallel if the UI wants to.
- **Preconditions**: the sales order is `completed` and not cancelled; in
  deployments with `delivery_order_requires_paid_or_credit_sales_order`
  enabled, also paid or on credit terms. **Both are satisfied by
  construction**, because the delivery step runs after payment (spec D-002).
- **Failure modes**: `409` "Only a completed, uncancelled sales order can be
  delivered"; `409` "This sales order is already fully delivered" (no `lines`,
  nothing left — the expected signal that distribution is complete); `422`
  naming a specific line and its shortfall when a **named** subset over-claims,
  repeats a line, or names a line of another sale.
- **`fulfillmentType` is immutable after creation** — it is absent from the
  update body.

### `PUT /api/v1/delivery-orders/{id}` — address, date, contact, comment

- **Body**: `DeliveryOrderUpdate` — `date`, `priority`, `shipTo`, `contact`,
  `comment`. **Precondition**: `status == draft`.
- **`contact` is now a real, reachable id** (resolved, research §10) — no
  longer written into `comment` as a stopgap. `comment` goes back to being
  genuine free-text delivery instructions.
- Used for post-create edits only — the initial address/contact/date/comment
  are set in the same `POST` that creates the destination (§ above).

### `PUT /api/v1/delivery-orders/{id}/lines/{lineId}` — adjust a line after creation

- **Body**: `DeliveryOrderLineUpdate` — `quantity` (`> 0`).
- Still exists for editing an already-created destination; no longer part of
  the *creation* sequence.

### `DELETE /api/v1/delivery-orders/{id}/lines/{lineId}` — drop a line after creation

- Same scope change as above — an edit affordance, not part of creation.

---

## 3. Customer payments — `CustomerPaymentsApi`

### `POST /api/v1/customer-payments` — record the tender

- **Body**: `CustomerPaymentCreate` — `customer` (required), `amount` (`> 0`),
  `method`, `currency`, `paymentCharge` (the payment method option),
  `reference`, `date`, `paymentType`.
- The cashier's open cash session is attached server-side automatically —
  and, per this feature's own precondition (§0), one always exists by the
  time a payment can be recorded.

### `POST /api/v1/customer-payments/{id}/applications` — apply it to the sale

- **Body**: `ApplicationCreate` — `salesOrder`, `amount` (`> 0`),
  `amountChange` (default 0; change handed back on a cash tender, which does
  **not** consume the payment's unapplied amount).
- **Preconditions**: the order is `completed` and not cancelled ("Only a
  completed order can be paid; confirm it first"); same customer; **same
  currency**; the amount is within the payment's unapplied balance.
- **Always called immediately after the create** — the pair is one logical
  action (FR-046).

### `POST /api/v1/customer-payments/{id}/applications/{applicationId}/reverse`

- **Body**: `ReversalRequest` — `reason` (required, 1–500 chars).
- Backs FR-048. The reason is mandatory; the screen must ask for it.

---

## 4. Master data (existing repositories, extended)

| Need | Call | Note |
|---|---|---|
| Customer search and selection | `GET /customers` | Existing `CustomerRepository` |
| Create a customer | `POST /customers` | `code` is **required** (spec A-002) |
| A customer's addresses | `Customer.addresses` — **embedded** on `GET /customers/{id}` | Resolved, research §9. `CustomerRepository`/`Customer` entity need extending to map it — not done as of 2026-08-05 |
| A customer's contacts | `Customer.contacts` — **embedded** on `GET /customers/{id}` | Resolved, research §10. Same extension needed |
| Link an address/contact to a customer | `PUT /customers/{id}` with `addresses`/`contacts: [int]` | Replace-all, only for a collection actually sent — omit to leave links alone |
| Create an address | `POST /addresses` | Existing inline-create dialog; link via the customer update above |
| Create a contact | `POST /contacts` | **New** — no inline-create dialog exists yet; build mirroring the address one |
| Payment method options, incl. `requiresReference` | `GET /payment-method-options` | Facility-scoped; existing repository, entity needs the new field mapped |
| The facility's own address | `GET /facilities/{id}` → `.address` | Encodes counter pickup in `shipTo` |
| Cashier defaults | `GET /auth/me` → `settings` | Existing session provider |
| Current cash session | `GET /cash-sessions/current` | 021-cash-sessions, reused (§0) |

---

## 5. mbe-api issues — all shipped

Every capability this feature originally filed against mbe-api has shipped,
verified directly against source and the regenerated client (research.md, top
of file). Nothing is outstanding.

| # | Issue | Ask | Shipped in |
|---|---|---|---|
| 1 | [mbe-api#132](https://github.com/mictlanix/mbe-api/issues/132) | Customer addresses | `CustomerResponse.addresses` |
| 2 | [mbe-api#133](https://github.com/mictlanix/mbe-api/issues/133) | Contacts API | `/api/v1/contacts`, `CustomerResponse.contacts` |
| 3 | [mbe-api#134](https://github.com/mictlanix/mbe-api/issues/134) | Sale payments listing | `GET /sales-orders/{id}/payments` |
| 4 | [mbe-api#135](https://github.com/mictlanix/mbe-api/issues/135) | Writable line tax rate | `SalesOrderLineCreate/Update.taxRate` |
| 5 | [mbe-api#136](https://github.com/mictlanix/mbe-api/issues/136) | `point_sale` filter | `GET /sales-orders?point_sale=` |
| 6 | [mbe-api#131](https://github.com/mictlanix/mbe-api/issues/131) | Reprice on customer change | `update_order`'s `_reprice_lines` |
| 7 | [mbe-api#137](https://github.com/mictlanix/mbe-api/issues/137) | `requires_reference` flag | `PaymentMethodOptionResponse.requiresReference` |
| 8 | [mbe-api#138](https://github.com/mictlanix/mbe-api/issues/138) | Per-destination delivery create | `DeliveryOrderCreate.lines` |
