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
}

/// `ListResponse[ProductListItem]` (`items`, `total`) — used by
/// `ProductsListController` for pagination (research.md §5).
class ProductListResult {
  const ProductListResult({required this.items, required this.total});

  final List<ProductListItem> items;
  final int total;
}
