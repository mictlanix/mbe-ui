# Quickstart: Merge Products Review Step — manual validation

Validates this feature per user story, on top of spec 008's already-validated
pickers/RBAC/basic confirmation (see `specs/008-merge-products/quickstart.md`
steps 1–12, unchanged by this feature).

## Prerequisites

- mbe-ui pointed at a test mbe-api, signed in with the `productsMerge`
  (value 73) Create privilege.
- Two products that differ in at least one comparable field (e.g. different
  `status`, unit of measure, or tax rate) to exercise the diff-flagging in
  Story 2, plus a pair that are identical in every compared field to exercise
  the Edge Case ("no differences" still renders all rows unflagged).

## Run

```sh
flutter run -d chrome   # or your usual device/flavor
```

## US1 — See exactly which product survives and which is destroyed (P1)

1. Select a canonical "Producto" and a different "Duplicado". → A review step
   appears below the pickers, before any confirmation dialog, showing a
   `merge_kept_panel` and a `merge_deleted_panel`, each labeled by visible text
   (not color alone) and each showing photo, name, code, SKU, and model.
2. Inspect the deleted panel. → Its product name is struck through.
3. Go back and change the "Duplicado" selection to a third product. → The
   review step updates to the new selection; it never shows data for the
   previously-selected duplicate.

## US2 — Field-by-field comparison with differences flagged (P1)

4. With two products that differ in status (or unit of measure/tax rate).
   → The comparison table's status row (and any other differing row) is
   visually flagged (`merge_diff_row`); matching rows are not.
5. With two products that are identical in every compared field. → The table
   still renders every row, none flagged — not an empty or missing table.
6. Resize the window to a narrow/compact width. → Kept vs. deleted attribution
   remains unambiguous (persistent column headers or clearly stacked
   sections); no horizontal scrolling is required to tell the columns apart.

## US3 — Correct a backwards pick via swap (P2)

7. With the review step showing, tap the swap control
   (`merge_swap_button`). → The panel previously labeled deleted is now
   labeled kept (and vice versa); the comparison table's kept/deleted columns
   exchange accordingly.
8. Proceed to the final confirmation after a swap. → It names the
   post-swap kept and deleted products, not the original pre-swap pairing.

## US4 — Explicit acknowledgment gate + restated confirmation (P2)

9. Reach the review step for the first time. → The merge button
   (`merge_submit_button`) is disabled even though both selections are valid;
   the acknowledgment checkbox (`merge_acknowledge_checkbox`) is unchecked and
   its label names the specific product currently marked for deletion.
10. Check the acknowledgment. → The merge button becomes enabled.
11. Tap swap (step 7) after checking the acknowledgment. → The acknowledgment
    unchecks itself and must be re-confirmed against the new deleted product;
    the merge button becomes disabled again until it is.
12. Re-check the acknowledgment and tap Merge. → The confirmation dialog
    names **both** products by name and code (kept and deleted), not just by
    name as in the pre-existing spec 008 dialog.
13. Cancel the confirmation dialog. → No merge is submitted; the review step
    (panels, table, acknowledgment) is unchanged.

## US5 — Related-records summary (P3, degraded in this pass)

14. Reach the review step. → No "will be reassigned" counts summary is shown
    (no backend support yet — [mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111)),
    and no placeholder/zero-value section appears in its place. Everything
    else on the review step (panels, table, acknowledgment, confirmation)
    works normally without it.

## Error handling

15. Before the review step's product data loads, simulate a failure (e.g. one
    of the two products is deleted by another session between selection and
    review). → The review step shows an error (not a partial/stale
    comparison); the acknowledgment and merge button remain disabled; the
    original picker selections are untouched.

## Automated coverage (expected)

- **Widget** (`test/widget/features/catalog/merge_products_screen_test.dart`,
  extended): kept/deleted panel rendering and labeling (steps 1–2), review
  step recomputes on selection change (step 3), diff-row flagging on a
  differing pair and an identical pair (steps 4–5), compact-width layout
  (step 6), swap exchanges panels/table/confirmation (steps 7–8, 11),
  acknowledgment gates the merge button and resets on swap (steps 9–11),
  extended confirmation dialog content (step 12), cancel leaves review state
  intact (step 13), related-records summary omitted (step 14), comparison
  fetch failure blocks proceeding (step 15).
- **Widget** (new, `test/widget/features/catalog/merge_comparison_table_test.dart`):
  diff-row computation in isolation across a matrix of matching/differing
  field combinations.
- **Unit** (`test/unit/features/catalog/merge_products_controller_test.dart`,
  extended): `swap()` and `acknowledgeToggled()` transitions, `acknowledged`
  reset rules, updated `canSubmit`.
- **Unit** (new, `.../merge_products_comparison_provider_test.dart`): parallel
  fetch of both products, `AsyncError` propagation on a not-found id, API
  client mocked.
- **Integration** (`test/integration/product_merge_flow_test.dart`, extended):
  the review step appears as part of the existing golden path, skip-gated on
  live-mbe-api credentials exactly as spec 008's integration test already is.
