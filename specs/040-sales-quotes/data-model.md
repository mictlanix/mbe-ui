# Phase 1 Data Model: Sales Quotes

**Feature**: `040-sales-quotes` | **Date**: 2026-09-20

No new document entity is introduced. A quote is carried by the existing `Sale`/`SaleLine`
pair, widened so that order-only fields can be absent. The reasoning is in
[research.md](./research.md) R2; this file records the resulting shape.

---

## 1. Widened: `Sale`

`lib/features/sales/domain/entities/sale.dart`

| Field | Today | Becomes | Why |
|---|---|---|---|
| `pointSale` | `required int` | `int?` | A quote is raised by a person, not a register. **Must** be nullable rather than filled — `capture_step.dart:189` feeds this to a real point-of-sale fetch (research R1b). |
| `promiseDate` | `required DateTime` | `DateTime?` | A quote promises nothing; delivery is planned on the order a conversion produces. |
| `priority` | `required Priority` | `Priority?` | Order-only concept. |
| `balance` | `required String` | `String?` | A quote is not payable. Null is the compile-time guard that keeps it out of the payment surface. |
| *(new)* `hasExpired` | — | `@Default(false) bool` | Quote-only. Orthogonal to `status`: a quote can be `completed` **and** expired. |

Everything else is unchanged. `id`, `serial`, `facility`, `salesperson`, `customer`,
`paymentTerms`, `currency`, `exchangeRate`, `shipTo`, `contact`, `comment`, `status`, `lines`,
`subtotal`, `taxTotal`, `total`, `date`, `dueDate` all exist on both documents.
`customerName`, `fulfillmentIntent`, `origin`, `recipient`, `recipientName` are already
nullable and are simply never set for a quote.

**New getter**: `String get balanceOrZero => balance ?? '0';` — used by the ten payment-surface
sites, so the assumption "an order always has a balance" is asserted once, with a comment,
instead of ten times as an anonymous `??`.

**New factory**: `Sale.fromQuoteResponse(api.SalesQuoteResponse r)` alongside the existing
`Sale.fromResponse`. Leaves the four order-only fields null, sets `hasExpired`, and maps lines
through `SaleLine.fromQuoteLineResponse`.

### Status

Quotes reuse `DocumentStatus` on the wire, so `SaleStatus` maps unchanged. A quote reaches
three of its four values:

| `SaleStatus` | On a quote | Meaning |
|---|---|---|
| `draft` | ✅ | Editable. No folio. |
| `completed` | ✅ | Confirmed. Folio assigned. Read-only. Convertible **unless** expired. |
| `paid` | ❌ never | — |
| `cancelled` | ✅ | Terminal. |

`Sale.isEditable => status == draft` already gives a confirmed quote a read-only capture
surface through `capture_step.dart:167`. `Sale.isPaid` is never true for a quote and is not
read by any capture widget.

---

## 2. Widened: `SaleLine`

`lib/features/sales/domain/entities/sale_line.dart`

| Field | Today | Becomes | Why |
|---|---|---|---|
| `cost` | `required String` | `String?` | Absent on quote lines. **Zero readers** anywhere in `lib/` — the only mention is the mapping itself. |
| *(new)* `priceAdjustment` | — | `String?` | Quote-only absolute markup. **Read-only in v1** (spec A3): mapped in, displayed nowhere, never written. Present so the value survives a round trip rather than being silently dropped. |

`unit`, `photo`, `warehouse`, `comment`, `availability` are already nullable and are simply
absent on a quote line. `availability` is not mapped for either document — it is joined by the
UI from the stock cache.

**New factory**: `SaleLine.fromQuoteLineResponse(api.SalesQuoteLineResponse r)`.

---

## 3. New: `SalesQuoteSummary` (list row)

`lib/features/sales/domain/entities/sales_quote_summary.dart`

`OpenSale` cannot be reused: it requires `balance`, which `SalesQuoteSummary` does not carry,
and it has no `hasExpired`.

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | `salesQuoteId` |
| `serial` | `int?` | Null until confirmed (FR-022) |
| `customer` | `int` | |
| `customerDisplayName` | `String?` | Joined server-side (mbe-api#213). Null only if the customer row is gone. |
| `salesperson` | `int` | |
| `date` | `DateTime` | |
| `dueDate` | `DateTime` | Expiry |
| `currency` | `Currency` | |
| `status` | `SaleStatus` | |
| `hasExpired` | `bool` | Rendered as a **separate marker**, never folded into the status chip (FR-024, FR-037) |
| `total` | `String` | |

Plus `SalesQuotePage { List<SalesQuoteSummary> items; int total; }`, mirroring `OpenSalePage`.

---

## 4. New: `SalesQuotesFilter` (UI-only, URL-backed)

`lib/features/sales/presentation/quotes/sales_quotes_list_controller.dart`

| Field | Type | URL facet |
|---|---|---|
| `search` | `@Default('') String` | `q` |
| `status` | `SaleStatus?` | `status` |
| `customer` | `int?` | `customer` |
| `salesperson` | `int?` | `salesperson` |
| `pageIndex` | `@Default(0) int` | `page` |

With a `fromQuery(ListQuery)` factory and an extension carrying `activeFilterCount` /
`hasActiveFilters` (search excluded from the count, per the house convention).

**Deliberately absent**: any date field, and therefore the `today` parameter the orders filter
carries. The endpoint has no date range (research R5). This removes the infinite-refetch hazard
rather than introducing one — but the rule that produced it still binds any future facet:
**never put a `DateTime.now()` inside a value used as a Riverpod family key.**

---

## 5. State transitions

Server-owned. The client offers an action only when the document's own state allows it; the
server is the authority and its refusal is surfaced (research R4).

```
              ┌──────────────── duplicate ─────────────────┐
              │  (from any state, yields a NEW draft)      ▼
   [ draft ] ──confirm──► [ completed ] ──convert──► SalesOrder (draft, back-office origin)
       │                        │
       └────── cancel ──────► [ cancelled ]  ◄────── cancel ──────┘

   hasExpired is a SEPARATE boolean, not a state.
   completed + expired  →  convert refused; duplicate offered instead.
```

| Action | Offered when | Server refusal |
|---|---|---|
| Edit header / lines | `status == draft` **and** `salesQuotes/update` | 409 if not editable |
| Confirm | `draft`, `lineCount > 0`, no outstanding write | — |
| Cancel | `draft` or `completed`, and not already cancelled | 409 if already cancelled |
| Duplicate | any state | — |
| Convert | `completed` **and** `!hasExpired` **and** `salesOrders/create` | 409 (draft / cancelled / expired), 422 (no point of sale) |

**FR-029's recovery is driven by `hasExpired`, not by the error text.** All four convert
refusals arrive as `ServerError(409, prose)` and are distinguishable only by matching prose,
which this codebase avoids. The screen already knows the quote is expired, so it offers
Duplicate from that fact — correct even if the server's wording changes (research R4).

---

## 6. Which step a reopened quote resumes on

There is no step to resume. The quote screen is **one step** (spec A1): the customer band and
product capture on a single surface. A reopened quote renders according to `status` alone:

| `status` | Renders |
|---|---|
| `draft` | Editable. Customer band in facts mode (a customer is always attached). |
| `completed` | Read-only. Convert offered unless expired; duplicate and cancel offered. |
| `cancelled` | Read-only. Duplicate offered. |

A *new* quote (`sale == null`) opens with the customer band in **search** mode and product
capture withheld — `CaptureStep`'s existing behaviour under `excludeGenericCustomer: true`
(`capture_step.dart:176, 184`).

---

## 7. Validation rules, and where each is already enforced

| Rule | Source | Enforced by |
|---|---|---|
| Customer required; never the generic walk-in | FR-005, FR-007, FR-008 | `AppSettings.isGenericCustomer`; `CaptureStep(excludeGenericCustomer: true)` — both the picker filter and the default-customer suppression |
| Nothing written before a customer is chosen | FR-006 | `CaptureStep`'s `canCaptureProducts` gate + `updateHeader`'s first-write fast path |
| Quote opens carrying its customer | FR-009 | The fast path → one `POST /sales-quotes` with `customer` |
| No warehouse on a quote line | FR-014 | `showWarehouse: false` (new, research R1) |
| No stock or shortfall warning | FR-015 | Same flag: the stock cache is not seeded, so `shortfall()` returns null |
| No fulfilment mode, payment or delivery | FR-016 | `showFulfillmentSelector: false`; no such steps exist on this host |
| Totals never recomputed locally | FR-017 | `SaleTotalsBar` reads the server's figures; every mutation replaces state wholesale |
| At least one line before confirming | FR-018 | `onContinue == null` when `lineCount == 0` |
| No write outstanding, no unconfirmed edit | FR-019 | `pendingWritesProvider(salesQuoteWritesScope)`, `resolveUnconfirmedEdits` |
| Header shows reference, status, expiry, currency and comment; expiry and comment editable while draft, currency never (A11) | FR-020, FR-022, FR-024 | `QuoteHeaderPanel`, rendered through `CaptureStep`'s `headerExtra` slot — the same seam `OrderHeaderPanel` uses. Customer and payment terms are not duplicated there; `CustomerBar` already owns both |
| Confirmed/cancelled quote is read-only | FR-023 | `Sale.isEditable`; plus `showAction: false` so the primary action is absent, not greyed |
| Folio only on confirm | FR-021, FR-022 | **Server**; `Sale.provisionalReference` covers the draft |
| Convert requires order-create rights | FR-004 | `can(salesOrders, create)` client-side; **server** enforces it too |
| Convert refusals | FR-028 – FR-030 | **Server** 409/422, surfaced through `ErrorBanner` with its own message (research R4) |
