import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;

import 'package:mbe_ui/features/sales/domain/entities/product_lookup_result.dart';

void main() {
  test('WarehouseStock.fromResponse maps the facility and its name', () {
    final row = WarehouseStock.fromResponse(
      (api.ProductStockResponseBuilder()
            ..warehouse = 4
            ..warehouseName = 'Bodega'
            ..facility = 2
            ..facilityName = 'Norte'
            ..onHand = '5'
            ..available = '3')
          .build(),
    );
    expect(row.facilityId, 2);
    expect(row.facilityName, 'Norte');
    expect(row.warehouse, 4);
    expect(row.available, '3');
  });

  test('a response without a facility leaves both null', () {
    final row = WarehouseStock.fromResponse(
      (api.ProductStockResponseBuilder()
            ..warehouse = 4
            ..onHand = '0'
            ..available = '0')
          .build(),
    );
    expect(row.facilityId, isNull);
    expect(row.facilityName, isNull);
  });
}
