# Contract: `ProductRepository.productLabelFacets()`

New method on the `domain` `ProductRepository` interface, implemented in `data/product_repository_impl.dart` via the generated facets API method (after mbe-api#78 regen).

## Signature

```dart
/// `GET /api/v1/products/labels/facets` (spec 009 FR-003, FR-009). Returns,
/// for the products matching the same filter as [list] (minus pagination),
/// the labels present on at least one matching product with their per-label
/// match count. Drives the filter drawer's enable/disable of label chips.
///
/// [labels] uses AND ("contains all") semantics, identical to [list].
/// Returns an empty list when no label co-occurs with the filter.
Future<List<ProductLabelFacet>> productLabelFacets({
  String? search,
  bool? deactivated,
  bool? stockable,
  bool? salable,
  bool? purchasable,
  List<int> labels = const [],
});
```

## Behavior

- Forwards each non-null filter to the generated facets endpoint; sends `label` as a `BuiltList<int>` only when `labels` is non-empty (mirrors `list`'s `label: labels.isEmpty ? null : BuiltList<int>(labels)`).
- Maps each generated row to `ProductLabelFacet.fromResponse`.
- Null/empty response body → returns `const []` (treated as "nothing available"; the provider fails open only on *thrown* errors, not on a legitimately empty set — an empty set correctly disables all non-selected chips when the filtered result is empty).

## Errors

- On `DioException`, throw the mapped `AppError` (reuse the impl's existing `_toAppError`). The **provider** (`productLabelFacetsProvider`) is responsible for fail-open behavior: it surfaces the error via `AsyncValue`, and `_ProductFiltersPanel` reads `.valueOrNull` (null → all chips enabled, FR-010). The repository itself does not swallow errors.

## Docstring correction (same PR)

- Fix `ProductRepository.list`'s docstring: it currently says `[labels]` uses "OR semantics"; the server has used AND ("contains all") since 2026-07-05. Update to state AND, matching `productLabelFacets` and `activeFilterCount`.

## Testing

- Unit test with `ProductsApi` (or dio) mocked: filter params forwarded correctly; response rows mapped to entities; empty body → `[]`; `DioException` → mapped `AppError`.
