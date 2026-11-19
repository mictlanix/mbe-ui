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

AppError _refusal(
  String name,
  api.ErrorCode code, [
  Map<String, Object?> params = const {},
]) => AppError.server(
  statusCode: 422,
  problem: ApiProblem(codeName: name, code: code, params: params),
);

/// Spec 074 C41, C42: add, edit and remove a paid invoice on a receipt draft.
void main() {
  late InvoiceHarness h;
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
    registerFallbackValue(Decimal.one);
  });

  setUp(() {
    h = InvoiceHarness();
    // Two issued invoices of the receipt's issuer and recipient, and one of
    // another recipient, which the picker drops.
    FiscalDocumentSummary row(int id, {String recipient = 'XEXX010101000'}) =>
        FiscalDocumentSummary(
          id: id,
          typeCode: 0,
          version: '4.0',
          series: 'A',
          serial: 5000 + id,
          issuerRfc: 'XAXX010101000',
          recipientRfc: recipient,
          issued: DateTime(2026, 11, 1),
          stampUuid: 'UUID-$id',
          status: FiscalDocumentStatus.issued,
          total: Decimal.parse('5800'),
        );
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
        // Invoice 12 is already on the receipt (aPaidInvoice).
        items: [
          row(12),
          row(40),
          row(41),
          row(42, recipient: 'OTRO010101AAA'),
        ],
        total: 4,
      ),
    );
  });

  FiscalDocument receipt() => aPaymentReceipt(
    paymentAmount: Decimal.parse('11600.00'),
    paidInvoices: [
      aPaidInvoice(
        amount: '8000.00',
        previousBalance: '8000.00',
        remaining: '0.00',
      ),
    ],
  );

  void stubWrites() {
    when(
      () => h.documents.addPaidInvoice(7, any(), amount: any(named: 'amount')),
    ).thenAnswer((_) async => receipt());
    when(
      () => h.documents.updatePaidInvoice(7, 31, any()),
    ).thenAnswer((_) async => receipt());
    when(
      () => h.documents.removePaidInvoice(7, 31),
    ).thenAnswer((_) async => receipt());
  }

  Future<void> openAdd(WidgetTester tester) async {
    await h.pump(tester, document: receipt());
    await tester.tap(key('fiscal_document_add_paid_invoice'));
    await tester.pumpAndSettle();
  }

  bool canAdd(WidgetTester tester) =>
      tester.widget<FilledButton>(key('add_paid_invoice_submit')).onPressed !=
      null;

  group('add', () {
    testWidgets('lists issued invoices of the receipt\'s issuer and recipient, '
        'without the ones already on it', (tester) async {
      await openAdd(tester);

      expect(key('add_paid_invoice_dialog'), findsOneWidget);
      expect(key('add_paid_invoice_row_40'), findsOneWidget);
      expect(key('add_paid_invoice_row_41'), findsOneWidget);
      // Already on the receipt, and another recipient.
      expect(key('add_paid_invoice_row_12'), findsNothing);
      expect(key('add_paid_invoice_row_42'), findsNothing);
      final call = verify(
        () => h.documents.list(
          search: captureAny(named: 'search'),
          issuer: captureAny(named: 'issuer'),
          type: captureAny(named: 'type'),
          status: captureAny(named: 'status'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).captured;
      expect(call, [
        'XEXX010101000',
        'XAXX010101000',
        0,
        FiscalDocumentStatus.issued,
      ]);
    });

    testWidgets('submit waits for a pick, then sends no amount when blank', (
      tester,
    ) async {
      stubWrites();
      await openAdd(tester);

      expect(canAdd(tester), isFalse);
      await tester.tap(key('add_paid_invoice_row_40'));
      await tester.pumpAndSettle();
      expect(key('add_paid_invoice_selected'), findsOneWidget);
      expect(canAdd(tester), isTrue);

      await tester.tap(key('add_paid_invoice_submit'));
      await tester.pumpAndSettle();

      verify(() => h.documents.addPaidInvoice(7, 40, amount: null)).called(1);
      expect(key('add_paid_invoice_dialog'), findsNothing);
    });

    testWidgets('sends the typed amount', (tester) async {
      stubWrites();
      await openAdd(tester);

      await tester.tap(key('add_paid_invoice_row_41'));
      await tester.pumpAndSettle();
      await tester.enterText(key('add_paid_invoice_amount'), '1500.50');
      await tester.pump();
      await tester.tap(key('add_paid_invoice_submit'));
      await tester.pumpAndSettle();

      verify(
        () =>
            h.documents.addPaidInvoice(7, 41, amount: Decimal.parse('1500.50')),
      ).called(1);
    });

    testWidgets('a zero amount disables submit', (tester) async {
      await openAdd(tester);

      await tester.tap(key('add_paid_invoice_row_40'));
      await tester.pumpAndSettle();
      await tester.enterText(key('add_paid_invoice_amount'), '0');
      await tester.pump();

      expect(canAdd(tester), isFalse);
      expect(find.text(l10n.editPaidInvoiceAmountPositive), findsOneWidget);
    });

    for (final (name, code, params, text) in [
      (
        'fiscal_document.invoice_not_payable',
        api.ErrorCode.fiscalDocumentPeriodInvoiceNotPayable,
        const {'invoice_id': 40},
        () => l10n.apiErrorFiscalDocumentInvoiceNotPayable,
      ),
      (
        'fiscal_document.invoice_already_on_receipt',
        api.ErrorCode.fiscalDocumentPeriodInvoiceAlreadyOnReceipt,
        const {'invoice_id': 40},
        () => l10n.apiErrorFiscalDocumentInvoiceAlreadyOnReceipt,
      ),
      (
        'fiscal_document.amounts_exceed_payment',
        api.ErrorCode.fiscalDocumentPeriodAmountsExceedPayment,
        const <String, Object?>{},
        () => l10n.apiErrorFiscalDocumentAmountsExceedPayment,
      ),
      (
        'fiscal_document.payment_date_out_of_range',
        api.ErrorCode.fiscalDocumentPeriodPaymentDateOutOfRange,
        const <String, Object?>{},
        () => l10n.apiErrorFiscalDocumentPaymentDateOutOfRange,
      ),
    ]) {
      testWidgets('$name keeps the dialog open so another invoice can be '
          'picked', (tester) async {
        when(
          () => h.documents.addPaidInvoice(
            7,
            any(),
            amount: any(named: 'amount'),
          ),
        ).thenThrow(_refusal(name, code, params));
        await openAdd(tester);

        await tester.tap(key('add_paid_invoice_row_40'));
        await tester.pumpAndSettle();
        await tester.tap(key('add_paid_invoice_submit'));
        await tester.pumpAndSettle();

        expect(key('add_paid_invoice_dialog'), findsOneWidget);
        expect(key('add_paid_invoice_refusal'), findsOneWidget);
        expect(find.text(text()), findsOneWidget);
        expect(key('add_paid_invoice_row_41'), findsOneWidget);
      });
    }

    testWidgets('the amount_exceeds_balance refusal names the balance', (
      tester,
    ) async {
      when(
        () =>
            h.documents.addPaidInvoice(7, any(), amount: any(named: 'amount')),
      ).thenThrow(
        _refusal(
          'fiscal_document.amount_exceeds_balance',
          api.ErrorCode.fiscalDocumentPeriodAmountExceedsBalance,
          const {'balance': '2200.00'},
        ),
      );
      await openAdd(tester);

      await tester.tap(key('add_paid_invoice_row_40'));
      await tester.pumpAndSettle();
      await tester.tap(key('add_paid_invoice_submit'));
      await tester.pumpAndSettle();

      expect(find.textContaining(r'$2,200.00'), findsOneWidget);
    });

    testWidgets('both buttons are disabled while the request runs', (
      tester,
    ) async {
      final pending = Completer<FiscalDocument>();
      when(
        () =>
            h.documents.addPaidInvoice(7, any(), amount: any(named: 'amount')),
      ).thenAnswer((_) => pending.future);
      await openAdd(tester);
      await tester.tap(key('add_paid_invoice_row_40'));
      await tester.pumpAndSettle();

      await tester.tap(key('add_paid_invoice_submit'));
      await tester.pump();

      expect(
        tester.widget<FilledButton>(key('add_paid_invoice_submit')).onPressed,
        isNull,
      );
      expect(
        tester
            .widget<TextButton>(
              find.widgetWithText(TextButton, l10n.cancelButton),
            )
            .onPressed,
        isNull,
      );
      pending.complete(receipt());
      await tester.pumpAndSettle();
    });

    testWidgets('Cancelar sends nothing', (tester) async {
      await openAdd(tester);

      await tester.tap(find.text(l10n.cancelButton));
      await tester.pumpAndSettle();

      expect(key('add_paid_invoice_dialog'), findsNothing);
      verifyNever(
        () => h.documents.addPaidInvoice(
          any(),
          any(),
          amount: any(named: 'amount'),
        ),
      );
    });

    testWidgets('with no invoices to pick says so', (tester) async {
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
      ).thenAnswer((_) async => const FiscalDocumentPage(items: [], total: 0));
      await openAdd(tester);

      expect(key('add_paid_invoice_empty'), findsOneWidget);
      expect(find.text(l10n.addPaidInvoiceEmpty), findsOneWidget);
    });
  });

  group('edit', () {
    Future<void> openEdit(WidgetTester tester) async {
      // Wired through the screen's row action.
      await h.pump(tester, document: receipt());
      await tester.tap(key('fiscal_document_paid_invoice_edit_31'));
      await tester.pumpAndSettle();
    }

    bool canSave(WidgetTester tester) =>
        tester
            .widget<FilledButton>(key('edit_paid_invoice_submit'))
            .onPressed !=
        null;

    testWidgets('opens prefilled and shows the previous balance', (
      tester,
    ) async {
      await openEdit(tester);

      expect(
        tester
            .widget<TextField>(key('edit_paid_invoice_amount'))
            .controller!
            .text,
        '8000.00',
      );
      expect(
        find.text(l10n.editPaidInvoicePreviousBalance(r'$8,000.00')),
        findsOneWidget,
      );
      expect(canSave(tester), isFalse);
    });

    testWidgets('blocks an amount above the previous balance, or zero', (
      tester,
    ) async {
      await openEdit(tester);

      await tester.enterText(key('edit_paid_invoice_amount'), '8000.01');
      await tester.pump();
      expect(
        find.text(l10n.editPaidInvoiceAmountMax(r'$8,000.00')),
        findsOneWidget,
      );
      expect(canSave(tester), isFalse);

      await tester.enterText(key('edit_paid_invoice_amount'), '0');
      await tester.pump();
      expect(find.text(l10n.editPaidInvoiceAmountPositive), findsOneWidget);
      expect(canSave(tester), isFalse);
    });

    testWidgets('saves the new amount', (tester) async {
      stubWrites();
      await openEdit(tester);

      await tester.enterText(key('edit_paid_invoice_amount'), '3600');
      await tester.pump();
      await tester.tap(key('edit_paid_invoice_submit'));
      await tester.pumpAndSettle();

      verify(
        () => h.documents.updatePaidInvoice(7, 31, Decimal.parse('3600')),
      ).called(1);
      expect(key('edit_paid_invoice_dialog'), findsNothing);
    });

    for (final (name, code, text) in [
      (
        'fiscal_document.amounts_exceed_payment',
        api.ErrorCode.fiscalDocumentPeriodAmountsExceedPayment,
        () => l10n.apiErrorFiscalDocumentAmountsExceedPayment,
      ),
    ]) {
      testWidgets('$name stays inline', (tester) async {
        when(
          () => h.documents.updatePaidInvoice(7, 31, any()),
        ).thenThrow(_refusal(name, code));
        await openEdit(tester);

        await tester.enterText(key('edit_paid_invoice_amount'), '7000');
        await tester.pump();
        await tester.tap(key('edit_paid_invoice_submit'));
        await tester.pumpAndSettle();

        expect(key('edit_paid_invoice_dialog'), findsOneWidget);
        expect(key('edit_paid_invoice_refusal'), findsOneWidget);
        expect(find.text(text()), findsOneWidget);
      });
    }

    testWidgets('amount_exceeds_balance stays inline with the balance', (
      tester,
    ) async {
      when(() => h.documents.updatePaidInvoice(7, 31, any())).thenThrow(
        _refusal(
          'fiscal_document.amount_exceeds_balance',
          api.ErrorCode.fiscalDocumentPeriodAmountExceedsBalance,
          const {'balance': '7500.00'},
        ),
      );
      await openEdit(tester);

      await tester.enterText(key('edit_paid_invoice_amount'), '7900');
      await tester.pump();
      await tester.tap(key('edit_paid_invoice_submit'));
      await tester.pumpAndSettle();

      expect(find.textContaining(r'$7,500.00'), findsOneWidget);
    });
  });

  group('remove', () {
    testWidgets('names the folio and removes the relation', (tester) async {
      stubWrites();
      await h.pump(tester, document: receipt());
      await tester.tap(key('fiscal_document_paid_invoice_remove_31'));
      await tester.pumpAndSettle();

      expect(key('paid_invoice_remove_dialog'), findsOneWidget);
      expect(find.text(l10n.removePaidInvoiceBody('A5238')), findsOneWidget);
      await tester.tap(key('paid_invoice_remove_submit'));
      await tester.pumpAndSettle();

      verify(() => h.documents.removePaidInvoice(7, 31)).called(1);
      expect(key('paid_invoice_remove_dialog'), findsNothing);
    });

    testWidgets('Cancelar sends nothing', (tester) async {
      await h.pump(tester, document: receipt());
      await tester.tap(key('fiscal_document_paid_invoice_remove_31'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.cancelButton));
      await tester.pumpAndSettle();

      verifyNever(() => h.documents.removePaidInvoice(any(), any()));
    });

    testWidgets('a refusal stays inline', (tester) async {
      when(() => h.documents.removePaidInvoice(7, 31)).thenThrow(
        _refusal(
          'fiscal_document.not_draft',
          api.ErrorCode.fiscalDocumentPeriodNotDraft,
        ),
      );
      await h.pump(tester, document: receipt());
      await tester.tap(key('fiscal_document_paid_invoice_remove_31'));
      await tester.pumpAndSettle();
      await tester.tap(key('paid_invoice_remove_submit'));
      await tester.pumpAndSettle();

      expect(key('paid_invoice_remove_dialog'), findsOneWidget);
      expect(find.text(l10n.apiErrorFiscalDocumentNotDraft), findsOneWidget);
    });
  });

  group('the control band (constitution §VI)', () {
    double baselineY(WidgetTester tester, Finder finder) {
      final box = tester.renderObject<RenderBox>(finder);
      return box.localToGlobal(Offset.zero).dy +
          box.getDryBaseline(box.constraints, TextBaseline.alphabetic)!;
    }

    testWidgets('the add dialog\'s two buttons share a baseline, and its '
        'amount text sits centred in its field', (tester) async {
      await openAdd(tester);
      await tester.tap(key('add_paid_invoice_row_40'));
      await tester.pumpAndSettle();
      await tester.enterText(key('add_paid_invoice_amount'), '1500');
      await tester.pump();

      final cancel = find.descendant(
        of: find.widgetWithText(TextButton, l10n.cancelButton),
        matching: find.text(l10n.cancelButton),
      );
      final add = find.descendant(
        of: key('add_paid_invoice_submit'),
        matching: find.text(l10n.addPaidInvoiceSubmit),
      );
      expect(baselineY(tester, cancel), closeTo(baselineY(tester, add), 0.5));

      final field = tester.getRect(key('add_paid_invoice_amount'));
      final text = tester.getRect(
        find.descendant(
          of: key('add_paid_invoice_amount'),
          matching: find.byType(EditableText),
        ),
      );
      // The helper line sits under the input, so the input is above centre
      // of the whole field by exactly the helper's share: the input's top
      // and the field's top are as far apart as the label area needs.
      expect(text.top - field.top, greaterThan(0));
      expect(text.bottom, lessThan(field.bottom));
    });

    testWidgets('the edit dialog\'s two buttons share a baseline', (
      tester,
    ) async {
      await h.pump(tester, document: receipt());
      await tester.tap(key('fiscal_document_paid_invoice_edit_31'));
      await tester.pumpAndSettle();

      final cancel = find.descendant(
        of: find.widgetWithText(TextButton, l10n.cancelButton),
        matching: find.text(l10n.cancelButton),
      );
      final save = find.descendant(
        of: key('edit_paid_invoice_submit'),
        matching: find.text(l10n.saveButton),
      );
      expect(baselineY(tester, cancel), closeTo(baselineY(tester, save), 0.5));
    });
  });
}
