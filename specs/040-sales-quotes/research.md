# Phase 0 Research: Sales Quotes

**Feature**: `040-sales-quotes` | **Date**: 2026-09-20

Every unknown in the plan's Technical Context is resolved here. Findings are taken from the
current source — `main` as merged into this branch, with `039` and `041` landed — and from
mbe-api's own source, not from either spec's description of them.

The feature description makes quotes sound like a small feature: the server is finished, the
client is generated, the screen already exists in another host. That is true of the *screen*.
It is not true of the *document*. R2 is where the real work is.

---

## R1 — What the shared capture step still assumes about orders

**Decision**: add **one** parameter, `showWarehouse`, and use it to gate three things at once
— the picker, the stock cache seed, and the point-of-sale lookup. Do not add a parameter per
symptom.

`039` left `CaptureStep` host-agnostic in every respect except stock. Three findings, in
descending severity:

**(a) The warehouse picker is rendered unconditionally, and it writes.** `sale_line_row.dart`
places `_warehouseCell` (`:219-222`) at `:381` in the single-row layout and `:433` in the
two-row one, with no flag; `sale_line_card.dart:192` likewise. Tapping it calls
`update(warehouse:)` → `saleEditor.updateLine(warehouse:)`. The quote endpoints have no
`warehouse` field at all, so a quote host would either drop the write silently or send a
field the server rejects. This is a live violation of FR-014, not a cosmetic one.

**(b) `CaptureStep` resolves a default warehouse through the register.** `capture_step.dart`:

```dart
final pointSale = sale?.pointSale ?? ref.watch(registerPointSaleProvider);   // :189
final defaultWarehouse = pointSale == null
    ? const AsyncValue<int>.loading()
    : ref.watch(defaultWarehouseControllerProvider(pointSale));              // :190-192
```

and `_addLine` stamps the result onto every new line (`:132`). For a quote this is wrong twice
over: it consults the *signed-in user's own register* — which a back-office salesperson often
does not have — and it would write a warehouse onto a document that has no such column.

This is also why **filling `Sale.pointSale` with a sentinel is not a safe shortcut** (R2): a
fabricated id at `:189` becomes a real `pointSaleRepository.get()` for a register the quote
has nothing to do with, and its warehouse lands on every line.

**(c) `_addLine` seeds two root-scoped caches** (`:119-126`). The **stock** seed should be
skipped for quotes — it is the only thing that makes the picker's stock flag and `shortfall()`
meaningful. The **tax-rate** seed should be kept: `taxRateOptions`
(`sale_line_editing.dart:285-290`) needs it to offer the product's own rate, and without it a
fresh quote line offers only zero and its own rate.

**What `showWarehouse: false` touches** — the complete list, verified by grep:

| File | Line(s) | Change |
|---|---|---|
| `capture/capture_step.dart` | `:40-50` | declare the param |
| | `:119-121` | skip the stock-cache seed |
| | `:132` | pass `warehouse: null` |
| | `:189-192` | skip the point-of-sale / default-warehouse resolution entirely |
| | `:423-436` | forward to `SaleLineRow` / `SaleLineCard` |
| `capture/sale_line_row.dart` | `:32-48`, `:219-222`, `:381`, `:433` | declare, make the cell conditional, drop its gaps |
| `capture/sale_line_card.dart` | `:20-36`, `:192` | same |
| `capture/sale_line_layout.dart` | `:42`, `:141-187` | see below |

**The column budget is the easy thing to miss.** `saleLineSingleRowMinWidth = 950.0`
(`sale_line_layout.dart:42`) is documented at `:14-18` as the sum of fixed columns *including*
`warehouse 168`, and `SaleLineColumns` carries `warehouse` as a required field in both `floor`
(`:160`) and `comfortable` (`:171`). Hiding the column without touching this file leaves the
threshold 168–240 px too conservative, so a quote row drops to the two-row fallback at widths
where one row would fit. Not a crash — a silent layout regression against the spirit of the
row-layout rules. The plan tasks a second threshold and a `warehouse`-aware `SaleLineColumns.of`.

**Two smaller gaps in `CaptureStep`'s param surface**, both worth closing while there:

- `showAction` and `actionKey` are **not forwarded** to `SaleTotalsBar` (`:386-402`), though the
  bar supports both (`sale_totals_bar.dart:73-78`). Without forwarding, a confirmed (read-only)
  quote can only *disable* its primary action, leaving a greyed button with nothing to do.
  FR-023 wants it gone.
- `showComment` is not forwarded either, so the per-line comment `SaleLineRow` supports is
  currently unreachable through `CaptureStep`. Quotes want it (a quote line's comment is how a
  salesperson qualifies an offer). Cheap to add in the same pass.

**Already fine, no change needed**: `SaleTotalsBar` reads only `lines`, `subtotal`, `taxTotal`,
`total` and never `balance`/`status`/`pointSale`; `CustomerBar` reads only
`customer`/`customerName`/`paymentTerms`/`fulfillmentIntent`, and its `excludeGenericCustomer`
already does exactly what FR-005 and FR-007 need; `ProductSearchField` and
`productLookupController` take `int? warehouse` and omit the filter when null; the advanced
search path is host-agnostic by construction.

**Alternatives rejected**: a `stockAware` enum (three states where two suffice); hiding the
picker by passing `enabled: false` (still renders a dead control and still reserves 168 px);
leaving the picker and letting the quote repository drop the field (moves a lie into the data
layer, which this codebase keeps honest — every repository method's doc names its exact
endpoint and refusals).

---

## R2 — Can a quote be a `Sale`? (the crux)

**Decision**: **yes — relax five fields on `Sale`/`SaleLine` to nullable, and add
`hasExpired` and `priceAdjustment`.** Do not introduce a separate `Quote` entity, and do not
fill order-only fields with sentinels.

### Why a separate entity is not available

It looks like the clean answer, and this codebase does keep near-twins apart (`Sale` vs
`OpenSale`). But the seam forecloses it: `SaleEditor.ensureOpen()` returns `Future<Sale>`
(`sale_editor.dart:29`), `SaleEditing` types its state as `AsyncValue<Sale?>`, and every shared
widget takes `Sale`/`SaleLine` — `CustomerBar.sale`, `SaleLineRow.line`, `SaleTotalsBar.sale`,
`CaptureStep.sale`. A quote controller must implement `SaleEditor` to be installable as
`saleEditorProvider`, so its state **must** be `Sale?`.

A separate `Quote` entity therefore buys nothing unless the capture widgets are forked or
given a projection — and a projection reintroduces sentinels with a second source of truth
beside them. Both are strictly worse than widening the entity the seam already has.

### What actually has to change

| Field | Today | Becomes | Reader sites to fix |
|---|---|---|---|
| `Sale.pointSale` | `required int` | `int?` | **3** — `pos_workspace_screen.dart:231, 253, 277`. `capture_step.dart:189` is already null-safe. |
| `Sale.promiseDate` | `required DateTime` | `DateTime?` | **2** — `order_header_panel.dart:162, 410` |
| `Sale.priority` | `required Priority` | `Priority?` | **1** — `order_header_panel.dart:222` |
| `Sale.balance` | `required String` | `String?` | **11** — the POS payment surface (`payment_summary_panel.dart:53,63,66,67,88`; `payment_capture_pane.dart:110,112,119`; `payment_controller.dart:137,138`) and `foreign_order_guard.dart:49` |
| `SaleLine.cost` | `required String` | `String?` | **1** — `sale_line.dart:63`, the mapping itself. No reader anywhere. |
| — | — | `Sale.hasExpired` (`@Default(false) bool`) | new |
| — | — | `SaleLine.priceAdjustment` (`String?`) | new, read-only in v1 (spec A3) |

Counts verified by grep across `lib/` excluding generated and `.freezed`/`.g` files. Matches on
`OpenSale.balance` (`pos_sales_list_screen.dart:221`, `sale_workability.dart:31`) and
`OrderApplication.balance` (`customer_payment_repository_impl.dart:131`) are a different entity
and are **not** affected.

### The price, stated plainly

Four of the five fields cost seven edits between them and are unarguable. **`balance` costs
eleven, and ten of those are in the POS payment surface — the highest-consequence code in this
application, for a feature that has no payment step at all.** That is the real objection to
this decision and it deserves to be answered rather than waved past.

Two ways to avoid it were considered:

- *Keep `balance` required and have the quote mapper pass `total`.* Defensible — an unpaid
  document's balance is its total — and it touches nothing. **Rejected**: if a quote ever did
  reach the payment surface, it would quietly offer to collect money against a non-payable
  document. Nullability turns that from a silent behaviour into a compile error, which is
  exactly the trade worth making in this particular file set.
- *Keep `balance` required and pass `'0'`.* Same objection, and additionally asserts the
  document is settled.

**Mitigation**: add one documented getter, `String get balanceOrZero => balance ?? '0'`, and
use it at the ten payment-surface sites. Each becomes a one-token change, and the assumption
"an order always has a balance; only a quote does not" is asserted in exactly one place with a
comment, instead of ten `??` operators that each look like defensive noise.

### What already works unchanged

- `SaleStatus` maps from the same generated `DocumentStatus` quotes use — `draft`, `completed`,
  `cancelled` (a quote never reaches `paid`). No new status enum.
- `PaymentTerms` and `currencyFromApi`/`currencyToApi` are shared types on both schemas.
- `Sale.isEditable => status == draft` (`sale.dart:102`) already gives a confirmed quote a
  read-only capture surface via `capture_step.dart:167`.
- `Sale.provisionalReference` already covers FR-022's folio-less draft.
- `SaleLine.availability` is never mapped and never read; nothing to do.

`Priority` is not used by quotes at all and stays an order-only concept.

---

## R3 — How the quote controller reuses the editing machinery

**Decision**: extract the ~15 generic lines of `SaleEditing` into a `TrackedEditing` mixin;
write a parallel `QuoteEditing` against a new `SalesQuoteRepository`. Do not generify
`SaleEditing` over a repository interface, and do not branch on document type inside it.

`SaleEditing` (`sale_editing.dart`, 222 lines) splits cleanly:

- **Generic (~15 lines)**: the four abstract declarations (`ref` `:34`, `state` `:35-36`,
  `writesScope` `:41`), `tracked()` (`:84-85`), `openSale` (`:69-75`).
- **Sales-order-specific (~170 lines)**: `salesOrderRepositoryProvider` is hard-coded at five
  call sites (`:61, :102, :165, :190, :207`); `origin` (`:50`) has no quote counterpart;
  `updateHeader`'s `fulfillmentIntent`/`promiseDate`/`priority`/`recipient`/`customerName` and
  the line methods' `warehouse`/`taxRate` do not exist on the quote schemas.

Generifying over a repository interface would force that interface to be the *union* of both
documents' parameters, so `SalesQuoteRepository.addLine` would have to accept `warehouse` and
silently drop it — moving a lie into the data layer. Generifying over a type parameter does not
work either: the mixin has **no `on` clause** and depends on `state`'s type matching the
generated notifier base exactly, a fragility its own doc comment (`:18-27`) records.

`QuoteEditorController` mirrors `OrderEditorController` (67 lines) closely: `@riverpod`,
family-keyed on `int? quoteId`, autoDispose, `build` returning `null` for a new quote. It
**drops** `origin` (no such field on `SalesQuoteCreate`) and needs a distinct
`salesQuoteWritesScope` constant. Quote-only operations — `duplicate()`, `convert()` — sit
*outside* `SaleEditor`, following the precedent `OrderEditorController.cancel` sets
(`order_editor_controller.dart:54-55`: "no shared widget calls it, so it is not on
`SaleEditor`").

`duplicate()` and `convert()` both return a **different document** from the one the family is
keyed on, so neither may write `state`. Both return an id for the caller to navigate to —
`/sales/quotes/<new>` and `/sales/orders/<new>` respectively.

**One incidental finding, not this feature's to fix**: `SalesOrderRepository.cancel` returns
`void` and `OrderEditorController.cancel` (`:56-66`) issues a second `getById` to read the
state back, on the strength of a comment (`:59-61`) saying the endpoint returns nothing. The
generated client returns `Response<SalesOrderResponse>`; the impl discards it
(`sales_order_repository_impl.dart:215-223`). The quote repository should **not** copy the
extra round trip — quote `cancel` returns the quote and the state can be replaced directly.
The order-side redundancy is noted here and left alone (spec OS: not this feature's scope).

---

## R4 — Getting the server's refusals in front of the user

**Decision**: the quote repository must carry its own error mapper. This is the single
highest-risk omission in the feature.

The chain already works for the common case: `AuthInterceptor.onError`
(`auth_interceptor.dart:33-40`) attaches an `AppError` to every `DioException`;
`mapDioException` (`:44-64`) routes a **409** through its `default` arm to
`ServerError(statusCode: 409, message: detail)`; `_detailFrom` (`:76-84`) reads `detail` as a
string *or* as a map with a `message` key; `ErrorBanner` (`error_banner.dart:88-95`) prints the
server's own text under a localized headline for `ServerError`.

So **convert's four refusals display correctly with no new code** — provided the UI only needs
to *show* them. FR-028 – FR-031 ask for exactly that, plus one branch: FR-029 must offer
Duplicate when the reason is expiry. Since all four arrive as `ServerError(409, prose)`,
distinguishing them means matching prose — which `app_error.dart:29-32` explicitly calls out as
the thing to avoid.

**The resolution**: FR-029's recovery is offered from the **quote's own state**, not from the
error. The screen already knows `hasExpired`; when a convert fails *and* `hasExpired` is true,
offer Duplicate. No prose matching, and it stays correct if the server's wording changes.

**The trap**: `_fieldErrorsFrom` (`:86-100`) handles `detail` only as a *list*. A **422 whose
`detail` is a plain string** yields `AppError.validation(const [])` — **the message is
destroyed** and the user sees a bare "validation failed". `convert` creates a sales order, and
mbe-api runs credit checks on order creation (the changes noted in `039`'s plan), so a
plain-string 422 is reachable on exactly this path. The sales-order repository already defends
against this with `_toSalesOrderError` (`sales_order_repository_impl.dart:382-389`), which
recovers the message as `AppError.creditHold`. **The quote repository must implement the
equivalent**, scoped to `convert` (and `open`/`updateHeader`, which can also credit-check), and
deliberately *not* folded into the generic `_toAppError` — `:377-381` records why.

`convert`'s 422 for "no point of sale configured" (FR-030) lands the same way and is recovered
by the same mapper.

---

## R5 — The quotes list

**Decision**: copy the back-office "Pedidos" list, minus its date apparatus.

`sales_orders_list_screen.dart` + `sales_orders_list_controller.dart` is the right template
over the POS list: quotes are a back-office document gated on their own `SystemObject`, scoped
by facility rather than by register, and FR-036's customer facet is exactly the
`CatalogEntityPicker` pattern the orders list already uses (`screen:360-423`).

The shared infrastructure is uniform across ~20 screens and is used as-is: a `@freezed` filter
with a `fromQuery(ListQuery)` factory, derived state in an extension, a `@riverpod` controller
family keyed by the filter, `fetchClampedPage` → `CatalogPage<T>`, rendered through
`CatalogListStateView` → `DataTableView`, with the URL as the only source of truth.
`customers_list_controller.dart` (90 lines) is the smallest clean example.

**Where quotes must diverge**, from the generated signature
(`sales_quotes_api.dart:687-702`, params `mine, customer, salesperson, status, search, skip,
limit`):

- **No date range.** Drop `DateRangeFilterChip`, `isDefaultRange`, and the whole `today`
  parameter. This removes a hazard rather than adding one — the orders controller passes
  `today` explicitly precisely because a `DateTime.now()` inside a family key produces an
  unequal key on every rebuild and an infinite refetch loop (`controller:46-54`). Quotes cannot
  hit it. **The underlying rule still applies to any future facet.**
- **No `facility` parameter**, though FR-034 says "the facility's quotes". The server scopes by
  the caller's facility implicitly (`list_quotes` filters
  `SalesQuote.facility == current.facility_id`). Verified in mbe-api source; still listed as a
  live check in `quickstart.md` because the client cannot assert it.
- **No origin.** Quotes have no origin field; `041`'s scoping does not apply to this list.
- **`hasExpired` is a separate boolean from `status`** and must render as a distinct marker
  beside the status chip, not as a fifth chip colour (FR-024, FR-037).
- **`SalesQuoteSummary` has no `balance`**, so `OpenSale` cannot be reused — the list needs its
  own summary entity. It *does* now carry `customerDisplayName` (mbe-api#213), so rows render
  customer names with no N+1 fetch.

**Refresh after a mutation**: invalidate the family **bare** — `ref.invalidate(controllerProvider)`
— so every live instance re-runs under its own already-applied filter. This is the fix `041`
shipped for the cash-sessions list (`open_session_form_controller.dart:139-143`) and is the
pattern for quote confirm / cancel / duplicate.

---

## R6 — Routing, navigation, RBAC, localization

All four are mechanical, with one invariant that is easy to break.

**Routing** (`app_router.dart`) splits a feature across three places: the list is a
`StatefulShellBranch` inside `StatefulShellRoute.indexedStack` (orders at `:292-300`), while
`/new` and `/:id` are **top-level siblings outside the shell** (`:413-428`) so they render
full-screen with no nav rail. The gate is one prefix clause in `_routeGate` (`:634-641`).
`int.parse` — not `tryParse` — is the deliberate convention for the id param.

**The invariant**: `NavBranch`'s stable int (`nav_destinations.dart:12-57`, currently ending at
`salesOrders = 20`) must equal the destination's **positional index** among the shell's
branches. Two hand-maintained lists in lockstep; the only thing guarding them is a router test
asserting `shell.navigationShell.currentIndex == NavBranch.X`. Quotes append `salesQuotes = 21`
and a branch in the matching position. **Never renumber.**

Also: do **not** add quotes to `_convertedEntityListPaths` (`:509-524`) — that map is for
entities whose detail routes were deleted in favour of a record sheet, and an entry there would
hijack the live `/sales/quotes/:id` route.

**RBAC** — `SystemObject.salesQuotes(30)` already exists and is unreferenced. The house pattern
is **hidden, not disabled**: the orders list omits the create button entirely without create
rights (`sales_orders_list_screen.dart:92, 126-158`) and omits row Edit when
`canUpdate && editable` is false (`:255-267`), because the status chip already explains why.
Quotes map to: route `salesQuotes/read`; new-quote `salesQuotes/create`; row edit
`salesQuotes/update` **and** `status == draft`; **convert additionally `salesOrders/create`**
(FR-004), mirroring the server, which enforces both.

**Localization** — `app_en.arb` carries an empty `@key` metadata sibling per key, `app_es.arb`
does not; the app is pinned to `es-MX`. Naming is `<feature><Noun><Role>`. Generic keys already
exist and must be reused, not duplicated (`editActionTooltip`, `filtersButton`, `applyFilters`,
`retryButton`, `loadErrorTitle`, `filteredEmptyTitle`). Budget from comparable features
(spec 029 ≈ 42 keys, spec 038 ≈ 20): **≈ 35-45 keys** for a list plus an editor with convert,
duplicate, cancel and four refusal messages.

---

## R7 — Test strategy

Three tiers, matching the constitution's quality gates and this repo's existing layout
(everything under `test/`; live-backend tests are in `test/integration/`, not a top-level
`integration_test/`).

- **Unit** — the filter's `fromQuery` decode and badge maths (mirroring
  `sales_orders_filter_test.dart`); the controller's request shape; the repository's DTO→entity
  mapping, including the quote-only fields; and the error mapper from R4, which needs a test
  per refusal shape (plain-string 422, map-with-message 409, string 409).
- **Widget** — the list (columns, privilege × status row actions, facets round-tripping through
  the URL, the expired marker); the quote screen (customer gate, no warehouse column, no
  fulfilment selector, read-only when confirmed); and the router group, copied verbatim from
  `app_router_test.dart:939-1035` **including the branch-index assertion**, which is the only
  guard on the R6 lockstep invariant.
- **Integration** — one flow against a live mbe-api, discovering its fixtures at runtime as the
  existing flows do: create a quote for a named customer → add a line → confirm → convert →
  assert the resulting order carries the quote reference and back-office origin.

**Host isolation is the test that matters most.** `sale_editor_isolation_test.dart` (231 lines)
asserts that two hosts do not share a document, a write gate, or a confirm target — its own
comment calls the third group "the single most important test this feature adds". It is
**hardcoded pairwise** POS↔order; three hosts mean three pairs, and the override block
(`:166-173`) and `pumpBoth` (`:30-34`) both need generalizing.

While extending it, two gaps the `039` contract already requires but nothing asserts:
`saleConfirmErrorProvider` isolation, and `unconfirmedEditsProvider` scope isolation (only
`pendingWritesProvider` is covered).

**Fixture blocker**: `pos_test_harness.dart`'s `testSale()` (`:41-90`) hardcodes `pointSale`,
`balance`, `promiseDate`, `priority`, and `testLine()` hardcodes `cost` and `warehouse` — all
currently required. R2's nullability change makes a `testQuote()` / `testQuoteLine()` sibling
possible; without R2 the harness cannot express a quote at all.

---

## R8 — Two root-scoped caches are shared across all hosts

`productStockCacheProvider` and `productTaxRateCacheProvider`
(`capture/product_stock_cache.dart:14-30`) are plain, **root-scoped, non-family** `StateProvider`s
keyed only by product id. They are *not* part of the four-provider seam, so all hosts share
them: a product looked up at the register seeds a tax rate a quote's line-tax picker then
offers, and vice versa.

**Decision**: leave them shared, seed only the tax cache from a quote host (R1c), and document
the sharing as intended. The data is per-product and advisory, not per-document, so sharing is
correct rather than merely tolerable. Recorded here because a third host is the point at which
someone will reasonably ask, and because nothing currently tests it.

---

## Resolved: nothing is blocked

Every dependency this feature was specified against has shipped — the host-agnostic capture
step (`039`), `customer_display_name` and name search on the quote list (mbe-api#213), and the
order-origin field with conversion stamping back-office (mbe-api#209). No codegen is required:
the quote client is already generated and committed.

The two items that remain are **verification**, not blockers, and are in `quickstart.md`: that
the quote list is facility-scoped server-side (R5), and the live shape of convert's refusal
bodies (R4).
