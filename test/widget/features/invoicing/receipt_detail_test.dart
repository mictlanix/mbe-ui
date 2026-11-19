import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/api_problem.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/invoicing/domain/entities/fiscal_document.dart';
import 'package:mbe_ui/features/invoicing/domain/repositories/fiscal_document_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import '../../../unit/features/invoicing/fiscal_document_fixtures.dart';
import 'invoicing_harness.dart';

/// Spec 074 C37–C39: the payment receipt's detail screen.
void main() {
  late InvoiceHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  setUp(() => h = InvoiceHarness());

  const hidden = [
    'fiscal_document_lines',
    'fiscal_document_relations',
    'invoice_totals',
    'fiscal_document_banner_read_only_kind',
  ];

  void expectReceiptShape() {
    for (final k in hidden) {
      expect(key(k), findsNothing, reason: k);
    }
    expect(key('fiscal_document_receipt_payment'), findsOneWidget);
    expect(key('fiscal_document_paid_invoices'), findsOneWidget);
    expect(key('fiscal_document_receipt_summary'), findsOneWidget);
  }

  Color? unassignedColor(WidgetTester tester) => tester
      .widget<Text>(
        find
            .descendant(
              of: key('fiscal_document_receipt_summary_unassigned'),
              matching: find.byType(Text),
            )
            .last,
      )
      .style
      ?.color;

  group('every state shows the payment, the paid invoices and the summary', () {
    for (final status in [
      FiscalDocumentStatus.draft,
      FiscalDocumentStatus.sealed,
      FiscalDocumentStatus.issued,
      FiscalDocumentStatus.cancelled,
    ]) {
      testWidgets('$status', (tester) async {
        await h.pump(
          tester,
          document: aPaymentReceipt(
            status: status,
            serial: status == FiscalDocumentStatus.draft ? null : 413,
          ),
        );

        expectReceiptShape();
        expect(
          tester.widget<Text>(key('fiscal_document_receipt_payment_date')).data,
          '2026-11-12',
        );
        expect(
          tester
              .widget<Text>(key('fiscal_document_receipt_operation_number'))
              .data,
          'SPEI 99812',
        );
        expect(key('fiscal_document_paid_invoice_31'), findsOneWidget);
        // The six columns of C37.
        for (final label in [
          l10n.fiscalDocumentPaidInvoicesColumnInvoice,
          l10n.fiscalDocumentPaidInvoicesColumnUuid,
          l10n.fiscalDocumentPaidInvoicesColumnInstallment,
          l10n.fiscalDocumentPaidInvoicesColumnPreviousBalance,
          l10n.fiscalDocumentPaidInvoicesColumnAmount,
          l10n.fiscalDocumentPaidInvoicesColumnRemaining,
        ]) {
          expect(find.text(label), findsOneWidget, reason: label);
        }
      });
    }
  });

  group('"Por asignar" (C39)', () {
    testWidgets('is plain when the amounts match', (tester) async {
      await h.pump(tester, document: aPaymentReceipt());

      expect(unassignedColor(tester), isNot(equals(_error(tester))));
    });

    testWidgets('is in the error colour on a draft that is not matched', (
      tester,
    ) async {
      await h.pump(
        tester,
        document: aPaymentReceipt(paymentAmount: Decimal.parse('9000.00')),
      );

      expect(unassignedColor(tester), _error(tester));
    });

    testWidgets('is in the error colour while the payment amount is unknown', (
      tester,
    ) async {
      await h.pump(
        tester,
        document: aDocument(typeCode: 200, paymentForm: 3, lines: const []),
      );

      expect(unassignedColor(tester), _error(tester));
      expect(
        find.descendant(
          of: key('fiscal_document_receipt_summary_unassigned'),
          matching: find.text('—'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('is plain once the receipt is sealed', (tester) async {
      await h.pump(
        tester,
        document: aPaymentReceipt(
          status: FiscalDocumentStatus.sealed,
          serial: 413,
          paymentAmount: Decimal.parse('9000.00'),
        ),
      );

      expect(unassignedColor(tester), isNot(equals(_error(tester))));
    });
  });

  group('the source payment (FR-015)', () {
    testWidgets('is a link with Read on customer payments', (tester) async {
      await h.pump(
        tester,
        document: aPaymentReceipt(),
        who: InvoiceHarness.access(customerPaymentsRead: true),
      );

      expect(
        find.descendant(
          of: key('fiscal_document_receipt_source_payment'),
          matching: find.text(
            l10n.fiscalDocumentReceiptSourcePaymentValue(4127),
          ),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget(key('fiscal_document_receipt_source_payment')),
        isA<TextButton>(),
      );
      await tester.tap(key('fiscal_document_receipt_source_payment'));
      await tester.pumpAndSettle();

      expect(find.text('payment 4127'), findsOneWidget);
    });

    testWidgets('is plain text without that right', (tester) async {
      await h.pump(tester, document: aPaymentReceipt());

      expect(
        tester.widget(key('fiscal_document_receipt_source_payment')),
        isA<Text>(),
      );
    });

    testWidgets('is absent on a by-hand receipt', (tester) async {
      await h.pump(
        tester,
        document: aPaymentReceipt(customerPaymentId: null),
        who: InvoiceHarness.access(customerPaymentsRead: true),
      );

      expect(key('fiscal_document_receipt_source_payment'), findsNothing);
    });
  });

  testWidgets('a paid invoice\'s folio is a link to that invoice', (
    tester,
  ) async {
    when(
      () => h.documents.getById(12),
    ).thenAnswer((_) async => aDocument(id: 12));
    await h.pump(tester, document: aPaymentReceipt());

    expect(find.text('A5238'), findsOneWidget);
    await tester.tap(key('fiscal_document_paid_invoice_link_31'));
    await tester.pumpAndSettle();

    verify(() => h.documents.getById(12)).called(1);
  });

  testWidgets('a read-only user can still follow a paid invoice\'s link', (
    tester,
  ) async {
    when(
      () => h.documents.getById(12),
    ).thenAnswer((_) async => aDocument(id: 12));
    await h.pump(
      tester,
      document: aPaymentReceipt(),
      who: InvoiceHarness.access(fiscalDocuments: 2),
    );

    await tester.tap(key('fiscal_document_paid_invoice_link_31'));
    await tester.pumpAndSettle();

    verify(() => h.documents.getById(12)).called(1);
  });

  group('the no-proposal banner (C38)', () {
    testWidgets('shows on a payment-backed draft with no paid invoices', (
      tester,
    ) async {
      await h.pump(tester, document: aPaymentReceipt(paysInvoice: false));

      expect(key('fiscal_document_banner_receipt_no_proposal'), findsOneWidget);
      expect(
        find.text(l10n.fiscalDocumentBannerReceiptNoProposal),
        findsOneWidget,
      );
      expect(key('fiscal_document_paid_invoices_empty'), findsOneWidget);
    });

    testWidgets('is for users who can update only', (tester) async {
      await h.pump(
        tester,
        document: aPaymentReceipt(paysInvoice: false),
        who: InvoiceHarness.access(fiscalDocuments: 2),
      );

      expect(key('fiscal_document_banner_receipt_no_proposal'), findsNothing);
    });

    testWidgets('is absent when the receipt has paid invoices', (tester) async {
      await h.pump(tester, document: aPaymentReceipt());

      expect(key('fiscal_document_banner_receipt_no_proposal'), findsNothing);
    });

    testWidgets('is absent when there is no source payment', (tester) async {
      await h.pump(
        tester,
        document: aPaymentReceipt(paysInvoice: false, customerPaymentId: null),
      );

      expect(key('fiscal_document_banner_receipt_no_proposal'), findsNothing);
    });

    testWidgets('is absent once the receipt is sealed', (tester) async {
      await h.pump(
        tester,
        document: aPaymentReceipt(
          paysInvoice: false,
          status: FiscalDocumentStatus.sealed,
          serial: 413,
        ),
      );

      expect(key('fiscal_document_banner_receipt_no_proposal'), findsNothing);
    });

    testWidgets('a draft stored on form 99 shows the payment-form banner', (
      tester,
    ) async {
      await h.pump(tester, document: aPaymentReceipt(paymentForm: 99));

      expect(key('fiscal_document_banner_credit_note_form'), findsOneWidget);
    });
  });

  group('a by-hand draft (US2)', () {
    testWidgets('shows a dash for the payment it lacks, and no source or '
        'proposal banner', (tester) async {
      await h.pump(
        tester,
        document: aDocument(typeCode: 200, paymentForm: 1, lines: const []),
      );

      for (final k in [
        'fiscal_document_receipt_payment_date',
        'fiscal_document_receipt_payment_amount_value',
        'fiscal_document_receipt_operation_number',
        'fiscal_document_receipt_ordering_bank',
      ]) {
        expect(tester.widget<Text>(key(k)).data, '—', reason: k);
      }
      expect(key('fiscal_document_receipt_source_payment'), findsNothing);
      expect(key('fiscal_document_banner_receipt_no_proposal'), findsNothing);
      expect(key('fiscal_document_banner_credit_note_form'), findsNothing);
      // The clerk can still add the invoices it pays, and "Por asignar" is
      // unknown and flagged until the payment amount is set.
      expect(key('fiscal_document_add_paid_invoice'), findsOneWidget);
      expect(key('fiscal_document_paid_invoices_empty'), findsOneWidget);
      expect(unassignedColor(tester), _error(tester));
    });
  });

  testWidgets('the compact tier shows each paid invoice as a card without '
      'its UUID', (tester) async {
    await h.pump(
      tester,
      document: aPaymentReceipt(),
      surface: const Size(400, 900),
    );

    expect(key('fiscal_document_paid_invoice_31'), findsOneWidget);
    expect(key('fiscal_document_paid_invoices_table'), findsNothing);
    expect(find.text('6F1C2A9E-0000-4000-8000-00000000AB21'), findsNothing);
    expect(
      find.textContaining(l10n.fiscalDocumentPaidInvoicesColumnInstallment),
      findsOneWidget,
    );
  });

  group('the editing controls (spec 074 C37, FR-011, FR-017, FR-018)', () {
    const rowActions = [
      'fiscal_document_paid_invoice_edit_31',
      'fiscal_document_paid_invoice_remove_31',
    ];
    const controls = [
      'fiscal_document_edit_header',
      'fiscal_document_add_paid_invoice',
      ...rowActions,
    ];
    const never = [
      'fiscal_document_add_order',
      'fiscal_document_add_product',
      'fiscal_document_copy_invoice_lines',
      'fiscal_document_add_relation',
    ];

    void expectControls(Set<String> shown) {
      for (final k in controls) {
        expect(
          key(k),
          shown.contains(k) ? findsOneWidget : findsNothing,
          reason: k,
        );
      }
      for (final k in never) {
        expect(key(k), findsNothing, reason: k);
      }
    }

    testWidgets('a draft with update shows every control', (tester) async {
      await h.pump(tester, document: aPaymentReceipt());
      expectControls(controls.toSet());
      expect(key('fiscal_document_confirm'), findsOneWidget);
    });

    testWidgets('a draft with Read only shows none', (tester) async {
      await h.pump(
        tester,
        document: aPaymentReceipt(),
        who: InvoiceHarness.access(fiscalDocuments: 2),
      );
      expectControls({});
      expect(key('fiscal_document_confirm'), findsNothing);
    });

    for (final status in [
      FiscalDocumentStatus.sealed,
      FiscalDocumentStatus.issued,
      FiscalDocumentStatus.cancelled,
    ]) {
      testWidgets('a $status receipt shows none, with its table read-only', (
        tester,
      ) async {
        await h.pump(
          tester,
          document: aPaymentReceipt(status: status, serial: 413),
        );
        expectControls({});
        expect(key('fiscal_document_paid_invoice_31'), findsOneWidget);
      });
    }

    testWidgets('adding refreshes the table and the summary', (tester) async {
      var calls = 0;
      when(() => h.documents.getById(any())).thenAnswer((_) async {
        calls++;
        return calls == 1
            ? aPaymentReceipt(
                paymentAmount: Decimal.parse('11600.00'),
                paidInvoices: [aPaidInvoice(amount: '8000.00')],
              )
            : aPaymentReceipt(
                paymentAmount: Decimal.parse('11600.00'),
                paidInvoices: [
                  aPaidInvoice(amount: '8000.00'),
                  aPaidInvoice(
                    relationId: 32,
                    invoiceId: 40,
                    serial: 5301,
                    amount: '3600.00',
                  ),
                ],
              );
      });
      when(
        () =>
            h.documents.addPaidInvoice(7, any(), amount: any(named: 'amount')),
      ).thenAnswer((_) async => aPaymentReceipt());
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
        (_) async => FiscalDocumentPage(
          items: [
            FiscalDocumentSummary(
              id: 40,
              typeCode: 0,
              version: '4.0',
              series: 'A',
              serial: 5301,
              issuerRfc: 'XAXX010101000',
              recipientRfc: 'XEXX010101000',
              status: FiscalDocumentStatus.issued,
            ),
          ],
          total: 1,
        ),
      );
      await h.pump(tester, document: aPaymentReceipt(), stubDocument: false);

      expect(key('fiscal_document_paid_invoice_32'), findsNothing);
      // 11,600 - 8,000 = 3,600 left: not matched yet.
      expect(unassignedColor(tester), _error(tester));

      await tester.tap(key('fiscal_document_add_paid_invoice'));
      await tester.pumpAndSettle();
      await tester.tap(key('add_paid_invoice_row_40'));
      await tester.pumpAndSettle();
      await tester.tap(key('add_paid_invoice_submit'));
      await tester.pumpAndSettle();

      expect(key('fiscal_document_paid_invoice_32'), findsOneWidget);
      expect(unassignedColor(tester), isNot(equals(_error(tester))));
    });

    testWidgets('while a paid-invoice write runs, no second action starts', (
      tester,
    ) async {
      final pending = Completer<FiscalDocument>();
      when(
        () => h.documents.removePaidInvoice(7, 31),
      ).thenAnswer((_) => pending.future);
      when(() => h.documents.confirm(any())).thenAnswer(
        (_) async => aPaymentReceipt(status: FiscalDocumentStatus.sealed),
      );
      await h.pump(tester, document: aPaymentReceipt());
      await tester.tap(key('fiscal_document_paid_invoice_remove_31'));
      await tester.pumpAndSettle();
      await tester.tap(key('paid_invoice_remove_submit'));
      await tester.pump();

      // The dialog is modal and its buttons are off.
      await tester.tap(key('fiscal_document_confirm'), warnIfMissed: false);
      await tester.tap(
        key('fiscal_document_add_paid_invoice'),
        warnIfMissed: false,
      );
      await tester.pump();

      verifyNever(() => h.documents.confirm(any()));
      expect(key('add_paid_invoice_dialog'), findsNothing);
      expect(
        tester
            .widget<FilledButton>(key('paid_invoice_remove_submit'))
            .onPressed,
        isNull,
      );
      pending.complete(aPaymentReceipt());
      await tester.pumpAndSettle();
    });
  });

  group('confirm, reopen and stamp (spec 074 US4, FR-012, FR-013, FR-016)', () {
    AppError refusal(
      String name,
      api.ErrorCode code, [
      Map<String, Object?> params = const {},
    ]) => AppError.server(
      statusCode: 422,
      problem: ApiProblem(codeName: name, code: code, params: params),
    );

    FiscalDocument sealed() =>
        aPaymentReceipt(status: FiscalDocumentStatus.sealed, serial: 413);

    for (final (name, code, params, text)
        in <(String, api.ErrorCode, Map<String, Object?>, String Function())>[
          (
            'fiscal_document.receipt_pays_no_invoice',
            api.ErrorCode.fiscalDocumentPeriodReceiptPaysNoInvoice,
            const {},
            () => l10n.apiErrorFiscalDocumentReceiptPaysNoInvoice,
          ),
          (
            'fiscal_document.receipt_needs_payment_data',
            api.ErrorCode.fiscalDocumentPeriodReceiptNeedsPaymentData,
            const {},
            () => l10n.apiErrorFiscalDocumentReceiptNeedsPaymentData,
          ),
          (
            'fiscal_document.payment_form_required',
            api.ErrorCode.fiscalDocumentPeriodPaymentFormRequired,
            const {'type': 200},
            () => l10n.apiErrorFiscalDocumentPaymentFormRequired,
          ),
          (
            'fiscal_document.payment_date_out_of_range',
            api.ErrorCode.fiscalDocumentPeriodPaymentDateOutOfRange,
            const {},
            () => l10n.apiErrorFiscalDocumentPaymentDateOutOfRange,
          ),
          (
            'fiscal_document.invoice_not_payable',
            api.ErrorCode.fiscalDocumentPeriodInvoiceNotPayable,
            const {'invoice_id': 12},
            () => l10n.apiErrorFiscalDocumentInvoiceNotPayable,
          ),
          (
            'fiscal_document.amounts_not_equal_payment',
            api.ErrorCode.fiscalDocumentPeriodAmountsNotEqualPayment,
            const {},
            () => l10n.apiErrorFiscalDocumentAmountsNotEqualPayment,
          ),
          (
            'fiscal_document.amount_exceeds_balance',
            api.ErrorCode.fiscalDocumentPeriodAmountExceedsBalance,
            const {'balance': '2200.00'},
            () => l10n.apiErrorFiscalDocumentAmountExceedsBalance(r'$2,200.00'),
          ),
        ]) {
      testWidgets('confirm refused with $name shows its text and leaves the '
          'draft', (tester) async {
        when(
          () => h.documents.confirm(7),
        ).thenThrow(refusal(name, code, params));
        await h.pump(tester, document: aPaymentReceipt());

        await tester.tap(key('fiscal_document_confirm'));
        await tester.pumpAndSettle();
        await tester.tap(key('invoice_confirm_submit'));
        await tester.pumpAndSettle();

        expect(key('fiscal_document_refusal'), findsOneWidget);
        expect(find.text(text()), findsOneWidget);
        expect(key('fiscal_document_confirm'), findsOneWidget);
        expect(key('fiscal_document_reopen'), findsNothing);
      });
    }

    testWidgets('speaks English too (FR-019): a refusal', (tester) async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      when(() => h.documents.confirm(7)).thenThrow(
        refusal(
          'fiscal_document.receipt_pays_no_invoice',
          api.ErrorCode.fiscalDocumentPeriodReceiptPaysNoInvoice,
        ),
      );
      await h.pump(
        tester,
        document: aPaymentReceipt(),
        locale: const Locale('en'),
      );

      await tester.tap(key('fiscal_document_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('invoice_confirm_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(en.apiErrorFiscalDocumentReceiptPaysNoInvoice),
        findsOneWidget,
      );
      expect(
        find.text(l10n.apiErrorFiscalDocumentReceiptPaysNoInvoice),
        findsNothing,
      );
    });

    testWidgets('speaks English too (FR-019): the sealed message', (
      tester,
    ) async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      var confirmed = false;
      when(() => h.documents.confirm(7)).thenAnswer((_) async {
        confirmed = true;
        return sealed();
      });
      await h.pump(
        tester,
        document: aPaymentReceipt(),
        locale: const Locale('en'),
      );
      when(
        () => h.documents.getById(any()),
      ).thenAnswer((_) async => confirmed ? sealed() : aPaymentReceipt());

      await tester.tap(key('fiscal_document_confirm'));
      await tester.pumpAndSettle();
      await tester.tap(key('invoice_confirm_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          en.fiscalDocumentConfirmed(
            en.fiscalDocumentKindPaymentReceipt,
            'CP413',
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a sealed receipt offers Reabrir and Timbrar, and the '
        'sealed banner', (tester) async {
      await h.pump(tester, document: sealed());

      expect(key('fiscal_document_reopen'), findsOneWidget);
      expect(key('fiscal_document_stamp'), findsOneWidget);
      expect(key('fiscal_document_confirm'), findsNothing);
      expect(
        find.text(l10n.fiscalDocumentBannerSealedStampOrReopen),
        findsOneWidget,
      );
    });

    testWidgets('Reabrir returns it to a draft that keeps its folio', (
      tester,
    ) async {
      var reopened = false;
      when(() => h.documents.reopen(7)).thenAnswer((_) async {
        reopened = true;
        return aPaymentReceipt(serial: 413);
      });
      await h.pump(tester, document: sealed());
      when(() => h.documents.getById(any())).thenAnswer(
        (_) async => reopened ? aPaymentReceipt(serial: 413) : sealed(),
      );
      await tester.pumpAndSettle();

      await tester.tap(key('fiscal_document_reopen'));
      await tester.pumpAndSettle();
      await tester.tap(key('invoice_reopen_submit'));
      await tester.pumpAndSettle();

      verify(() => h.documents.reopen(7)).called(1);
      expect(
        find.text(
          l10n.fiscalDocumentReopened(
            l10n.fiscalDocumentKindPaymentReceipt,
            'CP413',
          ),
        ),
        findsOneWidget,
      );
      expect(key('fiscal_document_confirm'), findsOneWidget);
      expect(key('fiscal_document_add_paid_invoice'), findsOneWidget);
    });

    testWidgets('Timbrar issues it and the paid invoices stay read-only (spec '
        '072)', (tester) async {
      var stamped = false;
      FiscalDocument issued() => sealed().copyWith(
        stamp: aStamp(),
        summary: sealed().summary.copyWith(
          status: FiscalDocumentStatus.issued,
          stampUuid: aStamp().uuid,
        ),
      );
      when(() => h.documents.stamp(7)).thenAnswer((_) async {
        stamped = true;
        return issued();
      });
      await h.pump(tester, document: sealed());
      when(
        () => h.documents.getById(any()),
      ).thenAnswer((_) async => stamped ? issued() : sealed());
      await tester.pumpAndSettle();

      await tester.tap(key('fiscal_document_stamp'));
      await tester.pumpAndSettle();
      await tester.tap(key('fiscal_document_stamp_submit'));
      await tester.pumpAndSettle();

      verify(() => h.documents.stamp(7)).called(1);
      expect(key('fiscal_document_view_pdf'), findsOneWidget);
      expect(key('fiscal_document_download_xml'), findsOneWidget);
      expect(key('fiscal_document_add_paid_invoice'), findsNothing);
      expect(key('fiscal_document_paid_invoice_edit_31'), findsNothing);
    });

    testWidgets('a read-only user sees no action row on a sealed receipt', (
      tester,
    ) async {
      await h.pump(
        tester,
        document: sealed(),
        who: InvoiceHarness.access(fiscalDocuments: 2),
      );

      expect(key('fiscal_document_reopen'), findsNothing);
      expect(key('fiscal_document_stamp'), findsNothing);
      expect(key('fiscal_document_confirm'), findsNothing);
    });

    testWidgets('a receipt is never offered a credit note', (tester) async {
      await h.pump(
        tester,
        document: aPaymentReceipt(
          status: FiscalDocumentStatus.issued,
          serial: 413,
        ),
      );

      expect(key('fiscal_document_issue_credit_note'), findsNothing);
    });
  });

  group('the control band (constitution §VI)', () {
    double baselineY(WidgetTester tester, Finder finder) {
      final box = tester.renderObject<RenderBox>(finder);
      return box.localToGlobal(Offset.zero).dy +
          box.getDryBaseline(box.constraints, TextBaseline.alphabetic)!;
    }

    testWidgets('a compact card has equal padding above and below its '
        'content, and the link and the amounts read on the card\'s own '
        'lines', (tester) async {
      await h.pump(
        tester,
        document: aPaymentReceipt(),
        surface: const Size(400, 900),
      );

      final card = tester.getRect(key('fiscal_document_paid_invoice_31'));
      // The first line holds the link and the two row icons: the content
      // starts at the tallest of them.
      final firstLine = [
        'fiscal_document_paid_invoice_link_31',
        'fiscal_document_paid_invoice_edit_31',
        'fiscal_document_paid_invoice_remove_31',
      ].map((k) => tester.getRect(key(k))).map((r) => r.top);
      final top = firstLine.reduce((a, b) => a < b ? a : b);
      final amounts = tester.getRect(
        find.textContaining(l10n.fiscalDocumentPaidInvoicesColumnRemaining),
      );
      expect(top - card.top, greaterThan(0));
      expect(top - card.top, closeTo(card.bottom - amounts.bottom, 0.5));
    });

    testWidgets('a table row\'s link and amounts share a baseline', (
      tester,
    ) async {
      await h.pump(tester, document: aPaymentReceipt());

      final link = find.descendant(
        of: key('fiscal_document_paid_invoice_link_31'),
        matching: find.text('A5238'),
      );
      final amount = find
          .descendant(
            of: key('fiscal_document_paid_invoices'),
            matching: find.text(r'$8,000.00'),
          )
          .first;
      expect(baselineY(tester, link), closeTo(baselineY(tester, amount), 0.5));
    });

    testWidgets('the row actions are centred on the row, and the Edit icon is '
        'the shared one', (tester) async {
      await h.pump(tester, document: aPaymentReceipt());

      final edit = tester.getRect(key('fiscal_document_paid_invoice_edit_31'));
      final remove = tester.getRect(
        key('fiscal_document_paid_invoice_remove_31'),
      );
      final link = tester.getRect(key('fiscal_document_paid_invoice_link_31'));
      expect(edit.center.dy, closeTo(link.center.dy, 1));
      expect(remove.center.dy, closeTo(link.center.dy, 1));
      expect(
        find.descendant(
          of: key('fiscal_document_paid_invoice_edit_31'),
          matching: find.byIcon(Icons.edit_outlined),
        ),
        findsOneWidget,
      );
    });
  });
}

Color _error(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).first)).colorScheme.error;
