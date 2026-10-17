import 'package:flutter_riverpod/legacy.dart';

import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';

/// Per-warehouse availability last seen for a product, keyed by product id
/// (FR-025, FR-026). `Sale`/`SaleLine` carry no availability field of their
/// own (data-model.md §2 — `SaleLine.availability` is explicitly advisory,
/// never round-tripped through the server), so [SaleLineRow]'s shortfall
/// warning reads this screen-local cache instead: [CaptureStep] populates an
/// entry every time a product-lookup result is added or shown, and the
/// warning simply doesn't render for a line whose product was never looked
/// up in this session (e.g. right after resuming a sale) — advisory, not a
/// substitute for the authoritative check at confirmation.
///
/// A key that is **missing** means the product's stock is unknown; a key that
/// is present with [ProductStock.checked] `false` means the product is not
/// stock-tracked (spec 047, data-model.md ProductStock). The old
/// `List<WarehouseStock>` value could not tell those two apart, because a
/// product that is not stockable comes back with an empty list.
final productStockCacheProvider =
    StateProvider<Map<int, ProductStock>>((ref) => const {});

/// What the product lookup said about a product's stock (spec 047).
///
/// [stockable] and [stockRequired] are both needed because that is exactly the
/// rule the backend applies when it confirms a sale (`stock_verification AND
/// stockable`): a product kept in inventory but configured to skip the check
/// can be oversold and so is never "short".
class ProductStock {
  const ProductStock({
    this.stockable = true,
    this.stockRequired = true,
    this.warehouses = const <WarehouseStock>[],
  });

  factory ProductStock.fromLookup(ProductLookupResult result) => ProductStock(
    stockable: result.stockable,
    stockRequired: result.stockRequired,
    warehouses: result.stock,
  );

  final bool stockable;
  final bool stockRequired;
  final List<WarehouseStock> warehouses;

  /// Whether a sale line for this product is checked against stock.
  bool get checked => stockable && stockRequired;
}

/// The product table's own tax rate, keyed by product id — the same
/// lookup-derived, screen-local cache as [productStockCacheProvider], written
/// at the same moment by [CaptureStep] and for the same reason: it is the one
/// place the rate is available.
///
/// `SalesOrderLineResponse` carries the **line's** `tax_rate` and nothing
/// about the product's, so a line's tax picker (FR-038b) needs this to know
/// what rate to offer besides zero. A line whose product was never looked up
/// this session (right after resuming a sale) falls back to its own non-zero
/// rate, which the server took from the product table when the line was
/// created — see `SaleLineEditing.taxRateOptions`.
final productTaxRateCacheProvider = StateProvider<Map<int, String>>(
  (ref) => const {},
);

// Both caches above are **intentionally shared across all three capture
// hosts** — the register, the back-office order workspace, and the quote
// screen (spec 040, research.md R8) — rather than scoped per host through
// the `saleEditorProvider`/`saleWritesScopeProvider` seam. They are plain,
// root-scoped `StateProvider`s keyed only by product id, which is correct
// here: the data they hold (a product's stock levels, a product's tax rate)
// is a fact about the *product*, not about any one document, so a product
// looked up at the register usefully seeding a quote's tax picker later in
// the same session is sharing working as intended, not a leak between
// documents. `CaptureStep._addLine` seeds the tax cache for every host —
// including a quote host with `showWarehouse: false`, since without it a
// fresh line offers only zero and its own rate — but seeds the stock cache
// only when `showWarehouse` is `true`: a quote reserves no stock, so there
// is nothing for it to advise on.
