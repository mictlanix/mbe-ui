import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/entities/product_price.dart';

part 'product_price_row.freezed.dart';

/// The pricing screen's unit of display (data-model.md §3) — the
/// client-side left join of the full price-list set against a product's
/// existing prices (research.md §5). [priceList] is always present, one row
/// per list; [price] is `null` when the product has no price on that list
/// yet, which is what makes "not set" ≠ `0.00` representable (FR-008).
@freezed
class ProductPriceRow with _$ProductPriceRow {
  const factory ProductPriceRow({
    required PriceList priceList,
    ProductPrice? price,
  }) = _ProductPriceRow;
}

/// Builds one [ProductPriceRow] per [priceLists], attaching the matching
/// entry from [prices] (joined on `priceList.priceListId`) when one exists.
List<ProductPriceRow> buildProductPriceRows({
  required List<PriceList> priceLists,
  required List<ProductPrice> prices,
}) {
  final byPriceListId = {for (final p in prices) p.priceList.priceListId: p};
  return priceLists
      .map(
        (list) => ProductPriceRow(
          priceList: list,
          price: byPriceListId[list.priceListId],
        ),
      )
      .toList();
}
