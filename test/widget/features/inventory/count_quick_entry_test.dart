import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_count_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 070 US3 (T022, T024): Captura rápida on the count detail.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(<CountLineInput>[]);
  });

  setUp(() => h = InventoryHarness());

  final code = key('count_quick_entry_code');
  final quantity = key('count_quick_entry_quantity');

  bool focused(WidgetTester tester, Finder field) =>
      tester.widget<TextField>(field).focusNode!.hasFocus;

  String text(WidgetTester tester, Finder field) =>
      tester.widget<TextField>(field).controller!.text;

  /// Types [c] and Enter, then [q] and Enter, as a scanner and keyboard do.
  Future<void> enter(WidgetTester tester, String c, String q) async {
    await tester.showKeyboard(code);
    tester.testTextInput.enterText(c);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(focused(tester, quantity), isTrue);
    tester.testTextInput.enterText(q);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  /// `setLines` answers [answer].
  void stubSetLines(Future<InventoryCount> Function() answer) =>
      when(() => h.counts.setLines(412, any())).thenAnswer((_) => answer());

  testWidgets('keyboard only: Enter moves to Cantidad, Enter submits, both '
      'fields clear and focus returns to Código; a counted product says '
      '"(reemplazada)" (FR-009, SC-008)', (tester) async {
    stubSetLines(() async => aCount(lines: [aCountLine(quantity: '12')]));
    await h.pumpCount(tester, aCount());

    await enter(tester, ' a-100 ', '12');

    final sent =
        verify(() => h.counts.setLines(412, captureAny())).captured.single
            as List<CountLineInput>;
    expect(sent, [
      CountLineInput.byCode(code: 'a-100', quantity: Decimal.parse('12')),
    ]);
    expect(text(tester, code), isEmpty);
    expect(text(tester, quantity), isEmpty);
    expect(focused(tester, code), isTrue);
    expect(
      tester.widget<Text>(key('count_quick_entry_feedback')).data,
      'A-100 Tornillo 1/4 caja: 8 → 12 (reemplazada)',
    );
    expect(
      tester.widget<Text>(key('inventory_count_line_quantity_1200')).data,
      '12',
    );
  });

  testWidgets('a product not yet counted shows its new quantity only', (
    tester,
  ) async {
    stubSetLines(
      () async => aCount(
        lines: [
          aCountLine(),
          aCountLine(
            id: 1201,
            productId: 8,
            productCode: 'B-220',
            productName: 'Taquete 5/16',
            quantity: '3.5',
          ),
        ],
      ),
    );
    await h.pumpCount(tester, aCount());

    await enter(tester, 'B-220', '3.5');

    expect(
      tester.widget<Text>(key('count_quick_entry_feedback')).data,
      'B-220 Taquete 5/16: 3.5',
    );
    expect(find.textContaining('reemplazada'), findsNothing);
    expect(focused(tester, code), isTrue);
  });

  testWidgets('an unknown code keeps the values and shows "El producto no '
      'existe." (US3 #2)', (tester) async {
    stubSetLines(
      () async => throw AppError.validation(
        const [],
        'SERVER TEXT',
        const ApiProblem(
          codeName: 'inventory_count.batch_invalid',
          code: api.ErrorCode.inventoryCountPeriodBatchInvalid,
          detail: 'SERVER TEXT',
          parts: [
            ApiProblemPart(
              codeName: 'inventory_count_line.product_unknown',
              code: api.ErrorCode.inventoryCountLinePeriodProductUnknown,
              extra: {'index': 0, 'product_code': 'Z-999'},
            ),
          ],
        ),
      ),
    );
    await h.pumpCount(tester, aCount());

    await enter(tester, 'Z-999', '4');

    expect(key('count_quick_entry_refusal'), findsOneWidget);
    expect(find.text('El producto no existe.'), findsOneWidget);
    expect(find.text('SERVER TEXT'), findsNothing);
    expect(text(tester, code), 'Z-999');
    expect(text(tester, quantity), '4');
    expect(key('count_quick_entry_feedback'), findsNothing);
  });

  testWidgets('an invalid quantity is not sent', (tester) async {
    await h.pumpCount(tester, aCount());

    await enter(tester, 'A-100', '-1');

    verifyNever(() => h.counts.setLines(any(), any()));
    expect(find.text(l10n.inventoryCountQuantityInvalid), findsOneWidget);
    expect(text(tester, code), 'A-100');
  });

  testWidgets('Registrar submits too', (tester) async {
    stubSetLines(() async => aCount());
    await h.pumpCount(tester, aCount());

    await tester.enterText(code, 'A-100');
    await tester.enterText(quantity, '8');
    await tester.tap(key('count_quick_entry_submit'));
    await tester.pumpAndSettle();

    verify(() => h.counts.setLines(412, any())).called(1);
    expect(text(tester, code), isEmpty);
  });

  testWidgets('the row is absent for a read-only user', (tester) async {
    await h.pumpCount(
      tester,
      aCount(),
      who: InventoryHarness.countUser(counts: 2),
    );

    expect(key('count_quick_entry'), findsNothing);
    expect(code, findsNothing);
  });

  testWidgets('the row is absent on a completed count', (tester) async {
    await h.pumpCount(
      tester,
      aCount(
        serial: 77,
        status: InventoryDocumentStatus.completed,
        lines: [aCompletedCountLine()],
      ),
    );

    expect(key('count_quick_entry'), findsNothing);
  });
}
