import 'dart:typed_data';

import 'package:mbe_ui/features/catalog/domain/entities/product.dart';
import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';

/// Product catalog calls to mbe-api (contracts/mbe-api-products.md). Access
/// is gated by `AccessControlService.can(SystemObject.products, ...)` at the
/// screen level (research.md §1 — these endpoints are not yet server-side
/// privilege-gated; tracked as mictlanix/mbe-api#70).
///
/// `create`/`update` are added by later tasks (T018, T026) as their user
/// stories are implemented; `delete` (hard delete) is intentionally never
/// added — soft delete goes through `update` (research.md §2).
abstract class ProductRepository {
  /// `GET /api/v1/products` (FR-001, FR-002).
  Future<ProductListResult> list({
    String? search,
    bool? deactivated,
    bool? stockable,
    bool? salable,
    bool? purchasable,
    int skip = 0,
    int limit = 20,
  });

  /// `GET /api/v1/products/{product_id}` (FR-008). Throws `NotFoundError` on
  /// `404`.
  Future<Product> get({required int productId});

  /// `POST /api/v1/products` (FR-003). Throws `ValidationError` on `422`
  /// (e.g. duplicate code, invalid name length, invalid barcode).
  Future<Product> create({
    required String code,
    required String name,
    required String unitOfMeasurement,
    String? brand,
    String? model,
    String? barCode,
    String? location,
    String? taxRate,
    String? comment,
    bool stockable = false,
    bool perishable = false,
    bool seriable = false,
    bool purchasable = false,
    bool salable = false,
    bool invoiceable = false,
  });

  /// `PUT /api/v1/products/{product_id}` (FR-009, FR-010). All fields
  /// optional; only non-null values are sent (mirrors `UserRepository.
  /// update`'s convention). Used both for ordinary edits (FR-009) and for
  /// soft-delete (FR-010 — call with only `deactivated: true`). Throws
  /// `NotFoundError` on `404`, `ValidationError` on `422` (e.g. duplicate
  /// code on rename).
  Future<Product> update({
    required int productId,
    String? code,
    String? name,
    String? unitOfMeasurement,
    String? brand,
    String? model,
    String? barCode,
    String? location,
    String? taxRate,
    String? comment,
    bool? stockable,
    bool? perishable,
    bool? seriable,
    bool? purchasable,
    bool? salable,
    bool? invoiceable,
    bool? deactivated,
  });

  /// `POST /api/v1/products/{product_id}/image` (FR-003, FR-004). Issued as
  /// a raw multipart `dio` call rather than through the generated client —
  /// the generated method's `file` param is codegen'd as a plain string,
  /// not a binary-capable parameter (research.md §3, contracts/
  /// mbe-api-products-photo.md). Throws `NotFoundError` on `404`,
  /// `ValidationError` on `422` (unsupported image type or over the 2 MB
  /// limit).
  Future<Product> uploadPhoto({
    required int productId,
    required Uint8List bytes,
    required String filename,
  });

  /// `PUT /api/v1/products/{product_id}` with a raw `{"photo": null}` body
  /// (FR-005). Issued as a raw `dio` call rather than through the generated
  /// `ProductUpdate` model — that model's serializer never emits a field
  /// once it's `null`, so it cannot express "clear this field" (research.md
  /// §3, contracts/mbe-api-products-photo.md). Throws `NotFoundError` on
  /// `404`.
  Future<Product> removePhoto({required int productId});
}

/// `ListResponse[ProductListItem]` (`items`, `total`) — used by
/// `ProductsListController` for pagination (research.md §5).
class ProductListResult {
  const ProductListResult({required this.items, required this.total});

  final List<ProductListItem> items;
  final int total;
}
