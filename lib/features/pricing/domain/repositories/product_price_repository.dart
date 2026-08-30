import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';

/// mbe-api's `BULK_LIMIT` — the largest page `GET /product-prices` returns
/// and the largest body `PUT /product-prices` accepts (one number for both,
/// so a page that can be read can always be written back). Mirrored here
/// because the grid sizes its own reads against it.
const kProductPriceBulkLimit = 500;

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

  /// Every price on [priceListIds] for [productIds] (spec 033
  /// contracts/mbe-api-pricing.md §3, data-model.md §2) — **one** request
  /// since mbe-api#182 made `product` repeatable. It shipped as a fan-out
  /// over [listByProduct] behind this same signature, so the change landed
  /// in the implementation alone (research.md §R5).
  ///
  /// Bounded by [kProductPriceBulkLimit]: `productIds.length *
  /// priceListIds.length` must stay under it or the page comes back
  /// truncated, which reads as "these products have no price".
  Future<List<ProductPrice>> listForProducts({
    required List<int> productIds,
    required List<int> priceListIds,
  });

  /// `POST /api/v1/product-prices` (FR-009) — creates a price row for a
  /// price list the product has none on yet. Throws `ValidationError` on
  /// `422`.
  ///
  /// [lowProfit]/[highProfit] are **deprecated** (mbe-api#185) and should be
  /// omitted: the sales-order margin validation that read them is retired,
  /// and a created row takes its band from the price list's own margins
  /// server-side. Passing them is still honoured, for the one screen that
  /// still edits them until spec 033 US7 removes it.
  Future<ProductPrice> create({
    required int productId,
    required int priceListId,
    required String price,
    String? lowProfit,
    String? highProfit,
  });

  /// `PUT /api/v1/product-prices/{product_price_id}` (FR-010) — revalues an
  /// existing price row. Cannot move a row between products/lists (data-model.md
  /// §2). Throws `NotFoundError` on `404`, `ValidationError` on `422`.
  ///
  /// [lowProfit]/[highProfit] are **deprecated** (mbe-api#185); omitted, the
  /// stored band is left untouched, which is what a caller changing only
  /// [price] wants.
  Future<ProductPrice> update({
    required int productPriceId,
    required String price,
    String? lowProfit,
    String? highProfit,
  });
}
