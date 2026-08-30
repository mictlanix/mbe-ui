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
    required String lowProfit,
    required String highProfit,
  }) = _ProductPrice;

  factory ProductPrice.fromResponse(ProductPriceResponse response) {
    return ProductPrice(
      productPriceId: response.productPriceId,
      productId: response.product,
      priceList: PriceList.fromResponse(response.priceList),
      price: response.price,
      // Deprecated on the wire since mbe-api#185 — still mapped because the
      // standalone per-product screen still displays them, until spec 033
      // US7 removes that.
      // ignore: deprecated_member_use
      lowProfit: response.lowProfit,
      // ignore: deprecated_member_use
      highProfit: response.highProfit,
    );
  }
}
