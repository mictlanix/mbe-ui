import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';

part 'product_price.freezed.dart';

/// A product's price on one price list (data-model.md §2), mapped from
/// `ProductPriceResponse`. Note [priceList] is a **nested object**, not an
/// id (research.md §5) — the join key for the left join is
/// `priceList.priceListId`.
@freezed
class ProductPrice with _$ProductPrice {
  const factory ProductPrice({
    required int productPriceId,
    required int productId,
    required PriceList priceList,
    required String price,
  }) = _ProductPrice;

  factory ProductPrice.fromResponse(ProductPriceResponse response) {
    return ProductPrice(
      productPriceId: response.productPriceId,
      productId: response.product,
      priceList: PriceList.fromResponse(response.priceList),
      price: response.price,
      // `low_profit`/`high_profit` are deliberately not mapped: deprecated on
      // the wire (mbe-api#185, which retired the sales-order validation that
      // read them) and shown by no screen since spec 033 US7. The columns
      // still exist server-side; nothing here needs them.
    );
  }
}
