import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/domain/entities/customer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/fiscal_document_kind.dart';
import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_batch.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/sat_catalog_repository.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/presentation/invoice_header_dialog.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';
import 'invoicing_harness.dart';

const _acme = TaxpayerRecipient(
  taxpayerRecipientId: 'XEXX010101000',
  name: 'Receptor SA',
  email: 'a@x.mx',
);
const _other = TaxpayerRecipient(
  taxpayerRecipientId: 'BBB010101BBB',
  name: 'Otro SA',
  email: 'b@x.mx',
);

TaxpayerBatch _batch(int id, String series, {int kind = 0}) => TaxpayerBatch(
  taxpayerBatchId: id,
  taxpayer: 'XAXX010101000',
  series: series,
  typeCode: kind,
  kind: FiscalDocumentKind.fromCode(kind),
  template: const TaxpayerBatchTemplate(name: 'Factura'),
  inUse: false,
);

/// Spec 066 US4, contract C7 and research R8: the header dialog.
void main() {
  late InvoiceHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(const InvoiceHeaderPatch());
  });

  setUp(() {
    h = InvoiceHarness();
    when(() => h.customers.get(customerId: 4)).thenAnswer(
      (_) async => const Customer(
        customerId: 4,
        code: 'C-4',
        name: 'Cliente 4',
        creditLimit: '0',
        creditDays: 0,
        priceList: PriceListRef(id: 1, name: 'M'),
        status: EntityStatus.active,
        taxpayers: [_acme, _other],
      ),
    );
    when(() => h.batches.listForIssuer('XAXX010101000')).thenAnswer(
      (_) async => [_batch(1, 'A'), _batch(2, 'B'), _batch(3, 'NC', kind: 100)],
    );
    when(
      () => h.sat.listCfdiUsages(
        search: any(named: 'search'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const SatCatalogListResult(
        items: [SatCatalogItem(code: 'G03', description: 'Gastos en general')],
        total: 1,
      ),
    );
  });

  FiscalDocument draft({int? serial, String? series = 'A'}) =>
      aDocument(serial: serial, series: series).copyWith(paymentForm: 3);

  Future<void> open(
    WidgetTester tester, {
    FiscalDocument? document,
    int fiscalDocuments = 6,
    bool taxpayersRead = true,
    bool issuedLocationUpdate = false,
    bool administrator = false,
  }) async {
    await h.pump(
      tester,
      document: document ?? draft(),
      who: InvoiceHarness.access(
        fiscalDocuments: fiscalDocuments,
        taxpayersRead: taxpayersRead,
        issuedLocationUpdate: issuedLocationUpdate,
        administrator: administrator,
      ),
    );
    await tester.tap(key('fiscal_document_edit_header'));
    await tester.pumpAndSettle();
  }

  bool canSave(WidgetTester tester) =>
      tester.widget<FilledButton>(key('invoice_header_submit')).onPressed !=
      null;

  InvoiceHeaderPatch sentPatch() =>
      verify(() => h.documents.updateHeader(7, captureAny())).captured.single
          as InvoiceHeaderPatch;

  void saves() => when(
    () => h.documents.updateHeader(7, any()),
  ).thenAnswer((_) async => draft());

  /// Picks [day] of the previous month, then confirms the time.
  Future<void> pickDateLastMonth(WidgetTester tester) async {
    await tester.tap(key('invoice_header_issued'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    final ok = MaterialLocalizations.of(
      tester.element(find.byType(Dialog).last),
    ).okButtonLabel;
    await tester.tap(find.text(ok));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ok));
    await tester.pumpAndSettle();
  }

  test('the 72-hour rule: past within the window, not before, not future', () {
    final now = DateTime(2026, 11, 16, 12);
    expect(
      isInvoiceIssueDateAllowed(DateTime(2026, 11, 16, 11), now: now),
      isTrue,
    );
    expect(
      isInvoiceIssueDateAllowed(DateTime(2026, 11, 13, 12, 1), now: now),
      isTrue,
    );
    expect(
      isInvoiceIssueDateAllowed(DateTime(2026, 11, 13, 11, 59), now: now),
      isFalse,
    );
    expect(
      isInvoiceIssueDateAllowed(DateTime(2026, 11, 16, 12, 1), now: now),
      isFalse,
    );
  });

  testWidgets('the fields fill from the document, and Guardar waits for an '
      'edit', (tester) async {
    await open(tester);

    expect(find.text('XEXX010101000'), findsWidgets);
    expect(find.text('G01'), findsWidgets);
    expect(
      tester
          .widget<SegmentedButton<InvoicePaymentTerms>>(
            key('invoice_header_terms'),
          )
          .selected,
      {InvoicePaymentTerms.pue},
    );
    expect(canSave(tester), isFalse);
  });

  testWidgets('choosing PPD locks the form at 99 and sends no form', (
    tester,
  ) async {
    saves();
    await open(tester);

    await tester.tap(find.text(l10n.fiscalDocumentHeaderTermsPpd));
    await tester.pumpAndSettle();

    expect(key('invoice_header_form_ppd'), findsOneWidget);
    expect(key('invoice_header_form'), findsNothing);
    expect(find.text(l10n.fiscalDocumentHeaderFormPpd), findsOneWidget);

    await tester.tap(key('invoice_header_submit'));
    await tester.pumpAndSettle();
    final patch = sentPatch();
    expect(patch.paymentTerms, InvoicePaymentTerms.ppd);
    expect(patch.paymentForm, isNull);
  });

  testWidgets('going back to PUE from PPD asks for a real form', (
    tester,
  ) async {
    await open(
      tester,
      document: draft().copyWith(
        paymentTerms: InvoicePaymentTerms.ppd,
        paymentForm: 99,
      ),
    );
    expect(key('invoice_header_form_ppd'), findsOneWidget);

    await tester.tap(find.text(l10n.fiscalDocumentHeaderTermsPue));
    await tester.pumpAndSettle();

    expect(key('invoice_header_form'), findsOneWidget);
    expect(canSave(tester), isFalse);
  });

  testWidgets('with PUE a changed form is sent', (tester) async {
    saves();
    await open(tester);

    await tester.tap(key('invoice_header_form'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('28 —').last);
    await tester.pumpAndSettle();
    await tester.tap(key('invoice_header_submit'));
    await tester.pumpAndSettle();

    final patch = sentPatch();
    expect(patch.paymentForm, 28);
    expect(patch.paymentTerms, isNull);
  });

  group('the series', () {
    testWidgets('is a dropdown of the issuer\'s invoice series only', (
      tester,
    ) async {
      saves();
      await open(tester);

      await tester.tap(key('invoice_header_series'));
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
      expect(find.text('NC'), findsNothing);
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      await tester.tap(key('invoice_header_submit'));
      await tester.pumpAndSettle();

      expect(sentPatch().series, 'B');
    });

    testWidgets('is read-only once a serial exists', (tester) async {
      await open(tester, document: draft(serial: 12));

      expect(find.text(l10n.fiscalDocumentHeaderSeriesLocked), findsOneWidget);
      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        key('invoice_header_series'),
      );
      expect(dropdown.onChanged, isNull);
    });

    testWidgets('is absent without Taxpayers read', (tester) async {
      await open(tester, taxpayersRead: false);
      expect(key('invoice_header_series'), findsNothing);
      expect(key('invoice_header_reference'), findsOneWidget);
    });
  });

  group('the facility', () {
    testWidgets('is absent without IssuedLocationId update', (tester) async {
      await open(tester);
      expect(key('invoice_header_facility'), findsNothing);
    });

    testWidgets('shows with IssuedLocationId update', (tester) async {
      await open(tester, issuedLocationUpdate: true);
      expect(key('invoice_header_facility'), findsOneWidget);
    });

    testWidgets('shows for an administrator', (tester) async {
      await open(tester, administrator: true);
      expect(key('invoice_header_facility'), findsOneWidget);
    });
  });

  group('the issue date', () {
    testWidgets('empty reads "Al confirmar"', (tester) async {
      await open(tester);
      expect(
        find.text(l10n.fiscalDocumentHeaderIssuedOnConfirm),
        findsOneWidget,
      );
      expect(find.text(l10n.fiscalDocumentHeaderIssuedHelper), findsOneWidget);
    });

    testWidgets('older than 72 hours is refused inline and disables '
        'Guardar', (tester) async {
      await open(tester);

      await pickDateLastMonth(tester);

      expect(
        find.text(l10n.fiscalDocumentHeaderIssuedOutOfRange),
        findsOneWidget,
      );
      expect(canSave(tester), isFalse);
    });
  });

  testWidgets('only the changed fields are sent', (tester) async {
    saves();
    await open(tester);

    await tester.enterText(key('invoice_header_reference'), 'OC-77');
    await tester.pump();
    await tester.tap(key('invoice_header_submit'));
    await tester.pumpAndSettle();

    final patch = sentPatch();
    expect(patch.reference, 'OC-77');
    expect(patch.recipientRfc, isNull);
    expect(patch.series, isNull);
    expect(patch.usage, isNull);
    expect(patch.paymentTerms, isNull);
    expect(patch.paymentForm, isNull);
    expect(patch.issued, isNull);
    expect(patch.comment, isNull);
    expect(key('invoice_header_dialog'), findsNothing);
    expect(find.text(l10n.fiscalDocumentHeaderSaved), findsOneWidget);
  });

  testWidgets('a changed recipient is sent', (tester) async {
    saves();
    await open(tester);

    await tester.tap(key('invoice_header_recipient'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BBB010101BBB').last);
    await tester.pumpAndSettle();
    await tester.tap(key('invoice_header_submit'));
    await tester.pumpAndSettle();

    expect(sentPatch().recipientRfc, 'BBB010101BBB');
  });

  testWidgets('a legacy draft with no customer has no recipient field', (
    tester,
  ) async {
    await open(tester, document: draft().copyWith(customerId: null));
    expect(key('invoice_header_recipient'), findsNothing);
  });

  testWidgets('closing after an edit asks before discarding', (tester) async {
    await open(tester);
    await tester.enterText(key('invoice_header_comment'), 'nota');
    await tester.pump();

    await tester.tap(find.text(l10n.cancelButton));
    await tester.pumpAndSettle();

    expect(key('record_sheet_discard_dialog'), findsOneWidget);
    await tester.tap(key('record_sheet_discard_confirm'));
    await tester.pumpAndSettle();
    expect(key('invoice_header_dialog'), findsNothing);
  });

  testWidgets('a refusal shows through the error banner and keeps the '
      'dialog open', (tester) async {
    when(() => h.documents.updateHeader(7, any())).thenThrow(
      const AppError.server(
        statusCode: 422,
        problem: ApiProblem(
          codeName: 'fiscal_document.issue_date_out_of_range',
          code: api.ErrorCode.fiscalDocumentPeriodIssueDateOutOfRange,
        ),
      ),
    );
    await open(tester);

    await tester.enterText(key('invoice_header_reference'), 'x');
    await tester.pump();
    await tester.tap(key('invoice_header_submit'));
    await tester.pumpAndSettle();

    expect(key('invoice_header_dialog'), findsOneWidget);
    expect(key('fiscal_document_refusal'), findsOneWidget);
    expect(
      find.text(l10n.apiErrorFiscalDocumentIssueDateOutOfRange),
      findsOneWidget,
    );
  });
}
