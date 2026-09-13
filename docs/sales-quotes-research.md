# Sales Quotes Research & Design Foundation

**Status**: Pre-spec — foundation for a future `NNN-sales-quotes` feature
**Date**: 2026-09-12
**Audience**: whoever writes the spec, possibly in parallel with other in-flight work
**Sources**: mbe-api source (`app/`, `specs/011-sales-cycle-endpoints/`), the generated
OpenAPI client in this repo, legacy `mbe/docs/`, and the current mbe-ui sales feature

---

## 0. Executive Summary

A sales quote ("cotización") is a priced, non-binding offer to a **named** customer that,
once the customer accepts, becomes a sales order. This document is the research basis for
building that screen in mbe-ui.

Three findings dominate everything else:

1. **The backend is already finished.** `/api/v1/sales-quotes` is fully implemented in
   mbe-api — 11 endpoints including a native `POST /{id}/convert` that returns a
   `SalesOrderResponse` — and the dio client is **already generated** in this repo at
   `lib/generated/openapi/lib/src/api/sales_quotes_api.dart`. There is no mbe-api issue
   to file and nothing to wait for. This is unusual for this project: quotes are a
   **pure UI feature**. (§2, §3)

2. **The RBAC slot already exists and is unused.** `SystemObject.salesQuotes(30)` is
   declared in `lib/core/access/system_object.dart:42` and referenced nowhere else in
   `lib/`. No enum change, no privilege plumbing. (§7)

3. **The reuse the feature depends on is being built right now by spec 039.** Quotes want
   to be the *third host* of the point-of-sale capture step. Spec 039
   (`039-back-office-order-workspace`, spec+plan+research written, **not implemented**) is
   the feature that makes that step host-agnostic. Before 039, reusing capture means
   fighting eleven hardcoded POS call sites; after 039, it is mostly free. **This is a
   sequencing constraint, not a preference.** (§5)

The single largest design decision is not the screen — it is **whether the quote document
can share the `Sale`/`SaleLine` domain entities with sales orders**, because a quote's wire
shape is deliberately narrower in some places and wider in others. (§4)

---

## 1. What a Sales Quote Is

**Lifecycle**: draft → confirmed (folio assigned, read-only) → converted to a sales order.
Side branches: cancelled, expired, duplicated.

```
        ┌──────────── duplicate ──────────┐
        │                                 ▼
   [ draft ] ──confirm──► [ completed ] ──convert──► SalesOrder (draft)
        │                       │
        └────cancel────► [ cancelled ]  ◄──cancel────┘

   `has_expired` (due_date < now) is a SEPARATE boolean, orthogonal to status.
   An expired quote still reports status `completed` — but cannot be converted.
```

**Scope per the user's framing** (2026-09-12):
- Reuses the POS **capture** step.
- Targeted at real customers only — never "Público en General".
- Capture is the **only** step: no payment step, no delivery step.
- An accepted quote can be turned into a **back-office sale**.

---

## 2. API Surface (already generated, ready to call)

All under `/api/v1/sales-quotes`. Generated class: `SalesQuotesApi`.

| Verb | Path | Body | Response |
|---|---|---|---|
| GET | `` | — | `ListResponse[SalesQuoteSummary]` |
| POST | `` | `SalesQuoteCreate` | `SalesQuoteResponse` 201 |
| GET | `/{id}` | — | `SalesQuoteResponse` |
| PUT | `/{id}` | `SalesQuoteUpdate` | `SalesQuoteResponse` (409 if not editable) |
| POST | `/{id}/confirm` | — | `SalesQuoteResponse` — assigns folio |
| POST | `/{id}/cancel` | — | `SalesQuoteResponse` (409 if already cancelled) |
| POST | `/{id}/duplicate` | — | `SalesQuoteResponse` 201 — **re-prices from current price list** |
| POST | `/{id}/convert` | — | **`SalesOrderResponse` 201** |
| POST | `/{id}/lines` | `SalesQuoteLineCreate` | `SalesQuoteResponse` |
| PUT | `/{id}/lines/{lineId}` | `SalesQuoteLineUpdate` | `SalesQuoteResponse` |
| DELETE | `/{id}/lines/{lineId}` | — | `SalesQuoteResponse` |

Every line mutation returns the **whole quote**, exactly like sales orders — so the
existing "replace state wholesale, never recompute totals locally" pattern in
`SaleEditing` carries over unchanged.

**List query params**: `mine`, `customer`, `salesperson`, `status` (`draft`/`completed`/
`cancelled`), `search`, `skip`, `limit` (1–100, default 20).

**Privileges**: `SALES_QUOTES` READ/CREATE/UPDATE. `convert` **additionally** requires
`SALES_ORDERS` CREATE.

### 2.1 Server-side defaults on create

`SalesQuoteCreate` has **every field optional** — an empty body opens a draft on defaults:

| Field | Default |
|---|---|
| `customer` | `settings.default_customer_id` — **i.e. Público en General** ⚠ |
| `salesperson` | `customer.salesperson`, else the current employee |
| `payment_terms` | `IMMEDIATE` |
| `currency` | `settings.default_currency` |
| `due_date` | `date + settings.default_quotation_due_days` (**30**) |
| `serial` | `NULL` until confirm |

⚠ The customer default is the direct enemy of the "no Público en General" rule. The quote
**must** be opened with an explicit `customer`, never with an empty body. The existing
`SaleEditing.updateHeader` first-write fast path
(`lib/features/sales/presentation/sale_editing.dart:93-108`) already does exactly this for
orders — fold the first customer pick into the POST — and is the pattern to copy.

### 2.2 Totals and pricing

Totals are computed server-side on the fly from `price + price_adjustment` and never
stored. Line default price comes from the customer's price list; default quantity is
`product.min_order_qty`. Identical to sales orders.

---

## 3. Conversion: quote → back-office sale

`POST /sales-quotes/{id}/convert` already implements the user's requirement. It is not
something the UI has to assemble.

**What it carries over**: `facility`, `salesperson`, `customer`, `payment_terms`,
`contact`, `ship_to`, `comment`, `currency`, `exchange_rate`, and every line — with
`price = quote.price + quote.price_adjustment` folded into one number.

**What it sets fresh**: `sales_quote = <quote id>` (the origin FK), `point_sale` from the
caller, `date = now`, `promise_date`, `due_date`, `serial = NULL`, all status flags false,
`priority = NORMAL`, line `cost = 0`, line `warehouse = None`, `fulfillment_intent = None`
("a quote has no fulfilment intent to carry"), `customer_name = None`.

**The result is a *draft* order.** It still needs `POST /sales-orders/{id}/confirm`.

### 3.1 Four constraints the spec must handle

1. **Only confirmed quotes convert.** 409 — "Only a confirmed quote can be converted;
   confirm it first."
2. **Expired quotes cannot convert.** 409 — "Quote has expired and cannot be converted;
   duplicate it to re-quote." The UI should offer *Duplicate* directly from that refusal —
   it is the server's own suggested recovery, and `duplicate` re-prices from the current
   price list, which is the commercially correct behaviour.
3. **Cancelled quotes cannot convert.** 409.
4. **The caller must have a point of sale configured**, else **422** — "No point of sale is
   configured for your user." This is a live operational trap: back-office staff writing
   quotes are precisely the users least likely to be bound to a register. Verify against
   the target deployment's user set before release, in the same spirit as spec 039's R6
   deployment preconditions.

A quote may be converted **more than once**; each conversion yields an independent order
(mbe-api spec 011, Assumption 11). The UI should not assume one-to-one.

### 3.2 Where the converted order lands — the important part

The converted order is a draft with **`fulfillment_intent = null` and no `warehouse` on any
line**. A back-office order in this codebase is expected to end in a planned delivery
(spec 039 FR-015/FR-021), and every line needs a source warehouse before it can be
confirmed.

So conversion cannot simply drop the user on a finished order. It must hand off into the
back-office order workspace **at the Venta step**, so the user can set warehouses and then
plan delivery. That makes spec 039's workspace the natural landing target and reinforces
the sequencing in §5.

Two knock-on notes for whoever writes the spec:

- **Spec 039's interim origin guard admits the converted order** — its customer is real
  (not generic), its intent is `null` (not `counterPickup`), and it has no payments. So the
  guard as designed in `specs/039-back-office-order-workspace/research.md` R5 will let the
  workspace open it. Good, but confirm rather than assume.
- **mbe-api#209 (`SaleOrigin = pointOfSale | backOffice`) does not cover quote
  conversion.** `convert_to_order` (`sales_quote_service.py:501`) builds the `SalesOrder`
  directly at line 519 — it never goes through `POST /sales-orders` and takes no request
  body — so #209's proposed write path cannot reach it. Unless convert sets `origin`
  itself, **every converted order is `NULL` forever**. `convert` also stamps `point_sale`
  from the caller (`:508`), so a converted order looks like a register sale to any
  `point_sale`-based heuristic.

  **Raised on [mbe-api#209](https://github.com/mictlanix/mbe-api/issues/209#issuecomment-5648664474)**
  before it is implemented. Two workable shapes were put to the maintainer: a third
  `QUOTE_CONVERSION` enum member (which would then need set-filtering on
  `GET /sales-orders`), or two members with convert stamping `BACK_OFFICE` and
  `sales_quote` added to `SalesOrderSummary` — the latter recommended, since `origin`
  ("which surface raised this") and `sales_quote` ("what preceded it") are orthogonal
  facts. Either works for this feature; the load-bearing part is that convert must set
  `origin` explicitly.

### 3.3 `sales_order.sales_quote` is read-only on the wire

`SalesOrderResponse.sales_quote: int | None` exists and is backed by the legacy
`FK_sales_order_sales_quote`. It is **absent from `SalesOrderCreate` and
`SalesOrderUpdate`** — the *only* way to set it is the convert endpoint. The UI cannot
fake a link.

It is also **absent from `SalesOrderSummary`**, so the "Pedidos" list cannot show
"came from quote #123" without opening each order. If that badge is wanted, it is an
mbe-api request.

**Not currently mapped in this repo**: `Sale.fromResponse`
(`lib/features/sales/domain/entities/sale.dart:56`) does not read `sales_quote`. Adding it
is a one-line domain change with no codegen.

---

## 4. The crux: can quotes share `Sale` / `SaleLine`?

The capture step is built entirely on the freezed `Sale` and `SaleLine` entities, and
`Sale.fromResponse` is hardwired to `api.SalesOrderResponse`. Reusing the capture step
therefore means deciding how a `SalesQuoteResponse` becomes a `Sale`.

### 4.1 Header: quotes are a strict subset

| `Sale` field | On a quote? |
|---|---|
| `id, serial, facility, salesperson, customer, paymentTerms, currency, exchangeRate, contact, shipTo, comment, status, date, dueDate, lines, subtotal, taxTotal, total` | ✅ present |
| `pointSale, customerName, fulfillmentIntent, promiseDate, priority, recipient, recipientName, balance` | ❌ absent |
| `hasExpired` | ⚠ **quote-only — no home in `Sale`** |

The absences are benign (nullable, and the quote screen renders none of them). `hasExpired`
is the one genuinely new field.

Note that `customerName` — the free-text walk-in name — has no counterpart on a quote.
That is a small piece of evidence that the API already assumes quotes are for named
customers, consistent with the user's requirement.

### 4.2 Lines: quotes diverge in **both** directions

This is the sharp edge.

| Field | Order line | Quote line |
|---|---|---|
| `product, productCode, productName, quantity, price, discountRate, taxRate, taxIncluded, currency, exchangeRate, comment, subtotal, taxTotal, total` | ✅ | ✅ |
| `warehouse` | ✅ | ❌ **absent** |
| `unitOfMeasurement` | ✅ | ❌ absent |
| `photo` | ✅ | ❌ absent |
| `cost`, `availability` | ✅ | ❌ absent |
| `price_adjustment` | ❌ absent | ✅ **present** |
| `tax_rate` override on create | ✅ | ❌ absent (server-derived) |

Consequences for the shared capture surface:

- **The warehouse picker must be hideable.** `SaleLineRow` already has exactly this kind of
  per-host flag — `showComment` (`sale_line_row.dart:37`) — so `showWarehouse: false`
  follows an established precedent rather than inventing one.
- **Stock/shortfall warnings do not apply.** No warehouse means no availability; the
  advisory shortfall UI and `productStockCacheProvider` seeding should be skipped. Product
  lookup already accepts a null warehouse
  (`sales_orders_api.dart:764` — `int? warehouse`), so `GET /sales-orders/product-lookup`
  is reusable as-is for quotes; it is customer-scoped, which is what matters.
- **No unit of measurement or photo** on the line — the product cell degrades. Check what
  `SaleLineRow` does with a null `unit`/`photo` before assuming it is graceful.

### 4.3 The price-editing tension — flag this early

The shared line row renders price **read-only** by deliberate design. From
`sale_line_row.dart:229-232`:

> The price, shown but not writable (FR-038c). … A price that needs adjusting is adjusted
> through the discount.

But a **quote is the document where price negotiation happens**, and `price_adjustment` is
the legacy system's dedicated mechanism for a manual price override on a quote line. So the
one field quotes add is the one field the shared row refuses to edit.

**Recommendation**: for a first release, keep the read-only price and use `discount_rate`,
sending `price_adjustment` as 0. It keeps the shared row untouched, stays consistent with
orders, and loses nothing functionally — `convert` folds `price_adjustment` into `price`
anyway, so any adjustment expressible one way is expressible the other. Record
`price_adjustment` as deferred rather than silently dropping it. If the business genuinely
needs an absolute markup, that is a separate, well-scoped follow-up.

---

## 5. Reuse and sequencing against spec 039

### 5.1 What is already shared

`sale_editor.dart` defines the seam:

- `abstract interface class SaleEditor` — 6 methods (`ensureOpen`, `updateHeader`,
  `addLine`, `updateLine`, `removeLine`, `confirm`)
- `saleEditorProvider` — which document is being edited (defaults to the register's sale)
- `saleWritesScopeProvider` — which pending-write / unconfirmed-edit gate applies

`CustomerBar`, `ProductSearchField`, `SaleLineRow`, `SaleLineCard`, `SaleTotalsBar` and the
`SaleLineEditing` mixin all read the seam and are already host-agnostic. A quote host would
provide a `QuoteEditorController` implementing `SaleEditor` plus a `quoteWritesScope`
string, installed via a nested `ProviderScope` — the pattern `order_screen.dart:49-58`
already demonstrates.

**Trap**: any new provider that reads the seam must carry
`@Riverpod(dependencies: [saleEditor])`, or it resolves against the root container and
writes to the register's sale. This is documented in 039's research and is not optional.

### 5.2 What is not yet shared

The **capture step itself** still hardcodes POS in eleven places — most damagingly
`capture_step.dart:61`, where `_addLine` writes to `posSaleControllerProvider` directly, and
`capture_step.dart:85`, where the forward action is hardwired to `advanceToCobro()`.

Spec 039 fixes exactly this. Its `contracts/shared-step-seam.md` specifies the target:

```dart
CaptureStep({
  required Sale? sale,
  required VoidCallback? onContinue,   // null disables the forward action
  required String continueLabel,
  bool showFulfillmentSelector = true,
})
```

The contract's own host table gains a third row:

| Host | `onContinue` | `continueLabel` | `showFulfillmentSelector` |
|---|---|---|---|
| Register | advance to Cobro | "Continuar al cobro" | `true` |
| Workspace | advance to Entrega | "Continuar a entrega" | `false` |
| **Quote** | **confirm the quote** | **e.g. "Confirmar cotización"** | **`false`** |

Note the quote host is the first whose forward action *ends* the document rather than
advancing to another step. `onContinue` is already just a callback, so this costs nothing —
but it is the reason a quote screen needs no step machine at all.

### 5.3 Sequencing — the one hard constraint

> **Quotes should be specified after spec 039 is implemented, or explicitly built on its
> contract.**

The user has noted this work may proceed in parallel with other specs. That is fine for
*writing* the spec, but the implementation order matters:

- **If 039 lands first**: quotes reuse `CaptureStep` by passing three parameters. Cheap.
- **If quotes land first**: quotes must either perform 039's eleven-call-site migration
  themselves — inheriting all of its register-regression risk — or carry a **third copy**
  of the capture body, which is the precise defect 039 was raised to eliminate.

If both are genuinely in flight at once, the quote spec should declare 039's
`contracts/shared-step-seam.md` as a **hard dependency** and write its tasks against that
signature, not against today's `CaptureStep`.

Also note both features touch the same files (`capture_step.dart`, `sale_editor.dart`,
`sale_line_row.dart`). Parallel branches will conflict there.

---

## 6. Excluding "Público en General"

Already solved; reuse it verbatim.

- **Representation**: a build-time sentinel id, not a flag on the customer record —
  `posDefaultCustomerId` (`lib/features/sales/pos_defaults.dart:30`,
  `int.fromEnvironment('POS_DEFAULT_CUSTOMER_ID', defaultValue: 1)`), mirroring mbe-api's
  server-only `settings.default_customer_id`.
- **The one shared predicate**: `AppSettings.isGenericCustomer(int customerId)`
  (`lib/core/config/app_settings.dart:99`).
- **The picker exclusion**: `CustomerBar(excludeGenericCustomer: true)` filters it out of
  search results (`customer_bar.dart:595`) and suppresses the default-customer fallback
  (`customer_bar.dart:218-222`).

Precedent to mirror: spec 036 applied this to the back-office order screen — product search
is **absent** (not merely disabled) until a real customer is chosen, and confirm stays
disabled (`orders/order_screen.dart:235-268, 319-327`). Spec 039 FR-011/FR-012 restates it.

Two quote-specific additions:
- The **server default is the generic customer** (§2.1), so the client gate is not enough on
  its own — the quote must never be opened without an explicit customer.
- The quote **list** should be checked too: quotes created before this screen existed, or by
  another client, could carry the generic customer. Decide whether those are read-only,
  hidden, or simply allowed.

---

## 7. RBAC, routing, navigation

- **SystemObject**: `salesQuotes(30)` — already declared, currently unused. No enum change.
- **Route gate**: `PrivilegeGate(SystemObject.salesQuotes, AccessRight.read)`, matching the
  pattern in `lib/core/navigation/nav_destinations.dart`.
- **Convert action** must additionally check `can(SystemObject.salesOrders, Create)` —
  mirroring the server, which enforces both.
- **Nav destination**: a new stable int id appended last, per the convention documented at
  `nav_destinations.dart:43-56` (display order comes from position in `kNavigationTree`, not
  from the id).
- **Routes**: `/sales/quotes`, `/sales/quotes/new`, `/sales/quotes/:quoteId` — parallel to
  the existing `/sales/orders` family in `app_router.dart:295, 404-425`.

---

## 8. Gaps and divergences worth knowing

### 8.1 `SalesQuoteSummary` has no customer name

`SalesOrderSummary` carries `customerName` **and** `customerDisplayName`
(`sales_order_summary.dart:42,46`). `SalesQuoteSummary` carries only a bare
`int customer` (`sales_quote_summary.dart:36`).

A quote list therefore cannot render customer names without an N+1 fetch per row — and
unlike the POS sales list, dedup does not help, because a quote list is *all* distinct
customers (quotes are never for the walk-in customer). Given that a quote list is
*primarily* browsed by customer, this is a real gap.

**Filed upstream as [mbe-api#213](https://github.com/mictlanix/mbe-api/issues/213)**,
covering this and §8.2 together — they are the same join. Precedent: #172 did this for
`SalesOrderSummary`, #173/#174 for `CustomerPaymentSummary`; quotes are the third list of
the same shape and the only one still missing it.

### 8.2 Quote search is numeric-only

mbe-api's `search` param on the quote list matches **id or serial only**
(`sales_quote_service.py:254-255`), and there is **no `else` branch** — a non-numeric term
is not applied at all, so the query returns the **full unfiltered page**. Typing `Acme`
returns every quote in the facility, which reads as "these are all quotes for Acme". A
filter that silently widens is worse than one that finds nothing.

Legacy searched quotes by customer name and salesperson nickname
(`mbe/docs/specs/02-sales.md` §2). Combined with §8.1, finding "that quote for Acme" is not
currently possible server-side.

**Filed upstream as part of [mbe-api#213](https://github.com/mictlanix/mbe-api/issues/213).**
Until it ships, filter by `customer` instead — which requires picking the customer first,
and is consistent with the customer-first framing of this feature.

### 8.3 No print / PDF / email

Legacy quotes had **Print/PDF** and **Send Email with PDF attachment**
(`mbe/docs/specs/02-sales.md:83-87`). mbe-api's spec 011 Assumption 2 explicitly puts
document rendering out of scope, and **no endpoint exists**.

This repo also has **no `printing` dependency and no PDF code** at all. Constitution VII
requires PDF generation to stay server-side, so mbe-ui cannot fill this gap locally.

This matters more for quotes than for any other document: **a quote's whole purpose is to be
sent to a customer.** A quote screen that cannot produce a shareable document is
functionally incomplete from the salesperson's point of view — even though everything else
works. Call this out in the spec as a known limitation with an upstream dependency, rather
than discovering it at demo time.

### 8.4 Rules present in legacy, not ported to mbe-api's quote service

- **Price-range / profit-margin validation** (`PriceValidationInRangeRequired`,
  `low_profit_margin`/`high_profit_margin`) — not enforced on quotes.
- **Credit check for `NET_D` terms** (legacy required `customer.HasCredit`) — not enforced
  on the quote path.

Neither blocks the UI. Both are worth noting in case the business expects them; a quote is
an unusually easy place to promise a price the company will not honour.

### 8.5 Folio timing diverges from legacy — intentional

Legacy assigned `serial` on **create**. mbe-api assigns it on **confirm**, matching orders
and refunds, so abandoned drafts leave no gaps. So a draft quote has **no folio** and needs
the same provisional-reference treatment `Sale.provisionalReference` already gives orders.

---

## 9. Open Design Questions

**Q1 — Is the customer a gate on one step, or a step of its own?** *(the biggest one)*

The user said capture "will be the only step". That clearly rules out payment and delivery
steps. It is ambiguous about the customer, which must still be chosen and must not be the
generic one.

- **(a) One step**, customer as a `CustomerBar` gate — matches the user's words literally
  and mirrors today's `OrderScreen` (spec 029/036).
- **(b) Two steps**, `Cliente → Cotización` — mirrors spec 039, which is *replacing*
  pattern (a) precisely because a gate-on-one-screen reads as a dead end.

Building (a) while 039 deletes (a) next door is the kind of inconsistency worth resolving
before either ships. Worth an explicit clarification with the user.

**Q2 — Where does the user land after converting?** §3.2 argues for the back-office order
workspace at the Venta step, since warehouses and delivery are still owed. Confirm.

**Q3 — Should the quote screen show `hasExpired` prominently, and what happens on reopening
an expired quote?** It is still `completed` and still readable, but it is a dead end until
duplicated. Suggest a banner plus a direct *Duplicate* action.

**Q4 — Is `price_adjustment` needed in v1?** §4.3 recommends no, using `discount_rate`
instead. Needs a business answer, not a technical one.

**Q5 — What is the default `due_date` in the UI?** The server applies +30 days. Is that
editable on the quote screen, and is 30 right for this deployment?

**Q6 — Does anything link *back* from an order to its quote?** `sales_order.sales_quote` is
on the detail response but not the summary (§3.3). Is a "from quote #N" link on the order
screen wanted?

**Q7 — Are quotes scoped to the current user by default?** The list supports `mine`; legacy
defaulted to the current user's own quotes with a `*` wildcard for all. Match legacy, or
show all?

---

## 10. Suggested Spec Shape

Priorities reflect that conversion is the feature's commercial reason to exist, but is
worthless without capture.

- **P1 — Write a quote for a named customer.** New quote → pick customer (generic excluded)
  → add lines → confirm → folio assigned, read-only.
- **P1 — Convert an accepted quote into a back-office sale.** Convert → land in the order
  workspace at Venta → warehouses → delivery. Includes the three 409s and the 422.
- **P2 — Browse and resume quotes.** List with status facet and customer filter; reopen a
  draft; cancel.
- **P3 — Duplicate a quote.** The recovery path for expired quotes, and re-quoting in
  general. Re-prices from the current price list.

**Explicitly out of scope**: payment, delivery, print/PDF/email (§8.3), `price_adjustment`
(§4.3, pending Q4).

**Dependencies**: spec 039's `contracts/shared-step-seam.md` (§5.3) — hard.
**Upstream issue filed**: [mbe-api#213](https://github.com/mictlanix/mbe-api/issues/213) —
`customer_display_name` on `SalesQuoteSummary` + quote search by customer name (§8.1, §8.2).
Not a build blocker: the P1 stories do not depend on it, but the P2 list story is degraded
until it ships.
**Raised upstream**: origin semantics for quote-converted orders, on
[mbe-api#209](https://github.com/mictlanix/mbe-api/issues/209#issuecomment-5648664474)
(§3.2). Awaiting the maintainer's decision; it shapes how conversion is detected but does
not block the P1 stories.

---

## 11. Reference Map

**In this repo**
- `lib/generated/openapi/lib/src/api/sales_quotes_api.dart` — the 11 generated methods
- `lib/generated/openapi/lib/src/model/sales_quote_*.dart` — all 8 quote models
- `lib/core/access/system_object.dart:42` — `salesQuotes(30)`
- `lib/features/sales/presentation/sale_editor.dart` — the reuse seam
- `lib/features/sales/presentation/sale_editing.dart` — shared mutation bodies
- `lib/features/sales/presentation/capture/` — the capture step and its widgets
- `lib/features/sales/domain/entities/sale.dart`, `sale_line.dart` — the shared entities
- `lib/core/config/app_settings.dart:99` — `isGenericCustomer`
- `lib/features/sales/pos_defaults.dart:30` — `posDefaultCustomerId`
- `specs/039-back-office-order-workspace/contracts/shared-step-seam.md` — the target contract
- `specs/036-live-testing-fixes/spec.md` FR-001…FR-004 — the generic-customer exclusion rules

**In mbe-api**
- `app/api/v1/endpoints/sales_quotes.py`, `app/services/sales_quote_service.py`
- `app/schemas/sales_quote.py`, `app/models/sales.py`
- `specs/011-sales-cycle-endpoints/` — spec of record (FR-030…FR-034)

**In legacy mbe**
- `docs/specs/02-sales.md` §2 — the quotations module
- `docs/data-dictionary.md` §6 — `sales_quote`, `sales_quote_detail`
