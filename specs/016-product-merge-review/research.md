# Phase 0 Research: Merge Products — Explicit Kept/Deleted Review

All Technical Context items are resolved; no `NEEDS CLARIFICATION` remain.

## 1. Source of comparison data: full `Product` vs. picker's `ProductListItem`

**Decision**: Fetch the full `Product` entity for both the canonical and duplicate ids via the existing `ProductRepository.get({required int productId})` (`lib/features/catalog/domain/repositories/product_repository.dart`), which already maps `GET /api/v1/products/{product_id}` to the rich domain entity (barCode, location, unit-of-measure description/symbol, SAT key, tax details, supplier, stockable/perishable/seriable/purchasable/salable/invoiceable/stockRequired flags, comment, labels — well beyond `ProductListItem`'s thin projection).

**Rationale**: `ProductListItem` (what the pickers already hold) only carries `productId, code, name, sku, brand, model, unitOfMeasurementCode/Name, taxRate, status, photo` — enough for FR-003's minimum panel fields but not enough to make FR-005's comparison table meaningfully richer than the picker itself already is. `Product.get()` is already implemented, already generated, and requires no client regeneration (constitution §III). Two `get()` calls (one per id) are the only new network activity this feature introduces.

**Alternatives considered**: Reuse only `ProductListItem` for the whole review step (rejected — the comparison table would then show nothing the operator couldn't already see on the picker's suggestion row, defeating Story 2's purpose); add a new bespoke "comparison" endpoint to mbe-api that returns both products in one call (rejected as unnecessary — two existing `get()` calls in parallel are cheap and require no backend change, unlike the genuinely-missing related-record-counts capability below).

## 2. Representing "kept" vs. "deleted" roles, and the swap control

**Decision**: No new "role" field. `MergeProductsState.canonical` continues to mean "kept" and `.duplicate` continues to mean "deleted" (unchanged from spec 008); `swap()` exchanges the two fields' values directly.

**Rationale**: The panels/diff table always render `canonical` as kept and `duplicate` as deleted, so swapping the *displayed* roles and swapping the *underlying selections* are the same operation — there is no independent "role" to track. This keeps `MergeProductsState` and the eventual `mergeProducts(productId:, duplicateId:)` call (spec 008, unchanged) trivially correct after a swap: whichever product ends up in `canonical` is exactly the one submitted as `productId` (kept).

**Alternatives considered**: Add a `swapped: bool` flag and compute "effective kept/deleted" from it at render time (rejected — doubles the number of places that must agree on which product is which, for no behavioral difference over just exchanging the two fields).

## 3. Resetting the acknowledgment on selection/role change

**Decision**: `MergeProductsState.acknowledged` resets to `false` whenever `canonical` or `duplicate` changes for any reason — a new picker selection, a clear, or a `swap()`.

**Rationale**: Spec FR-008/Story 4 #3 requires the acknowledgment to always refer to the *current* product marked for deletion. Since `canonicalSelected`/`duplicateSelected`/`canonicalCleared`/`duplicateCleared`/`swap()` are the only mutators of those two fields (mirroring spec 008's existing controller shape), resetting `acknowledged` inside each of them is sufficient and requires no separate "did the deleted product change" diffing logic.

**Alternatives considered**: Compute an implicit acknowledgment key (e.g. hash of the deleted product's id) and compare it lazily at submit time (rejected — more moving parts than simply resetting a boolean on the handful of mutators that can change the selections).

## 4. Related-record counts (FR-006 / Story 5): confirmed absent, filed upstream

**Decision**: Ship this feature with the "will be reassigned to the kept product" summary omitted entirely (spec Story 5 #2's fallback), and file the missing capability as an mbe-api issue rather than approximate it client-side.

**Rationale**: Direct inspection of mbe-api's merge implementation (`app/services/product_service.py`'s `merge_products`) confirms the authoritative set of tables a merge actually remaps or deletes: `sales_order_detail`, `purchase_order_detail`, `inventory_receipt_detail`, `inventory_issue_detail`, `inventory_transfer_detail`, `lot_serial_tracking` (remapped), plus `product_price` (deleted) and `product_label` (remapped/deleted). No endpoint today exposes counts against these tables for a given product. mbe-api does, however, already have a generic, metadata-driven building block for exactly this shape — `app/services/references.py`'s `find_blocking_references(db, instance, exempt=...)`, used today for delete-guard messages elsewhere (supplier, price list, taxpayer issuer) — so a preview endpoint is a small, well-precedented addition rather than new infrastructure. Per constitution §III, mbe-ui does not patch mbe-api's source directly even with a local checkout available; the request was filed as [mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111), mirroring how spec 008 handled its own SKU-projection gap via mictlanix/mbe-api#76.

**Alternatives considered**: Compute approximate counts client-side by querying list endpoints per category (rejected — no such per-product list endpoints exist for most of these categories either, and approximating would risk showing incomplete/misleading numbers, which FR-006 explicitly forbids); block this entire feature until the endpoint ships (rejected — Stories 1–4, the core safety value, do not depend on it and would be needlessly delayed).

## 5. Layout for side-by-side panels and the diff table at compact width

**Decision**: Reuse the existing `ResponsiveFormGrid`/breakpoint conventions already used by `MergeProductsScreen` (constitution §VI): kept/deleted panels render side by side above a given width breakpoint and stack vertically below it; the diff table's two value columns remain visually attributed to "kept"/"deleted" via a persistent header row (not per-row labels that could scroll out of view), avoiding the horizontal-scroll pattern the constitution disallows.

**Rationale**: The reference design mockup ("Fusión de productos") independently arrives at the same shape — a 412-wide compact layout with stacked panels and stacked comparison rows, and a 1360-wide layout with side-by-side panels and a three-column comparison table (field / kept / deleted) — which lines up with the project's existing shared breakpoint/table conventions rather than requiring anything new.

**Alternatives considered**: A horizontally-scrollable comparison table (rejected — constitution §VI explicitly disallows horizontal scroll on data tables in favor of truncation/stacking).
