import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mbe_api_client/mbe_api_client.dart'
    hide EntityStatus, FacilityType;

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';

part 'facility_list_item.freezed.dart';

/// A lightweight facility projection used by the Warehouses/Cash Drawers/
/// Points of Sale forms' facility `CatalogEntityPicker` and their list
/// screens' facility filter facet (data-model.md, FR-015/FR-018/FR-021).
@freezed
class FacilityListItem with _$FacilityListItem {
  const factory FacilityListItem({
    required int facilityId,
    required String code,
    required String name,
    required FacilityType type,
    required EntityStatus status,
  }) = _FacilityListItem;

  factory FacilityListItem.fromResponse(FacilityResponse r) =>
      FacilityListItem(
        facilityId: r.facilityId,
        code: r.code,
        name: r.name,
        type: FacilityType.fromApi(r.type),
        status: EntityStatus.fromApi(r.status),
      );

  factory FacilityListItem.fromSummary(FacilitySummary r) => FacilityListItem(
    facilityId: r.facilityId,
    code: r.code,
    name: r.name,
    type: FacilityType.fromApi(r.type),
    status: EntityStatus.fromApi(r.status),
  );
}
