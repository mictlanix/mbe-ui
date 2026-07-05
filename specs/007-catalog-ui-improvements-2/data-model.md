# Phase 1 Data Model: Catalog UI Improvements Round 2

This feature is UI-centric; the underlying mbe-api entities are unchanged. The deltas below are to **client-side domain entities, form state, and filter state**. Generated DTOs (`ProductCreate`, `ProductUpdate`, `ProductResponse`) already expose every field used here — no codegen change.

## Product (domain entity) — `features/catalog/domain/entities/product.dart`

Unchanged shape. Field-usage deltas only:

| Field | Delta |
|-------|-------|
| `sku` (`String?`) | Already present and mapped from `ProductResponse.sku`. **Now surfaced** on the form (previously never displayed). |
| `supplierId` / `supplierName` | Already present/mapped. Assign & change supported; **clear not supported** (mbe-api limitation — see plan Complexity Tracking). |
| `prices` (`List<ProductPrice>`) | Still mapped from the response (mbe-api still returns it) but **no longer displayed**. May stop being copied into `ProductFormState` since nothing reads it. Entity/DTO removal deferred to a future codegen pass when mbe-api drops prices. |
| `deactivated` (`bool`) | Retained; still used by the list's show-inactive filter and inactive badge. **No longer set from the product UI** (the soft-deactivate action is gone). |

No new fields, no validation-rule changes on the entity.

## ProductFormState — `features/catalog/presentation/product_form_controller.dart`

| Field | Change | Notes |
|-------|--------|-------|
| `sku` (`String`) | **Add** | Seeded from `Product.sku ?? ''` in `loadForEdit`; edited via `skuChanged`; sent through `create`/`update`. |
| `deleted` (`bool`, default `false`) | **Add** | Set true after a successful hard delete → triggers `context.pop()` (mirrors existing `saved` flag and `UserFormState.deleted`). |
| `prices` (`List<ProductPrice>`) | **Remove usage** | No UI consumer after FR-012; may be dropped from state, or left populated-but-unread if that minimizes churn. |
| (unchanged) `code, name, unitOfMeasurement…, supplierId, supplierName, labelIds, photo…` | — | Existing fields keep their behavior. |

Controller method deltas:

- **Add** `skuChanged(String)`.
- **Replace** `deactivate()` → `delete()`: calls `ProductRepository.delete(productId:)`; on success `state = state.copyWith(submitting:false, deleted:true)`; on `DioException` map to the existing `error`/`errorDetail` state. Guarded by `can(products, delete)` (same as today's deactivate guard) but **not** by `state.deactivated`.
- `ProductFormErrorCode`: rename `deactivate*` codes → `delete*` (or add `deleteFailed`, `deletePermissionDenied`) and update `_localizeFormError`.

## ProductFilter — `features/catalog/presentation/products_list_controller.dart`

| Field | Before | After |
|-------|--------|-------|
| label facet | `label` (`int?`) | `labels` (`List<int>`, default `const []`) |

Derived/behavior deltas:

- `activeFilterCount`: replace `if (label != null) count++` with `count += labels.length` (each selected label counts, per FR-009) — or `if (labels.isNotEmpty) count++` if the count should reflect "label filter active" rather than per-label; **chosen: `+= labels.length`** to match FR-009 "reflect the number of labels selected."
- `hasActiveFilters`: include `labels.isNotEmpty`.
- `reset`: clears `labels` to `const []`.
- Controller: replace `labelChanged(int?)` with `labelsChanged(List<int>)` (or `labelToggled(int)` that adds/removes).
- List controller → `productRepository.list(labels: filter.labels, …)`.

**Filter semantics**: OR — a product matches if it carries **any** selected label (spec FR-008, Assumption). Empty `labels` ⇒ no label filtering (same as the old `null`).

## Repository interface — `features/catalog/domain/repositories/product_repository.dart`

| Method | Change |
|--------|--------|
| `list({… label:int? …})` | Change to `labels: List<int> = const []` (or add alongside and deprecate `label`). |
| `create({…})` | **Add** `String? sku` param. |
| `update({…})` | **Add** `String? sku` param. |
| `delete({required int productId})` | **Add** — hard delete via `deleteProductApiV1ProductsProductIdDelete`; returns `Future<void>`. Update the interface doc comment that currently says delete is "intentionally never added." |

## State transitions

Product lifecycle from the UI after this feature:

```
        create ──▶ [active product]
                        │
             edit ◀────┤ (row Edit / edit-switch button)
                        │
    row click ─────────┤────▶ [read-only View]
                        │
           Delete ─────▶ [permanently removed]   (hard delete; irreversible)
```

The prior `active ──deactivate──▶ inactive` transition is **no longer reachable from the product UI** (the soft-deactivate action is replaced by hard Delete). Pre-existing `inactive` records remain visible/filterable via the list's show-inactive facet.
