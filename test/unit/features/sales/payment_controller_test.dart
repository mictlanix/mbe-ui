import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';

class MockCustomerPaymentRepository extends Mock
    implements CustomerPaymentRepository {}

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

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
  late ProviderContainer container;

  setUp(() {
    payments = MockCustomerPaymentRepository();
    salesOrders = MockSalesOrderRepository();
    cashSessions = MockCashSessionRepository();
    when(() => cashSessions.getCurrent()).thenAnswer(
      (_) async => const CurrentSession(state: SessionState.open),
    );
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
        posSaleControllerProvider.overrideWith(() => _FixedPosSale(sale)),
      ],
    );
    addTearDown(c.dispose);
    c.listen(posSaleControllerProvider, (_, _) {});
    return c;
  }

  test(
    'tender confirms the still-draft sale exactly once, before creating the '
    'payment',
    () async {
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
    },
  );

  test(
    'a tender on a sale that is no longer draft does not confirm again '
    '(the tender still goes through)',
    () async {
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
    },
  );

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
        when(() => cashSessions.getCurrent()).thenAnswer(
          (_) async => CurrentSession(state: state),
        );

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
      test('an amount of "$amount" is refused with amountRequired and no API call', () async {
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
      });
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

    test('after a partial payment the amount becomes the new remaining balance', () async {
      final sale = _sale(status: SaleStatus.completed);
      container = containerFor(sale);
      await container.read(posSaleControllerProvider.future);
      when(() => salesOrders.getById(saleId: 42))
          .thenAnswer((_) async => _sale(status: SaleStatus.completed, balance: '66.00'));
      final notifier = container.read(paymentControllerProvider.notifier);
      notifier.setAmount('50.00');

      await notifier.tender(sale, methodCode: 1);

      expect(container.read(paymentControllerProvider).amount, '66.00');
      expect(container.read(paymentControllerProvider).submitting, isFalse);
    });

    test('prefillAmount seeds an empty amount, never overwrites a keyed one', () async {
      container = containerFor(_sale());
      final notifier = container.read(paymentControllerProvider.notifier);

      notifier.prefillAmount('116.00');
      expect(container.read(paymentControllerProvider).amount, '116.00');

      notifier.setAmount('20.00');
      notifier.prefillAmount('116.00');
      expect(container.read(paymentControllerProvider).amount, '20.00');
    });
  });

  group('overpayment and change (spec 047 US6)', () {
    Future<(PaymentController, Sale)> arrange({String amount = '150.00'}) async {
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

    test('a non-cash method over the balance is refused before any API call', () async {
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
    });

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

    test('lastChange survives typing, and is cleared by dismissChange', () async {
      final (notifier, sale) = await arrange();
      await notifier.tender(sale, methodCode: 1);

      notifier.setAmount('20.00');
      expect(container.read(paymentControllerProvider).lastChange, '34');

      notifier.dismissChange();
      expect(container.read(paymentControllerProvider).lastChange, isNull);
    });

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

    test('leaving the step disposes the draft, and with it lastChange', () async {
      final (notifier, sale) = await arrange();
      await notifier.tender(sale, methodCode: 1);
      expect(container.read(paymentControllerProvider).lastChange, '34');

      container.invalidate(paymentControllerProvider);

      expect(container.read(paymentControllerProvider).lastChange, isNull);
    });
  });
}
