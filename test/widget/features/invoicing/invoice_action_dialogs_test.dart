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

  group('Timbrar (spec 072 C18, C20)', () {
    FiscalDocument issuedStamped({bool simulated = true}) => aDocument(
      status: FiscalDocumentStatus.issued,
      serial: 12,
      series: 'GR',
      total: Decimal.parse('232'),
      stamp: aStamp(simulated: simulated),
    );

    testWidgets('shows on a sealed invoice, next to Reabrir', (tester) async {
      await h.pump(tester, document: sealed());
      expect(key('fiscal_document_stamp'), findsOneWidget);
      expect(key('fiscal_document_reopen'), findsOneWidget);
    });

    testWidgets('shows on a sealed document of another type, which cannot be '
        'reopened', (tester) async {
      await h.pump(
        tester,
        document: aDocument(
          typeCode: 100,
          status: FiscalDocumentStatus.sealed,
          serial: 3,
          series: 'NC',
        ),
      );
      expect(key('fiscal_document_stamp'), findsOneWidget);
      expect(key('fiscal_document_reopen'), findsNothing);
    });

    testWidgets('is absent without update', (tester) async {
      await h.pump(
        tester,
        document: sealed(),
        who: InvoiceHarness.access(fiscalDocuments: 2),
      );
      expect(key('fiscal_document_stamp'), findsNothing);
    });

    for (final status in [
      FiscalDocumentStatus.draft,
      FiscalDocumentStatus.issued,
      FiscalDocumentStatus.stamping,
      FiscalDocumentStatus.cancellationPending,
      FiscalDocumentStatus.cancelled,
    ]) {
      testWidgets('is absent on a ${status.name} document', (tester) async {
        await h.pump(tester, document: aDocument(status: status));
        expect(key('fiscal_document_stamp'), findsNothing);
      });
    }

    testWidgets('its dialog names the document; stamping calls stamp, says so '
        'as simulated, and shows the stamp with no way back', (tester) async {
      var stamped = false;
      when(() => h.documents.stamp(7)).thenAnswer((_) async {
        stamped = true;
        return issuedStamped();
      });
      await h.pump(tester, document: sealed());
      when(
        () => h.documents.getById(7),
      ).thenAnswer((_) async => stamped ? issuedStamped() : sealed());

      await tester.tap(key('fiscal_document_stamp'));
      await tester.pumpAndSettle();
      expect(key('fiscal_document_stamp_dialog'), findsOneWidget);
      expect(
        find.text(l10n.fiscalDocumentStampTitle('Factura', 'GR12')),
        findsOneWidget,
      );
      expect(find.text(l10n.fiscalDocumentStampBody), findsOneWidget);

      await tester.tap(key('fiscal_document_stamp_submit'));
      await tester.pumpAndSettle();

      verify(() => h.documents.stamp(7)).called(1);
      expect(key('fiscal_document_stamp_dialog'), findsNothing);
      expect(
        find.text(l10n.fiscalDocumentStampedSimulated('GR12')),
        findsOneWidget,
      );
      expect(key('fiscal_document_simulated_badge'), findsOneWidget);
      expect(key('fiscal_document_view_pdf'), findsOneWidget);
      expect(key('fiscal_document_download_xml'), findsOneWidget);
      expect(key('fiscal_document_reopen'), findsNothing);
      expect(key('fiscal_document_stamp'), findsNothing);
    });

    testWidgets('a real (not simulated) stamp is reported without the '
        'simulated note', (tester) async {
      var stamped = false;
      when(() => h.documents.stamp(7)).thenAnswer((_) async {
        stamped = true;
        return issuedStamped(simulated: false);
      });
      await h.pump(tester, document: sealed());
      when(() => h.documents.getById(7)).thenAnswer(
        (_) async => stamped ? issuedStamped(simulated: false) : sealed(),
      );

      await tester.tap(key('fiscal_document_stamp'));
      await tester.pumpAndSettle();
      await tester.tap(key('fiscal_document_stamp_submit'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.fiscalDocumentStamped('GR12')), findsOneWidget);
      expect(key('fiscal_document_simulated_badge'), findsNothing);
    });

    testWidgets('pac.rejected closes the dialog and quotes the PAC; the '
        'document stays sealed', (tester) async {
      when(() => h.documents.stamp(7)).thenThrow(
        _refusal('pac.rejected', api.ErrorCode.pacPeriodRejected, {
          'pac_code': '301',
          'pac_message': 'El RFC del receptor no existe',
        }),
      );
      await h.pump(tester, document: sealed());

      await tester.tap(key('fiscal_document_stamp'));
      await tester.pumpAndSettle();
      await tester.tap(key('fiscal_document_stamp_submit'));
      await tester.pumpAndSettle();

      expect(key('fiscal_document_stamp_dialog'), findsNothing);
      expect(
        find.text(
          l10n.apiErrorPacRejected('301', 'El RFC del receptor no existe'),
        ),
        findsOneWidget,
      );
      expect(key('fiscal_document_stamp'), findsOneWidget);
      expect(key('fiscal_document_banner_sealed'), findsOneWidget);
    });

    testWidgets('pac.unavailable says nothing changed and Timbrar stays '
        'offered', (tester) async {
      when(() => h.documents.stamp(7)).thenThrow(
        _refusal('pac.unavailable', api.ErrorCode.pacPeriodUnavailable),
      );
      await h.pump(tester, document: sealed());

      await tester.tap(key('fiscal_document_stamp'));
      await tester.pumpAndSettle();
      await tester.tap(key('fiscal_document_stamp_submit'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.apiErrorPacUnavailable), findsOneWidget);
      expect(key('fiscal_document_stamp'), findsOneWidget);
    });

    testWidgets('pac.timeout says the outcome is unknown and the reloaded '
        'document is stamping, so Timbrar gives way to the banner', (
      tester,
    ) async {
      var timedOut = false;
      when(() => h.documents.stamp(7)).thenAnswer((_) async {
        timedOut = true;
        throw _refusal('pac.timeout', api.ErrorCode.pacPeriodTimeout, {
          'state': 'stamping',
        });
      });
      await h.pump(tester, document: sealed());
      final stamping = aDocument(
        status: FiscalDocumentStatus.stamping,
        serial: 12,
        series: 'GR',
        stampingSince: DateTime(2026, 11, 17, 11, 5),
      );
      when(
        () => h.documents.getById(7),
      ).thenAnswer((_) async => timedOut ? stamping : sealed());

      await tester.tap(key('fiscal_document_stamp'));
      await tester.pumpAndSettle();
      await tester.tap(key('fiscal_document_stamp_submit'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.apiErrorPacTimeout), findsOneWidget);
      expect(key('fiscal_document_banner_stamping'), findsOneWidget);
      expect(key('fiscal_document_stamp'), findsNothing);
      expect(key('fiscal_document_reopen'), findsNothing);
    });

    testWidgets('a stale issue date shows the way out, and the same code from '
        'another action does not', (tester) async {
      // Each refusal is its own error, as on the wire.
      AppError stale() => _refusal(
        'fiscal_document.issue_date_out_of_range',
        api.ErrorCode.fiscalDocumentPeriodIssueDateOutOfRange,
      );
      when(() => h.documents.stamp(7)).thenThrow(stale());
      when(() => h.documents.reopen(7)).thenThrow(stale());
      await h.pump(tester, document: sealed());

      await tester.tap(key('fiscal_document_stamp'));
      await tester.pumpAndSettle();
      await tester.tap(key('fiscal_document_stamp_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.apiErrorFiscalDocumentIssueDateOutOfRange),
        findsOneWidget,
      );
      expect(key('fiscal_document_refusal_hint'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentStampIssueDateHint), findsOneWidget);

      await tester.tap(key('fiscal_document_reopen'));
      await tester.pumpAndSettle();
      await tester.tap(key('invoice_reopen_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.apiErrorFiscalDocumentIssueDateOutOfRange),
        findsOneWidget,
      );
      expect(key('fiscal_document_refusal_hint'), findsNothing);
    });

    testWidgets('pressing twice while it runs stamps once', (tester) async {
      final gate = Completer<FiscalDocument>();
      when(() => h.documents.stamp(7)).thenAnswer((_) => gate.future);
      await h.pump(tester, document: sealed());

      await tester.tap(key('fiscal_document_stamp'));
      await tester.pumpAndSettle();
      await tester.tap(key('fiscal_document_stamp_submit'));
      await tester.pump();
      await tester.tap(
        key('fiscal_document_stamp_submit'),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(() => h.documents.stamp(7)).called(1);
      gate.complete(issuedStamped());
      await tester.pumpAndSettle();
    });

    testWidgets('Cancelar stamps nothing', (tester) async {
      await h.pump(tester, document: sealed());
      await tester.tap(key('fiscal_document_stamp'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.cancelButton));
      await tester.pumpAndSettle();

      expect(key('fiscal_document_stamp_dialog'), findsNothing);
      verifyNever(() => h.documents.stamp(any()));
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
