import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/sales/data/customer_refund_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_refund_repository.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refunds_filter.dart';
import 'package:mbe_ui/features/sales/presentation/refunds/refunds_list_controller.dart';

class MockCustomerRefundRepository extends Mock
    implements CustomerRefundRepository {}

CustomerRefundSummary _refund(
  int id, {
  RefundStatus status = RefundStatus.draft,
  int customer = 7,
  int order = 42,
}) => CustomerRefundSummary(
  id: id,
  salesOrderId: order,
  customerId: customer,
  currency: Currency.mxn,
  status: status,
  total: '10.00',
);

AccessControlService _access({bool read = true}) => AccessControlService(
  AuthState.authenticated(
    token: 't',
    user: User(
      userId: 'c',
      email: 'c@example.com',
      administrator: false,
      status: EntityStatus.active,
      sessionVersion: 1,
      privileges: [
        if (read)
          const Privilege(
            systemObject: SystemObject.customerRefunds,
            rawValue: 2,
          ),
      ],
    ),
  ),
);

void main() {
  late MockCustomerRefundRepository repository;

  setUp(() => repository = MockCustomerRefundRepository());

  ProviderContainer containerFor({bool read = true}) {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        customerRefundRepositoryProvider.overrideWithValue(repository),
        accessControlProvider.overrideWithValue(_access(read: read)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// A fake server holding [refunds] that honours the three facets, `skip`
  /// and `limit`, and counts in `total` only what its filters keep.
  void serve(List<CustomerRefundSummary> refunds) {
    when(
      () => repository.list(
        status: any(named: 'status'),
        customerId: any(named: 'customerId'),
        salesOrderId: any(named: 'salesOrderId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((invocation) async {
      final status = invocation.namedArguments[#status] as RefundStatus?;
      final customerId = invocation.namedArguments[#customerId] as int?;
      final orderId = invocation.namedArguments[#salesOrderId] as int?;
      final skip = invocation.namedArguments[#skip] as int;
      final limit = invocation.namedArguments[#limit] as int;
      final all = [
        for (final r in refunds)
          if ((status == null || r.status == status) &&
              (customerId == null || r.customerId == customerId) &&
              (orderId == null || r.salesOrderId == orderId))
            r,
      ];
      final end = (skip + limit).clamp(0, all.length);
      return RefundListResult(
        items: skip >= all.length ? const [] : all.sublist(skip, end),
        total: all.length,
      );
    });
  }

  test('asks for the first page and reports the server total', () async {
    serve([for (var i = 50; i >= 1; i--) _refund(i)]);

    final page = await containerFor().read(
      refundsListControllerProvider(const RefundsFilter()).future,
    );

    expect(page.items, hasLength(20));
    expect(page.total, 50);
    expect(page.pageIndex, 0);
    verify(
      () => repository.list(
        status: null,
        customerId: null,
        salesOrderId: null,
        skip: 0,
        limit: 20,
      ),
    ).called(1);
  });

  test('the three filters and the page reach the repository', () async {
    serve([for (var i = 50; i >= 1; i--) _refund(i)]);

    final page = await containerFor().read(
      refundsListControllerProvider(
        const RefundsFilter(
          status: RefundStatus.draft,
          customerId: 7,
          salesOrderId: 42,
          pageIndex: 2,
        ),
      ).future,
    );

    expect(page.items, hasLength(10));
    expect(page.pageIndex, 2);
    verify(
      () => repository.list(
        status: RefundStatus.draft,
        customerId: 7,
        salesOrderId: 42,
        skip: 40,
        limit: 20,
      ),
    ).called(1);
  });

  test('only matching refunds come back for a narrowed filter', () async {
    serve([
      _refund(3, status: RefundStatus.completed),
      _refund(2, customer: 8),
      _refund(1),
    ]);

    final page = await containerFor().read(
      refundsListControllerProvider(
        const RefundsFilter(status: RefundStatus.draft, customerId: 7),
      ).future,
    );

    expect(page.items.map((r) => r.id), [1]);
    expect(page.total, 1);
  });

  test('a page past the end is clamped to the last page', () async {
    serve([for (var i = 25; i >= 1; i--) _refund(i)]);

    final page = await containerFor().read(
      refundsListControllerProvider(const RefundsFilter(pageIndex: 9)).future,
    );

    expect(page.pageIndex, 1);
    expect(page.items, hasLength(5));
    expect(page.total, 25);
  });

  test('without customer-refunds read: an empty page and no request', () async {
    serve([_refund(1)]);

    final page = await containerFor(
      read: false,
    ).read(refundsListControllerProvider(const RefundsFilter()).future);

    expect(page.items, isEmpty);
    expect(page.total, 0);
    verifyNever(
      () => repository.list(
        status: any(named: 'status'),
        customerId: any(named: 'customerId'),
        salesOrderId: any(named: 'salesOrderId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    );
  });
}
