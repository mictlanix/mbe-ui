import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';
import 'package:mbe_ui/features/sales/presentation/capture/other_facility_stock.dart';
import 'package:mbe_ui/features/sales/presentation/capture/product_stock_cache.dart';

WarehouseStock _row(
  int id,
  String available, {
  int? facility = 2,
  String? facilityName = 'Norte',
  String? name,
}) => WarehouseStock(
  warehouse: id,
  warehouseName: name ?? 'W$id',
  facilityId: facility,
  facilityName: facilityName,
  onHand: available,
  available: available,
);

Warehouse _warehouse(int id, String name) => Warehouse(
  warehouseId: id,
  facilityId: 1,
  facilityName: 'Main',
  code: 'WH-$id',
  name: name,
  status: EntityStatus.active,
);

List<OtherFacilityGroup> _others(List<WarehouseStock> rows, {int? current}) =>
    otherFacilityStock(
      ProductStock(warehouses: rows),
      saleFacilityId: 1,
      saleWarehouseIds: const {3},
      currentWarehouse: current,
    );

void main() {
  group('otherFacilityStock', () {
    test('drops rows with nothing available, except the current warehouse', () {
      final groups = _others([
        _row(4, '0'),
        _row(5, '2'),
        _row(6, '0'),
      ], current: 6);
      expect(groups.single.warehouses.map((w) => w.warehouse), [5, 6]);
    });

    test('a row whose facility differs from the sale facility is other', () {
      final groups = _others([_row(3, '5', facility: 1), _row(4, '5')]);
      expect(groups.single.facilityId, 2);
      expect(groups.single.warehouses.single.warehouse, 4);
    });

    test('a row without a facility is skipped', () {
      expect(
        _others([_row(4, '5', facility: null, facilityName: null)]),
        isEmpty,
      );
    });

    test('groups sort by facility name and warehouses by name', () {
      final groups = _others([
        _row(4, '5', facility: 7, facilityName: 'Sur', name: 'B'),
        _row(5, '5', facility: 2, facilityName: 'Norte', name: 'Z'),
        _row(6, '5', facility: 2, facilityName: 'Norte', name: 'A'),
      ]);
      expect(groups.map((g) => g.facilityName), ['Norte', 'Sur']);
      expect(groups.first.warehouses.map((w) => w.warehouseName), ['A', 'Z']);
    });

    test('no other stock gives an empty list', () {
      expect(_others(const []), isEmpty);
      expect(_others([_row(3, '5', facility: 1)]), isEmpty);
    });
  });

  group('lineWarehouseLabel', () {
    final list = [_warehouse(3, 'Principal')];
    final stock = ProductStock(warehouses: [_row(4, '5', name: 'Bodega')]);

    test('the facility list name wins', () {
      expect(
        lineWarehouseLabel(3, facilityWarehouses: list, stock: stock),
        'Principal',
      );
    });

    test('then the stock row with its facility', () {
      expect(
        lineWarehouseLabel(4, facilityWarehouses: list, stock: stock),
        'Bodega · Norte',
      );
    });

    test('then #id, never empty', () {
      expect(
        lineWarehouseLabel(9, facilityWarehouses: list, stock: stock),
        '#9',
      );
      expect(lineWarehouseLabel(9, facilityWarehouses: const []), '#9');
    });
  });
}
