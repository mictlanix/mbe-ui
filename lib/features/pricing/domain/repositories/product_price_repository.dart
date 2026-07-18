import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';

/// Product-price calls to mbe-api (contracts/mbe-api-pricing.md §2). Access
/// is gated by `AccessControlService.can(SystemObject.pricing, ...)` at the
/// screen level.
abstract class ProductPriceRepository {
  /// `GET /api/v1/product-prices?product={id}` (research.md §5). [limit]
  /// MUST be passed explicitly and cover the price-list count — the API
  /// defaults to 20, which would silently truncate a product priced across
  /// more than 20 lists (contracts/mbe-api-pricing.md G5).
  Future<List<ProductPrice>> listByProduct({
    required int productId,
    required int limit,
  });

  /// `POST /api/v1/product-prices` (FR-009) — creates a price row for a
  /// price list the product has none on yet. Throws `ValidationError` on
  /// `422`.
  Future<ProductPrice> create({
    required int productId,
    required int priceListId,
    required String price,
    required String lowProfit,
    required String highProfit,
  });

  /// `PUT /api/v1/product-prices/{product_price_id}` (FR-010) — revalues an
  /// existing price row. Cannot move a row between products/lists (data-model.md
  /// §2). Throws `NotFoundError` on `404`, `ValidationError` on `422`.
  Future<ProductPrice> update({
    required int productPriceId,
    required String price,
    required String lowProfit,
    required String highProfit,
  });
}
