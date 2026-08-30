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
  /// Sends the price alone. `low_profit`/`high_profit` are deprecated
  /// (mbe-api#185) and no longer passed by anything: the created row takes
  /// its band from the price list's own margins server-side.
  Future<ProductPrice> create({
    required int productId,
    required int priceListId,
    required String price,
  });

  /// `PUT /api/v1/product-prices/{product_price_id}` (FR-010) — revalues an
  /// existing price row. Cannot move a row between products/lists (data-model.md
  /// §2). Throws `NotFoundError` on `404`, `ValidationError` on `422`.
  ///
  /// Sends the price alone; the stored profit band is left untouched, which
  /// is what mbe-api#185 defines an omitted margin to mean.
  Future<ProductPrice> update({
    required int productPriceId,
    required String price,
  });

  /// `PUT /api/v1/product-prices` (mbe-api#183) — upserts a page of prices in
  /// **one transaction**, keyed on the unique `(product, price_list)` rather
  /// than on a row id. Either every cell lands or none does, which is what
  /// makes spec 033's column actions all-or-nothing (FR-015) without any
  /// client-side rollback.
  ///
  /// Keyed on the pair, so there is no create-vs-update branch to get wrong
  /// and no 409 when someone else priced that product between the caller's
  /// last read and this write.
  ///
  /// Three server rules the caller must respect (contracts/mbe-api-pricing.md §6):
  ///
  /// * a **repeated `(product, priceList)`** anywhere in [writes] is a `400` —
  ///   de-duplicate by cell before calling; two cells for one cell is a client
  ///   bug the server refuses to resolve silently;
  /// * at most [kProductPriceBulkLimit] entries;
  /// * every product and price list id is validated up front, so one bad id
  ///   refuses the whole body rather than applying the good rows first.
  ///
  /// Sends `price` only — the profit band defaults from the price list on a
  /// created row and is left alone on an updated one (mbe-api#185).
  Future<List<ProductPrice>> applyPriceChanges(List<PriceCellWrite> writes);
}

/// One cell of a bulk price write — the request-side counterpart of the
/// presentation layer's `PriceWrite`, without the undo bookkeeping (which is
/// the controller's business, not the wire's).
class PriceCellWrite {
  const PriceCellWrite({
    required this.productId,
    required this.priceListId,
    required this.price,
  });

  final int productId;
  final int priceListId;
  final String price;
}
