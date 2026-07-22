import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';

part 'point_sale.freezed.dart';

/// A selling station belonging to exactly one facility and drawing stock
/// from exactly one warehouse — full detail entity for the Points of Sale
/// catalog's list and detail screens (data-model.md "Point of Sale"), mapped
/// from `PointSaleResponse`.
@freezed
class PointSale with _$PointSale {
  const factory PointSale({
    required int pointSaleId,
    required int facilityId,
    required String facilityName,
    required String code,
    required String name,
    required int warehouseId,
    required String warehouseName,
    String? comment,
    required EntityStatus status,
  }) = _PointSale;

  factory PointSale.fromResponse(PointSaleResponse r) => PointSale(
    pointSaleId: r.pointSaleId,
    facilityId: r.facility.facilityId,
    facilityName: r.facility.name,
    code: r.code,
    name: r.name,
    warehouseId: r.warehouse.warehouseId,
    warehouseName: r.warehouse.name,
    comment: r.comment,
    status: EntityStatus.fromApi(r.status),
  );
}

/// [facilityName]/[warehouseName] arrive empty only for a dangling/
/// misconfigured reference — both are always expanded and non-null on the
/// generated response, so this is a defensive fallback (FR-021), mirroring
/// [WarehouseFacilityDisplay]/[CashDrawerFacilityDisplay].
extension PointSaleFkDisplay on PointSale {
  String facilityDisplayName(String unknownFacilityLabel) =>
      facilityName.isNotEmpty ? facilityName : unknownFacilityLabel;

  String warehouseDisplayName(String unknownWarehouseLabel) =>
      warehouseName.isNotEmpty ? warehouseName : unknownWarehouseLabel;
}
