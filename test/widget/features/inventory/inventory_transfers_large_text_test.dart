import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/in_transit_screen.dart';

import '../../../unit/features/inventory/inventory_transfer_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 069 T040 (constitution §V, quickstart step 12): at the largest text
/// level, the transfers list, the dispatched lines table, the receive dialog
/// and the in-transit tables must not overflow or scroll sideways at a
/// supported desktop width. The platform scale stands in for the user's
/// extra-large level, as in `inventory_issues_large_text_test.dart`.
void main() {
  const desktop = Size(1280, 800);
  const longName =
      'Tornillo hexagonal galvanizado de acero inoxidable 1/4 pulgada '
      'caja con cien piezas';

  void useExtraLargeText(WidgetTester tester) {
    tester.platformDispatcher.textScaleFactorTestValue =
        TextSizeLevel.extraLarge.factor;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  InventoryTransferLine longLine({
    int id = 900,
    int productId = 7,
    required String quantity,
    required String received,
    required String outstanding,
  }) => aTransferLine(
    id: id,
    productId: productId,
    quantity: quantity,
    received: received,
    outstanding: outstanding,
  ).copyWith(productName: longName);

  final dispatched = aTransfer(
    serial: 2983,
    warehouseId: 3000001,
    warehouseToId: 4000002,
    status: InventoryTransferStatus.inTransit,
    comment: 'Reposicion semanal de tornilleria para la sucursal',
    lines: [
      longLine(
        quantity: '12345.678',
        received: '5000',
        outstanding: '7345.678',
      ),
      longLine(
        id: 901,
        productId: 8,
        quantity: '3',
        received: '0',
        outstanding: '3',
      ),
    ],
  );

  testWidgets('the list at the largest text level does not overflow', (
    tester,
  ) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    harness.serveTransfers([
      aTransferSummary(id: 412, warehouseId: 3000001, warehouseToId: 4000002),
      aTransferSummary(
        id: 413,
        serial: 2983,
        warehouseId: 3000001,
        warehouseToId: 4000002,
        status: InventoryTransferStatus.inTransit,
      ),
      aTransferSummary(
        id: 414,
        serial: 2986,
        status: InventoryTransferStatus.received,
      ),
      aTransferSummary(id: 415, status: InventoryTransferStatus.cancelled),
    ]);
    await harness.pumpTransfers(tester, surface: desktop);

    expect(key('inventory_transfers_table'), findsOneWidget);
    expect(key('inventory_transfer_folio_412'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a dispatched transfer\'s table and actions at the largest '
      'text level do not overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    await harness.pumpTransfer(tester, dispatched, surface: desktop);

    expect(key('inventory_transfer_lines_table'), findsOneWidget);
    expect(key('inventory_transfer_actions'), findsOneWidget);
    expect(key('inventory_transfer_receive'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the receive dialog at the largest text level does not '
      'overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    await harness.pumpTransfer(tester, dispatched, surface: desktop);
    await tester.tap(key('inventory_transfer_receive'));
    await tester.pumpAndSettle();

    expect(key('inventory_transfer_receive_table'), findsOneWidget);
    expect(key('inventory_transfer_receive_field_900'), findsOneWidget);
    expect(key('inventory_transfer_receive_submit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the in-transit tables at the largest text level do not '
      'overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    when(() => harness.transfers.inTransit(facilityId: 2)).thenAnswer(
      (_) async => InTransitView(
        facilityId: 2,
        products: [
          InTransitProductTotal(
            productId: 7,
            productCode: 'A-100',
            productName: longName,
            quantity: Decimal.parse('12345.678'),
          ),
        ],
        lines: [
          InTransitLineItem(
            transferId: 412,
            serial: 2983,
            warehouseId: 3000001,
            warehouseToId: 4000002,
            lineId: 900,
            productId: 7,
            productCode: 'A-100',
            productName: longName,
            quantityOutstanding: Decimal.parse('12345.678'),
          ),
        ],
      ),
    );
    await harness.pumpTransfers(
      tester,
      location: inTransitPath,
      surface: desktop,
    );

    expect(key('in_transit_products_table'), findsOneWidget);
    expect(key('in_transit_lines_table'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
