# Phase 0 Research: Catalog UI Improvements Round 2

All decisions below are grounded in the current codebase and the sibling `mbe-api` service; no `NEEDS CLARIFICATION` markers remain.

## §1 — Frozen-column removal (FR-001)

**Decision**: Remove the `frozen` concept from the shared table entirely rather than just stop passing it. Delete the `frozen` field from `DataTableColumn`, the `frozen` branch in the `DataTableColumn.text` factory, the two `assert`s and the `_fixedLeftColumns` getter in `DataTableView`, and pass `fixedLeftColumns: 0` (or drop the arg). Remove `frozen: true` at both call sites (`products_list_screen`, `users_list_screen`).

**Rationale**: The app already avoids horizontal scroll (constitution §VI), so a pinned leading column resolves to a no-op that only adds branching and a misleading doc comment referencing an old spec's FR numbers. Removing it reduces the shared widget's surface and aligns with §VI's anti-horizontal-scroll rule.

**Alternatives considered**: Keep the parameter but default it off — rejected: leaves dead, confusing code and an assert that constrains column ordering for no benefit.

## §2 — Row actions reduced to Edit-only + row-click → read-only view (FR-002, FR-003, FR-004)

**Decision**: `buildCatalogRowActions` becomes Edit-only: drop the `onView`/`onDelete` params and their tooltips, render a single Edit `IconButton` (still omitted when `onEdit == null`, i.e. no update right). Prune the now-unused `view`/`delete` entries from the `CatalogAction` enum if no other caller references them (verify at implementation; `create` stays for list toolbars). Change both list screens' `onRowTap` to push `…?view=true` (read-only) instead of the bare edit path. The products list drops its `_confirmDeactivate` row path; the users list drops its `_confirmDelete` row path and its `onView`.

**Rationale**: Matches the user request and the clarified scope. Both consumers share one component, so the behavior changes uniformly (§VI). Crucially, **no capability is lost on the users screen**: `user_detail_screen` already carries its own app-bar `delete_user_button` (hard delete), so removing the row-level Delete leaves user deletion reachable. Products deletion moves to the detail form (see §6).

**Alternatives considered**: (a) Keep `buildCatalogRowActions` capable of View/Delete and only have products pass Edit — rejected: FR-002 requires removing them from the shared vocabulary, and leaving optional-but-unused branches invites drift. (b) Make the users screen a special case with inline (non-shared) actions — rejected: violates §VI "shared component, one behavior."

## §3 — Read-only "View" title + edit-switch button (FR-005, FR-006)

**Decision**: In `product_detail_screen`, when `readOnly` is true show `l10n.viewProductTitle` ("Ver producto") instead of `editProductTitle`; when `readOnly && canUpdate` show an "Edit" action (app-bar `IconButton` with `CatalogAction.edit.icon`, or a header button) that navigates to the editable form via `context.replace('/products/$productId')` (no `?view=true`). Apply the same title treatment to `user_detail_screen` (`viewUserTitle`) for cross-screen consistency, since its rows now also open read-only.

**Rationale**: Read-only mode already exists (`forceReadOnly` + `?view=true` are wired in the router and both detail screens); this only fixes the misleading "Edit" title and adds the escape hatch to editing. `context.replace` swaps the read-only route for the editable one so Back returns to the list, not to a stale read-only view.

**Alternatives considered**: `context.push` the editable route — rejected: stacks read-only under editable, so Back lands on the read-only screen (confusing). A full page toggle via local state instead of re-navigation — rejected: the router already models mode via the query param; re-navigating keeps one source of truth.

## §4 — Multi-select label filter (FR-007, FR-008, FR-009)

**Decision**: Change `ProductFilter.label` (`int?`) to `labels` (`List<int>`, default `const []`); update `activeFilterCount` to add `labels.length`, `hasActiveFilters`, and `reset`. Replace the controller's `labelChanged(int?)` with `labelsChanged(List<int>)` (or `labelToggled(int)`). In the filter panel, replace the `DropdownButton` with the existing `LabelMultiPicker` (already used on the product form) driven by `filter.labels`. The list controller passes `labels` to `productRepository.list`. The repository's `list` currently takes a single `label: int?`; extend it to accept `labels: List<int>` and forward to the API's label filter (verify the generated `listProducts…` supports repeated `label` query params; if it only accepts one, send the first and note the backend limitation — see risk below).

**Rationale**: `LabelMultiPicker` already renders labels as multi-select `FilterChip`s and is the natural, consistent control (avoids inventing a new checkbox list). OR semantics (match any) matches how labels behave elsewhere and is the documented assumption.

**Risk / dependency**: mbe-api's product list filter may accept only a single `label` query param. If so, true multi-label filtering needs a backend change (repeated/`in` param). Confirm against `GET /api/v1/products` during implementation; if unsupported, ship the multi-select UI but flag the server-side OR filter as a dependency (do **not** silently send only one label without noting it).

**Alternatives considered**: A bespoke checkbox `ListView` — rejected: duplicates `LabelMultiPicker`. Client-side filtering of a full fetch — rejected: violates pagination/§VI and online-only data flow.

## §5 — Product form completeness: SKU, supplier, drop prices, reposition labels (FR-010, FR-011, FR-012, FR-013)

**SKU (FR-010) — Decision**: Add a `sku` field to `ProductFormState`, a `skuChanged` setter, seed it in `loadForEdit` from `Product.sku`, add a `TextFormField('sku_field')` on the form, and wire `sku` through `ProductRepository.create`/`update` → the generated `ProductCreate.sku`/`ProductUpdate.sku` (both already exist). Fully implementable, no backend change.

**Supplier (FR-011) — Decision**: The supplier picker already assigns/changes and persists (`supplierSelected` → `create`/`update` send `supplier`). Keep it. **Clearing is deferred**: mbe-api's update service does `if data.supplier is not None: product.supplier = data.supplier`, so a null supplier is treated as "leave unchanged" — the client cannot express "clear." Re-verified 2026-07-05 against mbe-api's latest `update_product` (post price-extraction refactor): unchanged, still `is not None`. Note for whoever eventually fixes this backend-side: `update_product` already has the needed pattern one field over — `if "photo" in data.model_fields_set: product.photo = data.photo` explicitly supports null-to-clear via Pydantic's `model_fields_set`, so applying the same pattern to `supplier` would be a small, precedented change, not a novel one. Ship assign/change; record supplier-clear as a backend dependency (Complexity Tracking). Do not wire a clear affordance that silently no-ops.

**Prices (FR-012) — Decision, updated 2026-07-05 post-codegen-refresh**: mbe-api has *already* shipped this (`mbe-api@e4b50c5`, "Extract per-product prices into a standalone price management service") and mbe-ui's generated client has *already* been regenerated against it (`2a9eddc`). `ProductResponse.prices` no longer exists on the generated model at all — confirmed via `dart analyze lib`, which currently reports exactly one error: `product.dart:86:25 - The getter 'prices' isn't defined for the type 'ProductResponse'`. This is **no longer a forward-looking client-side decision to make later** — it is a pre-existing build break on this branch that must be fixed as groundwork before/alongside US3, independent of task prioritization. Required fix: drop the `prices: List<ProductPrice>` field and its mapping from `Product`/`Product.fromResponse` entirely (not just stop displaying it), drop `ProductFormState.prices` and its seeding in `loadForEdit`, and remove the now-dead `ProductPrice`/`product_price.dart` entity (nothing will reference it once `Product` stops mapping it) and the price sub-panel UI (`_SwitchesPricesBand`'s `prices` argument, `pricesSubpanelTitle`/`unknownPriceList` l10n keys if unused elsewhere). Net effect: no price UI anywhere on the form, and no compile error.

**New, currently out-of-scope surface**: mbe-api's extraction also added a full CRUD price-management resource (`/api/v1/product-prices`, generated as `product_prices_api.dart`, gated by the existing `SystemObject.PRICING` — already mirrored in mbe-ui's `core/access/system_object.dart` as `pricing(106)`, unused by any screen today). Building a Price Management UI against it is a distinct, unrequested feature — noted here only so a future spec doesn't have to rediscover it; not pulled into this feature's scope.

**Labels reposition (FR-013) — Decision**: Move the `LabelMultiPicker` block from its standalone full-width section into the two-column band that previously paired switches with prices — switches left, labels right on wide tiers; stacked on compact. Rename `_SwitchesPricesBand` to `_SwitchesLabelsBand` (or generalize its second slot).

**Rationale**: SKU is already fully modelled end-to-end except the two repository wire-ups. Prices were read-only dead weight; labels are the more useful occupant of that reclaimed two-column band (§VI side-by-side grouping guidance).

## §6 — Hard delete: relocate + rename + rewire (FR-014, FR-015, FR-016, FR-016a/b/c)

**Decision**: Remove the app-bar `deactivate_product_button` `IconButton`. Add a full-width warning-styled button directly below Save: a `FilledButton` themed with `colorScheme.error`/`onError` (or `FilledButton` with an error `ButtonStyle`), keyed `delete_product_button`, visible when `_isEdit && canDelete && !forceReadOnly` — **not** gated by `deactivated` (a deactivated product is still deletable). Its confirmation dialog copy states the deletion is permanent/irreversible. Replace `ProductFormController.deactivate()` (which called `update(deactivated: true)`) with `delete()` calling a new `ProductRepository.delete(productId:)` → `deleteProductApiV1ProductsProductIdDelete`. On success set a `deleted` flag → `context.pop()` back to the list (mirrors the existing `saved` handling and `user_detail_screen`'s `deleted` flag). On `DioException`, map to the existing error state so the error banner shows the server message (e.g. referential-integrity rejection). Rename product `deactivate*` l10n keys to `delete*` (or add new `deleteProduct*` keys); reuse the shared `deleteButton` label where apt.

**Rationale**: mbe-api's `DELETE /api/v1/products/{id}` is a confirmed hard delete (`db.delete(product)` plus removal of the product's `ProductPrice` rows). The generated client already exposes it. The `user_detail_screen` `deleted`-flag → `pop` pattern is the established convention to copy.

**Alternatives considered**: Keep soft delete under a "Delete" label — rejected by the clarification. A separate confirmation screen — rejected: the existing `AlertDialog` pattern is consistent across the app; only its wording needs to convey permanence.

## §7 — Product photo size & fit (FR-017, FR-018)

**Decision**: `ProductPhoto` — change `fit: BoxFit.cover` → `BoxFit.contain` so nothing is cropped, and raise sizes by 75%: the shared default `48 → 84`; the detail-screen thumbnail (and its `Image.memory` pending-preview) `96 → 168`. Adjust the products list photo column's `fixedWidth` (currently 110) to comfortably fit the ~84 px image plus padding. Keep the rounded `ClipRRect` and placeholder, scaled to the new size.

**Rationale**: `contain` guarantees the whole image is visible (the reported cropping came from `cover`). 75% is applied to each surface's own current baseline per the spec's sizing assumption. A `contain` image in a square box letterboxes rather than crops — acceptable and the point of the change.

**Alternatives considered**: `BoxFit.fitWidth`/`scaleDown` — rejected: `contain` is the standard "show all, don't crop" fit and behaves well for both portrait and landscape source images.

## §8 — Photo-first, header-less column + copy code (FR-019, FR-020)

**Decision (FR-019)**: Move the photo `DataTableColumn` to index 0 with an empty `label: ''` (the header cell renders blank). Keep it a `fixedWidth` column sized for the enlarged thumbnail.

**Decision (FR-020)**: Render the code cell with a custom `cellBuilder` (not `DataTableColumn.text`) that pairs the code `Text` with a small copy `IconButton` (`Icons.copy`, compact visual density); on press call `Clipboard.setData(ClipboardData(text: p.code))` (from `flutter/services.dart`) and show a brief `SnackBar` (`l10n.codeCopiedMessage`). Code stays identity/critical text (never ellipsized, per §VI).

**Rationale**: The code column already uses a fixed width; swapping to a `Row(code, copyButton)` keeps alignment. Clipboard + SnackBar is the platform-standard, permission-free copy affordance on web/desktop.

**Alternatives considered**: Whole-cell tap-to-copy — rejected: conflicts with the row's tap-to-view gesture. A trailing copy in the row-actions area — rejected: users want the copy next to the code they're reading.

## §9 — Rename `LEGACY_PHOTOS_BASE_URL` → `PHOTOS_BASE_URL` (FR-021)

**Decision**: In `core/network/photo_url.dart`, rename the `String.fromEnvironment('LEGACY_PHOTOS_BASE_URL', …)` key to `'PHOTOS_BASE_URL'`, rename the Dart const `legacyPhotosBaseUrl` → `photosBaseUrl`, and update all references (currently `resolvePhotoUrl` and its doc comments). Grep the repo for `LEGACY_PHOTOS_BASE_URL` / `legacyPhotosBaseUrl` across code, `.vscode/launch.json` dart-defines, `.env*` files, and docs, and update each. Behavior is unchanged — same resolution logic, new name.

**Rationale**: Pure rename; the "legacy" qualifier no longer reflects how the setting is used. Keeping resolution behavior identical avoids regressions in photo URL construction.

**Alternatives considered**: Alias the old name for back-compat — rejected: `String.fromEnvironment` is compile-time; there are no external consumers to break, and an alias would defeat the rename's intent.

## §10 — Constitution amendment (governance)

**Decision**: This feature requires amending constitution §VI's action-set clause (lines 155–163) which currently mandates Create/View/Edit/Delete row actions in fixed order. The new rule: catalog/list rows expose **Edit** (permission-gated) as the sole row action, a **whole-row click opens the read-only View** (the Edit form rendered read-only), and **Delete/soft-delete is surfaced on the detail screen** (catalogs: a warning button in the form body; other modules may retain an app-bar action). Recommend running `/speckit-constitution` to ratify this (MINOR or MAJOR bump per governance) either alongside or immediately before implementation, and record the deviation in the plan's Complexity Tracking until ratified.

**Rationale**: Governance (§Compliance) requires deviations to be justified in the plan and the constitution kept authoritative. Amending is the honest path since the change is deliberate and app-wide, not an oversight.
