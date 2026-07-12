# Phase 1 Data Model: Merge Products

This feature adds no persisted entities and no new domain entity for the catalog — it composes existing ones. It introduces one presentation-layer state object and reuses the generated request DTO.

## Reused types

### `ProductListItem` (domain, existing) — the picker suggestion

`lib/features/catalog/domain/entities/product_list_item.dart`. Both pickers surface `ProductListItem`s returned by `ProductRepository.list`. Relevant fields used by the merge pickers:

| Field | Use in merge |
|-------|--------------|
| `productId` | The value written into `ProductMergeRequest.product_id` / `duplicate_id`. |
| `name` | Suggestion title + selected-field display text. |
| `code` | Suggestion subtitle. |
| `model` | Suggestion subtitle. |
| `brand` | Optional suggestion subtitle detail. |
| `photo` | Resolved thumbnail URL for the suggestion leading image. |
| `deactivated` | Not filtered on — both pickers surface products in any state. |

> **SKU** is currently absent from this projection (see research §3). It is searchable server-side but not yet shown in the row — tracked via [mictlanix/mbe-api#76](https://github.com/mictlanix/mbe-api/issues/76); add a `sku` field here once that lands and the client is regenerated.

### `ProductMergeRequest` (generated DTO, existing)

`lib/generated/openapi/lib/src/model/product_merge_request.dart`. Fields: `product_id: int`, `duplicate_id: int`. Built in `data/` and passed to `mergeProductsApiV1ProductsMergePost`. Never surfaced to `presentation`.

## New presentation state

### `MergeProductsState`

Held by `MergeProductsController` (a Riverpod `Notifier`). Plain immutable value (freezed or a small hand-written class consistent with the module's other form states).

| Field | Type | Meaning |
|-------|------|---------|
| `canonical` | `ProductListItem?` | The selected "Product" (kept). `null` until chosen. |
| `duplicate` | `ProductListItem?` | The selected "Duplicate" (removed). `null` until chosen. |
| `submission` | `AsyncValue<void>` | `AsyncData` (idle/success), `AsyncLoading` (in-flight), `AsyncError(AppError)` (failed). Drives the in-flight lock and the error banner. |

**Derived (computed) properties**

| Property | Rule |
|----------|------|
| `bothSelected` | `canonical != null && duplicate != null` |
| `isSameProduct` | `canonical?.productId == duplicate?.productId` (when both set) |
| `canSubmit` | `bothSelected && !isSameProduct && !submission.isLoading` |
| `validationMessage` | localized "both required" when `!bothSelected`; localized "cannot merge with itself" when `isSameProduct`; else `null` |

**Transitions**

- `canonicalSelected(item)` / `duplicateSelected(item)` → set the field; leave `submission` untouched (clears any prior error is optional — keep the error until a new submit).
- `canonicalCleared()` / `duplicateCleared()` → set the field back to `null`.
- `submit()` → guard on `canSubmit`; set `submission = AsyncLoading`; call `repository.mergeProducts(productId: canonical!.productId, duplicateId: duplicate!.productId)`; on success `submission = AsyncData` and signal the screen to confirm + navigate; on `AppError` `submission = AsyncError(e)` **without** clearing `canonical`/`duplicate` (FR-011 — preserve selections).

## Validation rules (from requirements)

| Rule | Source | Enforced |
|------|--------|----------|
| Both products required | FR-005 | client (`canSubmit`/`validationMessage`) |
| Product ≠ Duplicate | FR-006 | client (`isSameProduct`) **and** server (400 backstop) |
| Explicit permanence confirmation before submit | FR-007 | screen (confirm dialog gates `submit()`) |
| No double-submit while in flight | FR-009 | client (`submission.isLoading` disables action) |
| Selections preserved on failure | FR-011 | controller (error path does not reset fields) |

## RBAC

| Gate | Check |
|------|-------|
| Route access, entry point, submit | `can(SystemObject.productsMerge, AccessRight.create)` |

Mirrors mbe-api's `require_privilege(PRODUCTS_MERGE, CREATE)` (research §5).
