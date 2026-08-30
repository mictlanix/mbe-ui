# Contract: The Pricing Grid Screen

**Feature**: `033-bulk-pricing-grid`

The behavioural contract of `/pricing` — what a test may rely on. Layout comes from
the `Pricing Grid` artboard in `artifacts/pricing_redesign/`.

---

## 1. Structure

```text
CatalogFilterBar(search, filters: [badged tune button])
[worklist chips]                       ← US2, only when mbe-api#184 exists
[summary bar]                          ← only when the session holds changes
DataTableView<PricingGridRow>(minWidth: …)
  ├── photo (120)  code + copy (200)  name (L, ellipsis + tooltip)
  └── one column per shown price list (fixed 176, numeric, right-aligned)
CatalogPagination
[hint line]
```

Widget keys a test may bind to:

| Key | Widget |
|---|---|
| `pricing_grid_table` | the `DataTableView` |
| `price_cell_<productId>_<priceListId>` | a cell in reading state |
| `price_cell_field_<productId>_<priceListId>` | the `TextField` of the active cell |
| `price_cell_badge_<productId>_<priceListId>` | saving / saved / rejected indicator |
| `pricing_grid_summary_bar`, `pricing_grid_undo_last`, `pricing_grid_revert_all` | the change summary bar |
| `pricing_grid_column_menu_<priceListId>` | the column ⋮ (US3, absent until #183) |
| `pricing_grid_worklist_<priceListId>` / `_all` | worklist chips (US2, absent until #184) |
| `pricing_grid_columns_section` | the "price lists shown" section of the filter sheet |

## 2. Cell interaction

| Input | Result |
|---|---|
| click a cell, `canUpdate` | that cell becomes the single active cell; text selected |
| click a cell, `!canUpdate` | nothing — no field, no cursor change |
| `Enter` | commit, then open the same column one row down |
| `Tab` / `Shift+Tab` | commit, then open next/previous column, wrapping to the next/previous row |
| `ArrowDown` / `ArrowUp` | commit, then open the same column one row down/up |
| `ArrowRight` at end of text / `ArrowLeft` at start | commit, then move one column right/left |
| `Escape` | discard the typed text; stored price untouched |
| blur | commit (same path as Enter, without moving) |
| `⌘Z` / `Ctrl+Z` | undo the newest change in `history` |

Every one of these returns `KeyEventResult.handled`, so Flutter's default focus
traversal never runs inside the grid (research R4). At the first/last row the
wrapping move is a no-op rather than an error.

## 3. Commit outcomes

| Outcome | Cell shows | State |
|---|---|---|
| text unparseable or negative | typed text, rejected badge, reason on hover | `rejected[cell]`; `rows` untouched; **no request issued** |
| equal to stored value | current price, no badge | no request issued (FR-010) |
| accepted, in flight | new value, saving badge | `inFlight` contains the cell |
| server accepted | new value, saved badge, "was X" tooltip | `history` gains a `PriceChange`; `inFlight` clears |
| server refused | typed text, rejected badge with the server's message | `rejected[cell]`; `rows` untouched |

A failed write **never** leaves the grid showing a value the server did not accept
(FR-038).

## 4. Empty and degenerate states

| Condition | Rendered |
|---|---|
| no price lists exist | `ListEmptyView` — "No price lists exist yet. Create one first." (the existing `pricingNoPriceListsEmptyState` key, reused) |
| no products match the filters | `CatalogListStateView`'s filtered-empty state with clear-filters |
| load failed | `ListFailedView` with retry |
| product has no price on a list | the existing "not set" treatment — visually distinct from `$0.00` (FR-005) |
| `!canUpdate` | every price legible; no field, no column menu, no summary bar; hint line states why (FR-026) |

## 5. Navigation away with changes

Changing page, filter, search or worklist while `history` is non-empty, or while
any cell is `rejected`, prompts first (FR-025). Confirming discards the undo
history and the rejected text — the stored prices, which are already written, are
untouched. This reuses the confirm-or-discard machinery of
`ConfirmableFieldController` / `UnconfirmedEdits` rather than a bespoke dialog
(research R3).

## 6. Column actions *(US3 — contract only; not built until mbe-api#183)*

| Action | Applies to | Result |
|---|---|---|
| fill down from first row | every **shown** row after the first | one `PriceChange` with N writes |
| copy from the cost list | every shown row that has a cost price | one `PriceChange`; rows without a cost price are skipped |
| adjust by N% | every shown row that **has** a price on this column | one `PriceChange`; unpriced cells are skipped, never created at 0 (spec Edge Cases) |

Each states how many rows it changed, is one undo, and is all-or-nothing — which
is why it waits for a transactional endpoint (research R7).
