import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';
import 'invoicing_harness.dart';

/// Spec 066 US4, contract C8: the line dialog, opened with a row's ✎.
void main() {
  late InvoiceHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(const InvoiceLinePatch());
  });

  setUp(() => h = InvoiceHarness());

  Future<void> open(WidgetTester tester) async {
    await h.pump(tester);
    await tester.tap(key('fiscal_document_line_edit_10'));
    await tester.pumpAndSettle();
  }

  TextField field(WidgetTester tester, String k) =>
      tester.widget<TextField>(key(k));

  bool canSave(WidgetTester tester) =>
      tester.widget<FilledButton>(key('invoice_line_submit')).onPressed != null;

  InvoiceLinePatch sentPatch() =>
      verify(() => h.documents.updateLine(7, 10, captureAny())).captured.single
          as InvoiceLinePatch;

  testWidgets('the fields fill from the line, and Guardar waits for an edit', (
    tester,
  ) async {
    await open(tester);

    expect(field(tester, 'invoice_line_quantity').controller!.text, '2');
    expect(field(tester, 'invoice_line_price').controller!.text, '100.00');
    expect(field(tester, 'invoice_line_discount').controller!.text, '0');
    expect(field(tester, 'invoice_line_code').controller!.text, 'P-1');
    expect(field(tester, 'invoice_line_name').controller!.text, 'Tornillo');
    expect(find.text(l10n.fiscalDocumentTaxIva16), findsWidgets);
    expect(canSave(tester), isFalse);
  });

  testWidgets('a quantity of 0 or less is refused inline', (tester) async {
    await open(tester);

    await tester.enterText(key('invoice_line_quantity'), '0');
    await tester.pump();

    expect(find.text(l10n.fiscalDocumentLineQuantityInvalid), findsOneWidget);
    expect(canSave(tester), isFalse);

    await tester.enterText(key('invoice_line_quantity'), '-3');
    await tester.pump();
    expect(canSave(tester), isFalse);
  });

  testWidgets('a negative price and a discount above 100 are refused', (
    tester,
  ) async {
    await open(tester);

    await tester.enterText(key('invoice_line_price'), '-1');
    await tester.pump();
    expect(find.text(l10n.fiscalDocumentLinePriceInvalid), findsOneWidget);
    expect(canSave(tester), isFalse);

    await tester.enterText(key('invoice_line_price'), '100.00');
    await tester.enterText(key('invoice_line_discount'), '101');
    await tester.pump();
    expect(find.text(l10n.fiscalDocumentLineDiscountInvalid), findsOneWidget);
    expect(canSave(tester), isFalse);
  });

  testWidgets('only the changed fields are sent: a discount of 10 %', (
    tester,
  ) async {
    when(
      () => h.documents.updateLine(7, 10, any()),
    ).thenAnswer((_) async => aDocument());
    await open(tester);

    await tester.enterText(key('invoice_line_discount'), '10');
    await tester.pump();
    await tester.tap(key('invoice_line_submit'));
    await tester.pumpAndSettle();

    final patch = sentPatch();
    expect(patch.discountPercent, Decimal.parse('10'));
    expect(patch.quantity, isNull);
    expect(patch.price, isNull);
    expect(patch.taxRate, isNull);
    expect(patch.productCode, isNull);
    expect(patch.productName, isNull);
    expect(patch.comment, isNull);
    expect(key('invoice_line_dialog'), findsNothing);
  });

  testWidgets('Exento is sent as exempt', (tester) async {
    when(
      () => h.documents.updateLine(7, 10, any()),
    ).thenAnswer((_) async => aDocument());
    await open(tester);

    await tester.tap(key('invoice_line_tax'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.fiscalDocumentTaxExempt).last);
    await tester.pumpAndSettle();
    await tester.tap(key('invoice_line_submit'));
    await tester.pumpAndSettle();

    expect(sentPatch().taxRate, InvoiceTaxRate.exempt);
  });

  testWidgets('a blank description is sent blank so the server resets it', (
    tester,
  ) async {
    when(
      () => h.documents.updateLine(7, 10, any()),
    ).thenAnswer((_) async => aDocument());
    await open(tester);

    expect(find.text(l10n.fiscalDocumentLineNameHelper), findsOneWidget);
    await tester.enterText(key('invoice_line_name'), '');
    await tester.pump();
    await tester.tap(key('invoice_line_submit'));
    await tester.pumpAndSettle();

    expect(sentPatch().productName, '');
  });

  testWidgets('a new quantity and price are sent as decimals', (tester) async {
    when(
      () => h.documents.updateLine(7, 10, any()),
    ).thenAnswer((_) async => aDocument());
    await open(tester);

    await tester.enterText(key('invoice_line_quantity'), '2.5');
    await tester.enterText(key('invoice_line_price'), '99.5');
    await tester.pump();
    await tester.tap(key('invoice_line_submit'));
    await tester.pumpAndSettle();

    final patch = sentPatch();
    expect(patch.quantity, Decimal.parse('2.5'));
    expect(patch.price, Decimal.parse('99.5'));
  });

  group('closing', () {
    testWidgets('after an edit asks before discarding', (tester) async {
      await open(tester);
      await tester.enterText(key('invoice_line_comment'), 'urgente');
      await tester.pump();

      await tester.tap(find.text(l10n.cancelButton));
      await tester.pumpAndSettle();

      expect(key('record_sheet_discard_dialog'), findsOneWidget);
      expect(key('invoice_line_dialog'), findsOneWidget);

      await tester.tap(key('record_sheet_discard_cancel'));
      await tester.pumpAndSettle();
      expect(key('invoice_line_dialog'), findsOneWidget);

      await tester.tap(find.text(l10n.cancelButton));
      await tester.pumpAndSettle();
      await tester.tap(key('record_sheet_discard_confirm'));
      await tester.pumpAndSettle();
      expect(key('invoice_line_dialog'), findsNothing);
      verifyNever(() => h.documents.updateLine(any(), any(), any()));
    });

    testWidgets('untouched closes without asking', (tester) async {
      await open(tester);

      await tester.tap(find.text(l10n.cancelButton));
      await tester.pumpAndSettle();

      expect(key('record_sheet_discard_dialog'), findsNothing);
      expect(key('invoice_line_dialog'), findsNothing);
    });

    testWidgets('the back gesture after an edit asks too', (tester) async {
      await open(tester);
      await tester.enterText(key('invoice_line_comment'), 'x');
      await tester.pump();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(key('record_sheet_discard_dialog'), findsOneWidget);
    });
  });

  group('refusals', () {
    testWidgets('quantity_exceeds_invoiceable keeps the dialog open with what '
        'remains', (tester) async {
      when(() => h.documents.updateLine(7, 10, any())).thenThrow(
        const AppError.server(
          statusCode: 422,
          problem: ApiProblem(
            codeName: 'fiscal_document.quantity_exceeds_invoiceable',
            code: api.ErrorCode.fiscalDocumentPeriodQuantityExceedsInvoiceable,
            params: {'remaining': '1.5'},
          ),
        ),
      );
      await open(tester);

      await tester.enterText(key('invoice_line_quantity'), '9');
      await tester.pump();
      await tester.tap(key('invoice_line_submit'));
      await tester.pumpAndSettle();

      expect(key('invoice_line_dialog'), findsOneWidget);
      expect(
        find.text(l10n.apiErrorFiscalDocumentQuantityExceedsInvoiceable('1.5')),
        findsOneWidget,
      );
      expect(canSave(tester), isTrue);
    });

    testWidgets('any other refusal closes the dialog and shows above the '
        'action area', (tester) async {
      when(() => h.documents.updateLine(7, 10, any())).thenThrow(
        const AppError.server(
          statusCode: 409,
          problem: ApiProblem(
            codeName: 'fiscal_document.not_draft',
            code: api.ErrorCode.fiscalDocumentPeriodNotDraft,
          ),
        ),
      );
      await open(tester);

      await tester.enterText(key('invoice_line_comment'), 'x');
      await tester.pump();
      await tester.tap(key('invoice_line_submit'));
      await tester.pumpAndSettle();

      expect(key('invoice_line_dialog'), findsNothing);
      expect(find.text(l10n.apiErrorFiscalDocumentNotDraft), findsOneWidget);
    });
  });
}
