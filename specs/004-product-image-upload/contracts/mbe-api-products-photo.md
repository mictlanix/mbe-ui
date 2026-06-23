# Contract: mbe-api product photo endpoints

Extends `specs/002-product-catalog/contracts/mbe-api-products.md`. Both endpoints below already exist in mbe-api (no backend change required by this feature) but the generated Dart client cannot be used as-is for either (research.md §3) — both are called via a raw `dio` request issued by `ProductRepositoryImpl`, using the same shared `Dio` instance (and its auth/error interceptors) as the generated `ProductsApi`.

## Upload / replace photo

```text
POST /api/v1/products/{product_id}/image
Auth: Bearer token (existing auth interceptor)
Server-side privilege gate: require_privilege(SystemObject.PRODUCTS, AccessRight.UPDATE)
  — already enforced server-side, unlike most product endpoints (research.md §1).
Content-Type: multipart/form-data
Body: field name "file" = image bytes (any filename; server renames by content hash)

Success: 200, body = ProductResponse (photo already rewritten to a full URL)
Failure:
  404 — product not found
  422 — file is not a decodable image, OR exceeds 2 MB (image_service._MAX_BYTES)
  401 — session invalid (existing auth interceptor handles globally)
```

**Client call** (`ProductRepositoryImpl.uploadPhoto`):

```dart
final formData = FormData.fromMap({
  'file': MultipartFile.fromBytes(bytes, filename: filename),
});
final response = await _dio.post(
  '/api/v1/products/$productId/image',
  data: formData,
);
```

Errors mapped via the same `_toAppError(DioException)` helper already used by `create`/`update` — a 422 here maps to the same `ValidationError` shape FR-006/FR-007 already render through (no new error-display path needed).

## Remove photo

```text
PUT /api/v1/products/{product_id}
Auth: Bearer token (existing auth interceptor)
Server-side privilege gate: NONE today — same pre-existing gap as the rest of
  update_product (mictlanix/mbe-api#70, already noted in 002-product-catalog's
  spec.md Assumptions). This feature gates the action fully client-side
  regardless (FR-008).
Content-Type: application/json
Body: {"photo": null}  -- MUST include the literal key with a null value;
  omitting the key leaves the existing photo untouched (research.md §1, §3).
  May be merged with other field changes in the same PUT if the user also
  edited other fields in the same save.

Success: 200, body = ProductResponse (photo now null)
Failure:
  404 — product not found
  401 — session invalid
```

**Client call** (`ProductRepositoryImpl.removePhoto`):

```dart
final response = await _dio.put(
  '/api/v1/products/$productId',
  data: {'photo': null},
);
```

## Not introduced by this feature

- No new `SystemObject` or privilege — both operations reuse `SystemObject.products` / `AccessRight.update`, already established by 002-product-catalog and the auth feature.
- No backend change — both endpoints already exist exactly as documented above; this contract only documents how the client calls them, since the generated client can't.
