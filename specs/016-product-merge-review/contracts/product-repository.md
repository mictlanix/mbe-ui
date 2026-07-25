# Contract: Reusing `ProductRepository.get` for the comparison fetch

No new method is added to `ProductRepository` (`lib/features/catalog/domain/repositories/product_repository.dart`). This feature is a consumer of the existing method:

```dart
/// `GET /api/v1/products/{product_id}` (FR-008 of spec 002/existing product
/// feature). Throws `NotFoundError` on `404`.
Future<Product> get({required int productId});
```

## New usage: parallel comparison fetch

A new presentation-layer provider (`merge_products_comparison_provider.dart`) calls `get()` twice — once for `canonical.productId`, once for `duplicate.productId` — concurrently:

```dart
@riverpod
Future<(Product, Product)> mergeComparison(
  Ref ref, {
  required int canonicalId,
  required int duplicateId,
}) async {
  final repository = ref.read(productRepositoryProvider);
  final results = await Future.wait([
    repository.get(productId: canonicalId),
    repository.get(productId: duplicateId),
  ]);
  return (results[0], results[1]);
}
```

- Only invoked once `MergeProductsState.reviewReady` is true (data-model.md); the screen watches this provider keyed by the current `canonical`/`duplicate` ids and rebuilds the fetch whenever either id changes (including after `swap()`, which exchanges which id is "canonical").
- `AsyncLoading` → the review step shows a loading state in place of the panels/diff table (no partial/stale render).
- `AsyncError` (e.g. `NotFoundError` if a product was deleted by another session between selection and review) → the review step shows the shared error banner and does not allow proceeding to the final confirmation (FR-011); the picker selections themselves are untouched, matching spec 008's existing "preserve selections on failure" convention.
- `AsyncData((kept, deleted))` → feeds the panels and the diff table (data-model.md).

## No change to `mergeProducts()`

The existing merge call (`ProductRepository.mergeProducts({required int productId, required int duplicateId})`, spec 008) is unchanged — it is still invoked from `MergeProductsController.submit()` with `productId: canonical.productId, duplicateId: duplicate.productId`, using whichever product currently holds the `canonical` role after any swap (research.md §2).

## Not implemented in this pass: related-record counts

No repository method is added for FR-006 (Story 5)'s related-record counts. The backend endpoint it would call does not exist yet — tracked as [mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111) (Complexity Tracking, plan.md). Once it ships, a follow-up will add a method here (e.g. `mergePreview({required int productId, required int duplicateId})`) and this document will be updated alongside it.
