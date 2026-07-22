import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart' hide EntityStatus;

import 'package:mbe_ui/core/domain/entity_status.dart';

part 'warehouse.freezed.dart';

/// A stock-holding location belonging to exactly one facility — full detail
/// entity for the Warehouses catalog's list and detail screens
/// (data-model.md "Warehouse"), mapped from `WarehouseResponse`.
@freezed
class Warehouse with _$Warehouse {
  const factory Warehouse({
    required int warehouseId,
    required int facilityId,
    required String facilityName,
    required String code,
    required String name,
    String? comment,
    required EntityStatus status,
  }) = _Warehouse;

  factory Warehouse.fromResponse(WarehouseResponse r) => Warehouse(
    warehouseId: r.warehouseId,
    facilityId: r.facility.facilityId,
    facilityName: r.facility.name,
    code: r.code,
    name: r.name,
    comment: r.comment,
    status: EntityStatus.fromApi(r.status),
  );
}

/// [facilityName] arrives empty only for a dangling/misconfigured reference
/// — the generated `WarehouseResponse.facility` is always expanded and
/// non-null, so this is a defensive fallback rather than a case the API can
/// actually return today (FR-015). Kept as an extension, not baked into
/// [Warehouse.fromResponse], so the domain entity stays free of `BuildContext`/l10n
/// — the caller supplies the localized fallback label.
extension WarehouseFacilityDisplay on Warehouse {
  String facilityDisplayName(String unknownFacilityLabel) =>
      facilityName.isNotEmpty ? facilityName : unknownFacilityLabel;
}
