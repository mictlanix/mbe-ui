# Contract: ProductRepository deltas

Repository interface (`features/catalog/domain/repositories/product_repository.dart`) and its impl (`features/catalog/data/product_repository_impl.dart`). All calls go through the generated `ProductsApi` (constitution §III); no hand-written DTOs.

## delete (NEW)

```dart
Future<void> delete({required int productId});
```

- Impl calls `_api.deleteProductApiV1ProductsProductIdDelete(productId: productId)`.
- **Hard delete** — permanently removes the product (mbe-api also deletes its `ProductPrice` rows server-side). Irreversible.
- Maps `DioException` → the shared `AppError` types (`_toAppError`) so callers surface server messages (e.g. a referential-integrity 409/400) via the error banner.
- Update the interface doc comment that currently states delete is "intentionally never added — soft delete goes through update."
- RBAC: callers MUST gate on `can(products, delete)`; the endpoint itself also requires the `PRODUCTS/DELETE` privilege server-side.

## create (ADD `sku`)

```dart
Future<Product> create({
  required String code,
  required String name,
  required String unitOfMeasurement,
  String? sku,            // NEW → ProductCreate.sku (already generated)
  String? brand,
  // …existing params unchanged…
  int? supplier,
  String? key,
  List<int> labels = const [],
});
```

- Impl sets `b.sku = sku;` in the `ProductCreate((b) { … })` builder.

## update (ADD `sku`)

```dart
Future<Product> update({
  required int productId,
  String? code,
  String? name,
  String? sku,            // NEW → ProductUpdate.sku (already generated)
  // …existing params unchanged…
  int? supplier,
  List<int>? labels,
});
```

- Impl sets `if (sku != null) b.sku = sku;` in the `ProductUpdate((b) { … })` builder, following the existing "only send non-null" convention.
- **Supplier note**: the existing `if (supplier != null) b.supplier = supplier;` stays. Sending `null` cannot clear the supplier (mbe-api treats null as "leave unchanged"), so supplier-*clear* is not delivered by this feature.
- `deactivated` param becomes unused by the product UI (the delete flow no longer calls `update(deactivated: true)`). Leave the param on the interface for now (harmless) or remove if no caller remains — verify at implementation.

## list (label → labels)

```dart
Future<ProductListResult> list({
  // …
  List<int> labels = const [],   // was: int? label
  // …
});
```

- Forward `labels` to the generated products-list call's label filter.
- **Dependency**: if the generated endpoint accepts only a single `label` query param, true multi-label OR filtering needs an mbe-api change; confirm during implementation and flag if unsupported (see research §4). Do not silently drop selected labels.
