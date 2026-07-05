# Quickstart & Validation: Catalog UI/Layout Improvements

Validation guide for the two presentation-only improvements. No backend setup beyond a
running mbe-api (same as prior catalog features); the changes are client-side layout only.

## Prerequisites

- Repo on branch `006-catalog-ui-improvements`.
- `flutter pub get` run; codegen up to date (`dart run build_runner build --delete-conflicting-outputs`)
  after adding the `ProductFilter` getters/reset (freezed regen).
- A running mbe-api with product data (for manual checks), or use the existing widget-test
  fakes for automated checks.

## Automated validation (widget tests)

```bash
flutter test test/widget/features/catalog/products_list_screen_test.dart \
             test/widget/features/catalog/product_detail_screen_test.dart \
             test/unit/features/catalog/products_list_controller_test.dart
```

Expected after implementation:

- **Products list**:
  - The filter bar shows `products_search_field` and a `products_filter_button`; the facet
    chips are **not** in the tree until the button is tapped.
  - Tapping `products_filter_button` opens the sheet; `products_filter_stockable`,
    `products_filter_salable`, `products_filter_purchasable`, `products_filter_show_inactive`,
    and `products_filter_label` are then findable and behave exactly as before.
  - Activating N facets shows a `Badge` with count N on the button; Clear all resets facets
    and removes the badge.
- **Controller unit test**: `ProductFilter.activeFilterCount` returns the expected count for
  representative states; `reset()` clears facets while preserving `search`.
- **Product detail**: all field keys (`code_field`, `name_field`, …, `save_button`) remain
  present and editable/read-only per mode; photo action keys
  (`upload_photo_button`/`replace_photo_button`/`remove_photo_button`) still respond.

> Note: existing list-screen tests that assert inline facet chips **will fail until updated**
> to open the sheet first — this is expected and part of the task list.

## Manual validation

Run the app: `flutter run -d chrome` (or a desktop target), navigate to **Productos**.

### US1 — Decluttered filtering

1. At rest, confirm only the search box + a **Filters** button are visible; no inline chips.
2. Widen the window to ≥840px, open Filters → panel slides in from the **right** (side sheet).
3. Narrow the window to <840px, open Filters → panel rises from the **bottom** (bottom sheet).
4. Toggle Stockable/Salable/Purchasable and pick a label → list updates live; the Filters
   button shows a **count badge** matching the number of active facets.
5. Turn "Show inactive" off (active-only) → badge increments; turn it back to default → badge
   decrements.
6. **Clear all** → all facets reset, list returns to unfiltered, badge disappears; search text
   is preserved.
7. As a read-only user (no update/delete), confirm filtering still works.

### US2 — Responsive product form

1. Open a product for edit on a **≥1200px** window → text fields lay out in **3 columns**
   within a centered, max-width container (not stretched to the screen edges).
2. Resize to ~900px → **2 columns**; resize to <600px → **1 column**. No horizontal scroll at
   any width; no overlapping/clipped labels or error texts.
3. Trigger a validation error (e.g. clear the code field) → error shows with its field inside
   the grid without breaking layout.
4. Confirm switches, prices, and labels sections sit within the same max-width container.
5. Open the same product via **View** (read-only) → identical column layout, all fields
   disabled.

### US3 — Inline photo actions

1. Edit a product **with** a photo → **Change** and **Remove** actions appear **beside** the
   thumbnail on the same row.
2. Edit a product **without** a photo → the **Upload** action appears beside the placeholder.
3. Narrow to compact width → actions may stack below the thumbnail without overflow.
4. View (read-only) mode → no photo actions shown.
5. Upload/replace/remove still function; a photo validation error still displays near the
   photo area.

## Acceptance mapping

| Spec | Validated by |
|---|---|
| FR-001..FR-007, US1, SC-001..SC-003 | Manual US1 steps + list widget test |
| FR-008..FR-012, US2/US3, SC-004..SC-005 | Manual US2/US3 steps + detail widget test |
| FR-013, SC-006 | All existing keys/tests pass; RBAC + read-only preserved |
| FR-014 | Controller unit test (derived count/reset only; no logic change) |
| FR-015 | Breakpoints sourced from `LayoutBreakpoints` (grep: no hardcoded widths in screens) |
| FR-016 | `catalog_filter_sheet.dart` + `responsive_form_grid.dart` live in `core/widgets/` |
