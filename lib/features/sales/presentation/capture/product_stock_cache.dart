import 'package:flutter_riverpod/flutter_riverpod.dart';

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
final productStockCacheProvider =
    StateProvider<Map<int, List<WarehouseStock>>>((ref) => const {});

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
