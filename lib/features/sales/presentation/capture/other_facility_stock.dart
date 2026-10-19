import 'package:decimal/decimal.dart';

import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';

/// One other facility's warehouses that hold a product (spec 048 FR-020).
class OtherFacilityGroup {
  const OtherFacilityGroup({
    required this.facilityId,
    required this.facilityName,
    required this.warehouses,
  });

  final int facilityId;
  final String facilityName;
  final List<WarehouseStock> warehouses;
}

/// The stock rows outside the sale's facility, grouped by facility (R8).
/// Keeps a row when something is available, or when it is the line's
/// [currentWarehouse]; a row with no facility is skipped.
List<OtherFacilityGroup> otherFacilityStock(
  ProductStock stock, {
  required int saleFacilityId,
  required Set<int> saleWarehouseIds,
  int? currentWarehouse,
}) {
  final byFacility = <int, List<WarehouseStock>>{};
  for (final row in stock.warehouses) {
    final facility = row.facilityId;
    if (facility == null || facility == saleFacilityId) continue;
    if (saleWarehouseIds.contains(row.warehouse)) continue;
    final available = Decimal.tryParse(row.available) ?? Decimal.zero;
    if (available.sign <= 0 && row.warehouse != currentWarehouse) continue;
    byFacility.putIfAbsent(facility, () => []).add(row);
  }
  String nameOf(WarehouseStock r) => r.warehouseName ?? '#${r.warehouse}';
  final groups = [
    for (final e in byFacility.entries)
      OtherFacilityGroup(
        facilityId: e.key,
        facilityName:
            e.value
                .map((r) => r.facilityName)
                .firstWhere((n) => n != null, orElse: () => null) ??
            '#${e.key}',
        warehouses: [...e.value]
          ..sort((a, b) => nameOf(a).compareTo(nameOf(b))),
      ),
  ]..sort((a, b) => a.facilityName.compareTo(b.facilityName));
  return groups;
}

/// What the line's closed warehouse field shows (FR-025): the facility list's
/// name, else the cached row's `warehouse · facility`, else `#id`.
String lineWarehouseLabel(
  int warehouseId, {
  required List<Warehouse> facilityWarehouses,
  ProductStock? stock,
}) {
  for (final w in facilityWarehouses) {
    if (w.warehouseId == warehouseId) return w.name;
  }
  for (final row in stock?.warehouses ?? const <WarehouseStock>[]) {
    final name = row.warehouseName;
    if (row.warehouse != warehouseId || name == null) continue;
    final facility = row.facilityName;
    return facility == null ? name : '$name · $facility';
  }
  return '#$warehouseId';
}
