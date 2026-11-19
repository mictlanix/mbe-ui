import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/errors/localize_problem.dart';
import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_count_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 070 US3 (T021, T024): Pegar lista on the count detail.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(<CountLineInput>[]);
  });

  setUp(() => h = InventoryHarness());

  final dialog = key('count_paste_dialog');
  final send = key('count_paste_send');

  /// [n] clean tab-separated rows coded P1…Pn.
  String rows(int n) => [for (var i = 1; i <= n; i++) 'P$i\t$i'].join('\n');

  String count(int n) => h.container.read(formattersProvider).display.count(n);

  bool sendEnabled(WidgetTester tester) =>
      tester.widget<FilledButton>(send).onPressed != null;

  Future<void> open(WidgetTester tester) async {
    await h.pumpCount(tester, aCount());
    await tester.tap(key('inventory_count_paste'));
    await tester.pumpAndSettle();
    expect(dialog, findsOneWidget);
  }

  Future<void> paste(WidgetTester tester, String text) async {
    await tester.enterText(key('count_paste_text'), text);
    await tester.pump();
  }

  /// Each `setLines` call waits for its own completer, in order.
  List<Completer<InventoryCountLinesChange>> gateSetLines() {
    final gates = <Completer<InventoryCountLinesChange>>[];
    when(() => h.counts.setLines(412, any())).thenAnswer((_) {
      final gate = Completer<InventoryCountLinesChange>();
      gates.add(gate);
      return gate.future;
    });
    return gates;
  }

  AppError batchInvalid(int index) => AppError.validation(
    const [],
    'SERVER TEXT',
    ApiProblem(
      codeName: 'inventory_count.batch_invalid',
      code: api.ErrorCode.inventoryCountPeriodBatchInvalid,
      detail: 'SERVER TEXT',
      parts: [
        ApiProblemPart(
          codeName: 'inventory_count_line.product_unknown',
          code: api.ErrorCode.inventoryCountLinePeriodProductUnknown,
          extra: {'index': index, 'product_code': 'x', 'reason': 'SERVER'},
        ),
      ],
    ),
  );

  testWidgets('re-reads on every edit: the live counts and each problem with '
      'its row number, and Enviar waits for a clean list (US3 #3)', (
    tester,
  ) async {
    await open(tester);
    expect(find.text(l10n.inventoryCountPasteInstructions), findsOneWidget);
    expect(sendEnabled(tester), isFalse);

    await paste(tester, 'A-100\t12\nB-220\tabc\n\nC-310;4,5\na-100\t3');

    expect(
      tester.widget<Text>(key('count_paste_summary')).data,
      '4 filas leídas · 2 con problemas',
    );
    expect(find.text('Fila 2: la cantidad no es un número'), findsOneWidget);
    expect(find.text('Fila 5: el código está repetido'), findsOneWidget);
    expect(sendEnabled(tester), isFalse);

    await paste(tester, 'A-100\t12\nC-310;4,5');
    expect(
      tester.widget<Text>(key('count_paste_summary')).data,
      '2 filas leídas · 0 con problemas',
    );
    expect(key('count_paste_problems'), findsNothing);
    expect(sendEnabled(tester), isTrue);
  });

  testWidgets('a header row is reported as row 1 and Enviar stays disabled', (
    tester,
  ) async {
    await open(tester);
    await paste(tester, 'Código\tCantidad\nA-100\t12');

    expect(find.text('Fila 1: la cantidad no es un número'), findsOneWidget);
    expect(sendEnabled(tester), isFalse);
  });

  testWidgets('a clean list is sent by code, the dialog closes and the count '
      'is re-fetched', (tester) async {
    when(
      () => h.counts.setLines(412, any()),
    ).thenAnswer((_) async => aLinesChange());
    await open(tester);
    await paste(tester, 'A-100\t12\nB-220\t0,5');

    await tester.tap(send);
    await tester.pumpAndSettle();

    final sent =
        verify(() => h.counts.setLines(412, captureAny())).captured.single
            as List<CountLineInput>;
    expect(sent, [
      CountLineInput.byCode(code: 'A-100', quantity: Decimal.parse('12')),
      CountLineInput.byCode(code: 'B-220', quantity: Decimal.parse('0.5')),
    ]);
    expect(dialog, findsNothing);
    verify(() => h.counts.get(412)).called(2);
  });

  testWidgets('2,500 rows go as two batches with progress, and the dialog '
      "can't be dismissed while sending (FR-011d)", (tester) async {
    final gates = gateSetLines();
    await open(tester);
    await paste(tester, rows(2500));

    await tester.tap(send);
    await tester.pump();
    expect(key('count_paste_progress'), findsOneWidget);
    expect(find.text(l10n.inventoryCountPasteSending), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text(l10n.inventoryCountPasteBatch(1, 2)), findsOneWidget);
    expect(
      find.text(l10n.inventoryCountPasteProgress(count(0), count(2500))),
      findsOneWidget,
    );

    // Neither the barrier nor back closes it.
    await tester.tapAt(const Offset(4, 4));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(dialog, findsOneWidget);

    gates[0].complete(aLinesChange());
    await tester.pump();
    await tester.pump();
    expect(find.text(l10n.inventoryCountPasteBatch(2, 2)), findsOneWidget);
    expect(
      find.text(l10n.inventoryCountPasteProgress(count(2000), count(2500))),
      findsOneWidget,
    );

    gates[1].complete(aLinesChange());
    await tester.pumpAndSettle();
    expect(gates, hasLength(2));
    final batches = verify(
      () => h.counts.setLines(412, captureAny()),
    ).captured.cast<List<CountLineInput>>();
    expect(batches.map((b) => b.length), [2000, 500]);
    expect(dialog, findsNothing);
  });

  testWidgets('a refused second batch lists the code with its row number, '
      'how many rows were applied and the safe-to-repaste note; closing '
      're-fetches (US3 #5)', (tester) async {
    var calls = 0;
    when(() => h.counts.setLines(412, any())).thenAnswer((_) async {
      calls++;
      if (calls == 2) throw batchInvalid(3);
      return aLinesChange();
    });
    await open(tester);
    await paste(tester, rows(2500));

    await tester.tap(send);
    await tester.pumpAndSettle();

    expect(key('count_paste_stopped'), findsOneWidget);
    expect(
      find.text(l10n.inventoryCountPasteStopped(count(2000), count(2500))),
      findsOneWidget,
    );
    expect(find.textContaining('2,000 de 2,500'), findsOneWidget);
    expect(
      find.text(l10n.inventoryCountPasteRejectedHeading(2)),
      findsOneWidget,
    );
    // Index 3 of batch 2 is row 2,004.
    expect(
      tester.widget<Text>(key('count_paste_rejected_2004')).data,
      l10n.inventoryCountPasteRejectedLine(
        'P2004',
        'El producto no existe.',
        2004,
      ),
    );
    expect(find.text(l10n.inventoryCountPasteSafeNote), findsOneWidget);
    expect(find.textContaining('SERVER'), findsNothing);

    await tester.tap(key('count_paste_close'));
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    verify(() => h.counts.get(412)).called(2);
  });

  testWidgets('a non-batch refusal (lock.busy) stops with the banner', (
    tester,
  ) async {
    final busy = aRefusal(api.ErrorCode.lockPeriodBusy, 'lock.busy', {
      'resource': 'inventory_count',
    });
    when(() => h.counts.setLines(412, any())).thenAnswer((_) async {
      throw busy;
    });
    await open(tester);
    await paste(tester, rows(3));

    await tester.tap(send);
    await tester.pumpAndSettle();

    expect(key('count_paste_refusal'), findsOneWidget);
    expect(
      find.text(
        busy.localizedMessage(l10n, h.container.read(formattersProvider))!,
      ),
      findsOneWidget,
    );
    expect(find.text('SERVER TEXT'), findsNothing);
    expect(
      find.text(l10n.inventoryCountPasteStopped(count(0), count(3))),
      findsOneWidget,
    );
    expect(key('count_paste_rejected'), findsNothing);
  });

  testWidgets('closing with unsent text asks before discarding it', (
    tester,
  ) async {
    await open(tester);
    await paste(tester, 'A-100\t12');

    await tester.tap(
      find.descendant(of: dialog, matching: find.text(l10n.cancelButton)),
    );
    await tester.pumpAndSettle();
    expect(key('record_sheet_discard_dialog'), findsOneWidget);

    await tester.tap(key('record_sheet_discard_cancel'));
    await tester.pumpAndSettle();
    expect(dialog, findsOneWidget);

    await tester.tap(
      find.descendant(of: dialog, matching: find.text(l10n.cancelButton)),
    );
    await tester.pumpAndSettle();
    await tester.tap(key('record_sheet_discard_confirm'));
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    // Nothing was sent, so nothing is re-fetched.
    verify(() => h.counts.get(412)).called(1);
  });

  testWidgets('closing an empty dialog asks nothing', (tester) async {
    await open(tester);

    await tester.tap(
      find.descendant(of: dialog, matching: find.text(l10n.cancelButton)),
    );
    await tester.pumpAndSettle();
    expect(key('record_sheet_discard_dialog'), findsNothing);
    expect(dialog, findsNothing);
  });
}
