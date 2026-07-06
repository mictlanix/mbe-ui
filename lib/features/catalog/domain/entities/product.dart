import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart';

import 'package:mbe_ui/core/network/photo_url.dart';

import 'product_label.dart';

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
    required String unitOfMeasurementCode,
    required String unitOfMeasurementName,
    String? unitOfMeasurementDescription,
    String? unitOfMeasurementSymbol,
    String? satKeyCode,
    String? satKeyDescription,
    required String taxRate,
    required bool taxIncluded,
    required int priceType,
    required int currency,
    required int minOrderQty,
    int? supplierId,
    String? supplierName,
    required bool stockable,
    required bool perishable,
    required bool seriable,
    required bool purchasable,
    required bool salable,
    required bool invoiceable,
    required bool stockRequired,
    required bool deactivated,
    String? comment,
    @Default([]) List<ProductLabel> labels,
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
      unitOfMeasurementCode: response.unitOfMeasurement.id,
      unitOfMeasurementName: response.unitOfMeasurement.name,
      unitOfMeasurementDescription: response.unitOfMeasurement.description,
      unitOfMeasurementSymbol: response.unitOfMeasurement.symbol,
      satKeyCode: response.key?.id,
      satKeyDescription: response.key?.description,
      taxRate: response.taxRate,
      taxIncluded: response.taxIncluded,
      priceType: response.priceType,
      currency: response.currency,
      minOrderQty: response.minOrderQty,
      supplierId: response.supplier?.supplierId,
      supplierName: response.supplier?.name,
      stockable: response.stockable,
      perishable: response.perishable,
      seriable: response.seriable,
      purchasable: response.purchasable,
      salable: response.salable,
      invoiceable: response.invoiceable,
      stockRequired: response.stockVerification,
      deactivated: response.deactivated,
      comment: response.comment,
      labels: (response.labels?.toList() ?? <LabelResponse>[])
          .map(ProductLabel.fromResponse)
          .toList(),
    );
  }
}
