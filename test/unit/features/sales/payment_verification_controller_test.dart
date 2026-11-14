import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/widgets/catalog_pagination.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/payment_verification_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/payment_verification_filter.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/verification_queue_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payment_detail_controller.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_list_controller.dart';

class MockCustomerPaymentRepository extends Mock
    implements CustomerPaymentRepository {}

var _queueBuilds = 0;
var _detailBuilds = 0;
var _listBuilds = 0;

class _CountingQueue extends VerificationQueueController {
  @override
  Future<CatalogPage<CustomerPayment>> build(
    PaymentVerificationFilter filter,
  ) async {
    _queueBuilds++;
    return const CatalogPage(items: [], total: 0, pageIndex: 0, pageSize: 20);
  }
}

class _CountingList extends PaymentsListController {
  @override
  Future<CatalogPage<CustomerPayment>> build(PaymentsFilter filter) async {
    _listBuilds++;
    return const CatalogPage(items: [], total: 0, pageIndex: 0, pageSize: 20);
  }
}

CustomerPayment _payment({int? verifier}) => CustomerPayment(
  customerPaymentId: 501,
  customerId: 77,
  amount: '4250.00',
  currency: Currency.mxn,
  methodCode: 3,
  date: DateTime(2026, 11, 13),
  facilityId: 3,
  type: PaymentType.creditPayment,
  verifierId: verifier,
  unapplied: '4250.00',
);

/// Spec 060 R4 (T008): verify and reject.
void main() {
  late MockCustomerPaymentRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockCustomerPaymentRepository();
    _queueBuilds = 0;
    _detailBuilds = 0;
    _listBuilds = 0;
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        customerPaymentRepositoryProvider.overrideWithValue(repository),
        verificationQueueControllerProvider(
          const PaymentVerificationFilter(),
        ).overrideWith(_CountingQueue.new),
        paymentDetailProvider.overrideWith((ref, id) async {
          _detailBuilds++;
          return _payment();
        }),
        paymentsListControllerProvider(
          const PaymentsFilter(),
        ).overrideWith(_CountingList.new),
      ],
    );
    addTearDown(container.dispose);
    // The screens keep these alive; listening here is what makes an
    // invalidation visible as a rebuild.
    container.listen(
      verificationQueueControllerProvider(const PaymentVerificationFilter()),
      (_, _) {},
    );
    container.listen(paymentDetailProvider(501), (_, _) {});
    container.listen(
      paymentsListControllerProvider(const PaymentsFilter()),
      (_, _) {},
    );
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  Future<void> expectReloaded(Future<void> Function() act) async {
    await settle();
    expect([_queueBuilds, _detailBuilds, _listBuilds], everyElement(1));

    await act();
    await settle();

    expect(_queueBuilds, 2, reason: 'the queue');
    expect(_detailBuilds, 2, reason: 'the payment');
    expect(_listBuilds, 2, reason: 'the Pagos list');
  }

  group('verify', () {
    test('answers null and reloads everything on screen', () async {
      when(
        () => repository.verify(customerPaymentId: 501),
      ).thenAnswer((_) async => _payment(verifier: 12));

      await expectReloaded(() async {
        final refusal = await container
            .read(paymentVerificationProvider.notifier)
            .verify(paymentId: 501);
        expect(refusal, isNull);
      });
      verify(() => repository.verify(customerPaymentId: 501)).called(1);
    });

    test('answers the refusal as a value, not a throw, and still '
        'reloads', () async {
      when(() => repository.verify(customerPaymentId: 501)).thenThrow(
        const AppError.server(
          statusCode: 409,
          message: 'Payment is already verified',
        ),
      );

      await expectReloaded(() async {
        final refusal = await container
            .read(paymentVerificationProvider.notifier)
            .verify(paymentId: 501);
        expect(refusal, isA<ServerError>());
      });
    });

    test(
      'a lost connection comes back as the NetworkError, and reloads',
      () async {
        when(
          () => repository.verify(customerPaymentId: 501),
        ).thenThrow(const AppError.network());

        await expectReloaded(() async {
          final refusal = await container
              .read(paymentVerificationProvider.notifier)
              .verify(paymentId: 501);
          expect(refusal, isA<NetworkError>());
        });
      },
    );
  });

  group('reject', () {
    test('passes the reason through untouched and reloads', () async {
      when(
        () => repository.reject(
          customerPaymentId: 501,
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => _payment());

      await expectReloaded(() async {
        final refusal = await container
            .read(paymentVerificationProvider.notifier)
            .reject(paymentId: 501, reason: 'No aparece en el estado');
        expect(refusal, isNull);
      });
      verify(
        () => repository.reject(
          customerPaymentId: 501,
          reason: 'No aparece en el estado',
        ),
      ).called(1);
    });

    test('answers a refusal as a value and reloads', () async {
      when(
        () => repository.reject(
          customerPaymentId: 501,
          reason: any(named: 'reason'),
        ),
      ).thenThrow(const AppError.notFound());

      await expectReloaded(() async {
        final refusal = await container
            .read(paymentVerificationProvider.notifier)
            .reject(paymentId: 501, reason: 'x');
        expect(refusal, isA<NotFoundError>());
      });
    });
  });
}
