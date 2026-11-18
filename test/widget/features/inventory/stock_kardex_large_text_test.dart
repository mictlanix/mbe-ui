import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/features/inventory/domain/entities/kardex.dart';

import '../../../unit/features/inventory/kardex_fixtures.dart';
import '../../../unit/features/inventory/stock_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 071 T025 (constitution §V, quickstart step 12): at the largest text
/// level, Existencias with long product names, the product view with its
/// totals and in-transit section, and the Kardex with its two strips and a
/// linked row must not overflow at a supported desktop width. The platform
/// scale stands in for the user's extra-large level, as in
/// `inventory_counts_large_text_test.dart`.
void main() {
  const desktop = Size(1280, 800);

  void useExtraLargeText(WidgetTester tester) {
    tester.platformDispatcher.textScaleFactorTestValue =
        TextSizeLevel.extraLarge.factor;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  testWidgets('Existencias with long names and negative figures at the '
      'largest text level does not overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    harness.serveStock([
      aStockRow(
        productName: 'Cemento gris saco 50 kg uso general resistente al agua',
        onHand: '-98765.432',
        reserved: '12345.678',
        available: '-111111.11',
        incoming: '99999.999',
      ),
      aStockRow(
        productId: 8,
        productCode: 'B-200-EXTRA-LARGO',
        productName: 'Varilla corrugada 3/8 pulgada por 12 metros grado 42',
      ),
    ]);
    await harness.pumpStock(
      tester,
      location: '/inventory/stock?warehouse=3',
      surface: desktop,
    );

    expect(key('stock_table'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the product view with its totals, several warehouses and '
      'in-transit at the largest text level does not overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    await harness.pumpProductStock(
      tester,
      aProductStock(
        warehouses: [
          aStockRow(warehouseId: 3, onHand: '12345.678', incoming: '5'),
          aStockRow(
            warehouseId: 4,
            onHand: '-98765.432',
            reserved: '1',
            available: '-98766.432',
          ),
          aStockRow(warehouseId: 5, onHand: '0', reserved: '0', available: '0'),
        ],
        inTransit: [
          anInTransitStock(),
          anInTransitStock(facilityId: 5, warehouseId: 11, onHand: '-3.5'),
        ],
      ),
      surface: desktop,
    );

    expect(key('product_stock_totals'), findsOneWidget);
    expect(key('product_stock_table'), findsOneWidget);
    expect(key('product_stock_in_transit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Kardex with both strips, a linked row and long source '
      'labels at the largest text level does not overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    harness.serveKardex(
      aKardex(
        opening: '-12345.678',
        totalIn: '99999.999',
        totalOut: '98765.432',
        closing: '-11111.111',
        movements: [
          aKardexMovement(
            id: 1,
            document: const KardexDocumentRef(type: 4, id: 57, serial: 31),
          ),
          aKardexMovement(
            id: 2,
            sourceType: 8,
            reference: 58,
            document: const KardexDocumentRef(type: 8, id: 58, serial: 32),
            quantityOut: '12345.678',
            quantityIn: '0',
            balance: '-98765.432',
          ),
          aKardexMovement(
            id: 3,
            sourceType: 10,
            reference: 4321,
            document: null,
          ),
        ],
      ),
    );
    await harness.pumpKardex(
      tester,
      who: InventoryHarness.kardexUser().copyWith(
        privileges: [
          ...InventoryHarness.kardexUser().privileges,
          const Privilege(
            systemObject: SystemObject.inventoryReceipts,
            rawValue: 2,
          ),
        ],
      ),
      location:
          '/inventory/kardex?product=7&warehouse=3&from=2026-10-19&to=2026-11-17',
      surface: desktop,
    );

    expect(key('kardex_selection'), findsOneWidget);
    expect(key('kardex_summary'), findsOneWidget);
    expect(key('kardex_table'), findsOneWidget);
    expect(key('kardex_doc_1'), findsOneWidget);
    expect(key('kardex_doc_2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
