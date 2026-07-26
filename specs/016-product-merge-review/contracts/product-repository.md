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

## New method: `mergePreview()` (FR-006 / Story 5)

The endpoint this originally waited on has shipped ([mictlanix/mbe-api#111](https://github.com/mictlanix/mbe-api/issues/111), closed) and mbe-ui's client is already regenerated against it (mbe-ui `2d9b1e5`), so one method is added to the domain interface:

```dart
/// `GET /api/v1/products/merge/preview` (FR-006). Reports every category of
/// record attached to [duplicateId] together with its count and a server-computed
/// total — the blast radius of merging [duplicateId] into [productId] — without
/// modifying anything.
///
/// Server-side this validates the pair through the same guard the real merge
/// uses, so a preview that answers describes the same pair a merge would act on.
/// Requires `PRODUCTS_MERGE` at read level (the merge itself requires create),
/// so any user who can reach the merge screen can call this.
///
/// Throws `NotFoundError` on `404` (either product missing), `ServerError` on a
/// rejected pair (e.g. self-merge) or other backend failure, `NetworkError` on
/// transport failure. Callers treat any failure as "omit the summary" — it is
/// informational and MUST NOT block the merge (Story 5 #4).
Future<MergePreview> mergePreview({
  required int productId,
  required int duplicateId,
});
```

### Data implementation

```dart
@override
Future<MergePreview> mergePreview({
  required int productId,
  required int duplicateId,
}) async {
  try {
    final response = await _api.previewProductMergeApiV1ProductsMergePreviewGet(
      productId: productId,
      duplicateId: duplicateId,
    );
    return MergePreview.fromResponse(response.data!);
  } on DioException catch (e) {
    throw _toAppError(e);
  }
}
```

- `MergePreview.fromResponse` maps the generated `ProductMergePreviewResponse` (`items: BuiltList<ProductMergePreviewItem>{category, count}`, `total: int`) into the domain entity from data-model.md, preserving the server's category order and its `total` verbatim (never recomputed — SC-006).
- The `category` string is carried through **unmodified** as `MergePreviewCategory.key`; all label resolution (known-key lookup, humanized fallback) happens in `presentation`, not here, so the domain entity stays free of display concerns.
- Error handling reuses the existing `_toAppError(e)` → `mapDioException(e)` chain, same as `mergeProducts`.

### Provider

A second `@riverpod` function provider (alongside the comparison fetch) keyed by `(canonicalId, duplicateId)` exposes `AsyncValue<MergePreview>`. It is **independent** of the comparison provider: the review step renders panels and the diff table as soon as the comparison resolves, and slots the summary in when the preview resolves. A preview `AsyncError` leaves the rest of the review step fully functional and the merge button unaffected (Story 5 #4) — unlike a comparison failure, which does block (FR-011).
