import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_receipt_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 067 US2 (T020): the quantity, remove-line and confirm prompts,
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
      await h.pumpReceipt(tester, aReceipt());
      await tester.tap(key('inventory_receipt_line_edit_900'));
      await tester.pumpAndSettle();
    }

    Finder field() => key('inventory_receipt_line_quantity_field');

    FilledButton submit(WidgetTester tester) => tester.widget<FilledButton>(
      key('inventory_receipt_line_quantity_submit'),
    );

    testWidgets('is prefilled, and unchanged it can\'t be saved', (
      tester,
    ) async {
      await open(tester);

      expect(key('inventory_receipt_line_quantity_dialog'), findsOneWidget);
      expect(tester.widget<TextField>(field()).controller!.text, '8');
      expect(submit(tester).onPressed, isNull);
    });

    testWidgets('a quantity of 0 can\'t be saved', (tester) async {
      await open(tester);

      await tester.enterText(field(), '0');
      await tester.pumpAndSettle();

      expect(find.text(l10n.inventoryReceiptQuantityInvalid), findsOneWidget);
      expect(submit(tester).onPressed, isNull);
    });

    testWidgets('saves the new quantity and closes', (tester) async {
      when(
        () => h.receipts.updateLine(318, 900, quantity: any(named: 'quantity')),
      ).thenAnswer(
        (_) async => aReceipt(lines: [aReceiptLine(quantity: '12')]),
      );
      await open(tester);

      await tester.enterText(field(), '12');
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_receipt_line_quantity_submit'));
      await tester.pumpAndSettle();

      verify(
        () => h.receipts.updateLine(318, 900, quantity: Decimal.fromInt(12)),
      ).called(1);
      expect(key('inventory_receipt_line_quantity_dialog'), findsNothing);
      expect(
        tester.widget<Text>(key('inventory_receipt_line_quantity_900')).data,
        '12',
      );
    });

    testWidgets('a refusal stays in the dialog, localized', (tester) async {
      when(
        () => h.receipts.updateLine(318, 900, quantity: any(named: 'quantity')),
      ).thenAnswer((_) async => throw notEditable);
      await open(tester);

      await tester.enterText(field(), '12');
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_receipt_line_quantity_submit'));
      await tester.pumpAndSettle();

      expect(key('inventory_receipt_line_quantity_dialog'), findsOneWidget);
      expect(key('inventory_receipt_dialog_refusal'), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
    });
  });

  group('remove', () {
    Future<void> open(WidgetTester tester) async {
      await h.pumpReceipt(tester, aReceipt());
      await tester.tap(key('inventory_receipt_line_remove_900'));
      await tester.pumpAndSettle();
    }

    testWidgets('names the product and removes the line', (tester) async {
      when(
        () => h.receipts.removeLine(318, 900),
      ).thenAnswer((_) async => aReceipt(lines: const []));
      await open(tester);

      expect(
        find.text(l10n.inventoryReceiptRemoveTitle('Tornillo 1/4 caja')),
        findsOneWidget,
      );
      await tester.tap(key('inventory_receipt_line_remove_submit'));
      await tester.pumpAndSettle();

      verify(() => h.receipts.removeLine(318, 900)).called(1);
      expect(key('inventory_receipt_line_remove_dialog'), findsNothing);
      expect(key('inventory_receipt_lines_empty'), findsOneWidget);
    });

    testWidgets('a refusal stays in the dialog', (tester) async {
      when(
        () => h.receipts.removeLine(318, 900),
      ).thenAnswer((_) async => throw notEditable);
      await open(tester);

      await tester.tap(key('inventory_receipt_line_remove_submit'));
      await tester.pumpAndSettle();

      expect(key('inventory_receipt_line_remove_dialog'), findsOneWidget);
      expect(key('inventory_receipt_dialog_refusal'), findsOneWidget);
    });
  });

  group('confirm', () {
    Future<void> open(WidgetTester tester) async {
      await h.pumpReceipt(tester, aReceipt());
      await tester.tap(key('inventory_receipt_confirm'));
      await tester.pumpAndSettle();
    }

    testWidgets('explains what confirming does', (tester) async {
      await open(tester);

      expect(find.text(l10n.inventoryReceiptConfirmTitle), findsOneWidget);
      expect(find.text(l10n.inventoryReceiptConfirmBody), findsOneWidget);
    });

    testWidgets('Volver closes without confirming', (tester) async {
      await open(tester);

      await tester.tap(find.text(l10n.inventoryReceiptBack));
      await tester.pumpAndSettle();

      expect(key('inventory_receipt_confirm_dialog'), findsNothing);
      verifyNever(() => h.receipts.confirm(any()));
    });

    testWidgets('Confirmar confirms and closes', (tester) async {
      when(() => h.receipts.confirm(318)).thenAnswer(
        (_) async =>
            aReceipt(serial: 1043, status: InventoryDocumentStatus.completed),
      );
      await open(tester);

      await tester.tap(key('inventory_receipt_confirm_submit'));
      await tester.pumpAndSettle();

      verify(() => h.receipts.confirm(318)).called(1);
      expect(key('inventory_receipt_confirm_dialog'), findsNothing);
    });
  });

  group('cancel (US4)', () {
    Future<void> open(WidgetTester tester, InventoryReceipt receipt) async {
      await h.pumpReceipt(tester, receipt);
      await tester.tap(key('inventory_receipt_cancel'));
      await tester.pumpAndSettle();
    }

    testWidgets('a draft says cancelling adds no stock', (tester) async {
      await open(tester, aReceipt());

      expect(key('inventory_receipt_cancel_dialog'), findsOneWidget);
      expect(
        tester.widget<Text>(key('inventory_receipt_cancel_body')).data,
        l10n.inventoryReceiptCancelDraftBody,
      );
    });

    testWidgets('a confirmed receipt says its stock is taken back out', (
      tester,
    ) async {
      await open(
        tester,
        aReceipt(serial: 1043, status: InventoryDocumentStatus.completed),
      );

      expect(
        tester.widget<Text>(key('inventory_receipt_cancel_body')).data,
        l10n.inventoryReceiptCancelCompletedBody,
      );
    });

    testWidgets('Volver closes without cancelling', (tester) async {
      await open(tester, aReceipt());

      await tester.tap(find.text(l10n.inventoryReceiptBack));
      await tester.pumpAndSettle();

      expect(key('inventory_receipt_cancel_dialog'), findsNothing);
      verifyNever(() => h.receipts.cancel(any()));
    });

    testWidgets('Cancelar entrada cancels and closes', (tester) async {
      when(() => h.receipts.cancel(318)).thenAnswer(
        (_) async => aReceipt(status: InventoryDocumentStatus.cancelled),
      );
      await open(tester, aReceipt());

      await tester.tap(key('inventory_receipt_cancel_submit'));
      await tester.pumpAndSettle();

      verify(() => h.receipts.cancel(318)).called(1);
      expect(key('inventory_receipt_cancel_dialog'), findsNothing);
    });
  });
}
