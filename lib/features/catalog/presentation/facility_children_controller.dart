import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_children.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';

part 'facility_children_controller.g.dart';

/// mbe-api caps every list request at 100 (research §7) — requesting at
/// this size means the common case (a handful of children) resolves in one
/// round trip per child type.
const _pageLimit = 100;

/// Loads and holds one facility's complete child set for the nested
/// Facilities hierarchy (018-nested-facility-management FR-017/018/019).
///
/// Keyed by [facilityId] **and** [facilityType]: the type decides which
/// child types are requested at all (research §2) — a production site never
/// issues a points-of-sale or cash-drawers request. The type is supplied by
/// the caller (`FacilityCard`, which already holds the `FacilityListItem`
/// it is rendering) rather than fetched here, so this controller costs
/// exactly the requests its own child types need — no extra "get this
/// facility" round trip.
@riverpod
class FacilityChildrenController extends _$FacilityChildrenController {
  @override
  Future<FacilityChildren> build(int facilityId, FacilityType facilityType) async {
    final access = ref.watch(accessControlProvider);
    final isStore = facilityType == FacilityType.store;

    final warehousesReadable = access.can(
      SystemObject.warehouses,
      AccessRight.read,
    );
    final pointsOfSaleReadable =
        isStore && access.can(SystemObject.pointsOfSale, AccessRight.read);
    final cashDrawersReadable =
        isStore && access.can(SystemObject.cashDrawers, AccessRight.read);

    final warehouses = warehousesReadable
        ? await _fetchAllWarehouses(facilityId)
        : const <Warehouse>[];
    final pointsOfSale = pointsOfSaleReadable
        ? await _fetchAllPointsOfSale(facilityId)
        : const <PointSale>[];
    final cashDrawers = cashDrawersReadable
        ? await _fetchAllCashDrawers(facilityId)
        : const <CashDrawer>[];

    return FacilityChildren(
      facilityId: facilityId,
      warehouses: warehouses,
      pointsOfSale: pointsOfSale,
      cashDrawers: cashDrawers,
      warehousesReadable: warehousesReadable,
      pointsOfSaleReadable: pointsOfSaleReadable,
      cashDrawersReadable: cashDrawersReadable,
    );
  }

  Future<List<Warehouse>> _fetchAllWarehouses(int facilityId) {
    final repo = ref.read(warehouseRepositoryProvider);
    return _fetchAllPages<Warehouse>((skip) async {
      final result = await repo.list(
        facilityId: facilityId,
        skip: skip,
        limit: _pageLimit,
      );
      return (items: result.items, total: result.total);
    });
  }

  Future<List<PointSale>> _fetchAllPointsOfSale(int facilityId) {
    final repo = ref.read(pointSaleRepositoryProvider);
    return _fetchAllPages<PointSale>((skip) async {
      final result = await repo.list(
        facilityId: facilityId,
        skip: skip,
        limit: _pageLimit,
      );
      return (items: result.items, total: result.total);
    });
  }

  Future<List<CashDrawer>> _fetchAllCashDrawers(int facilityId) {
    final repo = ref.read(cashDrawerRepositoryProvider);
    return _fetchAllPages<CashDrawer>((skip) async {
      final result = await repo.list(
        facilityId: facilityId,
        skip: skip,
        limit: _pageLimit,
      );
      return (items: result.items, total: result.total);
    });
  }

  /// The FR-019 complete-the-collection loop: keeps requesting subsequent
  /// pages by `skip` until every record the reported `total` promises has
  /// been loaded, so a section can never be silently truncated now that the
  /// standalone lists are gone. In practice this is a single iteration —
  /// mbe-api's own cap keeps [_pageLimit] above any real facility's child
  /// count (research §7).
  Future<List<T>> _fetchAllPages<T>(
    Future<({List<T> items, int total})> Function(int skip) fetchPage,
  ) async {
    final items = <T>[];
    var skip = 0;
    while (true) {
      final page = await fetchPage(skip);
      items.addAll(page.items);
      if (items.length >= page.total || page.items.isEmpty) break;
      skip += _pageLimit;
    }
    return items;
  }
}
