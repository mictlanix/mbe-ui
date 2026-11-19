import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_count_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 070 US2 (T019): the quantity, remove-line and confirm prompts,
/// opened from a draft's detail screen.
void main() {
  late InventoryHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.zero);
  });

  setUp(() => h = InventoryHarness());

  final notEditable = aRefusal(
    api.ErrorCode.documentPeriodNotEditable,
    'document.not_editable',
  );

  group('quantity', () {
    Future<void> open(WidgetTester tester) async {
      await h.pumpCount(tester, aCount());
      await tester.tap(key('inventory_count_line_edit_1200'));
      await tester.pumpAndSettle();
    }

    Finder field() => key('inventory_count_line_quantity_field');

    FilledButton submit(WidgetTester tester) => tester.widget<FilledButton>(
      key('inventory_count_line_quantity_submit'),
    );

    testWidgets('is prefilled, and unchanged it can\'t be saved', (
      tester,
    ) async {
      await open(tester);

      expect(key('inventory_count_line_quantity_dialog'), findsOneWidget);
      expect(tester.widget<TextField>(field()).controller!.text, '8');
      expect(submit(tester).onPressed, isNull);
    });

    testWidgets('a negative quantity or one with 5 decimals can\'t be saved', (
      tester,
    ) async {
      await open(tester);

      for (final text in ['-1', '1.23456', 'abc']) {
        await tester.enterText(field(), text);
        await tester.pumpAndSettle();
        expect(find.text(l10n.inventoryCountQuantityInvalid), findsOneWidget);
        expect(submit(tester).onPressed, isNull);
      }
    });

    testWidgets('0 and 4 decimals are valid', (tester) async {
      await open(tester);

      for (final text in ['0', '1.2345']) {
        await tester.enterText(field(), text);
        await tester.pumpAndSettle();
        expect(find.text(l10n.inventoryCountQuantityInvalid), findsNothing);
        expect(submit(tester).onPressed, isNotNull);
      }
    });

    testWidgets('saves 0 and closes', (tester) async {
      when(
        () => h.counts.updateLine(412, 1200, quantity: any(named: 'quantity')),
      ).thenAnswer(
        (_) async => aLinesChange(lines: [aCountLine(quantity: '0')]),
      );
      await open(tester);

      await tester.enterText(field(), '0');
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_count_line_quantity_submit'));
      await tester.pumpAndSettle();

      verify(
        () => h.counts.updateLine(412, 1200, quantity: Decimal.zero),
      ).called(1);
      expect(key('inventory_count_line_quantity_dialog'), findsNothing);
      expect(
        tester.widget<Text>(key('inventory_count_line_quantity_1200')).data,
        '0',
      );
    });

    testWidgets('a refusal stays in the dialog, localized', (tester) async {
      when(
        () => h.counts.updateLine(412, 1200, quantity: any(named: 'quantity')),
      ).thenAnswer((_) async => throw notEditable);
      await open(tester);

      await tester.enterText(field(), '12');
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_count_line_quantity_submit'));
      await tester.pumpAndSettle();

      expect(key('inventory_count_line_quantity_dialog'), findsOneWidget);
      expect(key('inventory_count_dialog_refusal'), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
    });
  });

  group('remove', () {
    Future<void> open(WidgetTester tester) async {
      await h.pumpCount(tester, aCount());
      await tester.tap(key('inventory_count_line_remove_1200'));
      await tester.pumpAndSettle();
    }

    testWidgets('names the product and removes the line', (tester) async {
      when(() => h.counts.removeLine(412, 1200)).thenAnswer(
        (_) async => aLinesChange(lineCount: 0, removedLineId: 1200),
      );
      await open(tester);

      expect(
        find.text(l10n.inventoryCountDialogRemoveBody('Tornillo 1/4 caja')),
        findsOneWidget,
      );
      await tester.tap(key('inventory_count_line_remove_submit'));
      await tester.pumpAndSettle();

      verify(() => h.counts.removeLine(412, 1200)).called(1);
      expect(key('inventory_count_line_remove_dialog'), findsNothing);
      expect(key('inventory_count_lines_empty'), findsOneWidget);
    });

    testWidgets('a refusal stays in the dialog', (tester) async {
      when(
        () => h.counts.removeLine(412, 1200),
      ).thenAnswer((_) async => throw notEditable);
      await open(tester);

      await tester.tap(key('inventory_count_line_remove_submit'));
      await tester.pumpAndSettle();

      expect(key('inventory_count_line_remove_dialog'), findsOneWidget);
      expect(key('inventory_count_dialog_refusal'), findsOneWidget);
    });
  });

  group('confirm', () {
    final completed = aCount(
      serial: 77,
      status: InventoryDocumentStatus.completed,
      lines: [aCompletedCountLine()],
    );

    Future<void> open(WidgetTester tester) async {
      await h.pumpCount(tester, aCount());
      await tester.tap(key('inventory_count_confirm'));
      await tester.pumpAndSettle();
    }

    void stubConfirm() =>
        when(
          () => h.counts.confirm(
            412,
            includeUncounted: any(named: 'includeUncounted'),
          ),
        ).thenAnswer(
          (_) async => CountConfirmResult(
            count: completed,
            warnings: const CountWarnings(),
          ),
        );

    testWidgets('says the stock is set to the counted quantities and that a '
        'confirmed count can\'t be cancelled', (tester) async {
      await open(tester);

      expect(find.text(l10n.inventoryCountDialogConfirmTitle), findsWidgets);
      final body = l10n.inventoryCountConfirmBody('Almacén 3');
      expect(find.text(body), findsOneWidget);
      expect(body, contains('quedan igual a lo contado'));
      expect(body, contains('no se puede cancelar'));
    });

    testWidgets('the uncounted option is off by default, and its value is '
        'sent', (tester) async {
      stubConfirm();
      await open(tester);

      final box = tester.widget<CheckboxListTile>(
        key('inventory_count_confirm_include_uncounted'),
      );
      expect(box.value, isFalse);
      expect(
        find.text(l10n.inventoryCountConfirmIncludeUncounted),
        findsOneWidget,
      );

      await tester.tap(key('inventory_count_confirm_include_uncounted'));
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_count_confirm_submit'));
      await tester.pumpAndSettle();

      verify(() => h.counts.confirm(412, includeUncounted: true)).called(1);
      expect(key('inventory_count_confirm_dialog'), findsNothing);
    });

    testWidgets('left off, it sends false', (tester) async {
      stubConfirm();
      await open(tester);

      await tester.tap(key('inventory_count_confirm_submit'));
      await tester.pumpAndSettle();

      verify(() => h.counts.confirm(412, includeUncounted: false)).called(1);
    });

    testWidgets('Volver closes without confirming', (tester) async {
      await open(tester);

      await tester.tap(find.text(l10n.inventoryCountDialogBack));
      await tester.pumpAndSettle();

      expect(key('inventory_count_confirm_dialog'), findsNothing);
      verifyNever(
        () => h.counts.confirm(
          any(),
          includeUncounted: any(named: 'includeUncounted'),
        ),
      );
    });
  });

  group('cancel draft (US5)', () {
    Future<void> open(WidgetTester tester) async {
      await h.pumpCount(tester, aCount());
      await tester.tap(key('inventory_count_cancel'));
      await tester.pumpAndSettle();
    }

    testWidgets('says the draft is cancelled with no stock changed', (
      tester,
    ) async {
      await open(tester);

      expect(key('inventory_count_cancel_dialog'), findsOneWidget);
      expect(
        tester.widget<Text>(key('responsive_dialog_title')).data,
        'Cancelar borrador',
      );
      expect(
        tester.widget<Text>(key('inventory_count_cancel_body')).data,
        'Cancelar el borrador #412. No se modifica ninguna existencia.',
      );
      expect(find.text(l10n.inventoryCountDialogBack), findsOneWidget);
      expect(
        find.descendant(
          of: key('inventory_count_cancel_submit'),
          matching: find.text(l10n.inventoryCountDialogCancelDraft),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Volver closes without cancelling', (tester) async {
      await open(tester);

      await tester.tap(find.text(l10n.inventoryCountDialogBack));
      await tester.pumpAndSettle();

      expect(key('inventory_count_cancel_dialog'), findsNothing);
      verifyNever(() => h.counts.cancel(any()));
    });

    testWidgets('accepting cancels the draft, which then shows Cancelado '
        'with no actions', (tester) async {
      when(() => h.counts.cancel(412)).thenAnswer(
        (_) async => aCount(status: InventoryDocumentStatus.cancelled),
      );
      await open(tester);

      await tester.tap(key('inventory_count_cancel_submit'));
      await tester.pumpAndSettle();

      verify(() => h.counts.cancel(412)).called(1);
      expect(find.text(l10n.inventoryCountStatusCancelled), findsOneWidget);
      expect(key('inventory_count_actions'), findsNothing);
      expect(key('inventory_count_refusal'), findsNothing);
    });

    testWidgets('a stale confirmed_cannot_cancel refusal shows in Spanish '
        'and re-fetches the count', (tester) async {
      var confirmed = false;
      when(() => h.counts.get(412)).thenAnswer(
        (_) async => confirmed
            ? aCount(serial: 57, status: InventoryDocumentStatus.completed)
            : aCount(),
      );
      when(() => h.counts.cancel(412)).thenAnswer((_) async {
        confirmed = true;
        throw aRefusal(
          api.ErrorCode.inventoryCountPeriodConfirmedCannotCancel,
          'inventory_count.confirmed_cannot_cancel',
        );
      });
      h.serveCounts(const []);
      await h.pumpCounts(tester, location: '/inventory/counts/412');
      await tester.tap(key('inventory_count_cancel'));
      await tester.pumpAndSettle();

      await tester.tap(key('inventory_count_cancel_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Un conteo confirmado no se puede cancelar. Corrígelo con un '
          'conteo nuevo.',
        ),
        findsOneWidget,
      );
      expect(find.text('SERVER TEXT'), findsNothing);
      verify(() => h.counts.get(412)).called(2);
      expect(find.text(l10n.inventoryCountStatusCompleted), findsOneWidget);
      expect(key('inventory_count_cancel'), findsNothing);
    });
  });
}
