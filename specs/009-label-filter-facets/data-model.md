# Phase 1 — Data Model: Faceted Label Filtering

## Domain entity: `ProductLabelFacet`

New `freezed` entity in `lib/features/catalog/domain/entities/product_label_facet.dart`, mapped from the generated `ProductLabelFacet` DTO once mbe-api#78 ships and codegen re-runs.

| Field | Type | Notes |
|-------|------|-------|
| `labelId` | `int` | Maps from response `label_id`. Corresponds to `LabelItem.labelId`. |
| `count` | `int` | Number of products in the current filtered set that carry this label. `> 0` for every returned row (labels absent from the response have count 0 → unavailable). |

```dart
@freezed
class ProductLabelFacet with _$ProductLabelFacet {
  const factory ProductLabelFacet({
    required int labelId,
    required int count,
  }) = _ProductLabelFacet;

  factory ProductLabelFacet.fromResponse(/* generated */ r) =>
      ProductLabelFacet(labelId: r.labelId, count: r.count);
}
```

**Validation / invariants**:
- The response is a (possibly empty) list; an empty list means *no* label co-occurs with the current filter (e.g. the filtered set is empty) → every non-selected chip disabled.
- Counts are informational for v1 (not displayed); reserved for a future "count on chip" enhancement.

## Derived value: label availability (`Set<int>`)

The drawer needs O(1) per-chip availability, so the provider reduces `List<ProductLabelFacet>` to the set of available label ids:

```dart
Set<int> availableIds = facets.map((f) => f.labelId).toSet();
```

Consumed by `LabelMultiPicker` (see contracts/ui-contracts.md). Chip enabled ⇔ `selectedIds.contains(id) || availableIds.contains(id)`.

## Provider: `productLabelFacetsProvider`

`@riverpod` **autodispose**, in `lib/features/catalog/presentation/products_list_controller.dart` (alongside the existing filter/list controllers).

- **Signature**: `Future<Set<int>>` exposed as `AsyncValue<Set<int>>`.
- **Inputs**: watches `productFilterControllerProvider` → the current `ProductFilter` (search + attributes + selected labels).
- **Body**: calls `productRepository.productLabelFacets(...)` with the same fields the list uses (`search`, `deactivated`, `stockable`, `salable`, `purchasable`, `labels`), maps the result to the id set. **No** `skip`/`limit` (whole matching set).
- **Lifecycle**: autodispose → fires only while `_ProductFiltersPanel` watches it (drawer open); refetches on every filter change; disposed when the drawer closes.

```dart
@riverpod
Future<Set<int>> productLabelFacets(Ref ref) async {
  final filter = ref.watch(productFilterControllerProvider);
  final facets = await ref.read(productRepositoryProvider).productLabelFacets(
        search: filter.search.isEmpty ? null : filter.search,
        deactivated: filter.deactivated,
        stockable: filter.stockable,
        salable: filter.salable,
        purchasable: filter.purchasable,
        labels: filter.labels,
      );
  return facets.map((f) => f.labelId).toSet();
}
```

**Consumption (fail-open)** in `_ProductFiltersPanel`:

```dart
final availableIds = ref.watch(productLabelFacetsProvider).valueOrNull; // null while loading/errored
LabelMultiPicker(
  labels: allLabels,
  selectedIds: filter.labels,
  availableIds: availableIds,      // null → all chips enabled (fail open, FR-010)
  onChanged: filterController.labelsChanged,
);
```

## Reused: `ProductFilter`

Unchanged (`lib/features/catalog/presentation/products_list_controller.dart`). `labels` (AND-interpreted) already drives the list query; the facets provider reuses the same instance so availability always reflects the exact current filter. The stale "OR" comment on `ProductFilterBadge.activeFilterCount` / the `labels` field is corrected to "AND (contains all)".

## Reused: `LabelItem`

Unchanged (`labelId`, `name`). The drawer keeps rendering the full `allLabelsProvider` list; availability only toggles each chip's enabled state — labels are never removed from the drawer, so a currently-disabled label reappears as enabled when the filter changes.

## Relationships

```text
ProductFilter ──watched by──▶ productLabelFacetsProvider ──calls──▶ ProductRepository.productLabelFacets
                                        │                                    │
                                        ▼                                    ▼
                                 Set<int> availableIds              GET /products/labels/facets  (mbe-api#78)
                                        │                                    │
                                        ▼                                    ▼
                          LabelMultiPicker(availableIds:)          List<ProductLabelFacet>
allLabelsProvider ──List<LabelItem>──▶ (chips: enabled = selected || available)
```
