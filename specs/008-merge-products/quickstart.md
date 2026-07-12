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
5. Type ≥3 characters of a product's name/code/model/brand. → Suggestions list
   shows matching products, each with a photo thumbnail + name and code/model.
6. Type a term that matches only by **SKU**. → The product still appears (SKU is
   searched server-side), though the row itself shows name/code/model (not SKU).
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

## Automated coverage (for reference)

- **Widget** (`MergeProductsScreen`): picker selection, both-required and
  self-merge guards, confirm-dialog gate, in-flight disable, success→pop,
  error→banner with preserved selections. `CatalogEntityPicker`: photo/subtitle
  option rendering when the new params are provided; unchanged text-only path otherwise.
- **Unit** (`MergeProductsController`, `ProductRepositoryImpl.mergeProducts`):
  state transitions and `AppError` mapping (400 self-merge, 404 not-found, other),
  with the API client mocked.
- **Integration**: the US1 golden path against a test mbe-api.
