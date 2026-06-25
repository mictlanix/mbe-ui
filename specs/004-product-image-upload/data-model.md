# Phase 1 Data Model: Product Photo Display & Upload

No new domain entity is introduced. This feature extends the existing `Product` entity's already-present `photo` field (previously read-only display per 002-product-catalog's data-model.md, line 28: "Out of scope to edit in this feature") with editable upload/replace/remove behavior, plus local-only (non-persisted) form state for an in-progress, unsaved photo selection.

## Product (`lib/features/catalog/domain/entities/product.dart`) — unchanged shape, newly-editable field

| Field | Type | Notes |
|---|---|---|
| `photo` | `String?` | **Now editable via this feature** (previously read-only). A fully-resolved, ready-to-fetch URL string already returned by the backend in every `ProductResponse` (research.md §1) — never a bare filename the client must resolve. `null` means no photo; a non-`null` value (including the backend's own default placeholder URL) is rendered directly. No change to the `Product.fromResponse` mapping — `photo` already maps through unchanged. |

## ProductListItem (`lib/features/catalog/domain/entities/product_list_item.dart`) — new field

| Field | Type | Notes |
|---|---|---|
| `photo` | `String?` | A fully-resolved, ready-to-fetch photo URL, same shape as `Product.photo`. mbe-api's list-row projection initially had no `photo` field (discovered during implementation, not anticipated in research.md/plan.md — tracked as [mictlanix/mbe-api#71](https://github.com/mictlanix/mbe-api/issues/71)); that's now resolved, and `ProductListItem.fromResponse` maps it directly. |

## ProductFormState (`lib/features/catalog/presentation/product_form_controller.dart`) — new fields

Local UI state only (constitution §II), not persisted. Represents an in-progress, *unsaved* photo change so FR-010 ("changes apply only on save") holds — selecting or removing a photo updates this state but does not call the API until the surrounding form is submitted.

| Field | Type | Notes |
|---|---|---|
| `photo` | `String?` | The product's currently-saved photo URL, loaded via `loadForEdit` (mirrors the existing pattern for `code`/`name`/etc.). `null` in create mode until a photo is staged. |
| `pendingPhotoBytes` | `Uint8List?` | In-memory bytes of a newly-picked image file, staged but not yet uploaded. `null` if no new photo has been picked since the form was opened/loaded. |
| `pendingPhotoFilename` | `String?` | Original filename of the staged file (used only for the upload's multipart filename; the backend renames it server-side by content hash — research.md §1). |
| `photoMarkedForRemoval` | `bool` | `true` if the user chose "remove photo" since the form was opened/loaded, and no new photo has been picked since. Mutually exclusive with a non-null `pendingPhotoBytes` (picking a new photo clears this flag; marking for removal clears `pendingPhotoBytes`/`pendingPhotoFilename`). |

**Derived display rule** (presentation-layer, not stored state): the photo shown in the form preview is — `pendingPhotoBytes` if set (show the in-memory picked image) → else placeholder if `photoMarkedForRemoval` is `true` → else `photo` if non-null → else placeholder. This same fallback also governs the catalog list and read-only detail view, minus the two pending/local-only branches (research.md §5).

## State transitions

- **Pick a new photo** (User Story 2/3): client-side validates type (JPEG/PNG) and size (≤2 MB, FR-006/FR-007) before staging; on failure, sets a field error and leaves any previously-staged/saved photo untouched. On success: `pendingPhotoBytes`/`pendingPhotoFilename` set, `photoMarkedForRemoval` reset to `false`.
- **Remove photo** (User Story 3): only enabled when there is a photo to remove (`photo != null && !photoMarkedForRemoval`) or a pending pick to discard (edge case in spec.md: remove action unavailable on a product with no photo). Sets `photoMarkedForRemoval = true`, clears `pendingPhotoBytes`/`pendingPhotoFilename`.
- **Save (create)**: `submitCreate()` creates the product first (the dedicated image-upload endpoint is keyed by `product_id`, which doesn't exist until creation succeeds — research.md §1). If `pendingPhotoBytes` is set, immediately follow with one upload call using the newly-returned `productId`. A photo-upload failure after a successful product creation is surfaced as a distinct, non-blocking warning (the product now exists; see quickstart.md) rather than rolling back the create.
- **Save (edit)**: `submitUpdate()` performs the existing field `PUT` as today, then — if `pendingPhotoBytes` is set — calls the upload endpoint; else if `photoMarkedForRemoval` is `true` — calls the raw "set photo to null" `PUT` (research.md §3); else makes no photo-related call at all (no-op when nothing changed, consistent with FR-010).
- **Discard / navigate away without saving**: per spec.md Edge Cases, no API call is ever made for a pending pick/removal until save succeeds; simply not calling save (e.g. leaving the screen) leaves the stored photo untouched by construction — no extra state needed to "roll back."

## No new repository entity, two new repository operations

`ProductRepository` (interface) gains two methods alongside the unchanged `create`/`update`/`get`/`list` (contracts/mbe-api-products-photo.md):

- `Future<Product> uploadPhoto({required int productId, required Uint8List bytes, required String filename})` — `POST /api/v1/products/{product_id}/image`, hand-rolled multipart (research.md §3). Returns the updated `Product` (the endpoint's response already includes the new `photo` URL).
- `Future<Product> removePhoto({required int productId})` — `PUT /api/v1/products/{product_id}` with a raw `{"photo": null}` JSON body (research.md §3). Returns the updated `Product`.

Both throw the same shared `AppError` family (`NotFoundError`, `ValidationError`, `ServerError`, `NetworkError`) as the existing `update`/`create` methods, via the same `_toAppError(DioException)` mapping already in `ProductRepositoryImpl`.
