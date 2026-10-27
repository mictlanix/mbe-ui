import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/core/domain/payment_method.dart';
import 'package:mbe_ui/features/sales/data/customer_payment_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_payment.dart';
import 'package:mbe_ui/features/sales/domain/payment_type.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_payment_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_filter.dart';
import 'package:mbe_ui/features/sales/presentation/payments/payments_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';

class MockCustomerPaymentRepository extends Mock
    implements CustomerPaymentRepository {}

CustomerPayment _payment(int id) => CustomerPayment(
  customerPaymentId: id,
  customerId: 7,
  amount: '100.00',
  currency: Currency.mxn,
  methodCode: PaymentMethod.cash.code,
  date: DateTime(2026, 8, 5, 9),
  facilityId: 9,
  type: PaymentType.immediate,
  unapplied: '0.00',
);

/// Spec 054 FR-004, FR-009, SC-004: the facility is never a facet — the
/// controller always sends the user's own (mbe-api#271).
void main() {
  late MockCustomerPaymentRepository repository;

  setUp(() {
    repository = MockCustomerPaymentRepository();
  });

  ProviderContainer containerFor({
    required int? facilityId,
    bool editor = false,
  }) {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        if (editor)
          accessControlProvider.overrideWithValue(
            AccessControlService(
              AuthState.authenticated(
                token: 't',
                user: const User(
                  userId: 'e',
                  email: 'e@example.com',
                  administrator: false,
                  status: EntityStatus.active,
                  sessionVersion: 1,
                  privileges: [
                    Privilege(
                      systemObject: SystemObject.paymentsEditor,
                      rawValue: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        customerPaymentRepositoryProvider.overrideWithValue(repository),
        userFacilityIdProvider.overrideWithValue(facilityId),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  void stubList({int total = 0, List<CustomerPayment> items = const []}) {
    when(
      () => repository.list(
        facilityId: any(named: 'facilityId'),
        customerId: any(named: 'customerId'),
        cashSessionId: any(named: 'cashSessionId'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        methodCode: any(named: 'methodCode'),
        verified: any(named: 'verified'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => CustomerPaymentListResult(items: items, total: total),
    );
  }

  test('with no filters, requests the user\'s own facility, page 0', () async {
    stubList();
    final container = containerFor(facilityId: 9);

    await container.read(
      paymentsListControllerProvider(const PaymentsFilter()).future,
    );

    verify(
      () => repository.list(
        facilityId: 9,
        customerId: null,
        cashSessionId: null,
        dateFrom: null,
        dateTo: null,
        methodCode: null,
        verified: null,
        skip: 0,
        limit: 20,
      ),
    ).called(1);
  });

  test('forwards every facet and the page offset, still with the user\'s '
      'facility', () async {
    stubList(total: 100, items: [_payment(1)]);
    final container = containerFor(facilityId: 9);
    final filter = PaymentsFilter(
      customerId: 12,
      dateFrom: DateTime(2026, 8, 1),
      dateTo: DateTime(2026, 8, 5),
      methodCode: 4,
      verified: false,
      cashSessionId: 77,
      pageIndex: 2,
    );

    await container.read(paymentsListControllerProvider(filter).future);

    verify(
      () => repository.list(
        facilityId: 9,
        customerId: 12,
        cashSessionId: 77,
        dateFrom: DateTime(2026, 8, 1),
        dateTo: DateTime(2026, 8, 5),
        methodCode: 4,
        verified: false,
        skip: 40,
        limit: 20,
      ),
    ).called(1);
  });

  test('the facility is the user\'s whatever the filter, for every filter '
      'shape', () async {
    stubList();
    final container = containerFor(facilityId: 3);

    for (final filter in [
      const PaymentsFilter(),
      const PaymentsFilter(customerId: 1),
      const PaymentsFilter(verified: true),
      const PaymentsFilter(cashSessionId: 5),
    ]) {
      await container.read(paymentsListControllerProvider(filter).future);
    }

    final captured = verify(
      () => repository.list(
        facilityId: captureAny(named: 'facilityId'),
        customerId: any(named: 'customerId'),
        cashSessionId: any(named: 'cashSessionId'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        methodCode: any(named: 'methodCode'),
        verified: any(named: 'verified'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).captured;
    expect(captured, [3, 3, 3, 3]);
  });

  test('maps items and total onto a CatalogPage', () async {
    stubList(total: 2, items: [_payment(1), _payment(2)]);
    final container = containerFor(facilityId: 9);

    final page = await container.read(
      paymentsListControllerProvider(const PaymentsFilter()).future,
    );

    expect(page.total, 2);
    expect(page.items.map((p) => p.customerPaymentId), [1, 2]);
    expect(page.pageSize, 20);
    expect(page.pageIndex, 0);
  });

  test('a page beyond the result set clamps to the last valid page', () async {
    when(
      () => repository.list(
        facilityId: any(named: 'facilityId'),
        customerId: any(named: 'customerId'),
        cashSessionId: any(named: 'cashSessionId'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        methodCode: any(named: 'methodCode'),
        verified: any(named: 'verified'),
        skip: 100,
        limit: 20,
      ),
    ).thenAnswer(
      (_) async => const CustomerPaymentListResult(items: [], total: 5),
    );
    when(
      () => repository.list(
        facilityId: any(named: 'facilityId'),
        customerId: any(named: 'customerId'),
        cashSessionId: any(named: 'cashSessionId'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        methodCode: any(named: 'methodCode'),
        verified: any(named: 'verified'),
        skip: 0,
        limit: 20,
      ),
    ).thenAnswer(
      (_) async => CustomerPaymentListResult(items: [_payment(1)], total: 5),
    );
    final container = containerFor(facilityId: 9);

    final page = await container.read(
      paymentsListControllerProvider(const PaymentsFilter(pageIndex: 5)).future,
    );

    expect(page.pageIndex, 0);
    expect(page.items, hasLength(1));
  });

  test('a user with no facility gets an empty page and the repository is '
      'never called', () async {
    stubList(total: 1, items: [_payment(1)]);
    final container = containerFor(facilityId: null);

    final page = await container.read(
      paymentsListControllerProvider(
        const PaymentsFilter(customerId: 12, verified: true),
      ).future,
    );

    expect(page.items, isEmpty);
    expect(page.total, 0);
    verifyZeroInteractions(repository);
  });

  test('a repository failure surfaces as an error state', () async {
    when(
      () => repository.list(
        facilityId: any(named: 'facilityId'),
        customerId: any(named: 'customerId'),
        cashSessionId: any(named: 'cashSessionId'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        methodCode: any(named: 'methodCode'),
        verified: any(named: 'verified'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(StateError('boom'));
    final container = containerFor(facilityId: 9);

    await expectLater(
      container.read(
        paymentsListControllerProvider(const PaymentsFilter()).future,
      ),
      throwsA(isA<StateError>()),
    );
  });

  group('all-facilities scope (US3)', () {
    void stubSearch({List<CustomerPayment> items = const [], int total = 0}) =>
        when(
          () => repository.searchAcrossFacilities(
            customerId: any(named: 'customerId'),
            reference: any(named: 'reference'),
            dateFrom: any(named: 'dateFrom'),
            dateTo: any(named: 'dateTo'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => CustomerPaymentListResult(items: items, total: total),
        );

    test('an editor calls searchAcrossFacilities with the reference, '
        'customer, dates and offset, and never list', () async {
      stubSearch(items: [_payment(1)], total: 100);
      final container = containerFor(facilityId: 9, editor: true);
      final filter = PaymentsFilter(
        scope: PaymentsScope.allFacilities,
        customerId: 12,
        reference: 'REF',
        dateFrom: DateTime(2026, 8, 1),
        dateTo: DateTime(2026, 8, 5),
        pageIndex: 2,
      );

      await container.read(paymentsListControllerProvider(filter).future);

      verify(
        () => repository.searchAcrossFacilities(
          customerId: 12,
          reference: 'REF',
          dateFrom: DateTime(2026, 8, 1),
          dateTo: DateTime(2026, 8, 5),
          skip: 40,
          limit: 20,
        ),
      ).called(1);
      verifyNever(
        () => repository.list(
          facilityId: any(named: 'facilityId'),
          customerId: any(named: 'customerId'),
          cashSessionId: any(named: 'cashSessionId'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          methodCode: any(named: 'methodCode'),
          verified: any(named: 'verified'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test(
      'an editor with no facility of their own can still search all',
      () async {
        stubSearch();
        final container = containerFor(facilityId: null, editor: true);

        final page = await container.read(
          paymentsListControllerProvider(
            const PaymentsFilter(scope: PaymentsScope.allFacilities),
          ).future,
        );

        expect(page.items, isEmpty);
        verify(
          () => repository.searchAcrossFacilities(
            customerId: null,
            reference: null,
            dateFrom: null,
            dateTo: null,
            skip: 0,
            limit: 20,
          ),
        ).called(1);
      },
    );

    test(
      'a user WITHOUT Payments Editor read gets the own-facility list '
      'even for a scope=all filter, and the search is never called',
      () async {
        stubList(total: 1, items: [_payment(1)]);
        final container = containerFor(facilityId: 9);

        await container.read(
          paymentsListControllerProvider(
            const PaymentsFilter(
              scope: PaymentsScope.allFacilities,
              reference: 'REF',
            ),
          ).future,
        );

        verify(
          () => repository.list(
            facilityId: 9,
            customerId: null,
            cashSessionId: null,
            dateFrom: null,
            dateTo: null,
            methodCode: null,
            verified: null,
            skip: 0,
            limit: 20,
          ),
        ).called(1);
        verifyNever(
          () => repository.searchAcrossFacilities(
            customerId: any(named: 'customerId'),
            reference: any(named: 'reference'),
            dateFrom: any(named: 'dateFrom'),
            dateTo: any(named: 'dateTo'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        );
      },
    );

    test('an editor in the facility scope still sends their own facility, '
        'never the search', () async {
      stubList();
      final container = containerFor(facilityId: 9, editor: true);

      await container.read(
        paymentsListControllerProvider(const PaymentsFilter()).future,
      );

      verify(
        () => repository.list(
          facilityId: 9,
          customerId: null,
          cashSessionId: null,
          dateFrom: null,
          dateTo: null,
          methodCode: null,
          verified: null,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
      verifyNever(
        () => repository.searchAcrossFacilities(
          customerId: any(named: 'customerId'),
          reference: any(named: 'reference'),
          dateFrom: any(named: 'dateFrom'),
          dateTo: any(named: 'dateTo'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );
    });
  });
}
