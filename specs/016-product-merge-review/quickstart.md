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
   visually flagged (carries a `merge_diff_badge`); matching rows are not.
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

## US5 — Blast-radius summary (P3)

14. Reach the review step with a duplicate that carries history (orders,
    inventory movements, price rows). → A summary lists each record category
    with its count, largest first, plus a total.
15. Compare the displayed total against the sum of the listed rows. → They
    match (the total comes from the server, not a client-side re-add).
16. Inspect the price-list row in the summary. → It is marked as destroyed
    rather than moved to the kept product; the other categories are not.
17. Point the app at a backend that reports a category the UI has no label
    for (or temporarily rename one in a stub). → It still appears, under a
    humanized fallback label, and is still included in the total.
18. Simulate a preview failure (e.g. block the preview request). → The
    summary section disappears entirely — no banner, no zero-filled rows —
    and the merge button remains enabled; the rest of the review step is
    unaffected.
19. Open the confirmation dialog with the preview loaded. → It includes the
    total line. With the preview failed or pending, the dialog omits that
    line rather than showing a blank or zero.

## Error handling

20. Before the review step's product data loads, simulate a failure (e.g. one
    of the two products is deleted by another session between selection and
    review). → The review step shows an error (not a partial/stale
    comparison); the acknowledgment and merge button remain disabled; the
    original picker selections are untouched. Note the contrast with step 18:
    a **comparison** failure blocks the merge because it is identity data; a
    **preview** failure does not, because it is informational context.

## Automated coverage (as implemented)

Steps 1–20 above are exercised by the automated suite below rather than a live
manual run — this repo has no running mbe-api instance or seeded credentials in
dev-container contexts, so `test/integration/*` stays skip-gated on
`--dart-define` credentials exactly as spec 008's does. The widget/unit tests
build real widget trees via `flutter_test` and assert the same outcomes.

**Result**: `flutter test` → **993 passed, 41 skipped, 0 failed**. `flutter build web` compiles clean.
`dart analyze lib test` → 0 issues in this feature's files (3 pre-existing
`info`-level lints elsewhere: `payment_method_option_detail_screen.dart`,
`taxpayer_issuer_detail_screen.dart`).

Coverage added by this feature (48 tests across 6 files):

- `merge_products_screen_test.dart` (29 tests) — review-step visibility,
  panel labelling, strikethrough, recompute-on-change, comparison-failure
  blocking, diff flagging, compact width, swap (including a post-swap merge
  submitting reversed ids), the acknowledgment gate and its reset, the
  summary, and the confirmation dialog with/without the total line.
- `merge_comparison_table_test.dart` (5) — the diff matrix: each field flagged
  in isolation, all-identical products, and null/empty treated as matching.
- `merge_related_records_summary_test.dart` (7) — categories, server total,
  destroyed-vs-moved marking, humanized fallback, empty preview.
- `merge_preview_test.dart` (4) — response mapping, order/total preserved,
  `isDestroyed` only for price rows.
- `merge_products_comparison_provider_test.dart` (4) — parallel fetch,
  error propagation, per-pair re-keying.
- `merge_review_panel_test.dart` (3) — a width sweep (320–1400px, both sides
  of the 600px breakpoint) asserting no layout overflow, including with
  deliberately long names/codes/unit labels; stacked-vs-side-by-side
  behaviour; and equal panel heights. Added after an `IntrinsicHeight`
  wrapper was lost during an editing session and the panels threw
  "BoxConstraints forces an infinite height" — `CrossAxisAlignment.stretch`
  has no bounded height to stretch against inside the screen's scroll view,
  so that wrapper is load-bearing rather than cosmetic.

**Not verified from the UI**: step 15's guarantee that the server total equals
what the merge actually touches, and the reference remapping itself, are
backend behaviours covered by mbe-api's own suite (issues #111/#112).

**Live walkthrough still outstanding**: steps 1–20 have not been run against a
real backend. mbe-api requires a MySQL instance plus seeded products, a user
holding `productsMerge`, and a duplicate carrying real history — none of which
exist in this working copy, and there is no compose file to stand one up. Step
17 in particular (an unlabelled category) cannot be produced without a backend
that reports a relation this UI has no translation for. The automated suite
above substitutes for these, exactly as spec 008's quickstart did; the manual
pass should be run once against a seeded environment before this ships.

### Original expectations



- **Widget** (`test/widget/features/catalog/merge_products_screen_test.dart`,
  extended): kept/deleted panel rendering and labeling (steps 1–2), review
  step recomputes on selection change (step 3), diff-row flagging on a
  differing pair and an identical pair (steps 4–5), compact-width layout
  (step 6), swap exchanges panels/table/confirmation (steps 7–8, 11),
  acknowledgment gates the merge button and resets on swap (steps 9–11),
  extended confirmation dialog content and the conditional total line
  (steps 12, 19), cancel leaves review state intact (step 13), comparison
  fetch failure blocks proceeding (step 20).
- **Widget** (new, `test/widget/features/catalog/merge_related_records_summary_test.dart`):
  per-category rows and server-supplied total (steps 14–15), destroyed-vs-moved
  marking (step 16), humanized fallback for an unknown category (step 17),
  loading placeholder, and error-omits-without-blocking (step 18).
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
