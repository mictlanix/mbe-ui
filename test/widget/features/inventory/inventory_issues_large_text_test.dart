import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';

import '../../../unit/features/inventory/inventory_issue_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 068 T030 (constitution §V, quickstart step 10): at the largest text
/// level, the issues list and the lines table must not overflow at a
/// supported desktop width. The platform scale stands in for the user's
/// extra-large level, as in `inventory_receipts_large_text_test.dart`.
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
    harness.serveIssues([
      anIssueSummary(id: 32056),
      anIssueSummary(
        id: 32020,
        serial: 2983,
        status: InventoryDocumentStatus.completed,
      ),
      anIssueSummary(
        id: 32054,
        serial: 2986,
        status: InventoryDocumentStatus.cancelled,
      ),
    ]);
    await harness.pumpIssues(tester, surface: desktop);

    expect(key('inventory_issues_table'), findsOneWidget);
    expect(key('inventory_issue_folio_32056'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a draft\'s lines table with its row icons at the largest text '
      'level does not overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    await harness.pumpIssue(
      tester,
      anIssue(
        comment: 'Merma por humedad en bodega',
        lines: [
          anIssueLine(),
          anIssueLine(id: 901, productId: 8, quantity: '12345.678'),
        ],
      ),
      surface: desktop,
    );

    expect(key('inventory_issue_lines_table'), findsOneWidget);
    expect(key('inventory_issue_line_edit_900'), findsOneWidget);
    expect(key('inventory_issue_line_remove_901'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a confirmed issue\'s lines table at the largest text level '
      'does not overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    await harness.pumpIssue(
      tester,
      anIssue(
        serial: 2983,
        status: InventoryDocumentStatus.completed,
        lines: [
          anIssueLine(quantity: '1440'),
          anIssueLine(id: 901, productId: 8, quantity: '12345.678'),
        ],
      ),
      surface: desktop,
    );

    expect(key('inventory_issue_lines_table'), findsOneWidget);
    expect(key('inventory_issue_line_quantity_901'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
