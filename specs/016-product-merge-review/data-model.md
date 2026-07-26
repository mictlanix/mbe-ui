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

## New: `MergePreview` (domain entity)

`lib/features/catalog/domain/entities/merge_preview.dart`. Mapped in `data/` from the generated `ProductMergePreviewResponse` before reaching `presentation` (constitution §III). Backs FR-006 / Story 5.

| Field | Type | Meaning |
|-------|------|---------|
| `categories` | `List<MergePreviewCategory>` | One entry per category of record attached to the product marked for deletion, as returned by the preview endpoint. Order preserved from the server (largest count first). |
| `total` | `int` | Server-computed sum across `categories`. Displayed as-is, never recomputed client-side, so the displayed total always matches the server's own accounting (SC-006). |

### `MergePreviewCategory`

| Field | Type | Meaning |
|-------|------|---------|
| `key` | `String` | The raw `table.column` identifier from the API (e.g. `sales_order_detail.product`). Preserved verbatim — it is the lookup key for the label map and the fallback. |
| `count` | `int` | How many rows in that relation point at the product marked for deletion. |

**Derived**

| Property | Rule |
|----------|------|
| `isDestroyed` | `key` starts with `product_price.` — those rows are deleted by the merge rather than moved (research.md §4), so the UI labels them differently. Every other category moves to the kept product. |

### Category label resolution (FR-006 / Story 5 #3)

The API's category set is derived from mbe-api's mapped metadata and grows whenever a new foreign key to `product` is added, with no mbe-ui change. Resolution is therefore two-tier:

1. **Known key → localized label.** A lookup table in the presentation layer maps the keys known today (sales/purchase order detail, the three inventory movement details, lot-serial tracking, price list, label, fiscal document detail, commission product, customer discount) to `.arb` strings.
2. **Unknown key → humanized fallback.** Anything unrecognized is rendered from the raw key (strip the `.column` suffix, replace underscores with spaces, sentence-case) rather than dropped. A category is **never** omitted from the list and never excluded from the displayed total — dropping one would understate the blast radius, the opposite of this feature's purpose.

## Validation rules (from requirements)

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
| Related-record counts sourced from the server, never estimated or fabricated | FR-006 | client (`MergePreview` from the preview endpoint; section omitted on failure, never zero-filled) |
| Every returned category is displayed; total matches the sum shown | FR-006, SC-006 | client (label fallback for unknown keys — no silent drops) |
| Price-list rows described as destroyed, not reassigned | FR-006 (Story 5 #2) | client (`MergePreviewCategory.isDestroyed`) |
| Preview failure does not block the merge | FR-006 (Story 5 #4) | client (summary is informational; only the comparison fetch gates continuation) |

## RBAC

Unchanged from spec 008: `can(SystemObject.productsMerge, AccessRight.create)` gates the route, entry point, and submit action. This feature adds no new client-side gate — the review step is additional content inside the already-gated screen.

Server-side, the preview endpoint requires `PRODUCTS_MERGE` at **read** level while the merge itself requires **create**. Any user who can reach this screen already holds create on that object, so no additional client-side check is needed for the preview call; a `403` would surface through the normal error path.
