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

## 4. Related-record counts (FR-006 / Story 5): dependency filed and **now resolved upstream**

**Decision**: Story 5 is **in scope** for this feature. Consume mbe-api's merge-preview endpoint through the already-regenerated client rather than omitting the summary.

**History**: This started as a confirmed gap — no endpoint exposed per-product reference counts — so per constitution §III it was filed as [mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111) rather than patched from an mbe-ui session, and the spec was written to degrade gracefully in the meantime. **That issue has since shipped and is closed** (mbe-api `990fa83`, "Report a merge's blast radius before it is committed"), and mbe-ui's generated client has already been regenerated against it (mbe-ui `2d9b1e5`). The deferral is therefore obsolete; this section supersedes it.

**Current contract** (verified against mbe-api `main`):

- `GET /api/v1/products/merge/preview?product_id={id}&duplicate_id={id}` → `ProductMergePreviewResponse { items: [ProductMergePreviewItem { category: String, count: int }], total: int }`.
- Gated by `require_privilege(SystemObject.PRODUCTS_MERGE, AccessRight.READ)` — a **read**-level check on the same privilege object the merge itself gates on at create level, so any user who can reach the merge screen (create) can also read the preview.
- Generated client method: `ProductsApi.previewProductMergeApiV1ProductsMergePreviewGet(...)`; models `ProductMergePreviewItem` / `ProductMergePreviewResponse` (`lib/generated/openapi/lib/src/model/`). No further regeneration needed.
- Server-side it calls `preview_merge` → `find_blocking_references(db, duplicate)`, and validates the pair through the same `_load_merge_pair` the real merge uses — so a preview that answers describes the same pair a merge would act on, and a bad pair (self-merge, missing product) fails the same way.

**Two contract properties that drive UI requirements**:

1. **`category` is a raw `table.column` label** (e.g. `sales_order_detail.product`), deliberately reusing the vocabulary mbe-api's referential guard already surfaces in delete conflicts — *not* a friendly display name. The set is derived from mapped metadata, so it grows whenever mbe-api adds a foreign key to `product`, with no mbe-ui change. **Decision**: maintain a localized label map for the categories known today and fall back to a humanized rendering of the raw key for anything unrecognized (spec Story 5 #3), so a new relationship appears in the summary the day it exists rather than vanishing from the list or corrupting the total.
2. **The preview counts `product_price`, which a merge deletes rather than moves.** `preview_merge` calls `find_blocking_references` with no `exempt`, whereas `merge_products` remaps every referencing column *except* `product_price` (which it deletes wholesale via `product_price_service.delete_for_product`). **Decision**: the summary must not be labeled "will be reassigned" across the board (as the reference mockup's "Se reasignarán" heading implies); price-list rows are called out as destroyed (spec Story 5 #2). Framing the whole list as reassigned would be actively misleading about the one category the operator most likely cares about preserving.

**Related upstream fix (affects what the counts mean)**: mictlanix/mbe-api#112 ("merge_products leaves 11 product references behind") shipped as `caa4fcc`. `merge_products` previously remapped six hard-coded tables; it now iterates `referencing_columns(Product, exempt={'product_price'})` off the same mapped metadata the preview counts. Consequence for this feature: the preview and the merge describe the **same** set of records, so a count shown in the review step is not an underestimate of what the merge will touch — which is precisely what makes the summary trustworthy enough to show. An earlier draft of this document listed those six tables as "the authoritative set"; that is no longer true and should not be relied on.

**Alternatives considered**: Keep the summary omitted and ship it as a follow-up (rejected — the endpoint and the generated client both already exist, so the only thing deferring it would buy is a second pass over the same screen); compute approximate counts client-side (rejected and now moot); map only known categories and drop unknown ones (rejected — silently dropping a category understates the blast radius and breaks the total, the opposite of this feature's purpose).

## 5. Layout for side-by-side panels and the diff table at compact width

**Decision**: Reuse the existing `ResponsiveFormGrid`/breakpoint conventions already used by `MergeProductsScreen` (constitution §VI): kept/deleted panels render side by side above a given width breakpoint and stack vertically below it; the diff table's two value columns remain visually attributed to "kept"/"deleted" via a persistent header row (not per-row labels that could scroll out of view), avoiding the horizontal-scroll pattern the constitution disallows.

**Rationale**: The reference design mockup ("Fusión de productos") independently arrives at the same shape — a 412-wide compact layout with stacked panels and stacked comparison rows, and a 1360-wide layout with side-by-side panels and a three-column comparison table (field / kept / deleted) — which lines up with the project's existing shared breakpoint/table conventions rather than requiring anything new.

**Alternatives considered**: A horizontally-scrollable comparison table (rejected — constitution §VI explicitly disallows horizontal scroll on data tables in favor of truncation/stacking).
