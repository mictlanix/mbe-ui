import 'dart:async';

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

AppError _refusal(
  String name,
  api.ErrorCode code, [
  Map<String, Object?> params = const {},
]) => AppError.server(
  statusCode: 422,
  problem: ApiProblem(codeName: name, code: code, params: params),
);

/// Spec 066 US5, contract C13: Confirmar and Reabrir.
void main() {
  late InvoiceHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = InvoiceHarness());

  FiscalDocument sealed() => aDocument(
    status: FiscalDocumentStatus.sealed,
    serial: 12,
    series: 'GR',
    total: Decimal.parse('232'),
  );

  group('Confirmar', () {
    testWidgets('shows on an editable draft with update', (tester) async {
      await h.pump(tester);
      expect(key('fiscal_document_confirm'), findsOneWidget);
      expect(key('fiscal_document_reopen'), findsNothing);
    });

    testWidgets('is absent without update, and on a non-draft', (tester) async {
      await h.pump(tester, who: InvoiceHarness.access(fiscalDocuments: 2));
      expect(key('fiscal_document_confirm'), findsNothing);
    });

    testWidgets('its dialog names the series; confirming seals the invoice and '
        'says which folio', (tester) async {
      var reloaded = false;
      when(() => h.documents.confirm(7)).thenAnswer((_) async {
        reloaded = true;
        return sealed();
      });
      await h.pump(tester, document: aDocument(series: 'GR'));
      // After the write the screen reloads and reads the sealed document.
      when(
        () => h.documents.getById(7),
      ).thenAnswer((_) async => reloaded ? sealed() : aDocument(series: 'GR'));

      await tester.tap(key('fiscal_document_confirm'));
      await tester.pumpAndSettle();

      expect(key('invoice_confirm_dialog'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentConfirmBody('GR')), findsOneWidget);

      await tester.tap(key('invoice_confirm_submit'));
      await tester.pumpAndSettle();

      verify(() => h.documents.confirm(7)).called(1);
      expect(key('invoice_confirm_dialog'), findsNothing);
      expect(find.text(l10n.fiscalDocumentConfirmed('GR12')), findsOneWidget);
      expect(key('fiscal_document_banner_sealed'), findsOneWidget);
      // No edit control is left on the sealed invoice.
      expect(key('fiscal_document_confirm'), findsNothing);
      expect(key('fiscal_document_edit_header'), findsNothing);
      expect(key('fiscal_document_line_edit_10'), findsNothing);
    });

    for (final (name, error, text) in <(String, AppError, String Function())>[
      (
        'no_lines',
        _refusal(
          'fiscal_document.no_lines',
          api.ErrorCode.fiscalDocumentPeriodNoLines,
        ),
        () => l10n.apiErrorFiscalDocumentNoLines,
      ),
      (
        'line_missing_sat_key',
        _refusal(
          'fiscal_document.line_missing_sat_key',
          api.ErrorCode.fiscalDocumentPeriodLineMissingSatKey,
          {'line': 2},
        ),
        () => l10n.apiErrorFiscalDocumentLineMissingSatKey('2'),
      ),
      (
        'recipient_incomplete',
        _refusal(
          'fiscal_document.recipient_incomplete',
          api.ErrorCode.fiscalDocumentPeriodRecipientIncomplete,
        ),
        () => l10n.apiErrorFiscalDocumentRecipientIncomplete,
      ),
      (
        'issue_date_out_of_range',
        _refusal(
          'fiscal_document.issue_date_out_of_range',
          api.ErrorCode.fiscalDocumentPeriodIssueDateOutOfRange,
        ),
        () => l10n.apiErrorFiscalDocumentIssueDateOutOfRange,
      ),
      (
        'no_valid_certificate',
        _refusal(
          'fiscal_document.no_valid_certificate',
          api.ErrorCode.fiscalDocumentPeriodNoValidCertificate,
        ),
        () => l10n.apiErrorFiscalDocumentNoValidCertificate,
      ),
      (
        'quantity_exceeds_invoiceable',
        _refusal(
          'fiscal_document.quantity_exceeds_invoiceable',
          api.ErrorCode.fiscalDocumentPeriodQuantityExceedsInvoiceable,
          {'remaining': '1.5', 'line': 1},
        ),
        () => l10n.apiErrorFiscalDocumentQuantityExceedsInvoiceableLine(
          '1',
          '1.5',
        ),
      ),
    ]) {
      testWidgets('$name closes the dialog, shows its own message above the '
          'actions, and the document stays a draft', (tester) async {
        when(() => h.documents.confirm(7)).thenThrow(error);
        await h.pump(tester);

        await tester.tap(key('fiscal_document_confirm'));
        await tester.pumpAndSettle();
        await tester.tap(key('invoice_confirm_submit'));
        await tester.pumpAndSettle();

        expect(key('invoice_confirm_dialog'), findsNothing);
        expect(find.text(text()), findsOneWidget);
        expect(key('fiscal_document_confirm'), findsOneWidget);
        expect(find.text(l10n.fiscalDocumentTotalEstimated), findsOneWidget);
      });
    }

    testWidgets('the next action clears an old refusal', (tester) async {
      when(() => h.documents.confirm(7)).thenThrow(
        _refusal(
          'fiscal_document.no_lines',
          api.ErrorCode.fiscalDocumentPeriodNoLines,
        ),
      );
      await h.pump(tester);
      await tester.tap(key('fiscal_document_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('invoice_confirm_submit'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.apiErrorFiscalDocumentNoLines), findsOneWidget);

      await tester.tap(key('fiscal_document_confirm'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.apiErrorFiscalDocumentNoLines), findsNothing);
    });

    testWidgets('pressing twice while it runs confirms once', (tester) async {
      final gate = Completer<FiscalDocument>();
      when(() => h.documents.confirm(7)).thenAnswer((_) => gate.future);
      await h.pump(tester);

      await tester.tap(key('fiscal_document_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('invoice_confirm_submit'));
      await tester.pump();
      await tester.tap(key('invoice_confirm_submit'), warnIfMissed: false);
      await tester.pump();

      verify(() => h.documents.confirm(7)).called(1);
      gate.complete(sealed());
      await tester.pumpAndSettle();
    });

    testWidgets('Cancelar seals nothing', (tester) async {
      await h.pump(tester);
      await tester.tap(key('fiscal_document_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.cancelButton));
      await tester.pumpAndSettle();

      expect(key('invoice_confirm_dialog'), findsNothing);
      verifyNever(() => h.documents.confirm(any()));
    });
  });

  group('Reabrir', () {
    testWidgets('shows only on a sealed invoice, with update', (tester) async {
      await h.pump(tester, document: sealed());
      expect(key('fiscal_document_reopen'), findsOneWidget);
      expect(key('fiscal_document_confirm'), findsNothing);
    });

    testWidgets('is absent on a draft and an issued invoice', (tester) async {
      await h.pump(tester);
      expect(key('fiscal_document_reopen'), findsNothing);
    });

    testWidgets('is absent for a user with read but not update', (
      tester,
    ) async {
      await h.pump(
        tester,
        document: sealed(),
        who: InvoiceHarness.access(fiscalDocuments: 2),
      );
      expect(key('fiscal_document_reopen'), findsNothing);
      expect(key('fiscal_document_confirm'), findsNothing);
    });

    testWidgets('its dialog names the folio; reopening calls reopen and says '
        'so', (tester) async {
      when(() => h.documents.reopen(7)).thenAnswer((_) async => aDocument());
      await h.pump(tester, document: sealed());

      await tester.tap(key('fiscal_document_reopen'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.fiscalDocumentReopenBody('GR12')), findsOneWidget);

      await tester.tap(key('invoice_reopen_submit'));
      await tester.pumpAndSettle();

      verify(() => h.documents.reopen(7)).called(1);
      expect(find.text(l10n.fiscalDocumentReopened('GR12')), findsOneWidget);
    });

    testWidgets('a refusal closes the dialog and shows above the actions', (
      tester,
    ) async {
      when(() => h.documents.reopen(7)).thenThrow(
        _refusal(
          'fiscal_document.not_sealed',
          api.ErrorCode.fiscalDocumentPeriodNotSealed,
        ),
      );
      await h.pump(tester, document: sealed());

      await tester.tap(key('fiscal_document_reopen'));
      await tester.pumpAndSettle();
      await tester.tap(key('invoice_reopen_submit'));
      await tester.pumpAndSettle();

      expect(key('invoice_reopen_dialog'), findsNothing);
      expect(find.text(l10n.apiErrorFiscalDocumentNotSealed), findsOneWidget);
    });
  });
}
