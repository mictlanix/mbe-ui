import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/inventory/inventory_issue_fixtures.dart';
import 'inventory_harness.dart';

/// Spec 068 US2 (T021): the quantity, remove-line and confirm prompts,
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
      await h.pumpIssue(tester, anIssue());
      await tester.tap(key('inventory_issue_line_edit_900'));
      await tester.pumpAndSettle();
    }

    Finder field() => key('inventory_issue_line_quantity_field');

    FilledButton submit(WidgetTester tester) => tester.widget<FilledButton>(
      key('inventory_issue_line_quantity_submit'),
    );

    testWidgets('is prefilled, and unchanged it can\'t be saved', (
      tester,
    ) async {
      await open(tester);

      expect(key('inventory_issue_line_quantity_dialog'), findsOneWidget);
      expect(tester.widget<TextField>(field()).controller!.text, '8');
      expect(submit(tester).onPressed, isNull);
    });

    testWidgets('a quantity of 0 can\'t be saved', (tester) async {
      await open(tester);

      await tester.enterText(field(), '0');
      await tester.pumpAndSettle();

      expect(find.text(l10n.inventoryIssueQuantityInvalid), findsOneWidget);
      expect(submit(tester).onPressed, isNull);
    });

    testWidgets('saves the new quantity and closes', (tester) async {
      when(
        () => h.issues.updateLine(318, 900, quantity: any(named: 'quantity')),
      ).thenAnswer((_) async => anIssue(lines: [anIssueLine(quantity: '12')]));
      await open(tester);

      await tester.enterText(field(), '12');
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_issue_line_quantity_submit'));
      await tester.pumpAndSettle();

      verify(
        () => h.issues.updateLine(318, 900, quantity: Decimal.fromInt(12)),
      ).called(1);
      expect(key('inventory_issue_line_quantity_dialog'), findsNothing);
      expect(
        tester.widget<Text>(key('inventory_issue_line_quantity_900')).data,
        '12',
      );
    });

    testWidgets('a refusal stays in the dialog, localized', (tester) async {
      when(
        () => h.issues.updateLine(318, 900, quantity: any(named: 'quantity')),
      ).thenAnswer((_) async => throw notEditable);
      await open(tester);

      await tester.enterText(field(), '12');
      await tester.pumpAndSettle();
      await tester.tap(key('inventory_issue_line_quantity_submit'));
      await tester.pumpAndSettle();

      expect(key('inventory_issue_line_quantity_dialog'), findsOneWidget);
      expect(key('inventory_issue_dialog_refusal'), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
    });
  });

  group('remove', () {
    Future<void> open(WidgetTester tester) async {
      await h.pumpIssue(tester, anIssue());
      await tester.tap(key('inventory_issue_line_remove_900'));
      await tester.pumpAndSettle();
    }

    testWidgets('names the product and removes the line', (tester) async {
      when(
        () => h.issues.removeLine(318, 900),
      ).thenAnswer((_) async => anIssue(lines: const []));
      await open(tester);

      expect(
        find.text(l10n.inventoryIssueRemoveTitle('Tornillo 1/4 caja')),
        findsOneWidget,
      );
      await tester.tap(key('inventory_issue_line_remove_submit'));
      await tester.pumpAndSettle();

      verify(() => h.issues.removeLine(318, 900)).called(1);
      expect(key('inventory_issue_line_remove_dialog'), findsNothing);
      expect(key('inventory_issue_lines_empty'), findsOneWidget);
    });

    testWidgets('a refusal stays in the dialog', (tester) async {
      when(
        () => h.issues.removeLine(318, 900),
      ).thenAnswer((_) async => throw notEditable);
      await open(tester);

      await tester.tap(key('inventory_issue_line_remove_submit'));
      await tester.pumpAndSettle();

      expect(key('inventory_issue_line_remove_dialog'), findsOneWidget);
      expect(key('inventory_issue_dialog_refusal'), findsOneWidget);
    });
  });

  group('confirm', () {
    Future<void> open(WidgetTester tester) async {
      await h.pumpIssue(tester, anIssue());
      await tester.tap(key('inventory_issue_confirm'));
      await tester.pumpAndSettle();
    }

    testWidgets('explains what confirming does', (tester) async {
      await open(tester);

      expect(find.text(l10n.inventoryIssueConfirmTitle), findsOneWidget);
      // Names the issue's warehouse and says the stock is taken out (FR-012).
      expect(
        find.text(l10n.inventoryIssueConfirmBody('Almacén 3')),
        findsOneWidget,
      );
      expect(l10n.inventoryIssueConfirmBody('Almacén 3'), contains('retira'));
    });

    testWidgets('Volver closes without confirming', (tester) async {
      await open(tester);

      await tester.tap(find.text(l10n.inventoryIssueBack));
      await tester.pumpAndSettle();

      expect(key('inventory_issue_confirm_dialog'), findsNothing);
      verifyNever(() => h.issues.confirm(any()));
    });

    testWidgets('Confirmar confirms and closes', (tester) async {
      when(() => h.issues.confirm(318)).thenAnswer(
        (_) async =>
            anIssue(serial: 1043, status: InventoryDocumentStatus.completed),
      );
      await open(tester);

      await tester.tap(key('inventory_issue_confirm_submit'));
      await tester.pumpAndSettle();

      verify(() => h.issues.confirm(318)).called(1);
      expect(key('inventory_issue_confirm_dialog'), findsNothing);
    });
  });

  group('cancel', () {
    Future<void> open(WidgetTester tester, InventoryIssue issue) async {
      await h.pumpIssue(tester, issue);
      await tester.tap(key('inventory_issue_cancel'));
      await tester.pumpAndSettle();
    }

    testWidgets('a draft reads "Cancelar el borrador"', (tester) async {
      await open(tester, anIssue());

      expect(
        tester.widget<Text>(key('inventory_issue_cancel_body')).data,
        l10n.inventoryIssueCancelDraftBody,
      );
      expect(l10n.inventoryIssueCancelDraftBody, 'Cancelar el borrador');
    });

    testWidgets('a completed issue names the folio and the warehouse and '
        'says the stock goes back', (tester) async {
      await open(
        tester,
        anIssue(serial: 1043, status: InventoryDocumentStatus.completed),
      );

      expect(
        tester.widget<Text>(key('inventory_issue_cancel_body')).data,
        'Cancelar la salida 1043 regresa a Almacén 3 las existencias que '
        'retiró.',
      );
    });

    testWidgets('Volver closes without cancelling', (tester) async {
      await open(tester, anIssue());

      await tester.tap(find.text(l10n.inventoryIssueBack));
      await tester.pumpAndSettle();

      expect(key('inventory_issue_cancel_dialog'), findsNothing);
      verifyNever(() => h.issues.cancel(any()));
    });

    testWidgets('Cancelar salida cancels and closes', (tester) async {
      when(() => h.issues.cancel(318)).thenAnswer(
        (_) async => anIssue(status: InventoryDocumentStatus.cancelled),
      );
      await open(tester, anIssue());

      await tester.tap(key('inventory_issue_cancel_submit'));
      await tester.pumpAndSettle();

      verify(() => h.issues.cancel(318)).called(1);
      expect(key('inventory_issue_cancel_dialog'), findsNothing);
    });
  });
}
