# Contract: `ProductRepository.mergeProducts`

Adds one method to the existing `ProductRepository` domain interface
(`lib/features/catalog/domain/repositories/product_repository.dart`) and its
implementation (`lib/features/catalog/data/product_repository_impl.dart`).

## Domain interface

```dart
/// `POST /api/v1/products/merge` (FR-008). Merges [duplicateId] into
/// [productId]: mbe-api remaps the duplicate's transactional references
/// (sales/purchase order details, inventory receipt/issue/transfer details,
/// lot-serial tracking, …) and its labels onto the canonical product, deletes
/// the duplicate's price and label rows, then permanently deletes the
/// duplicate. Irreversible; there is no undo.
///
/// Returns normally on `204 No Content`. Throws:
/// - `ServerError(statusCode: 400, message: …)` if [productId] == [duplicateId]
///   ("Cannot merge a product with itself") — a backstop; the UI blocks this
///   client-side (FR-006).
/// - `NotFoundError(message: …)` on `404` if the canonical or duplicate
///   product no longer exists (FR-011).
/// - `ServerError` / `NetworkError` on other backend/transport failures
///   (FR-011) — surfaced with mbe-api's `detail` message where present.
Future<void> mergeProducts({
  required int productId,
  required int duplicateId,
});
```

## Data implementation

```dart
@override
Future<void> mergeProducts({
  required int productId,
  required int duplicateId,
}) async {
  try {
    await _api.mergeProductsApiV1ProductsMergePost(
      productMergeRequest: ProductMergeRequest((b) => b
        ..productId = productId
        ..duplicateId = duplicateId),
    );
  } on DioException catch (e) {
    throw _toAppError(e);
  }
}
```

- The generated method returns `Response<void>`; a `204` needs no body handling
  (unlike `list`/`get`, there is no `response.data == null` check).
- Error handling reuses the existing `_toAppError(e)` → `mapDioException(e)`
  chain (`auth_interceptor.dart:41`), which yields the `AppError` variants above.

## Notes

- No server-side privilege dependency to track for the UI: unlike the
  general product CRUD endpoints (which are not yet privilege-gated —
  mictlanix/mbe-api#70), the merge endpoint **is** already gated
  (`require_privilege(PRODUCTS_MERGE, CREATE)`), so an unauthorized call
  returns `403`. The UI gates the action client-side regardless (constitution
  §IV); a `403` would map to `ServerError` and surface as a generic error.
- Product **search** for the pickers does **not** need a new method — it reuses
  the existing `list(search:, deactivated: null, limit: 15)` (research §2).
