# Phase 0 Research: Bulk Pricing Grid

**Feature**: `033-bulk-pricing-grid` | **Date**: 2026-08-29
**Revised**: 2026-08-29, after mbe-api#182–#185 landed (`98d3254`)

Everything below was verified against the working tree and the sibling
`mbe-api` / `mbe` checkouts on 2026-08-29. Line references are to that state.

> **Four findings were overtaken by the API landing** — §R5, §R6, §R7 and §R8
> each turned on a gap mbe-api has since closed. Each is kept with its
> original reasoning and a **Landed** block recording what replaced it: the
> reasoning is why the endpoints have the shape they do, and deleting it would
> leave the design looking arbitrary.

---

## R1. What is actually being replaced

`PricingScreen` (`lib/features/pricing/presentation/pricing_screen.dart`) serves
**two** routes from one widget:

| Route | Mode | Fate |
|---|---|---|
| `/pricing` | `standalone: false` — product picker above a `DataTableView` of that product's price rows | **replaced** by the grid |
| `/products/:productId/pricing` | `standalone: true` — own `Scaffold`/`AppBar`, picker hidden, `initialProductId` locked in | **kept unchanged** (spec CL-002, FR-028a) |

**Decision**: keep `pricing_screen.dart` as the standalone screen and delete only
its `!standalone` branch (the picker and the `Expanded` empty-state ladder). The
new grid is a **new screen** at `/pricing`. `pricing_controller.dart`,
`product_price_row.dart` and `pricing_validators.dart` all stay — they are the
standalone screen's machinery, and the grid does not reuse them (its unit of
display is a product row across many lists, not a list row for one product).

**Rejected**: making the grid a one-row special case of itself to serve both
routes. The standalone screen's job is "this product on every list", which is the
grid transposed; sharing would mean a column-per-list *and* row-per-list widget.

## R2. The shared table can carry the grid, with one addition

`DataTableView` (`lib/core/widgets/data_table_view.dart`) wraps `DataTable2` /
`PaginatedDataTable2`. Three properties matter here:

- **Columns are data, not literals** — `List<DataTableColumn<T>>` with
  `cellBuilder`, so a column per price list is built from the fetched list set at
  runtime. Nothing in the widget assumes a fixed column count.
- **Pagination is already correct** — `PaginatedDataTable2` is keyed by
  `pagination.pageIndex` (the post-mutation page-reset bug is already solved
  there) and `renderEmptyRowsInTheEnd: false` avoids the blank-row gap a short
  page would otherwise show.
- **Horizontal scroll is not wired up.** `DataTable2` accepts `minWidth`, which
  is exactly FR-006's "the grid's own region may scroll while the page does not";
  `DataTableView` never passes it.

**Decision**: add an optional `minWidth` pass-through to `DataTableView` and use
it from the grid. Per §VI ("implemented once, shared"), table sizing stays the
shared widget's business — the grid must not reach for `DataTable2` directly.

## R3. The focus hazard — and a corrected plan for it

A `TextField` built inside a `DataTableSource` row is rebuilt whenever the
controller's state changes. Holding the draft text in Riverpod state means a
rebuild per keystroke, and the field loses focus mid-typing. That much of the
original plan held.

**Correction (found during implementation, spec 033 Phase 3): `ConfirmableFieldController`
/ `ConfirmableTextField` (specs 030/031) is the wrong fit for the edit loop
itself.** Its `submit`/`flush` treat an unparseable or server-refused value as
a *discard*: the typed text is thrown away and a brief "reset" animation plays,
returning the field to the last accepted value. That is exactly backwards for
FR-009, which requires a rejected value to **stay on screen, flagged, with its
reason**, until the user corrects it — a persistent per-cell state, not a
field-local animation. Forcing the cell through that controller would mean
either fighting its `parse`-returns-`null` contract (which always discards) or
never actually calling it in the one path (invalid input) it exists to handle.

**Decision, corrected**: `PriceCell` (`lib/features/pricing/presentation/price_cell.dart`)
holds a plain `TextEditingController` + `FocusNode` in its own `State`,
disposed with the widget — draft text still never enters Riverpod, so the
focus problem above is still solved. What changes is where **rejection**
lives: `RejectedEdit` is real state on `PricingGridController` (data-model.md
§6), keyed by `PriceCellKey`, set on a failed commit and cleared only by a
later successful one — a value FR-023's summary bar can count and FR-009's
tooltip can read, not an animation tick.

One piece of the original idea survives: disposing a `FocusNode` that still
holds focus can itself fire a final "focus lost" notification, which would
double-commit a cell that just moved away on its own key handler. `PriceCell`
avoids it by unregistering its listener *before* disposing the node, rather
than relying on `ConfirmableFieldController`'s machinery to absorb it.

**Consequence**: FR-022's three cell states are plain fields on
`PricingGridState` — `inFlight: Set<PriceCellKey>` (saving),
`rejected: Map<PriceCellKey, RejectedEdit>` (rejected), and "saved" as the
derived comparison against `baseline` — rather than a per-field controller's
internal lifecycle.

## R4. Keyboard traversal must intercept Tab

Flutter's default focus traversal treats Tab as "next focusable widget", which in
a grid full of cells is not the next *cell* in a defined order, and Enter in a
single-line field does nothing by default.

**Decision**: the active cell's `Focus` handles `onKeyEvent` for Enter, Tab /
Shift+Tab, Escape and the arrow keys, returning `KeyEventResult.handled` for each
so default traversal never runs (FR-008). Left/Right only move between cells when
the caret is already at the end/start of the text, which is the canvas's rule and
keeps ordinary text editing intact. The undo shortcut (⌘Z / Ctrl+Z) is a
`Shortcuts`/`Actions` pair scoped to the grid, not a global handler.

## R5. Reading a page today costs one request per row

| What the grid needs | What exists |
|---|---|
| a page of products | `GET /products` — `ProductRepository.list(...)`, already used by the products list |
| every shown list's price for those products | `GET /product-prices?product=N` — **one product per request** (`ProductPriceRepository.listByProduct`) |
| the price lists themselves | `GET /price-lists?limit=100` — already used by `PricingController._load` |

A 20-row page is therefore 1 + 1 + 20 requests, against SC-006's "constant, small
number". mbe-api#182 asks for a repeatable `product` filter, which collapses it to
3.

**Decision**: put a `listForProducts({required List<int> productIds, List<int>?
priceListIds})` method on `ProductPriceRepository` **now**, implemented today as
`Future.wait` over the existing per-product call, and rewritten to a single
request the day #182 lands. One method, one call site, one line of change later.
The interim fan-out is reads only — bounded by page size, cancellable, and unable
to corrupt anything.

**Note on the cap**: `limit` is `Query(20, ge=1, le=100)` on both endpoints. The
per-product call already asks for `priceLists.length.clamp(20, 1000)` and would be
silently truncated above 100 lists; the batched call returns products × lists
rows, so a 20-row page against 6 lists is 120 — over the cap. Recorded on #182;
until it is answered the grid requests prices **per shown column set**, so the
row count stays under the cap for any realistic page.

### Landed (#182)

`product` now repeats, and the seam paid off exactly as designed: the body of
`listForProducts` became one call, its signature and its single call site
untouched. A 20-row page is **1** price request, not 20.

The cap moved with it, which the note above asked for and did not assume:
`BULK_LIMIT = 500` replaces the 100, and is one constant shared by this read's
`limit` and the bulk write's body cap — a read cap the write could not match
would make a full page unwritable. Mirrored client-side as
`kProductPriceBulkLimit`; `productIds.length * priceListIds.length` must stay
under it.

One client-side wrinkle worth recording: dio sends a repeated query parameter as
a `ListParam`, so a test asserting on `queryParameters['product']` gets that
wrapper rather than a plain list, and `ListFormat.multi` is what produces
`?product=1&product=2` rather than a CSV the server would not parse. Both are
now pinned by `product_price_repository_impl_test.dart`.

## R6. The write path has a landmine: the profit band

`ProductPriceCreate` requires `low_profit` and `high_profit`
(`app/schemas/product_price.py:8`), and the grid does not ask for them (FR-012).
Sending zeros is **not** a safe default:

`assert_margin_in_range` (`app/services/sales_order_service.py:56`) enforces, on
every sales-order line, `low_profit ≤ (price − cost) / price ≤ high_profit` for
the customer's price list. A row created with `[0, 0]` therefore refuses **every
sale of that product at any profit at all** while
`price_validation_in_range_required` is on.

**Decision**, in order:

1. **Update** — echo the row's existing `lowProfit`/`highProfit` back unchanged.
   The grid changes the price and nothing else.
2. **Create** — copy the band from the target price list's own
   `high_profit_margin` / `low_profit_margin`, which are still on the wire and
   already on the `PriceList` entity (they simply stop being *shown*, R11).
3. **Create when that band is degenerate** (`low == high == 0`, which is the
   shipped default for a price list created without margins) — send `[0, 1]`:
   the widest band the schema permits (`ge=0`, and a margin of `(p − c)/p` is
   always ≤ 1), i.e. "at or above cost, no ceiling".

**Rejected**: sending `[0, 0]` and treating it as "no opinion" — it is the
opposite, the strictest possible band. **Rejected**: leaving the fields on the
grid so the user supplies them — the whole point of FR-034.

**Risk, recorded**: rule 3 is the client choosing a business rule the server
should own. It is written up on mbe-api#185 as the reason the deprecation needs a
decision on the validation, not just a schema edit. If #183 lands first with
server-side defaulting, rules 2 and 3 are deleted, not reworked.

### Landed (#185) — the landmine is defused, and rules 2 and 3 are deleted

The server took the decision this finding said it should, and took it the
whole way:

- **The validation is retired**, not relocated — `assert_margin_in_range`,
  both call sites in `add_line`/`update_line`, the
  `EXCLUDE_PRICE_RANGE_VALIDATION` bypass and the
  `price_validation_in_range_required` setting are gone. Nothing reads the
  band. A wrong default can no longer make a product unsellable, because
  there is nothing left to refuse a line.
- **All four fields are deprecated** but still accepted and returned — a
  client still sending them is obeyed, and a generated client keeps fields it
  compiles against. The columns stay until the legacy monolith is retired.
- **The one surviving use is server-side and is the useful half**: a created
  row with no margins named takes the price list's own
  `low_profit_margin`/`high_profit_margin`. That is rule 2, moved to where it
  belonged. On an *update*, omitted margins leave the stored band alone.

So the client sends `price` and nothing else, on create and update alike.
`_bandFor` and its `('0','1')` fallback are **deleted** — rule 3 existed only
because a wrong band was dangerous, and it is not any more.

**The order-of-operations trap the issue named was honoured**: the validation
and the UI stop depending on these fields in the same release, so no stored
band is left refusing lines nobody can adjust.

**Consequence for the entities**: the generated Dart fields now carry
`@Deprecated`, and `PriceList.fromResponse`/`ProductPrice.fromResponse` still
map them for the standalone screen that still shows them (until US7). Each
read carries an explicit `// ignore: deprecated_member_use` with the reason —
reading a field deprecated *for callers* is precisely what a mapping layer is
for, and leaving the analyzer noisy would train the next reader to skim it.

## R7. Atomic column actions cannot be faked

FR-015 requires a column action to be all-or-nothing. With only per-row
`POST`/`PUT` there is no transaction: a failure halfway leaves half a column
moved, and "undo the ones that worked" is itself a fan-out that can fail.

**Decision**: **US3 is not built until mbe-api#183 lands.** The grid ships with
single-cell editing (US1), which needs no atomicity. This is the one place the
plan refuses to approximate the spec.

### Landed (#183) — US3 is unblocked

`PUT /product-prices` upserts a page in one transaction, keyed on the existing
`UNIQUE (product, list)`. Either every cell lands or none does, so FR-015 is
reachable and the client needs no rollback path. Three details shape the US3
implementation:

- **Ids are checked up front**, so one bad id refuses the whole body rather
  than applying the good rows first.
- **A repeated `(product, price_list)` in one body is a 400.** A column action
  must therefore de-duplicate by cell before sending — two cells for one cell
  is a client bug the server refuses to paper over.
- **Body capped at `BULK_LIMIT` (500)**, the same constant as the read cap, so
  a page that can be read can always be written back.

It also removes the POST-vs-PUT branch from the single-cell path: the upsert
has no such fork, so the stale-read race — a 409 on what the user experienced
as a plain edit — is gone. US1 still uses the per-row endpoints, which are
untouched; moving it onto the upsert is optional and not required by any FR.

## R8. The worklist has no query

"Products with no price on list N" is not expressible: `GET /products` has no
price-related filter, and subtracting one paged list from another client-side is
wrong at 21k products.

**Decision**: **US2 ships with mbe-api#184**, and FR-019 (omit the chips
entirely) is the behaviour until then — not zeroed chips, not a client-side
approximation.

### Landed (#184) — US2 is unblocked

Both halves exist, and the facet endpoint is the nicety this finding said it
would be rather than the part that was needed:

- **`GET /products?missing_price_list=N`** — a correlated `NOT EXISTS`
  composing with `search`/`label`/`status`/`salable`, so "unpriced *and*
  salable" is one query and `ListResponse.total` is the count. Now wired
  through `ProductRepository.list` as `missingPriceList`.
- **`GET /products/prices/missing-facets`** — `(price_list, missing_count)`
  for every list over the current filter set, in one call. Counted as
  *matching minus priced*, so a list nobody has priced at all still gets a
  row. It takes no `missing_price_list` of its own, so clicking one chip does
  not move the numbers on the chips beside it.

⚠️ **`0` is a real price list id** in the deployment (`Costo`). The server
tests `is not None` rather than truthiness, and the client must do the same —
a falsy-check would silently drop the cost list's own worklist chip.

The audit test `repository_list_params_audit_test.dart` caught the new
parameter arriving upstream and failed until it was wired through, which is
exactly what it exists for.

## R9. Column choice is a view preference, not a filter

Every other narrowing on a catalog screen lives in the URL via `ListQuery`
(`lib/core/navigation/list_query.dart`, spec 017), because it changes *which
records* are shown and should be shareable. Shown columns change **which
attributes** are shown of the same records.

**Decision**: a session-scoped (`keepAlive`) Riverpod provider holding the shown
price-list ids, seeded to "all lists" on first read. Not in the URL — a link to
the grid should not carry someone else's column layout — and not in
`SharedPreferences`, because FR-020 asks for the session, not the device.
(`lib/core/settings/` is where it would go if that changes.)

## R10. Formatting and validation already have a home

`fmt.display.currency` renders a price; `fmt.input.parsePrice` is its inverse and
is what the cell's `parse` callback uses; `emptyValuePlaceholder` is the shared
em-dash for a null (spec 028). `PricingValidators.isNonNegativeDecimal`
(`lib/features/pricing/domain/pricing_validators.dart`) is the existing
non-negative check FR-009 needs.

**Decision**: no new formatting or validation code. FR-005's "no price ≠ zero" is
the existing `pricingPriceNotSet` treatment, reused.

## R11. Retiring the profit fields is a presentation-layer edit

The four fields appear in three layers. Only one of them changes:

| Layer | Holds | Change |
|---|---|---|
| Generated client (`lib/generated/openapi/`) | ~~required on `ProductPriceCreate`~~ → **optional and `@Deprecated`** since #185, present on responses | **none** — regenerated already |
| Domain entities (`PriceList`, `ProductPrice`) | `highProfitMargin`/`lowProfitMargin`, `lowProfit`/`highProfit` | **none yet** — the standalone screen still displays them; each mapping now carries an `// ignore: deprecated_member_use` and a reason |
| Presentation | 2 form fields, 4 table columns, 1 edit dialog, 6 l10n keys, margin validation in `price_list_form_controller` | **removed** (FR-034, FR-036) |

Concretely: `price_list_detail_screen.dart:134-166` (two fields),
`price_lists_list_screen.dart:92-103` (two columns), `pricing_screen.dart`
(two columns + the two dialog inputs), `price_list_form_controller.dart`
(`highProfitMargin`/`lowProfitMargin` state, `marginInvalid`), and the keys
`priceListHighProfitMarginLabel`, `priceListLowProfitMarginLabel`,
`columnHighProfitMargin`, `columnLowProfitMargin`, `columnHighProfit`,
`columnLowProfit` in both `.arb` files.

**Verified safe for FR-035**: `PriceListCreate` defaults both margins to `0`
server-side (`app/schemas/product.py:29`), so a create that omits them succeeds;
`PriceListUpdate` has them optional. The repository's `create`/`update` already
pass them only `if (… != null)`.

### Landed (#185) — the US7 gate is answered, outcome (a)

The task list gated the price-list form/list half of US7 (T050–T054) on which
way #185 went, because one plausible answer — relocating the margin band to
the price list's own margins — would have made those two fields load-bearing
and un-deprecated them. **It went the other way**: the validation is retired
outright and all four fields are deprecated, `price_list` margins included.
T049's confirmation gate is satisfied and T050–T054 may proceed.

Once they do, the entity fields become genuinely unread and can be dropped
from `PriceList`/`ProductPrice` along with the `// ignore` comments above —
worth doing in the same change, since an entity field nothing maps to a screen
is exactly the dead weight #185 is retiring.

**Test impact**: 94 references across 12 test files. Most are *fixture builders*
constructing `PriceList`/`ProductPrice` entities, which keep compiling untouched
because the entities keep their fields. The assertions that must change are in
`price_list_detail_screen_test`, `price_lists_list_screen_test`,
`price_list_form_controller_test`, `pricing_screen_test` and the
`pricing_flow_test` integration test.

## R12. The drawer corrections are two edits

`_ProductFiltersPanel` (`lib/features/catalog/presentation/products_list_screen.dart:262-355`)
renders: status (titled) → three `_TriStateFilterChip`s (**untitled**) → labels
(titled, hidden when no labels exist) → supplier.

**Decision**: add a `Text(l10n.productsAttributesFilterLabel,
style: titleSmall)` + 8px gap above the `Wrap`, and move the
`CatalogEntityPicker` block above the `if (allLabels.isNotEmpty)` block. New key
`productsAttributesFilterLabel` — "Atributos del producto" / "Product attributes",
`es-MX` authored first (§V). No controller, query or facet touched (FR-032).

**Note**: the labels section is conditional and supplier is not, so moving
supplier above labels also fixes the case where a deployment with no labels
currently renders "status, attributes, supplier" with a trailing gap where the
labels block was.
