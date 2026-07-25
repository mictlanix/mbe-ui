# Phase 1 Data Model: Merge Products — Explicit Kept/Deleted Review

This feature adds no new persisted or domain entity — it extends spec 008's presentation-layer state and composes the existing `Product` entity into a comparison view.

## Extended: `MergeProductsState`

`lib/features/catalog/presentation/merge_products_state.dart`. All spec 008 fields (`canonical`, `duplicate`, `submission`, `merged`) are unchanged in shape and meaning; this feature adds one field and updates one derived property.

| Field | Type | Meaning |
|-------|------|---------|
| `canonical` | `ProductListItem?` | Unchanged from spec 008 — the selection currently in the "kept" role. |
| `duplicate` | `ProductListItem?` | Unchanged from spec 008 — the selection currently in the "deleted" role. |
| `submission` | `AsyncValue<void>` | Unchanged from spec 008. |
| `merged` | `bool` | Unchanged from spec 008. |
| **`acknowledged`** | `bool` (new, default `false`) | `true` once the operator has checked the acknowledgment naming the product currently in the `duplicate` (deleted) role. Reset to `false` by any mutator that changes `canonical` or `duplicate` (FR-008). |

**Derived (computed) properties**

| Property | Rule | Change from spec 008 |
|----------|------|-----------------------|
| `bothSelected` | `canonical != null && duplicate != null` | Unchanged. |
| `isSameProduct` | `canonical?.productId == duplicate?.productId` | Unchanged. |
| `reviewReady` | `bothSelected && !isSameProduct` | **New** — gates whether the review step (panels, diff table, acknowledgment) renders at all (FR-001). |
| `canSubmit` | `reviewReady && acknowledged && !submission.isLoading` | **Changed** — spec 008's `canSubmit` did not require `acknowledged`; this feature adds that requirement (FR-007) ahead of the unchanged final confirmation dialog. |
| `validationMessageCode` | Unchanged rule set (`bothRequired` / `sameProduct` / `null`) | Unchanged — `acknowledged` is not a "validation error", it's an unchecked gate on an otherwise-valid review, communicated by the disabled submit button + visible checkbox, not an error message. |

**New transitions**

- `swap()` → exchanges `canonical` and `duplicate` (research.md §2); resets `acknowledged` to `false` (FR-008, since the product now in the `duplicate`/deleted role has changed).
- `acknowledgeToggled()` → flips `acknowledged`. No-op guard needed: this control is only rendered/enabled when `reviewReady` is true.
- Existing `canonicalSelected`/`duplicateSelected`/`canonicalCleared`/`duplicateCleared` (spec 008, unchanged signatures) additionally reset `acknowledged: false` on every call.

## New: comparison view (not persisted, derived per render)

Fetched by a new `@riverpod` function provider (e.g. `mergeComparisonProvider`), keyed by `(canonicalId: int, duplicateId: int)`, that calls `ProductRepository.get(productId:)` once for each id (in parallel) and exposes an `AsyncValue<(Product kept, Product deleted)>` — a record/tuple, not a new named class, since it is only ever destructured immediately into the two panels and the diff table.

| Source | Field | Used in |
|--------|-------|---------|
| `Product` (kept) | `productId, photo, name, code, sku, model, status, unitOfMeasurementName, taxRate` | Kept panel (FR-003) |
| `Product` (deleted) | same fields | Deleted panel (FR-003), name rendered struck through (FR-002) |
| Both | `productId, code, sku, model, brand, unitOfMeasurementName, taxRate, status` | Diff table rows (FR-005) — one row per field, each row's `diff` flag = `kept.field != deleted.field` |

No new fields are requested from mbe-api for this table — every field it needs is already present on the existing `Product` entity (`lib/features/catalog/domain/entities/product.dart`).

### Related-record summary (FR-006) — not modeled in this pass

No view model is introduced for the "will be reassigned" summary. Per research.md §4, the backend capability it would depend on does not exist yet ([mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111)); the summary section is simply not rendered. When the endpoint ships, this section will be added as a follow-up data-model entry alongside the new repository method and generated client types at that time.

## Validation rules (from requirements)

| Rule | Source | Enforced |
|------|--------|----------|
| Both products required, distinct | FR-001 (spec 008 FR-005/006, unchanged) | client (`reviewReady`) |
| Review step shows full-record comparison, not picker projection | FR-003, FR-005 | client (`mergeComparisonProvider` fetch) |
| Swap exchanges roles consistently | FR-004 | client (`swap()`) |
| Differing fields visually flagged | FR-005 | client (diff-row computation) |
| Acknowledgment required and tied to the current deleted product | FR-007, FR-008 | client (`canSubmit`, `acknowledged` reset rules) |
| Final confirmation restates both products by name and code | FR-009 (spec 008's dialog, extended) | screen (`_confirmMerge`, extended) |
| Full product fetch failure blocks proceeding | FR-011 | client (comparison provider's `AsyncError` disables the review step's continuation) |
| Related-record counts shown only when determinable, never fabricated | FR-006 | client (section omitted outright — research.md §4) |

## RBAC

Unchanged from spec 008: `can(SystemObject.productsMerge, AccessRight.create)` gates the route, entry point, and submit action. This feature adds no new gate — the review step is additional content inside the already-gated screen.
