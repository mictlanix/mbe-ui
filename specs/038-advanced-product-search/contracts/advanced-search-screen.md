# UI Contract: Advanced Product Search screen & affordance

**Feature**: 038-advanced-product-search | **Date**: 2026-09-09

This is the binding description of the new surface: its route, its states, its
widget keys, and the contract change to `ProductSearchField`. Test keys listed
here are the ones the widget tests assert on.

---

## §1. Route

| | |
|---|---|
| Path | `/sales/product-search` |
| Declaration | a **top-level** `GoRoute` in `lib/app/router/app_router.dart`, sibling of `/sales/pos/new` and `/sales/orders/new` — never a shell branch (there is no nav entry for it) |
| Builder | `AdvancedSearchScreen(query: ListQuery.fromUri(state.uri))` |
| Gate | new `_routeGate` clause: `if (location.startsWith('/sales/product-search')) return PrivilegeGate(SystemObject.products, AccessRight.read);` — placed with the other `/sales/*` clauses. Without it the route is **ungated** (`_routeGate` matches `/sales/cash-sessions`, `/sales/pos`, `/sales/orders` only). Refusal redirects to `/`, per `app_router.dart:480`. |
| Entered by | `context.push('/sales/product-search')` from `ProductSearchField` |
| Left by | `context.pop()` (confirm and cancel), or `context.go('/')` when `!canPop` |

**URL parameters** — identical grammar to `/products`, minus the forced facets:

| Param | Shape | Notes |
|---|---|---|
| `search` | string | free text, applied on submit only |
| `page` | 1-based int | omitted at page 1 |
| `stockable`, `purchasable` | `true` / `false` | absent = no filter |
| `supplier` | int | supplier id |
| `label` | repeated int | AND semantics, as on `/products` |
| `status`, `salable` | — | **ignored if present.** Forced to active / salable (data-model §3) |

**Navigation within the screen MUST use `GoRouter.of(context).replace(...)`**,
never `context.go`. `go` re-resolves the whole match list and would unmount the
sale beneath (research R1). `submitCatalogSearch` therefore cannot be used
as-is; the screen owns a `_replaceWith(ListQuery)` helper and passes the same
"unchanged term → invalidate instead of navigate" behaviour.

---

## §2. Layout

Body-only content under a standard `Scaffold` with an app bar titled
`l10n.advancedSearchTitle`, whose leading control cancels.

```
AppBar        [←]  Búsqueda avanzada
CatalogFilterBar
  search      CatalogSearchBar(label: l10n.productsSearchLabel)   key: advanced_search_search_field
  filters     Badge.count(...) → IconButton.outlined(Icons.tune)  key: advanced_search_filter_button
CatalogListStateView<ProductListItem>
  onData      DataTableView<ProductListItem>                      key: advanced_search_table
                ├ [ ]  (56px, IgnorePointer(Checkbox))            key: advanced_search_row_<productId>
                ├ photo (120)      ProductPhoto
                ├ code  (200)      Text            l10n.columnCode
                ├ name  (L)        Text            l10n.columnName
                ├ brand (S)        Text            l10n.columnBrand
                └ unit  (M)        Text            l10n.columnUnit
              rowActionsBuilder: omitted            (no action column)
              onRowTap: toggles selection           (never navigates)
Bottom action bar
  left        selection count                       key: advanced_search_selection_count
  right       [Cancelar]  [Agregar (n)]             keys: advanced_search_cancel_button,
                                                          advanced_search_add_button
```

- The status column and the row action icons of `/products` are **absent**
  (FR-007). No Edit icon — constitution §VI's "Edit is the primary row action"
  rule governs catalog list screens; this is a picker, and its row click selects
  rather than opening a record.
- Loading, empty, filtered-empty and failed states are `CatalogListStateView`'s, wired with
  `emptyMessage: noProductsFound`, `retryLabel: retryButton` + an invalidate of
  `productsListControllerProvider(filter)`, and `clearFiltersLabel: clearFiltersButton` + a
  `_replaceWith` of the bare route. `createLabel`/`onCreate` stay `null` — this screen creates
  nothing (FR-013).
- Filter panel (`showCatalogFilterSheet` + `CurrentListQueryBuilder`) offers
  exactly: attributes `Stockable` and `Purchasable` (tri-state chips), the
  supplier picker, and the label multi-picker. **No status control, no salable
  chip** (FR-008). Clear-all navigates to the bare `/sales/product-search`.
- Compact (< 840dp): `CatalogFilterBar` wraps on its own; the table scrolls
  horizontally inside its own viewport; the bottom action bar stays pinned and
  is not obscured by the selection count (FR-014).

---

## §3. Selection behaviour

| Rule | Behaviour |
|---|---|
| Toggle | Tapping anywhere on a row toggles it. The cell checkbox is a visual only (`IgnorePointer`) — one tap handler, one outcome (research R4). |
| Multiple mode | Any number; ticks persist across search, filter and page changes for the visit. |
| Single mode | Ticking a row releases the previous one; the list never exceeds one. |
| Count | `advanced_search_selection_count` shows the running total; hidden at zero. |
| Clear | The count row carries a clear action; available only in multiple mode with a non-empty selection. |
| Confirm | Enabled iff the selection is non-empty **and** `Navigator.of(context).canPop()`. When it cannot pop, it is disabled with `l10n.advancedSearchNoSaleHint` (research R8). |
| Cancel | Pops with the result provider left `null`; sets the working selection back to `[]`. |

---

## §4. `ProductSearchField` contract

**Changed signature**

```dart
final Future<void> Function(ProductLookupResult) onProductSelected;
```

Both hosts keep their existing expression
(`onProductSelected: (result) => _addLine(result, defaultWarehouse.value)`);
the returned future is now awaited instead of discarded (research R3).

**New affordance** — a trailing action in the field's row:

| | |
|---|---|
| Key | `advanced_search_button` |
| Label | `l10n.advancedSearchButton` ("Advanced search" / "Búsqueda avanzada") |
| Shown when | `access.can(SystemObject.products, AccessRight.read)` |
| Enabled when | `widget.enabled` **and** no add is in flight |
| On press | resets `advancedSearchSelectionProvider` to `const []`, then `context.push('/sales/product-search')` |

**Result handling** — `ref.listen(advancedSearchResultProvider, ...)` in the
field:

1. Ignore `null`.
2. Read the list, immediately set the provider back to `null` (so a rebuild
   cannot re-enter), and enter the adding state.
3. For each product **in order**, sequentially:
   - `ref.read(productLookupControllerProvider(product.code, warehouse: warehouse).future)`
   - take the row whose `product == item.productId`; if there is none, record a
     skip and continue;
   - `await widget.onProductSelected(result)`; on a thrown `AppError`, record a
     skip and continue.
4. Render the outcome: nothing when no product was skipped; otherwise a
   dismissable `SnackBar` (keyed `advanced_search_skipped`, swipeable, an
   8-second duration) listing `code — name`, one per skipped product — a
   one-time report, not a standing block in the field's own layout.

While adding, the field reports counted progress (`advancedSearchAdding` —
"Adding {done} of {total}…") and both the field and the advanced-search button are disabled
(FR-022, SC-005). The screen's own confirm is guarded against a second tap landing before the pop
completes, so one confirm can never publish two results. Sequencing is not a
performance choice: `ensureOpen()` is not concurrency-safe and parallel first
adds create two draft sales (research R3).

---

## §5. Localization keys

| Key | English | Spanish |
|---|---|---|
| `advancedSearchButton` | Advanced search | Búsqueda avanzada |
| `advancedSearchTitle` | Advanced search | Búsqueda avanzada |
| `advancedSearchAddButton` | `Add ({count})` | `Agregar ({count})` |
| `advancedSearchSelectionCount` | `{count} selected` | `{count} seleccionados` |
| `advancedSearchClearSelection` | Clear selection | Limpiar selección |
| `advancedSearchNoSaleHint` | Open this from a sale to add products | Ábrela desde una venta para agregar productos |
| `advancedSearchSkipped` | These products could not be added: | No se pudieron agregar estos productos: |
| `advancedSearchAdding` | `Adding {done} of {total}…` | `Agregando {done} de {total}…` |

Reused unchanged: `productsSearchLabel`, `searchButtonTooltip`, `filtersTooltip`,
`filtersButton`, `clearAllFilters`, `applyFilters`, `clearFiltersButton`,
`noProductsFound`, `retryButton`, `columnCode`, `columnName`, `columnBrand`,
`columnUnit`, `productsAttributesFilterLabel`, `productsStockableFilter`,
`productsPurchasableFilter`, `productsSupplierFilter`,
`productsSupplierSearchHint`, `productsLabelFilter`, `cancelButton`.

---

## §6. What this contract does **not** change

- `GET /sales-orders/product-lookup`, `GET /products` and
  `POST /sales-orders/{id}/lines` are used exactly as they are today. No
  endpoint, schema or codegen change (constitution §III).
- The scan and type-ahead paths of `ProductSearchField` keep their behaviour:
  debounced search on change, auto-add of a single exact match on submit
  (SC-009).
- No dedupe rule is introduced. A product already on the sale produces whatever
  `POST /lines` produces for a scan of the same product today.
- `DataTableView` is not modified.
