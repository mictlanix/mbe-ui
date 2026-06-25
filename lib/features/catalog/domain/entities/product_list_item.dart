import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

part 'product_list_item.freezed.dart';

/// A row in the products list screen (data-model.md "ProductListItem"),
/// mapped from `ProductListItem` — a smaller projection than the full
/// [Product] detail entity.
@freezed
class ProductListItem with _$ProductListItem {
  const factory ProductListItem({
    required int productId,
    required String code,
    required String name,
    String? brand,
    String? model,
    required String unitOfMeasurement,
    required String taxRate,
    required bool deactivated,
    /// A fully-resolved, ready-to-fetch photo URL, same as `Product.photo`
    /// (mictlanix/mbe-api#71 — the list endpoint now resolves this the same
    /// way the detail endpoint always has).
    String? photo,
  }) = _ProductListItem;

  factory ProductListItem.fromResponse(api.ProductListItem item) {
    return ProductListItem(
      productId: item.productId,
      code: item.code,
      name: item.name,
      brand: item.brand,
      model: item.model,
      unitOfMeasurement: item.unitOfMeasurement,
      taxRate: item.taxRate,
      deactivated: item.deactivated,
      photo: item.photo,
    );
  }
}
