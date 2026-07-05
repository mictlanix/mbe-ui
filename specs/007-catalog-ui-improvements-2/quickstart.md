# Quickstart: Validating Catalog UI Improvements Round 2

Manual + automated validation for each user story. Assumes a running mbe-api dev instance and a `.env`/dart-defines with `API_BASE_URL` and (renamed) `PHOTOS_BASE_URL`.

## Prerequisites

- mbe-api reachable (default `http://127.0.0.1:8000`) with seeded products, at least one product having a SKU, a supplier, ≥1 label, and a non-square photo.
- A user with `products` create/update/**delete** rights, and (for negative checks) a read-only user.
- Run the app: `flutter run -d chrome --dart-define=API_BASE_URL=… --dart-define=PHOTOS_BASE_URL=…`
- Static checks: `dart analyze` and `flutter test` (widget/unit), then `flutter test integration_test` against the dev API.

## US1 — Safe read-only default (P1)

1. Open `/products`. Confirm each row shows **only** an Edit icon (no View/Delete icons), and no column is pinned when the table is wide.
2. Click a row body → detail opens **read-only** (fields disabled, no Save, no Delete), app-bar title reads **"Ver producto"** (View).
3. With update rights, confirm an **Edit** affordance appears; pressing it switches to the editable form (title "Editar producto", Save visible). Press Back → returns to the list, not the read-only view.
4. As a read-only (no update) user, confirm the Edit affordance is absent and no Edit row icon renders.
5. Repeat 1–2 on `/users` (row click → read-only "Ver usuario"); confirm the user detail still has its own app-bar delete for admins.

## US2 — Multi-select label filter (P2)

1. Open the products Filters panel. The label facet is a **multi-select** chip list (not a dropdown).
2. Select two labels, Apply. The list shows products carrying **either** label. The filter badge count increases by 2.
3. Clear all filters → label selection empties and the full list returns.

## US3 — Form completeness (P2)

1. Open a product with a SKU in edit mode. Confirm the **SKU** field shows the value; change it and Save; reopen → the new SKU persists.
2. Confirm the supplier picker shows the assigned supplier; change it and Save → persists. (Clearing to "no supplier" is knowingly not supported this round.)
3. Confirm there is **no price section** anywhere on the form.
4. Confirm the **labels** control sits beside the attribute switches (two-column band on a wide window; stacked when narrow).

## US4 — Hard delete from the form (P3)

1. Open an editable product with delete rights. Confirm **no delete icon in the app bar**, and a **warning-styled "Eliminar"** button sits directly below Save.
2. Press it → a confirmation dialog states the deletion is **permanent/irreversible**. Cancel → nothing happens, edits intact.
3. Confirm → product is removed; you return to the list and it no longer appears (not merely hidden as inactive).
4. Negative: attempt to delete a product referenced elsewhere (if available) → the server error surfaces in the banner and the product remains.
5. Confirm the Delete button is hidden in create mode, in read-only mode, and for users without delete rights; and **shown** for an already-deactivated product.

## US5 — Photo size & fit (P3)

1. Open a product with a non-square photo. Confirm the detail thumbnail is visibly larger (~168 px) and the **whole image** is visible (letterboxed, not cropped).
2. On the list, confirm the photo thumbnail is larger and uncropped.

## US6 — Photo-first column & copy code (P3)

1. On `/products`, confirm the **photo is the first column** with a **blank header**.
2. Use the **copy** control on a code cell → a brief "copiado" confirmation appears; paste elsewhere and confirm the value matches the product's code exactly.
3. Confirm no table column is frozen/pinned and there is no horizontal scroll.

## FR-021 — Config rename

1. `grep -r LEGACY_PHOTOS_BASE_URL` across the repo (code, `.vscode/launch.json`, `.env*`, docs) returns **no matches**.
2. Photos still resolve correctly using `PHOTOS_BASE_URL`.

## Constitution

- Before/with implementation, ratify the §VI action-set amendment via `/speckit-constitution` (Edit-only rows + row-click→read-only View + Delete on detail). Confirm the plan's Complexity Tracking entry is cleared once ratified.

## Expected automated coverage

- Widget: `data_table_view` (no frozen), `catalog_action_icons` (Edit-only), `product_photo` (contain + size), products list (photo-first, copy-code, multi-label filter), product detail (view title, edit-switch, sku field, no prices, delete button visibility).
- Unit: `ProductFormController.delete()` success/error + `deleted` flag; `sku` create/update wiring; `ProductFilter` labels count/reset.
- Integration: row-click→read-only→edit switch; create/edit with SKU; hard-delete golden path.
