import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/count_confirm_notice.dart';

import '../../../unit/features/inventory/inventory_count_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 070 T033 (constitution §V, quickstart step 13): at the largest text
/// level, the counts list, the detail with the quick-entry row, the lines
/// table with Esperado and Diferencia, the warnings band and the paste
/// dialog must not overflow at a supported desktop width. The platform
/// scale stands in for the user's extra-large level, as in
/// `inventory_issues_large_text_test.dart`.
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
    harness.serveCounts([
      aCountSummary(),
      aCountSummary(
        id: 409,
        serial: 2983,
        status: InventoryDocumentStatus.completed,
      ),
      aCountSummary(
        id: 405,
        serial: 2986,
        status: InventoryDocumentStatus.cancelled,
      ),
    ]);
    await harness.pumpCounts(tester, surface: desktop);

    expect(key('inventory_counts_table'), findsOneWidget);
    expect(key('inventory_count_folio_412'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a draft with the quick-entry row and its lines at the largest '
      'text level does not overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    await harness.pumpCount(
      tester,
      aCount(
        comment: 'Conteo anual de la bodega principal',
        lines: [
          aCountLine(),
          aCountLine(
            id: 1201,
            productId: 8,
            productCode: 'B-200',
            productName: 'Cemento gris saco 50 kg uso general',
            quantity: '12345.678',
          ),
        ],
      ),
      surface: desktop,
    );

    expect(key('count_quick_entry'), findsOneWidget);
    expect(key('inventory_count_lines_table'), findsOneWidget);
    expect(key('inventory_count_line_edit_1200'), findsOneWidget);
    expect(key('inventory_count_line_remove_1201'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a completed count with Esperado, Diferencia and the warnings '
      'band at the largest text level does not overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    await harness.pumpCount(
      tester,
      aCount(
        serial: 2983,
        status: InventoryDocumentStatus.completed,
        lines: [
          aCompletedCountLine(quantity: '1440', quantityOnHand: '1500'),
          aCompletedCountLine(
            id: 1201,
            productId: 8,
            productCode: 'B-200',
            quantity: '12345.678',
            quantityOnHand: '-98765.432',
          ),
        ],
      ),
      surface: desktop,
    );
    harness.container
        .read(countConfirmNoticeProvider(412).notifier)
        .show(someCountWarnings());
    await tester.pumpAndSettle();

    expect(key('count_confirm_warnings'), findsOneWidget);
    expect(key('inventory_count_line_expected_1201'), findsOneWidget);
    expect(key('inventory_count_line_difference_1201'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the paste dialog with problem rows at the largest text level '
      'does not overflow', (tester) async {
    useExtraLargeText(tester);
    final harness = InventoryHarness();
    await harness.pumpCount(tester, aCount(), surface: desktop);
    await tester.tap(key('inventory_count_paste'));
    await tester.pumpAndSettle();

    await tester.enterText(
      key('count_paste_text'),
      'A-100\t12\nB-220\tabc\n\nC-310;4,5\na-100\t3',
    );
    await tester.pump();

    expect(key('count_paste_dialog'), findsOneWidget);
    expect(key('count_paste_problems'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
