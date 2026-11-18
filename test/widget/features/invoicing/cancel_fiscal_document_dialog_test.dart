import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_cancellation.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/sat_cancellation_reason.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';
import 'invoicing_harness.dart';

AppError _refusal(
  String name,
  api.ErrorCode code, [
  Map<String, Object?> params = const {},
]) => AppError.server(
  statusCode: 409,
  problem: ApiProblem(codeName: name, code: code, params: params),
);

/// Spec 072 US3, contract C21: the cancel dialog and the action that opens it.
void main() {
  late InvoiceHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(SatCancellationReason.withoutRelation);
  });

  setUp(() => h = InvoiceHarness());

  FiscalDocument issued({
    FiscalDocumentStatus status = FiscalDocumentStatus.issued,
    int typeCode = 0,
  }) => aDocument(
    status: status,
    typeCode: typeCode,
    serial: 12,
    series: 'GR',
    total: Decimal.parse('232'),
    stamp: aStamp(),
  );

  FiscalDocumentSummary candidate(
    int id, {
    String recipient = 'XEXX010101000',
    String? uuid,
  }) => FiscalDocumentSummary(
    id: id,
    typeCode: 0,
    version: '4.0',
    series: 'GR',
    serial: 100 + id,
    issuerRfc: 'XAXX010101000',
    recipientRfc: recipient,
    recipientName: 'Receptor SA',
    issued: DateTime(2026, 11, 15, 10, 30),
    stampUuid: uuid ?? 'UUID-$id',
    status: FiscalDocumentStatus.issued,
    total: Decimal.parse('232'),
  );

  void stubCandidates(List<FiscalDocumentSummary> rows) {
    when(
      () => h.documents.list(
        search: any(named: 'search'),
        issuer: any(named: 'issuer'),
        type: any(named: 'type'),
        status: any(named: 'status'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => FiscalDocumentPage(items: rows, total: rows.length),
    );
  }

  void stubCancel() {
    when(
      () => h.documents.cancel(
        7,
        any(),
        substitution: any(named: 'substitution'),
      ),
    ).thenAnswer((_) async => issued(status: FiscalDocumentStatus.cancelled));
  }

  Future<void> open(WidgetTester tester, {FiscalDocument? document}) async {
    await h.pump(tester, document: document ?? issued());
    await tester.tap(key('fiscal_document_cancel_cfdi'));
    await tester.pumpAndSettle();
  }

  Future<void> pickReason(WidgetTester tester, String code) async {
    await tester.tap(key('cancel_cfdi_reason_$code'));
    await tester.pumpAndSettle();
  }

  bool submitEnabled(WidgetTester tester) =>
      tester.widget<ButtonStyleButton>(key('cancel_cfdi_submit')).onPressed !=
      null;

  group('the action', () {
    testWidgets('shows on an issued invoice and on an issued document of '
        'another type', (tester) async {
      await h.pump(tester, document: issued());
      expect(key('fiscal_document_cancel_cfdi'), findsOneWidget);
    });

    testWidgets('shows on an issued payment receipt too', (tester) async {
      await h.pump(tester, document: issued(typeCode: 101));
      expect(key('fiscal_document_cancel_cfdi'), findsOneWidget);
    });

    testWidgets('is absent for a user with read but not update', (
      tester,
    ) async {
      await h.pump(
        tester,
        document: issued(),
        who: InvoiceHarness.access(fiscalDocuments: 2),
      );
      expect(key('fiscal_document_cancel_cfdi'), findsNothing);
    });

    for (final status in [
      FiscalDocumentStatus.draft,
      FiscalDocumentStatus.sealed,
      FiscalDocumentStatus.stamping,
      FiscalDocumentStatus.cancellationPending,
      FiscalDocumentStatus.cancelled,
    ]) {
      testWidgets('is absent on a ${status.name} document', (tester) async {
        await h.pump(tester, document: issued(status: status));
        expect(key('fiscal_document_cancel_cfdi'), findsNothing);
      });
    }
  });

  group('the dialog', () {
    testWidgets('offers the four SAT reasons with their codes and none '
        'picked; Enviar waits for one', (tester) async {
      await open(tester);

      expect(key('cancel_cfdi_dialog'), findsOneWidget);
      for (final r in SatCancellationReason.values) {
        expect(key('cancel_cfdi_reason_${r.code}'), findsOneWidget);
      }
      expect(
        find.text('01 ${l10n.fiscalDocumentCancelReason01}'),
        findsOneWidget,
      );
      expect(
        find.text('04 ${l10n.fiscalDocumentCancelReason04}'),
        findsOneWidget,
      );
      expect(find.text(l10n.fiscalDocumentCancelNote), findsOneWidget);
      expect(submitEnabled(tester), isFalse);
    });

    for (final code in ['02', '03', '04']) {
      testWidgets('reason $code asks for no substitute and sends none', (
        tester,
      ) async {
        stubCancel();
        await open(tester);

        await pickReason(tester, code);
        expect(key('cancel_cfdi_substitute'), findsNothing);
        expect(submitEnabled(tester), isTrue);

        await tester.tap(key('cancel_cfdi_submit'));
        await tester.pumpAndSettle();

        final reason = SatCancellationReason.fromCode(code)!;
        verify(
          () => h.documents.cancel(7, reason, substitution: null),
        ).called(1);
      });
    }

    testWidgets('reason 01 needs the replacement: Enviar stays off until one '
        'is picked, the document itself is not offered, and its UUID is '
        'sent', (tester) async {
      stubCandidates([candidate(7), candidate(8), candidate(9)]);
      stubCancel();
      await open(tester);

      await pickReason(tester, '01');
      expect(key('cancel_cfdi_substitute'), findsOneWidget);
      expect(key('cancel_cfdi_candidate_row_7'), findsNothing);
      expect(key('cancel_cfdi_candidate_row_8'), findsOneWidget);
      expect(submitEnabled(tester), isFalse);

      await tester.tap(key('cancel_cfdi_candidate_row_8'));
      await tester.pumpAndSettle();
      expect(key('cancel_cfdi_substitute_selected'), findsOneWidget);
      expect(find.textContaining('UUID-8'), findsOneWidget);
      expect(submitEnabled(tester), isTrue);

      await tester.tap(key('cancel_cfdi_submit'));
      await tester.pumpAndSettle();

      verify(
        () => h.documents.cancel(
          7,
          SatCancellationReason.withRelation,
          substitution: 'UUID-8',
        ),
      ).called(1);
    });

    testWidgets('Cambiar goes back to the list and turns Enviar off again', (
      tester,
    ) async {
      stubCandidates([candidate(8)]);
      await open(tester);
      await pickReason(tester, '01');
      await tester.tap(key('cancel_cfdi_candidate_row_8'));
      await tester.pumpAndSettle();

      await tester.tap(key('cancel_cfdi_substitute_change'));
      await tester.pumpAndSettle();

      expect(key('cancel_cfdi_substitute_selected'), findsNothing);
      expect(key('cancel_cfdi_candidate_row_8'), findsOneWidget);
      expect(submitEnabled(tester), isFalse);
    });

    testWidgets('switching from 01 to 02 forgets the replacement and lets '
        'Enviar through', (tester) async {
      stubCandidates([candidate(8)]);
      await open(tester);
      await pickReason(tester, '01');
      await tester.tap(key('cancel_cfdi_candidate_row_8'));
      await tester.pumpAndSettle();

      await pickReason(tester, '02');

      expect(key('cancel_cfdi_substitute'), findsNothing);
      expect(submitEnabled(tester), isTrue);
    });

    testWidgets('with no candidate, it explains the way out (reason 02, '
        'then a new document)', (tester) async {
      stubCandidates(const []);
      await open(tester);

      await pickReason(tester, '01');

      expect(key('cancel_cfdi_candidate_empty'), findsOneWidget);
      expect(find.text(l10n.fiscalDocumentCancelNoCandidates), findsOneWidget);
      expect(submitEnabled(tester), isFalse);
    });

    testWidgets("another recipient's document is never offered", (
      tester,
    ) async {
      stubCandidates([candidate(8, recipient: 'OTRO010101AAA'), candidate(9)]);
      await open(tester);

      await pickReason(tester, '01');

      expect(key('cancel_cfdi_candidate_row_8'), findsNothing);
      expect(key('cancel_cfdi_candidate_row_9'), findsOneWidget);
    });

    testWidgets('substitution_invalid stays inline and the dialog stays '
        'open', (tester) async {
      stubCandidates([candidate(8)]);
      when(
        () => h.documents.cancel(
          7,
          any(),
          substitution: any(named: 'substitution'),
        ),
      ).thenThrow(
        _refusal(
          'fiscal_document.substitution_invalid',
          api.ErrorCode.fiscalDocumentPeriodSubstitutionInvalid,
          {'substitution': 'UUID-8'},
        ),
      );
      await open(tester);
      await pickReason(tester, '01');
      await tester.tap(key('cancel_cfdi_candidate_row_8'));
      await tester.pumpAndSettle();

      await tester.tap(key('cancel_cfdi_submit'));
      await tester.pumpAndSettle();

      expect(key('cancel_cfdi_dialog'), findsOneWidget);
      expect(
        find.text(l10n.apiErrorFiscalDocumentSubstitutionInvalid),
        findsOneWidget,
      );
    });

    testWidgets('has_live_documents closes the dialog and the screen lists '
        'the documents; the invoice stays issued', (tester) async {
      when(
        () => h.documents.cancel(
          7,
          any(),
          substitution: any(named: 'substitution'),
        ),
      ).thenThrow(
        _refusal(
          'fiscal_document.has_live_documents',
          api.ErrorCode.fiscalDocumentPeriodHasLiveDocuments,
          {
            'documents': ['P12', 'NC3'],
          },
        ),
      );
      await open(tester);
      await pickReason(tester, '02');

      await tester.tap(key('cancel_cfdi_submit'));
      await tester.pumpAndSettle();

      expect(key('cancel_cfdi_dialog'), findsNothing);
      expect(
        find.text(l10n.apiErrorFiscalDocumentHasLiveDocuments('P12, NC3')),
        findsOneWidget,
      );
      expect(key('fiscal_document_cancel_cfdi'), findsOneWidget);
    });

    testWidgets('pressing Enviar twice while it runs cancels once', (
      tester,
    ) async {
      final gate = Completer<FiscalDocument>();
      when(
        () => h.documents.cancel(
          7,
          any(),
          substitution: any(named: 'substitution'),
        ),
      ).thenAnswer((_) => gate.future);
      await open(tester);
      await pickReason(tester, '03');

      await tester.tap(key('cancel_cfdi_submit'));
      await tester.pump();
      await tester.tap(key('cancel_cfdi_submit'), warnIfMissed: false);
      await tester.pump();

      verify(
        () => h.documents.cancel(
          7,
          SatCancellationReason.notCarriedOut,
          substitution: null,
        ),
      ).called(1);
      gate.complete(issued(status: FiscalDocumentStatus.cancelled));
      await tester.pumpAndSettle();
    });
  });

  group('closing', () {
    testWidgets('Volver with nothing picked closes without sending', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(key('cancel_cfdi_back'));
      await tester.pumpAndSettle();

      expect(key('cancel_cfdi_dialog'), findsNothing);
      verifyNever(
        () => h.documents.cancel(
          any(),
          any(),
          substitution: any(named: 'substitution'),
        ),
      );
    });

    testWidgets('Volver after picking a reason asks before discarding, and '
        'sends nothing either way', (tester) async {
      await open(tester);
      await pickReason(tester, '02');

      await tester.tap(key('cancel_cfdi_back'));
      await tester.pumpAndSettle();
      expect(key('record_sheet_discard_dialog'), findsOneWidget);

      await tester.tap(key('record_sheet_discard_confirm'));
      await tester.pumpAndSettle();

      expect(key('cancel_cfdi_dialog'), findsNothing);
      verifyNever(
        () => h.documents.cancel(
          any(),
          any(),
          substitution: any(named: 'substitution'),
        ),
      );
    });
  });

  group('the outcome', () {
    testWidgets('cancelled at once: the screen shows Cancelado, the banner '
        'and no Cancelar ante el SAT', (tester) async {
      var sent = false;
      when(
        () => h.documents.cancel(
          7,
          any(),
          substitution: any(named: 'substitution'),
        ),
      ).thenAnswer((_) async {
        sent = true;
        return issued(status: FiscalDocumentStatus.cancelled);
      });
      await h.pump(tester, document: issued());
      when(() => h.documents.getById(7)).thenAnswer(
        (_) async =>
            sent ? issued(status: FiscalDocumentStatus.cancelled) : issued(),
      );
      await tester.tap(key('fiscal_document_cancel_cfdi'));
      await tester.pumpAndSettle();
      await pickReason(tester, '02');

      await tester.tap(key('cancel_cfdi_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          l10n.fiscalDocumentCancelSent(l10n.fiscalDocumentStatusCancelled),
        ),
        findsOneWidget,
      );
      expect(key('fiscal_document_banner_cancelled'), findsOneWidget);
      expect(key('fiscal_document_cancel_cfdi'), findsNothing);
    });

    testWidgets('left pending: the screen shows Cancelación pendiente and '
        'its banner', (tester) async {
      var sent = false;
      FiscalDocument pending() =>
          issued(status: FiscalDocumentStatus.cancellationPending).copyWith(
            cancellations: [
              aCancellation(outcome: CancellationOutcome.pending),
            ],
          );
      when(
        () => h.documents.cancel(
          7,
          any(),
          substitution: any(named: 'substitution'),
        ),
      ).thenAnswer((_) async {
        sent = true;
        return pending();
      });
      await h.pump(tester, document: issued());
      when(
        () => h.documents.getById(7),
      ).thenAnswer((_) async => sent ? pending() : issued());
      await tester.tap(key('fiscal_document_cancel_cfdi'));
      await tester.pumpAndSettle();
      await pickReason(tester, '03');

      await tester.tap(key('cancel_cfdi_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          l10n.fiscalDocumentCancelSent(
            l10n.fiscalDocumentStatusCancellationPending,
          ),
        ),
        findsOneWidget,
      );
      expect(
        key('fiscal_document_banner_cancellation_pending'),
        findsOneWidget,
      );
      expect(key('fiscal_document_cancel_cfdi'), findsNothing);
      // Waiting for the receiver: the clerk can ask SAT now (US4).
      expect(key('fiscal_document_refresh'), findsOneWidget);
    });

    for (final (name, error, text) in <(String, AppError, String Function())>[
      (
        'pac.rejected',
        _refusal('pac.rejected', api.ErrorCode.pacPeriodRejected, {
          'pac_code': '305',
          'pac_message': 'UUID no encontrado',
        }),
        () => l10n.apiErrorPacRejected('305', 'UUID no encontrado'),
      ),
      (
        'pac.unavailable',
        _refusal('pac.unavailable', api.ErrorCode.pacPeriodUnavailable),
        () => l10n.apiErrorPacUnavailable,
      ),
      (
        'fiscal_document.not_cancellable',
        _refusal(
          'fiscal_document.not_cancellable',
          api.ErrorCode.fiscalDocumentPeriodNotCancellable,
        ),
        () => l10n.apiErrorFiscalDocumentNotCancellable,
      ),
      (
        'fiscal_document.no_valid_certificate',
        _refusal(
          'fiscal_document.no_valid_certificate',
          api.ErrorCode.fiscalDocumentPeriodNoValidCertificate,
        ),
        () => l10n.apiErrorFiscalDocumentNoValidCertificate,
      ),
    ]) {
      testWidgets('$name closes the dialog and shows its own message; the '
          'document stays issued', (tester) async {
        when(
          () => h.documents.cancel(
            7,
            any(),
            substitution: any(named: 'substitution'),
          ),
        ).thenThrow(error);
        await open(tester);
        await pickReason(tester, '02');

        await tester.tap(key('cancel_cfdi_submit'));
        await tester.pumpAndSettle();

        expect(key('cancel_cfdi_dialog'), findsNothing);
        expect(find.text(text()), findsOneWidget);
        expect(key('fiscal_document_cancel_cfdi'), findsOneWidget);
      });
    }
  });
}
