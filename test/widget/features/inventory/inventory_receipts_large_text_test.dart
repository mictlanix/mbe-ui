import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

import '../../../unit/features/inventory/inventory_receipt_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 067 T032 (constitution §V, quickstart step 10): at the largest text
/// level, the receipts list and the lines table must not overflow at a
/// supported desktop width. The platform scale stands in for the user's
/// extra-large level, as in `pos_047_extra_large_text_test.dart`.
void main() {
  const desktop = Size(1280, 800);

  void useExtraLargeText(WidgetTester tester) {
    tester.platformDispatcher.textScaleFactorTestValue =
        TextSizeLevel.extraLarge.factor;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  testWidgets('the list at the largest text level does not overflow', (
    tester,
  ) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    harness.serve([
      aReceiptSummary(id: 32056),
      aReceiptSummary(
        id: 32020,
        serial: 2983,
        purchaseOrderId: 11049,
        status: InventoryDocumentStatus.completed,
      ),
      aReceiptSummary(
        id: 32054,
        serial: 2986,
        status: InventoryDocumentStatus.cancelled,
      ),
    ]);
    await harness.pump(tester, surface: desktop);

    expect(key('inventory_receipts_table'), findsOneWidget);
    expect(key('inventory_receipt_folio_32056'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a linked receipt\'s lines table at the largest text level does '
      'not overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    await harness.pumpReceipt(
      tester,
      aReceipt(
        purchaseOrderId: 11049,
        comment: 'Entrega parcial del proveedor',
        lines: [
          aReceiptLine(
            quantity: '1440',
            purchaseOrderLineId: 87548,
            ordered: '1440',
            elsewhere: '120.5',
          ),
          aReceiptLine(
            id: 901,
            productId: 8,
            quantity: '12345.678',
            purchaseOrderLineId: 87549,
            ordered: '10000',
            elsewhere: '0',
          ),
        ],
      ),
      surface: desktop,
    );

    expect(key('inventory_receipt_lines_table'), findsOneWidget);
    expect(key('inventory_receipt_line_ordered_900'), findsOneWidget);
    expect(key('inventory_receipt_line_elsewhere_901'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a draft\'s lines table with its row icons at the largest text '
      'level does not overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    await harness.pumpReceipt(
      tester,
      aReceipt(
        lines: [
          aReceiptLine(),
          aReceiptLine(id: 901, productId: 8, quantity: '12345.678'),
        ],
      ),
      surface: desktop,
    );

    expect(key('inventory_receipt_line_edit_900'), findsOneWidget);
    expect(key('inventory_receipt_line_remove_901'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
