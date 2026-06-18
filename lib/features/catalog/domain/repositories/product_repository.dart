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
}

/// `ListResponse[ProductListItem]` (`items`, `total`) — used by
/// `ProductsListController` for pagination (research.md §5).
class ProductListResult {
  const ProductListResult({required this.items, required this.total});

  final List<ProductListItem> items;
  final int total;
}
