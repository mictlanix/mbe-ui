# UI Contracts: Catalog UI Improvements Round 2

Behavioral contracts for the shared widgets and screens this feature changes. "MUST" items are testable via widget/integration tests; keys in `const Key(...)` form are the stable test handles.

## C1 — Shared data table (`core/widgets/data_table_view.dart`)

- `DataTableColumn` MUST NOT expose a `frozen` parameter; `DataTableView` MUST NOT pin any column (`fixedLeftColumns` is effectively 0).
- No column-ordering assert tied to freezing may remain.
- A column MAY set `label: ''` to render a header-less column (used for the photo column).
- Existing contracts preserved: pagination, hover, borders, header alignment, ellipsis+tooltip truncation for non-critical text.

## C2 — Shared row actions (`core/widgets/catalog_action_icons.dart`)

- `buildCatalogRowActions` MUST render **only** an Edit action, and only when its edit callback is non-null (RBAC-gated by the caller). No View or Delete row icons.
- Consumers (`products_list_screen`, `users_list_screen`) MUST pass only the edit callback.

## C3 — Row click opens read-only View

- On any list backed by `DataTableView`, `onRowTap` MUST navigate to the detail route with `?view=true` (read-only), NOT the editable route.
  - Products: `context.push('/products/$productId?view=true')`.
  - Users: `context.push('/users/$userId?view=true')`.

## C4 — Detail screen read-only affordances (`product_detail_screen`, mirrored in `user_detail_screen`)

- When rendered read-only (`forceReadOnly == true`, or edit-mode without update right), the app-bar title MUST be the **View** title (`viewProductTitle` / `viewUserTitle`), not the Edit title.
- When read-only **and** the user has update right on the record, the screen MUST show an Edit affordance (`Key('edit_product_button')` / `Key('edit_user_button')`) that navigates to the editable route via `context.replace(<detail path without ?view=true>)`.
- When the user lacks update right, the Edit affordance MUST NOT be shown.

## C5 — Product form completeness

- The form MUST render a SKU field (`Key('sku_field')`), editable when `fieldsEnabled`, initialized from the loaded product's `sku`, and its value MUST be sent on create and update.
- The supplier picker MUST support assigning and changing the supplier and persisting it. (Clearing to "no supplier" is out of scope for this feature — backend dependency.)
- The form MUST NOT render any price-list section or price values (no `pricesSubpanelTitle`, no per-price `ListTile`s).
- The labels control (`Key('label_multi_picker')`) MUST occupy the two-column band position previously used by the price sub-panel (beside the attribute switches on wide tiers; stacked on compact).

## C6 — Product delete (destructive action)

- The product detail app bar MUST NOT contain a delete/deactivate icon (`Key('deactivate_product_button')` removed).
- The form MUST render a warning-styled Delete button (`Key('delete_product_button')`) directly below the Save button, themed with the error color scheme.
- The Delete button MUST be visible only when `isEdit && can(products, delete) && !forceReadOnly`; visibility MUST NOT depend on the product's `deactivated` state.
- Pressing Delete MUST open a confirmation dialog whose message conveys the deletion is permanent/irreversible, with a confirm control (`Key('confirm_delete_product_button')`).
- On confirm, the action MUST call `ProductRepository.delete(productId:)` (hard delete). On success the screen MUST pop back to the list. On failure the server error MUST surface via the existing error banner and the product MUST remain.

## C7 — Product photo (`core/widgets/product_photo.dart`)

- `ProductPhoto` MUST use `BoxFit.contain` (no cropping).
- Sizes MUST be 75% larger than current: shared default `84` (was 48); detail thumbnail and its pending `Image.memory` preview `168` (was 96).
- The list photo column's fixed width MUST accommodate the enlarged thumbnail without clipping.

## C8 — Products list column order & copy-code

- The photo column MUST be the first (index 0) column and MUST have an empty header label.
- The code cell MUST provide a copy affordance (`Key('copy_code_button')` or equivalent) that writes the exact code to the clipboard (`Clipboard.setData`) and shows a brief confirmation (`SnackBar` with `codeCopiedMessage`).
- The code text MUST NOT be ellipsized (identity/critical text per constitution §VI).

## C9 — Multi-select label filter

- The products filter panel MUST present labels as a multi-select control (reusing `LabelMultiPicker`), not a single-select dropdown (`Key('products_filter_label')` dropdown removed).
- Selecting N labels MUST contribute N to the active-filter badge count.
- Applying with ≥1 label MUST filter to products matching **any** selected label (OR).
- Clear-all MUST reset the label selection to empty.

## C10 — Config rename

- The photo base-URL setting MUST be read from `String.fromEnvironment('PHOTOS_BASE_URL', …)`; no reference to `LEGACY_PHOTOS_BASE_URL` may remain in code, launch configs, `.env*`, or docs. Resolution behavior MUST be unchanged.

## Localization (both `app_es.arb` default and `app_en.arb`)

New/changed keys (indicative): `viewProductTitle`, `viewUserTitle`, `editProductButton`/`editRecordTooltip`, `skuLabel`, `deleteProductButton`, `deleteProductConfirmTitle`, `deleteProductConfirmMessage`, `codeCopiedMessage`, `copyCodeTooltip`. Product `deactivate*` keys are renamed to `delete*` or superseded. Every new string MUST exist in both locales; es-MX is the default.
