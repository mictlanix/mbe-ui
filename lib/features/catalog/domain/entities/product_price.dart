import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

part 'product_price.freezed.dart';

/// A read-only, per-price-list price entry on a [Product] (data-model.md
/// "ProductPrice"). Displayed as a sub-panel of the product detail screen;
/// price-list values are not editable in this feature (spec.md Assumptions).
@freezed
class ProductPrice with _$ProductPrice {
  const factory ProductPrice({
    required int productPriceId,
    required int priceListId,
    required String priceListName,
    required String price,
    required String lowProfit,
    required String highProfit,
  }) = _ProductPrice;

  factory ProductPrice.fromResponse(ProductPriceResponse response) {
    return ProductPrice(
      productPriceId: response.productPriceId,
      priceListId: response.priceList.priceListId,
      priceListName: response.priceList.name,
      price: response.price,
      lowProfit: response.lowProfit,
      highProfit: response.highProfit,
    );
  }
}
