import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/presentation/orders/order_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment/order_payments_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_editor_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_list_controller.dart';
import 'package:mbe_ui/features/sales/domain/entities/sale_payment.dart';

class MockCustomerPaymentRepository extends Mock
    implements CustomerPaymentRepository {}

var _detailBuilds = 0;
var _applicationsBuilds = 0;
var _listBuilds = 0;
var _orderPaymentsBuilds = 0;
var _orderBuilds = 0;

class _CountingList extends PaymentsListController {
  @override
  Future<CatalogPage<CustomerPayment>> build(PaymentsFilter filter) async {
    _listBuilds++;
    return const CatalogPage(items: [], total: 0, pageIndex: 0, pageSize: 20);
  }
}

class _CountingOrder extends OrderEditorController {
  @override
  Future<Sale?> build(int? orderId) async {
    _orderBuilds++;
    return null;
  }
}

CustomerPayment _payment() => CustomerPayment(
  customerPaymentId: 501,
  customerId: 77,
  amount: '3000.00',
  currency: Currency.mxn,
  methodCode: 3,
  date: DateTime(2026, 11, 13),
  facilityId: 3,
  type: PaymentType.creditPayment,
  unapplied: '1500.00',
);

/// Spec 059 R3 (T008): the back office's reverse and apply.
void main() {
  late MockCustomerPaymentRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockCustomerPaymentRepository();
    _detailBuilds = 0;
    _applicationsBuilds = 0;
    _listBuilds = 0;
    _orderPaymentsBuilds = 0;
    _orderBuilds = 0;
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        customerPaymentRepositoryProvider.overrideWithValue(repository),
        paymentDetailProvider.overrideWith((ref, id) async {
          _detailBuilds++;
          return _payment();
        }),
        paymentApplicationsProvider.overrideWith((ref, id) async {
          _applicationsBuilds++;
          return const <PaymentApplication>[];
        }),
        paymentsListControllerProvider(
          const PaymentsFilter(),
        ).overrideWith(_CountingList.new),
        orderPaymentsControllerProvider(7).overrideWith((ref) async {
          _orderPaymentsBuilds++;
          return const <SalePayment>[];
        }),
        orderEditorControllerProvider(7).overrideWith(_CountingOrder.new),
      ],
    );
    addTearDown(container.dispose);
    // The screens keep these alive; listening here is what makes an
    // invalidation visible as a rebuild.
    container.listen(paymentDetailProvider(501), (_, _) {});
    container.listen(paymentApplicationsProvider(501), (_, _) {});
    container.listen(
      paymentsListControllerProvider(const PaymentsFilter()),
      (_, _) {},
    );
    container.listen(orderPaymentsControllerProvider(7), (_, _) {});
    container.listen(orderEditorControllerProvider(7), (_, _) {});
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  Future<void> expectEverythingReloaded(Future<void> Function() act) async {
    await settle();
    expect(
      [
        _detailBuilds,
        _applicationsBuilds,
        _listBuilds,
        _orderPaymentsBuilds,
        _orderBuilds,
      ],
      everyElement(1),
      reason: 'each provider built once on first read',
    );

    await act();
    await settle();

    expect(_detailBuilds, 2, reason: 'payment');
    expect(_applicationsBuilds, 2, reason: 'applications');
    expect(_listBuilds, 2, reason: 'Pagos list');
    expect(_orderPaymentsBuilds, 2, reason: "order's payments");
    expect(_orderBuilds, 2, reason: 'the order, for its paid status');
  }

  group('reverse', () {
    test('answers null and reloads everything on screen', () async {
      when(
        () => repository.reverseApplication(
          customerPaymentId: any(named: 'customerPaymentId'),
          applicationId: any(named: 'applicationId'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async {});

      await expectEverythingReloaded(() async {
        final result = await container
            .read(paymentEditorProvider.notifier)
            .reverse(
              paymentId: 501,
              applicationId: 9,
              saleId: 7,
              reason: 'Aplicado al pedido equivocado',
            );
        expect(result, isNull);
      });

      verify(
        () => repository.reverseApplication(
          customerPaymentId: 501,
          applicationId: 9,
          reason: 'Aplicado al pedido equivocado',
        ),
      ).called(1);
    });

    test('answers the refusal, and still reloads what was stale', () async {
      when(
        () => repository.reverseApplication(
          customerPaymentId: any(named: 'customerPaymentId'),
          applicationId: any(named: 'applicationId'),
          reason: any(named: 'reason'),
        ),
      ).thenThrow(const AppError.notFound());

      await expectEverythingReloaded(() async {
        final result = await container
            .read(paymentEditorProvider.notifier)
            .reverse(
              paymentId: 501,
              applicationId: 9,
              saleId: 7,
              reason: 'Motivo',
            );
        expect(result, isA<NotFoundError>());
      });
    });
  });

  group('apply', () {
    test('sends the amount with no change, answers null, reloads', () async {
      when(
        () => repository.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      ).thenAnswer((_) async {});

      await expectEverythingReloaded(() async {
        final result = await container
            .read(paymentEditorProvider.notifier)
            .apply(paymentId: 501, saleId: 7, amount: '900.00');
        expect(result, isNull);
      });

      verify(
        () => repository.applyPayment(
          customerPaymentId: 501,
          salesOrder: 7,
          amount: '900.00',
        ),
      ).called(1);
    });

    test('answers the refusal and still reloads', () async {
      when(
        () => repository.applyPayment(
          customerPaymentId: any(named: 'customerPaymentId'),
          salesOrder: any(named: 'salesOrder'),
          amount: any(named: 'amount'),
          amountChange: any(named: 'amountChange'),
        ),
      ).thenThrow(const AppError.server());

      await expectEverythingReloaded(() async {
        final result = await container
            .read(paymentEditorProvider.notifier)
            .apply(paymentId: 501, saleId: 7, amount: '900.00');
        expect(result, isA<ServerError>());
      });
    });
  });
}
