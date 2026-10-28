import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/catalog/data/customer_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/credit_note_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/credit_note.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';
import 'package:mbe_ui/features/sales/domain/money.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/credit_note_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';

class MockCustomerPaymentRepository extends Mock
    implements CustomerPaymentRepository {}

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

class MockCreditNoteRepository extends Mock implements CreditNoteRepository {}

class MockSalesOrderRepository extends Mock implements SalesOrderRepository {}

/// Seeds `posSaleControllerProvider` directly with a sale, bypassing
/// `open()`/`load()` — `tender`'s own `confirmBeforePayableAction` call reads
/// this controller, not the `sale` parameter `submit` is handed.
class _FixedPosSale extends PosSaleController {
  _FixedPosSale(this._sale);
  final Sale _sale;
  @override
  Future<Sale?> build() async => _sale;
}

Sale _sale({SaleStatus status = SaleStatus.draft, String balance = '116.00'}) =>
    Sale(
      id: 42,
      facility: 9,
      pointSale: 3,
      salesperson: 100,
      customer: 7,
      paymentTerms: PaymentTerms.immediate,
      currency: Currency.mxn,
      exchangeRate: '1',
      promiseDate: DateTime(2026, 8, 20),
      status: status,
      lines: const [],
      subtotal: '100.00',
      taxTotal: '16.00',
      total: '116.00',
      balance: balance,
      date: DateTime(2026, 8, 20),
      dueDate: DateTime(2026, 8, 20),
      priority: Priority.normal,
    );

/// spec 036 R1: `tender` confirms the sale — still `draft` at this point —
/// immediately before the first tender rather than earlier at Venta→Cobro
/// (`pos_confirm.dart`).
void main() {
  late MockCustomerPaymentRepository payments;
  late MockSalesOrderRepository salesOrders;
  late MockCashSessionRepository cashSessions;
  late MockCreditNoteRepository creditNotes;
  late ProviderContainer container;

  setUp(() {
    payments = MockCustomerPaymentRepository();
    salesOrders = MockSalesOrderRepository();
    cashSessions = MockCashSessionRepository();
    creditNotes = MockCreditNoteRepository();
    when(
      () => cashSessions.getCurrent(),
    ).thenAnswer((_) async => const CurrentSession(state: SessionState.open));
    when(
      () => payments.createPayment(
        customer: any(named: 'customer'),
        amount: any(named: 'amount'),
        method: any(named: 'method'),
        currency: any(named: 'currency'),
        paymentCharge: any(named: 'paymentCharge'),
        reference: any(named: 'reference'),
      ),
    ).thenAnswer((_) async => 900);
    when(
      () => payments.applyPayment(
        customerPaymentId: any(named: 'customerPaymentId'),
        salesOrder: any(named: 'salesOrder'),
        amount: any(named: 'amount'),
        amountChange: any(named: 'amountChange'),
      ),
    ).thenAnswer((_) async {});
  });

  /// Builds the container against [sale] and keeps `posSaleControllerProvider`
  /// (`autoDispose`) alive with a live listener for the rest of the test.
  ProviderContainer containerFor(Sale sale) {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        customerPaymentRepositoryProvider.overrideWithValue(payments),
        salesOrderRepositoryProvider.overrideWithValue(salesOrders),
        cashSessionRepositoryProvider.overrideWithValue(cashSessions),
        creditNoteRepositoryProvider.overrideWithValue(creditNotes),
        posSaleControllerProvider.overrideWith(() => _FixedPosSale(sale)),
      ],
    );
    addTearDown(c.dispose);
    c.listen(posSaleControllerProvider, (_, _) {});
    return c;
  }

  test('tender confirms the still-draft sale exactly once, before creating the '
      'payment', () async {
    final sale = _sale();
    container = containerFor(sale);
    await container.read(posSaleControllerProvider.future);
    when(() => salesOrders.confirm(saleId: 42)).thenAnswer((_) async => sale);
    when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => sale);

    final notifier = container.read(paymentControllerProvider.notifier);
    notifier.setAmount('116.00');

    final result = await notifier.tender(sale, methodCode: 1);

    expect(result, TenderResult.applied);
    verify(() => salesOrders.confirm(saleId: 42)).called(1);
    verify(
      () => payments.createPayment(
        customer: 7,
        amount: '116.00',
        method: 1,
        currency: any(named: 'currency'),
        paymentCharge: any(named: 'paymentCharge'),
        reference: any(named: 'reference'),
      ),
    ).called(1);
  });

  test('a tender on a sale that is no longer draft does not confirm again '
      '(the tender still goes through)', () async {
    final sale = _sale(status: SaleStatus.completed);
    container = containerFor(sale);
    await container.read(posSaleControllerProvider.future);
    when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => sale);

    final notifier = container.read(paymentControllerProvider.notifier);
    notifier.setAmount('50.00');

    final result = await notifier.tender(sale, methodCode: 1);

    expect(result, TenderResult.applied);
    verifyNever(() => salesOrders.confirm(saleId: any(named: 'saleId')));
    verify(
      () => payments.createPayment(
        customer: any(named: 'customer'),
        amount: any(named: 'amount'),
        method: any(named: 'method'),
        currency: any(named: 'currency'),
        paymentCharge: any(named: 'paymentCharge'),
        reference: any(named: 'reference'),
      ),
    ).called(1);
  });

  test(
    'a refused confirm blocks the tender — createPayment is never reached',
    () async {
      final sale = _sale();
      container = containerFor(sale);
      await container.read(posSaleControllerProvider.future);
      when(
        () => salesOrders.confirm(saleId: 42),
      ).thenThrow(const AppError.validation([]));

      final notifier = container.read(paymentControllerProvider.notifier);
      notifier.setAmount('116.00');

      final result = await notifier.tender(sale, methodCode: 1);

      expect(result, TenderResult.failed);
      verifyNever(
        () => payments.createPayment(
          customer: any(named: 'customer'),
          amount: any(named: 'amount'),
          method: any(named: 'method'),
          currency: any(named: 'currency'),
          paymentCharge: any(named: 'paymentCharge'),
          reference: any(named: 'reference'),
        ),
      );
    },
  );

  for (final state in [SessionState.stale, SessionState.none]) {
    test(
      'a $state session at payment time sets sessionInvalid and makes no API '
      'call (spec 047 FR-005)',
      () async {
        final sale = _sale();
        container = containerFor(sale);
        await container.read(posSaleControllerProvider.future);
        when(
          () => cashSessions.getCurrent(),
        ).thenAnswer((_) async => CurrentSession(state: state));

        final notifier = container.read(paymentControllerProvider.notifier);
        notifier.setAmount('116.00');

        final result = await notifier.tender(sale, methodCode: 1);

        expect(result, TenderResult.refused);
        expect(
          container.read(paymentControllerProvider).issue,
          PaymentIssue.sessionInvalid,
        );
        verifyNever(() => salesOrders.confirm(saleId: any(named: 'saleId')));
        verifyNever(
          () => payments.createPayment(
            customer: any(named: 'customer'),
            amount: any(named: 'amount'),
            method: any(named: 'method'),
            currency: any(named: 'currency'),
            paymentCharge: any(named: 'paymentCharge'),
            reference: any(named: 'reference'),
          ),
        );
      },
    );
  }

  group('tender (spec 047 US5)', () {
    void expectNoPaymentCreated() => verifyNever(
      () => payments.createPayment(
        customer: any(named: 'customer'),
        amount: any(named: 'amount'),
        method: any(named: 'method'),
        currency: any(named: 'currency'),
        paymentCharge: any(named: 'paymentCharge'),
        reference: any(named: 'reference'),
      ),
    );

    for (final amount in ['', '0', '0.00']) {
      test(
        'an amount of "$amount" is refused with amountRequired and no API call',
        () async {
          final sale = _sale(status: SaleStatus.completed);
          container = containerFor(sale);
          await container.read(posSaleControllerProvider.future);
          final notifier = container.read(paymentControllerProvider.notifier);
          notifier.setAmount(amount);

          final result = await notifier.tender(sale, methodCode: 1);

          expect(result, TenderResult.refused);
          expect(
            container.read(paymentControllerProvider).issue,
            PaymentIssue.amountRequired,
          );
          expectNoPaymentCreated();
        },
      );
    }

    test('a tap while a tender is in flight is ignored (FR-017)', () async {
      final sale = _sale(status: SaleStatus.completed);
      container = containerFor(sale);
      await container.read(posSaleControllerProvider.future);
      when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => sale);
      final gate = Completer<int>();
      when(
        () => payments.createPayment(
          customer: any(named: 'customer'),
          amount: any(named: 'amount'),
          method: any(named: 'method'),
          currency: any(named: 'currency'),
          paymentCharge: any(named: 'paymentCharge'),
          reference: any(named: 'reference'),
        ),
      ).thenAnswer((_) => gate.future);
      // The draft is `autoDispose`: a mounted payment step is what keeps it
      // alive while the first tender is still awaiting its API calls.
      container.listen(paymentControllerProvider, (_, _) {});
      final notifier = container.read(paymentControllerProvider.notifier);
      notifier.setAmount('50.00');

      final first = notifier.tender(sale, methodCode: 1);
      await pumpEventQueue();
      final second = await notifier.tender(sale, methodCode: 1);
      gate.complete(900);

      expect(second, TenderResult.ignored);
      expect(await first, TenderResult.applied);
      verify(
        () => payments.createPayment(
          customer: any(named: 'customer'),
          amount: any(named: 'amount'),
          method: any(named: 'method'),
          currency: any(named: 'currency'),
          paymentCharge: any(named: 'paymentCharge'),
          reference: any(named: 'reference'),
        ),
      ).called(1);
    });

    test('a method that requires a reference asks for one and applies nothing '
        'until it is given', () async {
      final sale = _sale(status: SaleStatus.completed);
      container = containerFor(sale);
      await container.read(posSaleControllerProvider.future);
      when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => sale);
      final notifier = container.read(paymentControllerProvider.notifier);
      notifier.setAmount('50.00');

      final asked = await notifier.tender(
        sale,
        methodCode: 4,
        paymentCharge: 2,
        requiresReference: true,
      );
      expect(asked, TenderResult.needsReference);
      expect(container.read(paymentControllerProvider).submitting, isFalse);
      expectNoPaymentCreated();

      final applied = await notifier.tender(
        sale,
        methodCode: 4,
        paymentCharge: 2,
        requiresReference: true,
        reference: 'AUTH-1',
      );
      expect(applied, TenderResult.applied);
      verify(
        () => payments.createPayment(
          customer: 7,
          amount: '50.00',
          method: 4,
          currency: any(named: 'currency'),
          paymentCharge: 2,
          reference: 'AUTH-1',
        ),
      ).called(1);
    });

    test(
      'after a partial payment the amount becomes the new remaining balance',
      () async {
        final sale = _sale(status: SaleStatus.completed);
        container = containerFor(sale);
        await container.read(posSaleControllerProvider.future);
        when(() => salesOrders.getById(saleId: 42)).thenAnswer(
          (_) async => _sale(status: SaleStatus.completed, balance: '66.00'),
        );
        final notifier = container.read(paymentControllerProvider.notifier);
        notifier.setAmount('50.00');

        await notifier.tender(sale, methodCode: 1);

        expect(container.read(paymentControllerProvider).amount, '66.00');
        expect(container.read(paymentControllerProvider).submitting, isFalse);
      },
    );

    test(
      'prefillAmount seeds an empty amount, never overwrites a keyed one',
      () async {
        container = containerFor(_sale());
        final notifier = container.read(paymentControllerProvider.notifier);

        notifier.prefillAmount('116.00');
        expect(container.read(paymentControllerProvider).amount, '116.00');

        notifier.setAmount('20.00');
        notifier.prefillAmount('116.00');
        expect(container.read(paymentControllerProvider).amount, '20.00');
      },
    );
  });

  group('overpayment and change (spec 047 US6)', () {
    Future<(PaymentController, Sale)> arrange({
      String amount = '150.00',
    }) async {
      final sale = _sale(status: SaleStatus.completed);
      container = containerFor(sale);
      container.listen(paymentControllerProvider, (_, _) {});
      await container.read(posSaleControllerProvider.future);
      when(() => salesOrders.getById(saleId: 42)).thenAnswer(
        (_) async => _sale(status: SaleStatus.completed, balance: '0.00'),
      );
      final notifier = container.read(paymentControllerProvider.notifier);
      notifier.setAmount(amount);
      return (notifier, sale);
    }

    test(
      'a non-cash method over the balance is refused before any API call',
      () async {
        final (notifier, sale) = await arrange();

        final result = await notifier.tender(sale, methodCode: 4);

        expect(result, TenderResult.refused);
        expect(
          container.read(paymentControllerProvider).issue,
          PaymentIssue.overpayNonCash,
        );
        verifyNever(() => cashSessions.getCurrent());
        verifyNever(
          () => payments.createPayment(
            customer: any(named: 'customer'),
            amount: any(named: 'amount'),
            method: any(named: 'method'),
            currency: any(named: 'currency'),
            paymentCharge: any(named: 'paymentCharge'),
            reference: any(named: 'reference'),
          ),
        );
      },
    );

    test('a non-cash method at exactly the balance is accepted', () async {
      final (notifier, sale) = await arrange(amount: '116.00');

      expect(await notifier.tender(sale, methodCode: 4), TenderResult.applied);
    });

    test('cash over the balance applies the balance, records the change and '
        'keeps it as lastChange', () async {
      final (notifier, sale) = await arrange();

      final result = await notifier.tender(sale, methodCode: 1);

      expect(result, TenderResult.applied);
      verify(
        () => payments.applyPayment(
          customerPaymentId: 900,
          salesOrder: 42,
          amount: '116.00',
          amountChange: '34',
        ),
      ).called(1);
      final draft = container.read(paymentControllerProvider);
      expect(draft.lastChange, '34');
      expect(draft.amount, '');
    });

    test('cash at or under the balance leaves no lastChange', () async {
      final (notifier, sale) = await arrange(amount: '116.00');

      await notifier.tender(sale, methodCode: 1);

      expect(container.read(paymentControllerProvider).lastChange, isNull);
    });

    test(
      'lastChange survives typing, and is cleared by dismissChange',
      () async {
        final (notifier, sale) = await arrange();
        await notifier.tender(sale, methodCode: 1);

        notifier.setAmount('20.00');
        expect(container.read(paymentControllerProvider).lastChange, '34');

        notifier.dismissChange();
        expect(container.read(paymentControllerProvider).lastChange, isNull);
      },
    );

    test('the next tender clears lastChange', () async {
      final (notifier, sale) = await arrange();
      await notifier.tender(sale, methodCode: 1);
      expect(container.read(paymentControllerProvider).lastChange, '34');

      notifier.setAmount('0');
      await notifier.tender(sale, methodCode: 1);
      // Refused for the empty amount — before it started, nothing was cleared…
      expect(container.read(paymentControllerProvider).lastChange, '34');

      notifier.setAmount('10.00');
      await notifier.tender(sale, methodCode: 1);
      // …but a tender that goes ahead clears the previous change.
      expect(container.read(paymentControllerProvider).lastChange, isNull);
    });

    test(
      'leaving the step disposes the draft, and with it lastChange',
      () async {
        final (notifier, sale) = await arrange();
        await notifier.tender(sale, methodCode: 1);
        expect(container.read(paymentControllerProvider).lastChange, '34');

        container.invalidate(paymentControllerProvider);

        expect(container.read(paymentControllerProvider).lastChange, isNull);
      },
    );
  });

  group('tenderCreditNotes (spec 056)', () {
    CreditNote note(int id, String remaining) => CreditNote(
      id: id,
      customerId: 7,
      salesOrderId: 300 + id,
      customerRefundId: 400 + id,
      customerPaymentId: 500 + id,
      issued: remaining,
      remaining: remaining,
    );

    /// The sale at [balance], seeded and kept alive, with the notifier ready.
    Future<(PaymentController, Sale)> arrange({
      String balance = '1000.00',
    }) async {
      final sale = _sale(status: SaleStatus.completed, balance: balance);
      container = containerFor(sale);
      await container.read(posSaleControllerProvider.future);
      when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => sale);
      // The draft is `autoDispose`; a live listener stands in for the mounted
      // payment step.
      container.listen(paymentControllerProvider, (_, _) {});
      return (container.read(paymentControllerProvider.notifier), sale);
    }

    /// The (payment id, amount) of every application, in call order.
    List<(int, String)> applications() {
      final flat = verify(
        () => payments.applyPayment(
          customerPaymentId: captureAny(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: captureAny(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      ).captured;
      return [
        for (var i = 0; i < flat.length; i += 2)
          (flat[i] as int, flat[i + 1] as String),
      ];
    }

    void expectAmount((int, String) applied, int payment, String amount) {
      expect(applied.$1, payment);
      expect(
        compareAmounts(applied.$2, amount),
        0,
        reason: '${applied.$2} is not $amount',
      );
    }

    test(
      'applies the notes oldest first, each for its own remaining',
      () async {
        final (notifier, sale) = await arrange();
        notifier.setAmount('1000.00');

        final result = await notifier.tenderCreditNotes(sale, [
          note(1, '300.00'),
          note(2, '700.00'),
        ], enteredAmount: '1000.00');

        expect(result, TenderResult.applied);
        final done = applications();
        expect(done, hasLength(2));
        expectAmount(done[0], 501, '300');
        expectAmount(done[1], 502, '700');
      },
    );

    test(
      'stops at the sale balance and leaves the last note part-spent',
      () async {
        final (notifier, sale) = await arrange();

        await notifier.tenderCreditNotes(sale, [
          note(1, '800.00'),
          note(2, '700.00'),
        ], enteredAmount: '1000.00');

        final done = applications();
        expect(done, hasLength(2));
        expectAmount(done[0], 501, '800');
        expectAmount(done[1], 502, '200');
      },
    );

    test('an entered amount below the balance caps the total', () async {
      final (notifier, sale) = await arrange();

      await notifier.tenderCreditNotes(sale, [
        note(1, '300.00'),
        note(2, '700.00'),
      ], enteredAmount: '400.00');

      final done = applications();
      expect(done, hasLength(2));
      expectAmount(done[0], 501, '300');
      expectAmount(done[1], 502, '100');
    });

    test('with no entered amount the sale balance is the cap', () async {
      final (notifier, sale) = await arrange(balance: '250.00');

      await notifier.tenderCreditNotes(sale, [note(1, '300.00')]);

      final done = applications();
      expect(done, hasLength(1));
      expectAmount(done[0], 501, '250');
    });

    test('never creates a payment and never sends change (FR-003)', () async {
      final (notifier, sale) = await arrange();

      await notifier.tenderCreditNotes(sale, [
        note(1, '300.00'),
      ], enteredAmount: '1000.00');

      verifyNever(
        () => payments.createPayment(
          customer: any(named: 'customer'),
          amount: any(named: 'amount'),
          method: any(named: 'method'),
          currency: any(named: 'currency'),
          paymentCharge: any(named: 'paymentCharge'),
          reference: any(named: 'reference'),
        ),
      );
      verifyNever(
        () => payments.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange', that: isNotNull),
        ),
      );
    });

    test('a successful spend re-reads the sale and resets the draft', () async {
      final (notifier, sale) = await arrange();
      notifier.setAmount('1000.00');

      await notifier.tenderCreditNotes(sale, [
        note(1, '300.00'),
      ], enteredAmount: '1000.00');

      verify(() => salesOrders.getById(saleId: 42)).called(1);
      final draft = container.read(paymentControllerProvider);
      expect(draft.submitting, isFalse);
      expect(draft.error, isNull);
      expect(draft.issue, isNull);
    });

    test('a later note failing keeps the earlier one applied and says how much '
        '(FR-008)', () async {
      final (notifier, sale) = await arrange();
      var calls = 0;
      when(
        () => payments.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      ).thenAnswer((_) async {
        if (++calls == 2) throw const AppError.server();
      });

      final result = await notifier.tenderCreditNotes(sale, [
        note(1, '300.00'),
        note(2, '700.00'),
      ], enteredAmount: '1000.00');

      expect(result, TenderResult.failed);
      final draft = container.read(paymentControllerProvider);
      expect(draft.issue, PaymentIssue.creditPartlyApplied);
      expect(compareAmounts(draft.creditApplied!, '300'), 0);
      expect(draft.error, const AppError.server());
      expect(draft.submitting, isFalse);
      // The sale is re-read even though the spend failed.
      verify(() => salesOrders.getById(saleId: 42)).called(1);
    });

    test(
      'the first note failing reports the error and no partial amount',
      () async {
        final (notifier, sale) = await arrange();
        when(
          () => payments.applyPayment(
            customerPaymentId: any(named: 'customerPaymentId'),
            salesOrder: any(named: 'salesOrder'),
            amount: any(named: 'amount'),
            amountChange: any(named: 'amountChange'),
          ),
        ).thenThrow(const AppError.server());

        final result = await notifier.tenderCreditNotes(sale, [
          note(1, '300.00'),
        ], enteredAmount: '1000.00');

        expect(result, TenderResult.failed);
        final draft = container.read(paymentControllerProvider);
        expect(draft.error, const AppError.server());
        expect(draft.issue, isNull);
        expect(draft.creditApplied, isNull);
      },
    );

    test('a tap while a spend is in flight is ignored', () async {
      final (notifier, sale) = await arrange();
      final gate = Completer<void>();
      when(
        () => payments.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      ).thenAnswer((_) => gate.future);

      final first = notifier.tenderCreditNotes(sale, [note(1, '300.00')]);
      await pumpEventQueue();
      final second = await notifier.tenderCreditNotes(sale, [
        note(1, '300.00'),
      ]);
      gate.complete();

      expect(second, TenderResult.ignored);
      expect(await first, TenderResult.applied);
      verify(
        () => payments.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      ).called(1);
    });

    test('no credit to spend is refused with no API call', () async {
      final (notifier, sale) = await arrange();

      final result = await notifier.tenderCreditNotes(sale, const []);

      expect(result, TenderResult.refused);
      expect(
        container.read(paymentControllerProvider).issue,
        PaymentIssue.amountRequired,
      );
      verifyNever(
        () => payments.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      );
    });
  });

  group('lookupCreditNoteTicket (spec 056 FR-006, FR-006a)', () {
    CustomerPayment payment({
      int id = 500,
      int customer = 7,
      PaymentType type = PaymentType.creditNote,
      String? customerName = 'MARTHA VARELA ORTIZ',
    }) => CustomerPayment(
      customerPaymentId: id,
      customerId: customer,
      customerName: customerName,
      amount: '27.00',
      currency: Currency.mxn,
      methodCode: 0,
      date: DateTime(2026, 9, 29),
      facilityId: 9,
      type: type,
      unapplied: '3.00',
    );

    CreditNote note({String remaining = '3.00'}) => CreditNote(
      id: 990,
      customerId: 7,
      salesOrderId: 343533,
      customerRefundId: 9605,
      customerPaymentId: 500,
      issued: '27.00',
      remaining: remaining,
    );

    SalePayment onSale(int customerPayment, {bool cancelled = false}) =>
        SalePayment(
          id: 1,
          customerPayment: customerPayment,
          amount: '10.00',
          methodCode: 0,
          currency: Currency.mxn,
          changeAmount: '0',
          cancelled: cancelled,
          type: PaymentType.creditNote,
          paymentDate: DateTime(2026, 9, 1),
        );

    Future<(PaymentController, Sale)> arrange() async {
      final sale = _sale(status: SaleStatus.completed, balance: '500.00');
      container = containerFor(sale);
      await container.read(posSaleControllerProvider.future);
      container.listen(paymentControllerProvider, (_, _) {});
      when(
        () => payments.listForOrder(saleId: 42),
      ).thenAnswer((_) async => const []);
      when(
        () => payments.get(customerPaymentId: 500),
      ).thenAnswer((_) async => payment());
      when(
        () => creditNotes.findByPayment(500),
      ).thenAnswer((_) async => note());
      return (container.read(paymentControllerProvider.notifier), sale);
    }

    test('a spendable note comes back with no refusal', () async {
      final (notifier, sale) = await arrange();

      final found = await notifier.lookupCreditNoteTicket(sale, 500);

      expect(found.refusal, isNull);
      expect(found.note?.id, 990);
    });

    test('an unknown payment is notFound', () async {
      final (notifier, sale) = await arrange();
      when(
        () => payments.get(customerPaymentId: 500),
      ).thenThrow(const AppError.notFound());

      final found = await notifier.lookupCreditNoteTicket(sale, 500);

      expect(found.refusal, CreditNoteRefusal.notFound);
      expect(found.note, isNull);
    });

    test('a payment of another type is notFound', () async {
      final (notifier, sale) = await arrange();
      when(
        () => payments.get(customerPaymentId: 500),
      ).thenAnswer((_) async => payment(type: PaymentType.immediate));

      final found = await notifier.lookupCreditNoteTicket(sale, 500);

      expect(found.refusal, CreditNoteRefusal.notFound);
      verifyNever(() => creditNotes.findByPayment(any()));
    });

    test('a payment with no credit note behind it is notFound', () async {
      final (notifier, sale) = await arrange();
      when(() => creditNotes.findByPayment(500)).thenAnswer((_) async => null);

      final found = await notifier.lookupCreditNoteTicket(sale, 500);

      expect(found.refusal, CreditNoteRefusal.notFound);
    });

    test('a note for another customer is otherCustomer, with the owner\'s '
        'name', () async {
      final (notifier, sale) = await arrange();
      when(
        () => payments.get(customerPaymentId: 500),
      ).thenAnswer((_) async => payment(customer: 9999));

      final found = await notifier.lookupCreditNoteTicket(sale, 500);

      expect(found.refusal, CreditNoteRefusal.otherCustomer);
      expect(found.ownerName, 'MARTHA VARELA ORTIZ');
    });

    test('the owner\'s name falls back to the customer lookup', () async {
      final sale = _sale(status: SaleStatus.completed, balance: '500.00');
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          customerPaymentRepositoryProvider.overrideWithValue(payments),
          salesOrderRepositoryProvider.overrideWithValue(salesOrders),
          cashSessionRepositoryProvider.overrideWithValue(cashSessions),
          creditNoteRepositoryProvider.overrideWithValue(creditNotes),
          posSaleControllerProvider.overrideWith(() => _FixedPosSale(sale)),
          customerDisplayNameProvider.overrideWith(
            (ref, id) async => 'Name for $id',
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(posSaleControllerProvider, (_, _) {});
      container.listen(paymentControllerProvider, (_, _) {});
      await container.read(posSaleControllerProvider.future);
      when(
        () => payments.listForOrder(saleId: 42),
      ).thenAnswer((_) async => const []);
      when(
        () => payments.get(customerPaymentId: 500),
      ).thenAnswer((_) async => payment(customer: 9999, customerName: null));

      final found = await container
          .read(paymentControllerProvider.notifier)
          .lookupCreditNoteTicket(sale, 500);

      expect(found.refusal, CreditNoteRefusal.otherCustomer);
      expect(found.ownerName, 'Name for 9999');
    });

    test('a note already on the sale is alreadyOnSale', () async {
      final (notifier, sale) = await arrange();
      when(
        () => payments.listForOrder(saleId: 42),
      ).thenAnswer((_) async => [onSale(500)]);

      final found = await notifier.lookupCreditNoteTicket(sale, 500);

      expect(found.refusal, CreditNoteRefusal.alreadyOnSale);
    });

    test(
      'a reversed application does not count as already on the sale',
      () async {
        final (notifier, sale) = await arrange();
        when(
          () => payments.listForOrder(saleId: 42),
        ).thenAnswer((_) async => [onSale(500, cancelled: true)]);

        final found = await notifier.lookupCreditNoteTicket(sale, 500);

        expect(found.refusal, isNull);
        expect(found.note?.id, 990);
      },
    );

    test('a note with nothing remaining is usedUp', () async {
      final (notifier, sale) = await arrange();
      when(
        () => creditNotes.findByPayment(500),
      ).thenAnswer((_) async => note(remaining: '0.000000'));

      final found = await notifier.lookupCreditNoteTicket(sale, 500);

      expect(found.refusal, CreditNoteRefusal.usedUp);
    });

    test('any other failure is an AppError, not a refusal', () async {
      final (notifier, sale) = await arrange();
      when(
        () => payments.get(customerPaymentId: 500),
      ).thenThrow(const AppError.network());

      await expectLater(
        () => notifier.lookupCreditNoteTicket(sale, 500),
        throwsA(const AppError.network()),
      );
    });
  });
}
