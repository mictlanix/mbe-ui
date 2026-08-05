import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

part 'product_lookup_result.freezed.dart';

/// What a search or scan returns (data-model.md §3), from
/// `GET /sales-orders/product-lookup`. Backs both the scan and the search
/// path (FR-020, FR-021).
@freezed
class ProductLookupResult with _$ProductLookupResult {
  const factory ProductLookupResult({
    required int product,
    required String code,
    required String name,
    String? sku,
    String? brand,
    String? model,
    String? barCode,
    required String price,
    required String taxRate,
    required bool taxIncluded,
    required int minOrderQty,
    required bool stockRequired,
    required bool stockable,
    @Default(<WarehouseStock>[]) List<WarehouseStock> stock,
  }) = _ProductLookupResult;

  factory ProductLookupResult.fromResponse(api.ProductLookupResponse r) =>
      ProductLookupResult(
        product: r.product,
        code: r.code,
        name: r.name,
        sku: r.sku,
        brand: r.brand,
        model: r.model,
        barCode: r.barCode,
        price: r.price,
        taxRate: r.taxRate,
        taxIncluded: r.taxIncluded,
        minOrderQty: r.minOrderQty,
        stockRequired: r.stockRequired,
        stockable: r.stockable,
        stock: (r.stock ?? const <api.ProductStockResponse>[])
            .map(WarehouseStock.fromResponse)
            .toList(),
      );
}

/// One warehouse's availability for a looked-up product. `available` — not
/// `onHand` — is what the shortfall warning (FR-025, FR-026) compares
/// against: it is exactly what confirmation itself checks.
@freezed
class WarehouseStock with _$WarehouseStock {
  const factory WarehouseStock({
    required int warehouse,
    String? warehouseName,
    required String onHand,
    required String available,
  }) = _WarehouseStock;

  factory WarehouseStock.fromResponse(api.ProductStockResponse r) =>
      WarehouseStock(
        warehouse: r.warehouse,
        warehouseName: r.warehouseName,
        onHand: r.onHand,
        available: r.available,
      );
}
