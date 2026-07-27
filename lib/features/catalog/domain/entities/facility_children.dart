import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';

part 'facility_children.freezed.dart';

/// The complete, presentation-scoped child set of one facility — every
/// warehouse, point of sale and cash drawer it owns — as displayed under its
/// card in the nested Facilities hierarchy
/// (018-nested-facility-management data-model.md §2). Assembled for display,
/// not a stored record.
///
/// Each list is always loaded to completion (FR-019) — there is no
/// partial-load state, so `list.length` is the true count. The `*Readable`
/// flags disambiguate "this facility has none" (FR-010, empty placeholder)
/// from "you may not see them" (FR-029, section omitted) without the widget
/// re-reading access control itself.
@freezed
class FacilityChildren with _$FacilityChildren {
  const factory FacilityChildren({
    required int facilityId,
    @Default(<Warehouse>[]) List<Warehouse> warehouses,
    @Default(<PointSale>[]) List<PointSale> pointsOfSale,
    @Default(<CashDrawer>[]) List<CashDrawer> cashDrawers,
    @Default(false) bool warehousesReadable,
    @Default(false) bool pointsOfSaleReadable,
    @Default(false) bool cashDrawersReadable,
  }) = _FacilityChildren;
}

/// Derived counts and cross-facility detection (data-model.md §2). Kept as
/// an extension, matching [WarehouseFacilityDisplay]/[CashDrawerFacilityDisplay].
extension FacilityChildrenDerived on FacilityChildren {
  int get warehouseCount => warehouses.length;
  int get pointSaleCount => pointsOfSale.length;
  int get cashDrawerCount => cashDrawers.length;

  /// `true` when [pointSale] draws stock from a warehouse that is not among
  /// this facility's own warehouses (FR-009). In current data this can only
  /// happen for a record migrated before mbe-api enforced same-facility
  /// warehouses (018-nested-facility-management research.md §3).
  bool isCrossFacility(PointSale pointSale) =>
      !warehouses.any((w) => w.warehouseId == pointSale.warehouseId);
}
