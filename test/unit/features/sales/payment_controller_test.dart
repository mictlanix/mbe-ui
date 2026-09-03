import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/data/sales_order_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/domain/repositories/sales_order_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_controller.dart';
import 'package:mbe_ui/features/sales/presentation/pos_sale_controller.dart';

class MockCustomerPaymentRepository extends Mock
    implements CustomerPaymentRepository {}

class MockSalesOrderRepository extends Mock implements SalesOrderRepository {}

/// Seeds `posSaleControllerProvider` directly with a sale, bypassing
/// `open()`/`load()` — `submit`'s own `confirmBeforePayableAction` call reads
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

/// spec 036 R1: `submit` confirms the sale — still `draft` at this point —
/// immediately before the first tender rather than earlier at Venta→Cobro
/// (`pos_confirm.dart`).
void main() {
  late MockCustomerPaymentRepository payments;
  late MockSalesOrderRepository salesOrders;
  late ProviderContainer container;

  setUp(() {
    payments = MockCustomerPaymentRepository();
    salesOrders = MockSalesOrderRepository();
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
      overrides: [
        customerPaymentRepositoryProvider.overrideWithValue(payments),
        salesOrderRepositoryProvider.overrideWithValue(salesOrders),
        posSaleControllerProvider.overrideWith(() => _FixedPosSale(sale)),
      ],
    );
    addTearDown(c.dispose);
    c.listen(posSaleControllerProvider, (_, _) {});
    return c;
  }

  test(
    'submit confirms the still-draft sale exactly once, before creating the '
    'payment',
    () async {
      final sale = _sale();
      container = containerFor(sale);
      await container.read(posSaleControllerProvider.future);
      when(() => salesOrders.confirm(saleId: 42)).thenAnswer((_) async => sale);
      when(() => salesOrders.getById(saleId: 42)).thenAnswer((_) async => sale);

      final notifier = container.read(paymentControllerProvider.notifier);
      notifier.setAmount('116.00');
      notifier.selectMethod(methodCode: 1);

      final ok = await notifier.submit(sale);

      expect(ok, isTrue);
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
      notifier.selectMethod(methodCode: 1);

      final ok = await notifier.submit(sale);

      expect(ok, isTrue);
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
      notifier.selectMethod(methodCode: 1);

      final ok = await notifier.submit(sale);

      expect(ok, isFalse);
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
