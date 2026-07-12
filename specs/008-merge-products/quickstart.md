# Quickstart: Merge Products — manual validation

Validates the feature end-to-end per user story. Assumes a running test mbe-api
with seeded products and a signed-in user; note which privileges the user holds.

## Prerequisites

- mbe-ui pointed at a test mbe-api (`--dart-define` API base URL as usual).
- A user **with** the `productsMerge` (value 73) Create privilege, and a second
  user **without** it, to exercise RBAC.
- At least two clearly-duplicated products (e.g. two "BROCA CONCRETO
  MULTICONSTRUCCION 1/4\" X 4\" BOSCH 7150" records) and, ideally, a duplicate
  that carries orders/inventory movements/labels so history remapping is visible.

## Run

```sh
flutter run -d chrome   # or your usual device/flavor
```

## US4 — Access control (P3)

1. Signed in **without** the merge privilege: open `/products`. → No Merge entry
   point in the app bar (`merge_products_button` absent).
2. Manually navigate to `/products/merge`. → Redirected to `/` (screen does not render).
3. Sign in **with** the merge privilege: `/products` shows the Merge entry point;
   tapping it opens the Merge Products screen.

## US2 — Search-as-you-type pickers (P2)

4. In "Producto", type 1–2 characters. → No suggestions yet (min-length gate).
5. Type ≥3 characters of a product's name/code/model/brand/SKU. → Suggestions
   list shows matching products, each with a photo thumbnail + name and
   code/model/SKU.
6. Type a term that matches only by **SKU**. → The product appears, and its SKU
   is visible in the suggestion row (mictlanix/mbe-api#76).
7. Select a product. → The field shows the product; only one product can occupy
   the field. Clear it and confirm it returns to empty and is searchable again.
8. Type gibberish that matches nothing. → The picker shows a no-results state, not
   a broken/empty overlay.

## US3 — Guardrails & error recovery (P2)

9. Leave "Duplicado" empty, fill "Producto". → Merge action disabled; the
   both-required validation message is shown; nothing is submitted.
10. Select the **same** product in both fields. → Merge action disabled; the
    "cannot merge with itself" message is shown.
11. Select two **different** products and tap Merge. → A confirmation dialog
    appears clearly stating the duplicate will be **permanently and irreversibly**
    deleted. Cancel it → no merge; both selections remain.
12. Force a server rejection (e.g. delete the chosen duplicate in another tab,
    then confirm the merge). → An error message is shown, no success is reported,
    and both selected products remain in their fields for retry.

## US1 — The merge itself (P1)

13. Select a canonical "Producto" and a different "Duplicado", tap Merge, and
    **confirm**. → A brief in-flight state (action disabled/progress), then a
    success confirmation, then you are returned to the products list.
14. Browse `/products`. → The duplicate no longer appears; the canonical product
    still exists.
15. Inspect records that referenced the duplicate (an order line, inventory
    movement, or the product's labels). → They now resolve to the canonical
    product; no history was lost.
16. Re-open the Merge screen. → It opens empty (selections were not retained),
    so a second merge is a fresh, deliberate action.

## Automated coverage (as implemented)

Steps 1–16 above are exercised by the automated suite below rather than a live
manual run — this repo has no running mbe-api instance or seeded test
credentials in CI/dev-container contexts, so `test/integration/*` is
skip-gated on `--dart-define` credentials (matching every other integration
test in this repo). The widget/unit tests below build real widget trees via
`flutter_test` and directly assert the same outcomes steps 1–16 describe:

- **Widget** (`test/widget/features/catalog/merge_products_screen_test.dart`):
  selection → confirm → merge → success SnackBar → navigate to `/products`
  (step 13–16); in-flight disable (step 13); back affordance without merging;
  confirm-dialog cancel keeps selections (step 11); both-required and
  self-merge guards block submit with the right message (steps 9–10); a
  mocked server rejection surfaces the error banner with both selections
  preserved (step 12); min-length gate, photo+code/model/SKU suggestions
  including a deactivated product, no-results state, single-select+clear
  (steps 4–8).
- **Widget** (`test/widget/core/widgets/catalog_entity_picker_test.dart`):
  the `CatalogEntityPicker` photo/subtitle rendering extension in isolation,
  plus its unchanged text-only path for existing callers.
- **Widget** (`test/widget/features/catalog/products_list_screen_test.dart`):
  Merge entry point shown/hidden by `productsMerge`/create (step 1, step 3).
- **Unit** (`test/unit/app/router/app_router_test.dart`): `/products/merge`
  reachable with the privilege, redirected to `/` without it (step 2); a
  regression check that `/users`/`/products` still gate on Read after the
  routing refactor.
- **Unit** (`test/unit/features/catalog/merge_products_controller_test.dart`,
  `.../product_repository_impl_test.dart`): state transitions and `AppError`
  mapping (400 self-merge, 404 not-found, network), API client mocked.
- **Integration** (`test/integration/product_merge_flow_test.dart`): the US1
  golden path (steps 13–14) plus self-merge (400) and not-found (404)
  scenarios against a real mbe-api — skipped here, runnable with
  `--dart-define=MBE_MERGE_TEST_USERNAME=... --dart-define=MBE_MERGE_TEST_PASSWORD=...`
  against a seeded instance.

Full suite: `flutter test` → 271 passed, 33 skipped (pre-existing + this
feature's integration tests, all requiring a live mbe-api), 0 failed.
`dart analyze lib test` → 0 issues in this feature's files (1 pre-existing,
unrelated `info` elsewhere). Step 15 (transactional-reference remapping) is a
backend guarantee already covered by mbe-api's own test suite, not
re-verified from the UI.
