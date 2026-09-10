# Research: Advanced Product Search

**Feature**: 038-advanced-product-search | **Date**: 2026-09-09

Every finding below was read out of this repository. Three of them contradict a
naive reading of the spec, and two close the questions the spec deliberately
left open (Assumptions 8 and 9).

---

## R1. `context.go` inside a pushed route would destroy the sale beneath it

**Decision**: the screen is a **top-level pushed route** (`/sales/product-search`),
and every in-screen navigation — search submit, filter change, page change —
uses **`GoRouter.replace`**, never `context.go`.

**Rationale**: `context.go` rebuilds the whole match list for the target
location. `/sales/product-search` matched on its own resolves to a one-page
stack, so going there from `/sales/pos/123` removes the register page from the
stack: the sale's host widget unmounts, and since `posSaleControllerProvider`
is autoDispose and is kept alive only by `_PosWorkspaceBodyState.build`'s
`ref.watch` (`lib/features/sales/presentation/pos_workspace_screen.dart:262`),
the in-progress sale would be disposed. Cancelling would then have nothing to
return to. This is the single highest-risk detail in the feature — it fails
silently and only on the second interaction.

`replace` is the right primitive and this repo already relies on it:
`_maybeRewriteUrl` (`pos_workspace_screen.dart:123-130`) uses
`GoRouter.of(context).replace('/sales/pos/${sale.id}')` precisely to rewrite
the address without disturbing the screen. It swaps the top-most match only,
leaves the stack beneath intact, and reuses the page key — so the screen's own
`State` survives the URL change (which is what lets a selection persist across
paging, FR-017).

**Consequence**: `submitCatalogSearch`
(`lib/core/navigation/list_search_submit.dart:18`) hardcodes `context.go`, and
so does `products_list_screen.dart`'s own filter panel. Neither can be reused
verbatim; the screen needs its own three-line `_replaceWith(ListQuery)` helper.
The rest of the list scaffolding (`CatalogFilterBar`, `CatalogSearchBar`,
`showCatalogFilterSheet`, `CurrentListQueryBuilder`, `CatalogListStateView`,
`DataTableView`) is reused unchanged.

**Alternatives considered**: (a) a nested route under each host
(`/sales/pos/:saleId/search` + `/sales/orders/:orderId/search`) so `go` keeps
the parent in the stack — two route declarations, two gates, and the POS one
would sit behind `SystemObject.pos` rather than `products`; rejected as more
surface for no gain once `replace` is available. (b) A `Navigator.push`ed
full-screen route with local view state, the `customer_inline_create.dart`
pattern — simpler and proven here, but gives up the addressable URL the user
chose; kept as the documented fallback if `replace` misbehaves in the browser.

---

## R2. The push future cannot carry the result — a provider must

**Decision**: the selection travels through two plain `StateProvider`s, and
`ProductSearchField` consumes the result with `ref.listen`. The screen's
confirm action sets the result and pops; it never calls back into the sale.

**Rationale**: two independent facts force this.

1. **The awaited `push` future dies on the first `replace`.** Documented in
   this repo at `pos_workspace_screen.dart:196-206`: a `GoRouter.replace`
   leaves the awaited `push` future "permanently uncompleted (verified against
   go_router)". Since R1 makes `replace` the screen's normal mode of operation,
   `final result = await context.push(...)` would simply never resolve after the
   user touches a filter. Repo-wide, nothing awaits a value from a go_router
   push today: the only `push<T>` in `lib/` is `Navigator.push<int>` in
   `lib/features/sales/presentation/customer_inline_create.dart:32`.
2. **The screen cannot add the lines itself.** `OrderScreen` overrides
   `saleEditorProvider` inside a *nested* `ProviderScope`
   (`lib/features/sales/presentation/orders/order_screen.dart:48-58`). A route
   pushed onto the root navigator is outside that scope, so it would resolve
   `saleEditorProvider` to `PosSaleController` — the register's sale — and a
   back-office selection would land on the wrong order. The host must do the
   adding, because only the host is inside the right scope.

**Consequence**: the two providers are
`advancedSearchSelectionProvider` (the working set, so it survives a page-key
change) and `advancedSearchResultProvider` (`null` until confirm). Non-autoDispose
by design; the field resets both when it opens the screen and clears the result
after consuming it.

---

## R3. Pricing must be resolved per product, and the callback must become awaitable

**Decision**: `ProductSearchField.onProductSelected` changes type from
`ValueChanged<ProductLookupResult>` to
`Future<void> Function(ProductLookupResult)`, and the field adds the returned
products **sequentially**, awaiting each one.

**Rationale**: three separate hazards converge here.

- `ProductListItem` carries no price, tax rate, min-order quantity or stock
  (`lib/features/catalog/domain/entities/product_list_item.dart:13`) — it does
  not even carry `salable`. Only `GET /sales-orders/product-lookup` returns a
  priced result, keyed to the sale's customer, so each selected product must be
  resolved through `productLookupControllerProvider(code, warehouse:)` at confirm
  time and matched back by `product == productId` — the endpoint matches code,
  name, brand, SKU **and** barcode (`specs/020-point-of-sale/research.md:237-241`),
  so a code that is a substring of another product's code returns several rows
  and the first is not necessarily the right one.
- `ensureOpen()` (`lib/features/sales/presentation/sale_editing.dart:42-50`) is
  **not concurrency-safe**: two simultaneous first actions both observe `null`
  state and both `POST /sales-orders`, creating two drafts. Firing N adds in
  parallel from a fresh sale would do exactly that.
- Both hosts wire the callback as `onProductSelected: (result) => _addLine(...)`
  into a `ValueChanged`, whose `void` return **discards the future**
  (`capture_step.dart:207`, `order_screen.dart:276`). A rejected add today
  produces an unhandled async error and no user-visible feedback at all. The
  bulk path cannot report which product was skipped (FR-021) without the future.

The change is one word in each host — `_addLine` already returns
`Future<void>` — and it is what makes sequencing, ordering (FR-019) and
per-product failure reporting possible at all.

**Alternatives considered**: adding a `addLines(List<int>)` bulk method to the
repository — needs an mbe-api endpoint that does not exist, and §III forbids
this repo from adding one. Resolving prices eagerly while the table is browsed —
violates FR-005 (the lookup opens the sale as a side effect,
`product_lookup_controller.dart:26`) and would cost one request per row.

---

## R4. `DataTableView` has no selection support, and its native one is unreachable

**Decision**: the checkbox column is an ordinary leading
`DataTableColumn` whose `cellBuilder` returns a **non-interactive** `Checkbox`
wrapped in `IgnorePointer`; the row's own tap (`onRowTap`) is the only thing
that toggles selection. `DataTableView` itself is not modified.

**Rationale**: `data_table_2`'s built-in selection is walled off — both table
constructors hardcode `showCheckboxColumn: false`
(`lib/core/widgets/data_table_view.dart:225,261`), `DataRow.selected` is never
set, and `_CatalogDataTableSource.selectedRowCount` returns a hardcoded `0`
(`:308`). Reaching it means editing a core widget that ~20 screens render and
that the golden suite covers.

Making the cell checkbox non-interactive removes a real trap rather than a
theoretical one: `onRowTap` is wired through `DataRow.onSelectChanged`
(`data_table_view.dart:170-173`), so an interactive `Checkbox` inside the cell
puts two tap handlers on the same pixels and a tap could toggle twice (net
zero) depending on which wins the gesture arena. One handler, one outcome, and
FR-012's "tapping a row toggles selection" is satisfied by construction.

**Watch out**: `privileges_grid.dart:98-102` documents that `DataColumn2`
mis-sizes every fixed-width column but the last when several appear
consecutively (upstream layout bug). The products table already opens with two
consecutive fixed-width columns (photo 120, code 200); the checkbox column makes
three. Keep it narrow (≈56) and assert the header/row alignment in a widget test
rather than eyeballing it.

**Alternatives considered**: extending `DataTableView` with
`isSelected`/`onSelectionChanged` and letting `PaginatedDataTable2` draw the
native checkbox column — cleaner in the abstract, but it also switches on that
widget's "N items selected" header banner (driven by `selectedRowCount`), which
would replace the header row with an unstyled Material banner, and it forces
new goldens for a core widget. Rejected for this feature; worth revisiting if a
second multi-select table ever appears.

---

## R5. The forced facets must live inside `ProductFilter`, not at the call site

**Decision**: the screen builds
`ProductFilter.fromQuery(query).copyWith(status: EntityStatus.active, salable: true)`
and passes that same value to **both** `productsListControllerProvider` and
`productLabelFacetsProvider`. The badge count is computed by the screen, not by
`ProductFilterBadge.activeFilterCount`.

**Rationale**: `productLabelFacets` takes `status` and `salable` explicitly
(`lib/features/catalog/domain/repositories/product_repository.dart:204`) and is
documented as mirroring `list`'s filter minus pagination. Forcing the two facets
only at the `list` call site would leave the label chips counting over the whole
catalog: chips would show counts larger than the rows they can reveal, and some
would appear enabled while yielding nothing.

Two knock-on details:

- `decodeStatusFacet` returns `EntityStatus.active` when the facet is **absent**
  (`lib/core/widgets/entity_status_controls.dart:22-32`) — active-only is
  already the catalog's default, so the forced value agrees with it. But
  `?status=all` in a hand-typed URL would override it, which FR-008 forbids;
  `copyWith` after `fromQuery` is what makes the restriction unforgeable.
- `ProductFilterBadge.activeFilterCount` counts a non-null `status` and a
  non-null `salable`, so it would read **2** on a virgin screen. The screen
  counts only what its panel can change: `stockable`, `purchasable`, `supplier`,
  and one per selected label.

`isFilteredBeyondStatusDefault(query, status)` has the same problem — it returns
`true` whenever `status != null`. The screen passes
`isFilteredBeyondStatusDefault(query, null)` semantics instead: filtered iff the
search term or any panel facet is set.

---

## R6. Both `productStockCache` and `productTaxRateCache` must be populated per product

**Decision**: nothing new — the bulk path reaches the existing `_addLine` in
each host, which already writes both caches.

**Rationale**: these two `StateProvider`s
(`lib/features/sales/presentation/capture/product_stock_cache.dart:14,28`) are
written only by the two `_addLine`s and read by `sale_line_editing.dart` at
`:287` (tax-rate options), `:451`/`:461`/`:477` (stock level and shortfall
warning). A new add path that bypassed them would produce lines with no
shortfall warning and a tax picker offering only the line's own rate — a silent
degradation. Routing the bulk path through `onProductSelected` → the host's
existing `_addLine` keeps this correct for free, and is the main reason the
field (not the screen) drives the adding.

---

## R7. There is no dev-tenant account that can answer the cashier-privilege question

**Decision**: gate the affordance on `can(SystemObject.products, AccessRight.read)`
and gate the route on the same, then verify the *negative* in a widget test with
an overridden `accessControlProvider`. Do not block the feature on a live check.

**Rationale**: `test/integration/TEST_ACCOUNTS.md` records that `MBE_POS_*`
points at `admin`, which satisfies every check by short-circuiting
(`AccessControlService.isAdministrator`). The only two non-administrators are
`agonzalez` (deliberately holds **nothing** — it is the negative control for
`can(products, read) == false`) and `augusto` (`products` read + `users` read,
but no `pos` or `salesOrders`, so it cannot reach a sale screen at all). No
account in the tenant is both a cashier and a non-administrator, so a live run
cannot distinguish "cashiers hold products.read" from "the account happens to be
an admin".

What this means in practice: in a real deployment a register operator may well
lack `products` read, and for them the button is simply absent and the field
behaves exactly as it does today. That is the designed outcome, not a
degradation to fix. Spec Assumption 8 is hereby resolved as *unverifiable with
the current tenant, and safe either way*.

`_routeGate` (`lib/app/router/app_router.dart:534-630`) matches by prefix and
has clauses for `/sales/cash-sessions`, `/sales/pos` and `/sales/orders` only —
`/sales/product-search` currently matches **nothing** and would be ungated. A
new clause is required, and refusal is a redirect to `/`
(`app_router.dart:480`), not an error screen.

---

## R8. Direct entry with no sale beneath: gate on `canPop`

**Decision**: the confirm action is disabled, with a short hint, whenever the
screen cannot pop (`!Navigator.of(context).canPop()`); cancel in that state
navigates to `/`.

**Rationale**: this is exactly the "opened by address, no host listening"
case from spec Assumption 9, and `canPop` answers it precisely — the host that
pushed the screen *is* the entry beneath it. Confirming with nobody listening
would set a result provider no one consumes (harmless but silently useless);
disabling it says so instead. Also prevents the pop-on-empty-stack crash.

---

## R9. No mbe-api change, and no bulk-mutation precedent to copy

**Decision**: zero backend dependency; the "some succeeded, some skipped"
surface is new code in `ProductSearchField`, modelled on the closest existing
shapes.

**Rationale**: `GET /sales-orders/product-lookup` takes `pattern`, `customer`
and `warehouse` only, with no paging, no facets and no documented result cap
(`lib/generated/openapi/lib/src/api/sales_orders_api.dart:761-771`; contract at
`specs/020-point-of-sale/contracts/mbe-api-pos.md:93-100`), which is why the
table is backed by `GET /products` instead. `POST /sales-orders/{id}/lines`
documents no duplicate-product case
(`specs/020-point-of-sale/contracts/mbe-api-pos.md:62-72`), and no client code
or test covers adding the same product twice — so the spec's "same as scanning
twice" rule holds by construction: this feature adds no dedupe of its own.

There is no N-sequential-mutations-with-progress loop anywhere in `lib/`. The
nearest shapes are the bulk pricing grid's `run()` helper
(`lib/features/pricing/presentation/pricing_grid_screen.dart:590-603`, one
all-or-nothing call + a counted snackbar) and the delivery controller's
"a refused create leaves every other destination untouched"
(`lib/features/sales/presentation/delivery/delivery_controller.dart:26-28`).
The error surface convention is an inline `ErrorBanner`/inline text on the
screen, never a snackbar for failures
(`lib/core/widgets/error_banner.dart`, `order_screen.dart:222-229`).

---

## R10. Settings, l10n and test conventions are already fixed

**Decision**: follow them exactly; nothing here is a judgement call.

- **App setting**: `PRODUCT_SEARCH_MULTI_SELECT`, read as a
  `String.fromEnvironment` and parsed in Dart with a documented fallback — the
  pattern `_parseDebounceMs` uses (`lib/core/config/app_settings.dart:132-140`),
  chosen over `bool.fromEnvironment` so a malformed value falls back instead of
  silently reading `false`. Exposed as `productSearchMultiSelectProvider` beside
  `inputDebounceProvider` (`lib/core/config/app_settings_provider.dart`),
  documented in `.env.template`'s app-settings block, and covered by two tests
  in `test/unit/core/config/app_settings_test.dart` (the real default off
  `fromEnvironment()`, plus the parser's rule mirrored inline for malformed
  input).
- **l10n**: add to `lib/l10n/app_es.arb` first, then `app_en.arb`, then run
  `flutter gen-l10n` — a missed regeneration produces a stale getter, not a
  compile error (`specs/034-price-list-retirement-ui/tasks.md:215`).
- **Tests**: `pumpPos` from `test/widget/features/sales/pos_test_harness.dart:118`
  for behaviour, `pumpGoldenScenario` when the assertion needs the real theme,
  `phoneSurface`/`expectNoHorizontalScroll` for the compact assertions. No new
  file lands in `lib/core/widgets/`, so no golden is forced by
  `core_widgets_golden_test.dart`'s file-scan guard.
