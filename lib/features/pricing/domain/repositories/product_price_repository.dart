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

  /// Every price on [priceListIds] for [productIds] (spec 033
  /// contracts/mbe-api-pricing.md §3, data-model.md §2). Batches today as one
  /// `listByProduct` call per product id — `GET /product-prices` only
  /// accepts a single `product` — and collapses to one request the day
  /// mbe-api#182 (a repeatable `product` filter) lands; only this method's
  /// body changes, not its signature or any call site.
  Future<List<ProductPrice>> listForProducts({
    required List<int> productIds,
    required List<int> priceListIds,
  });

  /// `POST /api/v1/product-prices` (FR-009) — creates a price row for a
  /// price list the product has none on yet. Throws `ValidationError` on
  /// `422`.
  ///
  /// [lowProfit]/[highProfit] gate `assert_margin_in_range` on every
  /// sales-order line for this product (spec 033 research.md §R6) — never
  /// pass `'0'`/`'0'` as a stand-in default, that is the *narrowest* band the
  /// schema allows and refuses every sale at any profit. Callers creating a
  /// row without asking the user for a band (spec 033 FR-012) MUST copy it
  /// from the target `PriceList`'s own `lowProfitMargin`/`highProfitMargin`,
  /// substituting `('0', '1')` when those are the shipped `0/0` default.
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
  ///
  /// A caller that only changes [price] (spec 033 FR-034 — the grid no
  /// longer edits profit thresholds) MUST echo the row's existing
  /// [lowProfit]/[highProfit] back unchanged rather than inventing a value.
  Future<ProductPrice> update({
    required int productPriceId,
    required String price,
    required String lowProfit,
    required String highProfit,
  });
}
