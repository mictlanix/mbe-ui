import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/payment_verification_filter.dart';
import 'package:mbe_ui/features/sales/presentation/payment_verification/verification_queue_controller.dart';

class MockCustomerPaymentRepository extends Mock
    implements CustomerPaymentRepository {}

CustomerPayment _payment(int id) => CustomerPayment(
  customerPaymentId: id,
  customerId: 7,
  amount: '100.00',
  currency: Currency.mxn,
  methodCode: PaymentMethod.eft.code,
  date: DateTime(2026, 11, 13, 9),
  facilityId: 9,
  type: PaymentType.creditPayment,
  unapplied: '100.00',
);

/// Spec 060 R2, R3: the queue is company-wide (no facility is ever added) and
/// sends exactly the filter's own values.
void main() {
  late MockCustomerPaymentRepository repository;

  setUp(() => repository = MockCustomerPaymentRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        customerPaymentRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  void stubPage(List<CustomerPayment> items, {int? total}) {
    when(
      () => repository.listUnverified(
        facilityId: any(named: 'facilityId'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        methodCode: any(named: 'methodCode'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          CustomerPaymentListResult(items: items, total: total ?? items.length),
    );
  }

  test('the opening view asks for transfers from every facility, first '
      'page', () async {
    stubPage([_payment(1)]);

    final page = await container().read(
      verificationQueueControllerProvider(
        const PaymentVerificationFilter(),
      ).future,
    );

    verify(
      () => repository.listUnverified(
        facilityId: null,
        dateFrom: null,
        dateTo: null,
        methodCode: PaymentMethod.eft.code,
        skip: 0,
        limit: 20,
      ),
    ).called(1);
    expect(page.items.single.customerPaymentId, 1);
  });

  test('"Todos" sends no method', () async {
    stubPage([_payment(1)]);

    await container().read(
      verificationQueueControllerProvider(
        const PaymentVerificationFilter(method: VerificationMethodFilter.all()),
      ).future,
    );

    verify(
      () => repository.listUnverified(
        facilityId: null,
        dateFrom: null,
        dateTo: null,
        methodCode: null,
        skip: 0,
        limit: 20,
      ),
    ).called(1);
  });

  test('a facility, dates, method and page are sent as given', () async {
    stubPage([_payment(1)], total: 60);

    final from = DateTime(2026, 11, 1);
    final to = DateTime(2026, 11, 13);
    final page = await container().read(
      verificationQueueControllerProvider(
        PaymentVerificationFilter(
          facilityId: 4,
          dateFrom: from,
          dateTo: to,
          method: const VerificationMethodFilter.code(1),
          pageIndex: 1,
        ),
      ).future,
    );

    verify(
      () => repository.listUnverified(
        facilityId: 4,
        dateFrom: from,
        dateTo: to,
        methodCode: 1,
        skip: 20,
        limit: 20,
      ),
    ).called(1);
    expect(page.total, 60);
    expect(page.pageIndex, 1);
  });

  test('a page left empty steps back to the last page with rows', () async {
    // Page index 2 was the last, and its only row has just been verified:
    // the server now has 40 rows (2 pages), so index 2 is empty.
    when(
      () => repository.listUnverified(
        facilityId: any(named: 'facilityId'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        methodCode: any(named: 'methodCode'),
        skip: 40,
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const CustomerPaymentListResult(items: [], total: 40),
    );
    when(
      () => repository.listUnverified(
        facilityId: any(named: 'facilityId'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        methodCode: any(named: 'methodCode'),
        skip: 20,
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => CustomerPaymentListResult(items: [_payment(30)], total: 40),
    );

    final page = await container().read(
      verificationQueueControllerProvider(
        const PaymentVerificationFilter(pageIndex: 2),
      ).future,
    );

    expect(page.pageIndex, 1);
    expect(page.items.single.customerPaymentId, 30);
  });
}
