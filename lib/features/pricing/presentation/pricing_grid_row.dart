import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/features/catalog/domain/entities/product_list_item.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';

part 'pricing_grid_row.freezed.dart';

/// The pricing grid's unit of display (data-model.md §2) — one product with
/// its price on each shown price list. The transpose of the standalone
/// pricing screen's `ProductPriceRow` (one price list, one product), which
/// stays in place for that screen (spec 033 research.md §R1).
///
/// [prices] is keyed by price-list id; an **absent** key means the product
/// has no price row on that list yet, which is what makes "not set" ≠
/// `0.00` representable (FR-005) — the same convention `ProductPriceRow`
/// uses via a nullable field, expressed here as map membership since a row
/// spans many lists at once.
@freezed
class PricingGridRow with _$PricingGridRow {
  const factory PricingGridRow({
    required ProductListItem product,
    required Map<int, ProductPrice> prices,
  }) = _PricingGridRow;
}

/// Builds one [PricingGridRow] per [products], attaching whichever of
/// [prices] belongs to that product (joined on `ProductPrice.productId`),
/// keyed by `priceList.priceListId`. Mirrors `buildProductPriceRows`'s join,
/// transposed.
List<PricingGridRow> buildPricingGridRows({
  required List<ProductListItem> products,
  required List<ProductPrice> prices,
}) {
  final byProductId = <int, Map<int, ProductPrice>>{};
  for (final price in prices) {
    (byProductId[price.productId] ??= {})[price.priceList.priceListId] =
        price;
  }
  return products
      .map(
        (product) => PricingGridRow(
          product: product,
          prices: byProductId[product.productId] ?? const {},
        ),
      )
      .toList();
}
