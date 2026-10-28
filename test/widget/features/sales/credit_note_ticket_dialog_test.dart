import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/presentation/payment/credit_note_ticket_dialog.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';
import 'session_override.dart';

/// The walk-in ticket dialog (spec 056 FR-005, FR-006, FR-006a), opened from a
/// bare host button so the dialog is exercised without the payment step.
void main() {
  late MockCustomerPaymentRepository payments;
  late MockCreditNoteRepository creditNotes;
  late AppLocalizations l10n;
  CreditNoteRedemption? returned;
  var opened = false;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  const walkIn = 1;
  final sale = testSale(
    status: SaleStatus.completed,
    balance: '500.00',
    customer: walkIn,
  );

  CustomerPayment ticket({int customer = walkIn, String? name}) =>
      CustomerPayment(
        customerPaymentId: 500,
        customerId: customer,
        customerName: name,
        amount: '200.00',
        currency: Currency.mxn,
        methodCode: 0,
        date: DateTime(2026, 9, 29),
        facilityId: 9,
        type: PaymentType.creditNote,
        unapplied: '200.00',
      );

  CreditNote note({String remaining = '200.00'}) => CreditNote(
    id: 990,
    customerId: walkIn,
    salesOrderId: 343533,
    customerRefundId: 9605,
    customerPaymentId: 500,
    issued: '200.00',
    remaining: remaining,
    date: DateTime(2026, 9, 29, 12, 55),
  );

  setUp(() {
    payments = MockCustomerPaymentRepository();
    creditNotes = MockCreditNoteRepository();
    returned = null;
    opened = false;
    when(
      () => payments.listForOrder(saleId: any(named: 'saleId')),
    ).thenAnswer((_) async => const []);
    when(
      () => payments.get(customerPaymentId: 500),
    ).thenAnswer((_) async => ticket());
    when(() => creditNotes.findByPayment(500)).thenAnswer((_) async => note());
  });

  Future<void> pumpDialog(
    WidgetTester tester, {
    String? enteredAmount,
    Size? surface,
  }) async {
    final container = await pumpPos(
      tester,
      Builder(
        builder: (context) => TextButton(
          key: const Key('open_dialog'),
          onPressed: () async {
            opened = true;
            returned = await showCreditNoteTicketDialog(
              context,
              sale: sale,
              enteredAmount: enteredAmount,
            );
          },
          child: const Text('open'),
        ),
      ),
      surface: surface ?? const Size(1200, 2400),
      overrides: [
        customerPaymentOverride(payments),
        creditNoteOverride(creditNotes),
        openSessionOverride(),
        fixedPosSale(sale),
      ],
    );
    // The payment step keeps this draft alive in the app; stand in for it.
    container.listen(paymentControllerProvider, (_, _) {});
    await container.read(posSaleControllerProvider.future);
    await tester.tap(find.byKey(const Key('open_dialog')));
    await tester.pumpAndSettle();
  }

  Future<void> typeAndSubmit(WidgetTester tester, String number) async {
    await tester.enterText(
      find.byKey(const Key('credit_note_ticket_input')),
      number,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  FilledButton confirm(WidgetTester tester) => tester.widget<FilledButton>(
    find.byKey(const Key('credit_note_ticket_confirm')),
  );

  testWidgets('opens empty, focused, with confirm disabled', (tester) async {
    await pumpDialog(tester);

    expect(find.text(l10n.creditNoteTicketTitle), findsOneWidget);
    expect(find.text(l10n.creditNoteTicketHelp), findsOneWidget);
    expect(confirm(tester).onPressed, isNull);
  });

  testWidgets('accepts digits only', (tester) async {
    await pumpDialog(tester);

    await tester.enterText(
      find.byKey(const Key('credit_note_ticket_input')),
      '3a0-0 7',
    );

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('credit_note_ticket_input')))
          .controller!
          .text,
      '3007',
    );
  });

  testWidgets('Enter submits the number', (tester) async {
    await pumpDialog(tester);

    await typeAndSubmit(tester, '500');

    verify(() => payments.get(customerPaymentId: 500)).called(1);
  });

  testWidgets('while it searches, confirm stays disabled', (tester) async {
    final gate = Completer<CustomerPayment>();
    when(
      () => payments.get(customerPaymentId: 500),
    ).thenAnswer((_) => gate.future);
    await pumpDialog(tester);

    await tester.enterText(
      find.byKey(const Key('credit_note_ticket_input')),
      '500',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(
      find.byKey(const Key('credit_note_ticket_searching')),
      findsOneWidget,
    );
    expect(find.text(l10n.creditNoteTicketSearching), findsOneWidget);
    expect(confirm(tester).onPressed, isNull);

    gate.complete(ticket());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('credit_note_ticket_searching')), findsNothing);
  });

  group('refusals — nothing is applied and the number stays', () {
    Future<void> expectRefused(WidgetTester tester, String message) async {
      await typeAndSubmit(tester, '500');

      expect(find.text(message), findsOneWidget);
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('credit_note_ticket_input')),
            )
            .controller!
            .text,
        '500',
      );
      expect(confirm(tester).onPressed, isNull);
      verifyNever(
        () => payments.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      );
    }

    testWidgets('an unknown number', (tester) async {
      when(
        () => payments.get(customerPaymentId: 500),
      ).thenThrow(const AppError.notFound());
      await pumpDialog(tester);

      await expectRefused(tester, l10n.creditNoteNotFound);
    });

    testWidgets('a note with nothing left', (tester) async {
      when(
        () => creditNotes.findByPayment(500),
      ).thenAnswer((_) async => note(remaining: '0.000000'));
      await pumpDialog(tester);

      await expectRefused(tester, l10n.creditNoteUsedUp);
    });

    testWidgets('a note already on this sale', (tester) async {
      when(() => payments.listForOrder(saleId: 42)).thenAnswer(
        (_) async => [
          SalePayment(
            id: 1,
            customerPayment: 500,
            amount: '10.00',
            methodCode: 0,
            currency: Currency.mxn,
            changeAmount: '0',
            cancelled: false,
            type: PaymentType.creditNote,
            paymentDate: DateTime(2026, 9, 1),
          ),
        ],
      );
      await pumpDialog(tester);

      await expectRefused(tester, l10n.creditNoteAlreadyOnSale);
    });

    testWidgets('a note issued to a named customer says whose it is', (
      tester,
    ) async {
      when(() => payments.get(customerPaymentId: 500)).thenAnswer(
        (_) async => ticket(customer: 9999, name: 'MARTHA VARELA ORTIZ'),
      );
      await pumpDialog(tester);

      await expectRefused(
        tester,
        l10n.creditNoteOtherCustomer('MARTHA VARELA ORTIZ'),
      );
    });
  });

  testWidgets('a network failure shows the shared error banner, not a '
      'refusal', (tester) async {
    when(
      () => payments.get(customerPaymentId: 500),
    ).thenThrow(const AppError.network());
    await pumpDialog(tester);

    await typeAndSubmit(tester, '500');

    expect(find.byKey(const Key('credit_note_ticket_refusal')), findsNothing);
    expect(confirm(tester).onPressed, isNull);
  });

  group('a found note', () {
    testWidgets('shows its heading, balance and what will be applied', (
      tester,
    ) async {
      await pumpDialog(tester);

      await typeAndSubmit(tester, '500');

      expect(find.byKey(const Key('credit_note_ticket_found')), findsOneWidget);
      expect(find.textContaining('Nº 500'), findsOneWidget);
      expect(find.text(l10n.creditNoteTicketAvailable('\$200.00')), findsOne);
      expect(find.text(l10n.creditNoteTicketWillApply('\$200.00')), findsOne);
      expect(confirm(tester).onPressed, isNotNull);
    });

    testWidgets('what will be applied is capped at the sale balance', (
      tester,
    ) async {
      when(
        () => creditNotes.findByPayment(500),
      ).thenAnswer((_) async => note(remaining: '800.00'));
      await pumpDialog(tester);

      await typeAndSubmit(tester, '500');

      expect(find.text(l10n.creditNoteTicketAvailable('\$800.00')), findsOne);
      expect(find.text(l10n.creditNoteTicketWillApply('\$500.00')), findsOne);
    });

    testWidgets('and at an amount keyed on the payment step', (tester) async {
      await pumpDialog(tester, enteredAmount: '120.00');

      await typeAndSubmit(tester, '500');

      expect(find.text(l10n.creditNoteTicketWillApply('\$120.00')), findsOne);
    });

    testWidgets('confirming returns the note and the amount that was shown', (
      tester,
    ) async {
      await pumpDialog(tester, enteredAmount: '120.00');
      await typeAndSubmit(tester, '500');

      await tester.tap(find.byKey(const Key('credit_note_ticket_confirm')));
      await tester.pumpAndSettle();

      expect(returned?.note.id, 990);
      expect(compareAmounts(returned!.amount, '120.00'), 0);
      expect(find.byKey(const Key('credit_note_ticket_dialog')), findsNothing);
    });

    testWidgets('typing again discards the answer', (tester) async {
      await pumpDialog(tester);
      await typeAndSubmit(tester, '500');
      expect(confirm(tester).onPressed, isNotNull);

      await tester.enterText(
        find.byKey(const Key('credit_note_ticket_input')),
        '5001',
      );
      await tester.pump();

      expect(find.byKey(const Key('credit_note_ticket_found')), findsNothing);
      expect(confirm(tester).onPressed, isNull);
    });
  });

  testWidgets('cancelling returns nothing', (tester) async {
    await pumpDialog(tester);

    await tester.tap(find.text(l10n.cancelButton));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
    expect(returned, isNull);
    expect(find.byKey(const Key('credit_note_ticket_dialog')), findsNothing);
  });

  testWidgets('on a phone it fills the screen with a close control', (
    tester,
  ) async {
    await pumpDialog(tester, surface: const Size(390, 800));

    expect(find.byKey(const Key('responsive_dialog_close')), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
    final dialog = tester.widget<Dialog>(find.byType(Dialog));
    expect(dialog.insetPadding, EdgeInsets.zero);
  });
}
