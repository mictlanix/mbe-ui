import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/network/photo_url.dart';

import 'product_price.dart';

part 'product.freezed.dart';

/// The central catalog record (data-model.md "Product"), mapped from
/// `ProductResponse`. Lives in `features/catalog/domain/` rather than
/// `core/` — research.md §4 explains why `Product` is a `catalog` shared
/// kernel entity rather than a `core/access` one.
@freezed
class Product with _$Product {
  const factory Product({
    required int productId,
    required String code,
    required String name,
    String? photo,
    String? sku,
    String? brand,
    String? model,
    String? barCode,
    String? location,
    required String unitOfMeasurement,
    String? key,
    required String taxRate,
    required bool taxIncluded,
    required int priceType,
    required int currency,
    required int minOrderQty,
    int? supplier,
    required bool stockable,
    required bool perishable,
    required bool seriable,
    required bool purchasable,
    required bool salable,
    required bool invoiceable,
    required bool stockRequired,
    required bool deactivated,
    String? comment,
    required List<ProductPrice> prices,
  }) = _Product;

  factory Product.fromResponse(ProductResponse response) {
    return Product(
      productId: response.productId,
      code: response.code,
      name: response.name,
      photo: resolvePhotoUrl(response.photo),
      sku: response.sku,
      brand: response.brand,
      model: response.model,
      barCode: response.barCode,
      location: response.location,
      unitOfMeasurement: response.unitOfMeasurement,
      key: response.key,
      taxRate: response.taxRate,
      taxIncluded: response.taxIncluded,
      priceType: response.priceType,
      currency: response.currency,
      minOrderQty: response.minOrderQty,
      supplier: response.supplier,
      stockable: response.stockable,
      perishable: response.perishable,
      seriable: response.seriable,
      purchasable: response.purchasable,
      salable: response.salable,
      invoiceable: response.invoiceable,
      stockRequired: response.stockVerification,
      deactivated: response.deactivated,
      comment: response.comment,
      prices: (response.prices?.toList() ?? <ProductPriceResponse>[])
          .map(ProductPrice.fromResponse)
          .toList(),
    );
  }
}
