# Contract: mbe-api calls consumed by the Point of Sale

**Feature**: `020-point-of-sale` | **Client**: `lib/generated/openapi` (already
generated — no new codegen expected, parity re-verified before implementation
per research §15)

Every call below was verified present in the checked-in generated client. The
preconditions are enforced server-side; the screen must respect them because
violating one returns a 409 the cashier cannot act on.

---

## 1. Sales order — `SalesOrdersApi`

### `POST /api/v1/sales-orders` — open a sale

- **Body**: `SalesOrderCreate`. **Every field is optional**; an empty body opens
  a draft on the caller's configured defaults (point of sale, facility,
  salesperson, default customer, currency, payment terms).
- **Returns**: `SalesOrderResponse` (status `draft`, `serial` null).
- **Called**: on entering the screen with no sale selected (FR-002).
- **RBAC**: `salesOrders:create`.

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

### `POST /api/v1/sales-orders/{id}/lines` — add a line

- **Body**: `SalesOrderLineCreate` — `product` (required), `quantity`, `price`,
  `discountRate`, `warehouse`, `comment`.
- **Omit `price`** to take the customer's price-list price; omit `quantity` to
  take the product's minimum order quantity.
- **Returns**: the **whole** `SalesOrderResponse` — this is what lets one
  notifier own the sale (research §1).
- **Failure modes**: `422` margin violation on a manual price; `422` quantity
  below the minimum; `404` unknown product; `409` order not editable.

### `PUT /api/v1/sales-orders/{id}/lines/{lineId}` — edit a line

- **Body**: `SalesOrderLineUpdate` — `quantity`, `price`, `discountRate`,
  `warehouse`, `comment`. **No `taxRate`** (research §12).
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

- **Query used**: `mine=true`, `status`, `dateFrom`, `skip`, `limit`. Facility
  defaults to the caller's own. **There is no `pointSale` filter** (research §5).
- **Called**: twice — `status=draft` and `status=completed` — to build the
  selector (US3).

### `GET /api/v1/sales-orders/{id}` — resume

- **Returns**: the full order with lines and derived totals. The screen decides
  which step to open from `status` and `shipTo` (research §4).

---

## 2. Delivery orders — `DeliveryOrdersApi`

### `POST /api/v1/delivery-orders` — create a destination

- **Body**: `DeliveryOrderCreate` — `salesOrder` (required), `fulfillmentType`
  (`DELIVERY` for an address, `COUNTER_PICKUP` for the remainder).
- **Behaviour that governs the whole step**: the new order takes **every
  quantity not already covered** by a non-cancelled delivery order for that
  sale. The client then trims it (research §3).
- **Preconditions**: the sales order is `completed` and not cancelled; in
  deployments with `delivery_order_requires_paid_or_credit_sales_order` enabled,
  also paid or on credit terms. **Both are satisfied by construction**, because
  the delivery step runs after payment (spec D-002).
- **Failure modes**: `409` "Only a completed, uncancelled sales order can be
  delivered"; `409` "This sales order is already fully delivered" — the latter
  is the expected signal that there is nothing left to distribute.
- **`fulfillmentType` is immutable after creation** — it is absent from the
  update body.

### `PUT /api/v1/delivery-orders/{id}` — address, date, contact, comment

- **Body**: `DeliveryOrderUpdate` — `date`, `priority`, `shipTo`, `contact`,
  `comment`. **Precondition**: `status == draft`.
- **`contact` is unusable today** — no API exposes or creates contacts
  (research §10). Contact name and phone go into `comment` in a fixed format
  until that ships.

### `PUT /api/v1/delivery-orders/{id}/lines/{lineId}` — trim a line

- **Body**: `DeliveryOrderLineUpdate` — `quantity` (`> 0`).

### `DELETE /api/v1/delivery-orders/{id}/lines/{lineId}` — drop a line

- Used when a destination takes none of a product.

---

## 3. Customer payments — `CustomerPaymentsApi`

### `POST /api/v1/customer-payments` — record the tender

- **Body**: `CustomerPaymentCreate` — `customer` (required), `amount` (`> 0`),
  `method`, `currency`, `paymentCharge` (the payment method option),
  `reference`, `date`, `paymentType`.
- The cashier's open cash session is attached server-side **when one exists**; a
  payment does not require one (spec A-005).

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

### Not available

`GET /sales-orders/{id}/payments` does not exist — a sale's payments cannot be
listed back (research §11). The applied-payments panel is session-scoped.

---

## 4. Master data (existing repositories, unchanged)

| Need | Call | Note |
|---|---|---|
| Customer search and selection | `GET /customers` | Existing `CustomerRepository` |
| Create a customer | `POST /customers` | `code` is **required** (spec A-002) |
| Address search | `GET /addresses?search=` | **No `customer` filter** (research §9) |
| Create an address | `POST /addresses` | Existing inline-create dialog |
| Payment method options | `GET /payment-method-options` | Facility-scoped; existing repository |
| The facility's own address | `GET /facilities/{id}` → `.address` | Encodes counter pickup in `shipTo` |
| Cashier defaults | `GET /auth/me` → `settings` | Existing session provider |

---

## 5. mbe-api issues to file

Per constitution §III these are recorded as external dependencies; none is
patched from this repository, and none blocks P1.

| # | Ask | Unblocks | Stopgap until then |
|---|---|---|---|
| 1 | `GET /customers/{id}/addresses` + a link route | FR-031, FR-056 — picking *the customer's* addresses | Global address search |
| 2 | A contacts API (list/create, per customer) | FR-029, FR-031 — per-destination contact | Name and phone written into the delivery order's `comment` |
| 3 | `GET /sales-orders/{id}/payments` | Rebuilding the applied-payments panel on resume | Session-scoped list + balance with an explanatory note |
| 4 | (optional) writable `tax_rate` on a sale line | FR-023's tax treatment | Tax rate rendered read-only |
| 5 | (optional) `point_sale` filter on `GET /sales-orders` | A per-station open-sales list | `mine=true` + facility scoping |
