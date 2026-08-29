# Quickstart: validating the Bulk Pricing Grid

**Feature**: `033-bulk-pricing-grid` | **Date**: 2026-08-29

How to prove the feature works. *What* to build is in [plan.md](./plan.md),
[research.md](./research.md), [data-model.md](./data-model.md) and
[contracts/](./contracts/).

---

## Prerequisites

- Flutter stable; mbe-api reachable (default `http://127.0.0.1:8000`, override with
  `--dart-define=API_BASE_URL=…`)
- **Two accounts**: one with `PRICING` read **and** update; one with `PRICING`
  read only — the read-only guarantee (US5) cannot be tested with one account.
  Credentials live in `.env` (gitignored).
- **Data**: at least two price lists (one of them the deployment's
  `cost_price_list_id`), and products in three shapes — priced on every list,
  priced on some, priced on none. The third is what US1's "not set ≠ 0.00" and
  US2's worklist need.
- A price list whose margins are **not** `0/0`, and one where they are — the two
  branches of the created-row band (research R6).

## Automated

```bash
flutter analyze
dart run build_runner build --delete-conflicting-outputs   # freezed/riverpod
flutter test                                               # unit + widget
flutter test integration_test/ -d chrome                   # live mbe-api
```

New/changed suites:

| Suite | Proves |
|---|---|
| `test/unit/features/pricing/pricing_grid_controller_test.dart` | the join, the baseline/changed maps, a batch undo reversing N writes as one, revert-all, the R6 band rules |
| `test/widget/features/pricing/pricing_grid_screen_test.dart` | cell editing, every key in contracts §2, badge states, read-only mode, empty states |
| `test/widget/features/catalog/products_list_screen_test.dart` | drawer heading present; section order status → attributes → supplier → labels (US6) |
| `test/widget/features/pricing/price_list_detail_screen_test.dart`, `price_lists_list_screen_test.dart`, `test/unit/.../price_list_form_controller_test.dart` | no profit field anywhere, and create/update still succeed (US7, FR-035) |
| `test/integration/pricing_flow_test.dart` | rewritten against the grid: read a page, edit a cell, reload, re-read the same value |

## Manual — slice A (US7, US6): no API dependency

1. `/price-lists` → open any list. **No** high/low profit margin fields; rename it
   and save; the change sticks.
2. `/price-lists` list → no margin columns.
3. Create a price list from scratch — succeeds with only a name (FR-035).
4. `/products` → filter drawer: the Stockable/Salable/Purchasable group has a
   heading; order reads status → attributes → supplier → labels.
5. Switch the app to Spanish: the new heading is translated; no `[key]` fallback.

## Manual — slice B (US1, US4, US5): the grid

6. `/pricing` → a populated grid renders with **no product selected** (FR-001).
7. A product with no price on a list shows the "not set" treatment, visibly
   different from another cell reading `$0.00` (FR-005).
8. Click a price → it becomes editable with the value selected. Type a new one,
   press Enter → it saves and the same column one row down opens (FR-008).
9. Tab across a row and off its end → the next row's first price-list column opens.
10. Type `abc`, press Enter → the cell keeps `abc`, flagged, with a reason on
    hover, and the stored price is unchanged (FR-009). Reload — the old price is
    still there.
11. Fill an empty cell → a price is created **without ever being asked for a
    profit threshold** (FR-012). Then, in mbe-api, confirm the created row's band
    is the list's margins, or `[0, 1]` if those were `0/0` (research R6) — and that
    a sales order for that product still accepts a normal price.
12. After a few edits the summary bar counts them; `⌘Z` reverses the last one;
    "revert all" restores every price to what it was when the page loaded (FR-024).
13. Try to change page with changes outstanding → warned first (FR-025).
14. Long product name → ellipsized with a tooltip; the page itself does not scroll
    sideways, only the grid's own region (FR-006).
15. Open the filter sheet → "price lists shown" narrows the columns; the choice
    survives navigating within the session (FR-020).
16. Sign in as the read-only account → every price legible, no cell opens, no
    column menu, no summary bar, and the hint line says why (FR-026).

## Manual — slices C and D

Not deliverable yet. Slice C needs **mbe-api#183** (atomic bulk upsert) and slice D
needs **mbe-api#184** (missing-price filter); until each lands the corresponding
affordance must be **absent**, not disabled or approximated — verify that too:

17. No column ⋮ menu appears on any price-list header (US3 not shipped).
18. No worklist chips appear above the grid (FR-019).
