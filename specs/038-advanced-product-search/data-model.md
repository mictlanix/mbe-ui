# Data Model: Advanced Product Search

**Feature**: 038-advanced-product-search | **Date**: 2026-09-09

No new domain entity, no new API DTO, no codegen. Every type below is either an
existing entity reused as-is, one new value object, or one new setting field.

---

## §1. Reused, unchanged

| Type | Where | Role here |
|---|---|---|
| `ProductListItem` | `lib/features/catalog/domain/entities/product_list_item.dart:13` | One row of the table, and one element of a selection. Carries `productId`, `code`, `name`, `brand`, `unitOfMeasurementName`, `photo`, `status`, `taxRate`. **No price, no stock, no `minOrderQty`, no `salable` flag** — which is why R3 exists. |
| `ProductFilter` | `lib/features/catalog/presentation/products_list_controller.dart:29` | The screen's query, with `status` and `salable` forced (§3). |
| `CatalogPage<ProductListItem>` | `lib/core/widgets/catalog_pagination.dart:9` | The page the table renders. `pageSize` stays the catalog's 20. |
| `ProductLookupResult` | `lib/features/sales/domain/entities/product_lookup_result.dart:12` | The priced product a line is actually created from. Produced at confirm time, one per selected product. |
| `ListQuery` | `lib/core/navigation/list_query.dart:21` | Search term, page index and facets, carried in the screen's own URL. |

---

## §2. New: `AdvancedSearchOutcome`

The result of confirming a selection — what the field reports back to the user.
A plain value object held in widget state; not persisted, not a provider.

| Field | Type | Meaning |
|---|---|---|
| `added` | `int` | Products that were priced and added as lines. |
| `skipped` | `List<ProductListItem>` | Products that could not be priced or whose add was refused, in selection order. Rendered as `code — name`, one per line (FR-021). |

Rules:

- `added + skipped.length` always equals the size of the confirmed selection —
  the count is the honesty guarantee behind SC-002 and SC-006.
- An outcome with `skipped.isEmpty` renders nothing; the lines themselves are
  the feedback.
- An outcome is cleared when the next search, scan or advanced search begins.

---

## §3. Forced filter

The screen never derives its filter from the URL alone:

```
filter = ProductFilter.fromQuery(query)
           .copyWith(status: EntityStatus.active, salable: true)
```

| Facet | Source | User-changeable |
|---|---|---|
| `status` | forced `EntityStatus.active` | **no** — no control rendered, and a hand-typed `?status=all` is overwritten |
| `salable` | forced `true` | **no** — same |
| `search` | URL `?search=` | yes (search box) |
| `stockable`, `purchasable` | URL facets, tri-state | yes (filter panel) |
| `supplier` | URL facet, int | yes (filter panel) |
| `label` | URL facet, repeated int | yes (filter panel) |
| `pageIndex` | URL `?page=` (1-based) | yes (pagination) |

**Badge count** (FR-010) counts only what the panel can change:

```
count = (stockable != null ? 1 : 0)
      + (purchasable != null ? 1 : 0)
      + (supplier != null ? 1 : 0)
      + labels.length
```

`ProductFilterBadge.activeFilterCount` is deliberately **not** reused: it counts
the two forced facets and would show `2` on a virgin screen (research R5).

**Empty-state discrimination**: `CatalogListStateView.isFiltered` receives
`query.search.isNotEmpty || <any panel facet set>` — not
`isFilteredBeyondStatusDefault`, which returns `true` whenever `status != null`
and would make every empty result read as filtered.

---

## §4. Selection state

Two providers, both plain (non-autoDispose) `StateProvider`s in
`lib/features/sales/presentation/capture/advanced_search_state.dart`, because
the screen's `State` cannot be relied on across a `GoRouter.replace` and the
field must be able to read the result after the screen is gone (research R2).

| Provider | Type | Lifecycle |
|---|---|---|
| `advancedSearchSelectionProvider` | `List<ProductListItem>` | The working set, in tick order. Reset to `const []` by the field immediately **before** pushing the screen. Mutated only by the screen. |
| `advancedSearchResultProvider` | `List<ProductListItem>?` | `null` except in the instant between the screen's confirm and the field consuming it. Set by confirm; set back to `null` by the field's `ref.listen` handler. Cancel never sets it. |

Invariants:

- Order is tick order, and it is preserved end-to-end into line order (FR-019).
- Membership is by `productId`.
- Single-selection mode keeps the list at length ≤ 1 by replacing rather than
  appending.
- The result provider is consumed exactly once per confirm; the field clears it
  before adding anything, so a rebuild mid-add cannot double-add.

---

## §5. New app setting

| Field | Type | Env key | Default |
|---|---|---|---|
| `AppSettings.productSearchMultiSelect` | `bool` | `PRODUCT_SEARCH_MULTI_SELECT` | `true` |

Parsed from a `String.fromEnvironment` with a Dart-side fallback
(`'true'`/`'false'`, case-insensitive; anything else → default), matching
`_parseDebounceMs`'s rule that a malformed build flag must not brick startup.
Exposed as `productSearchMultiSelectProvider`. Never mutable from the UI
(constitution §V). See `contracts/app-settings-additions.md`.

---

## §6. Changed widget contract

`ProductSearchField.onProductSelected` changes type:

```
- final ValueChanged<ProductLookupResult> onProductSelected;
+ final Future<void> Function(ProductLookupResult) onProductSelected;
```

Both hosts already pass a call to their own `Future<void> _addLine(...)`, so the
expression at each call site is unchanged — only the discarded future becomes
awaited. This is what allows sequential adds, ordering, and per-product failure
capture (research R3). Existing widget tests that pass
`(result) => selected = result` keep compiling only if the closure is adapted;
`test/widget/features/sales/product_search_field_test.dart` has three such call
sites.

---

## §7. State transitions — one advanced search

```
idle
  └─ button pressed ─────────► browsing        (selection reset to [], screen pushed)
browsing
  ├─ tick / untick ──────────► browsing        (selection mutated)
  ├─ search / filter / page ─► browsing        (URL replaced, selection preserved)
  ├─ cancel ─────────────────► idle            (result stays null, nothing added)
  └─ confirm ────────────────► adding          (result set, screen popped)
adding                                          (field: sequential, one product at a time)
  ├─ each product: lookup ──► priced ──► onProductSelected(awaited) ──► added++
  │                └─ no match / refused ─────────────────────────────► skipped += product
  └─ all products done ──────► reporting
reporting
  └─ outcome rendered (nothing when skipped is empty) ──► idle
```

`adding` is a blocking state for the affordance: the button and the field's
submit path are disabled while it runs (FR-022).
