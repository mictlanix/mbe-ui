import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/sales/data/customer_refund_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/customer_refund.dart';
import 'package:mbe_ui/features/sales/domain/repositories/customer_refund_repository.dart';
import 'package:mbe_ui/features/sales/presentation/payments/reverse_application_flow.dart';

class _MockRefunds extends Mock implements CustomerRefundRepository {}

User _user({required bool canReadRefunds}) => User(
  userId: 'u',
  email: 'u@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    if (canReadRefunds)
      const Privilege(systemObject: SystemObject.customerRefunds, rawValue: 2),
  ],
);

/// Spec 059 FR-004, R4 (T009): when the reverse dialog may warn about refunds.
void main() {
  late _MockRefunds refunds;

  setUp(() {
    refunds = _MockRefunds();
  });

  ProviderContainer containerFor({required bool canReadRefunds}) {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        customerRefundRepositoryProvider.overrideWithValue(refunds),
        accessControlProvider.overrideWithValue(
          AccessControlService(
            AuthState.authenticated(
              token: 't',
              user: _user(canReadRefunds: canReadRefunds),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  void stubList(Future<RefundListResult> Function() answer) => when(
    () => refunds.list(
      status: any(named: 'status'),
      salesOrderId: any(named: 'salesOrderId'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) => answer());

  test('without Customer Refunds read it is false and asks nothing', () async {
    final container = containerFor(canReadRefunds: false);

    expect(await container.read(orderHasRefundsProvider(7).future), isFalse);

    verifyNever(
      () => refunds.list(
        status: any(named: 'status'),
        salesOrderId: any(named: 'salesOrderId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    );
  });

  test('asks for one completed refund of that order', () async {
    stubList(() async => const RefundListResult(items: [], total: 0));
    final container = containerFor(canReadRefunds: true);

    await container.read(orderHasRefundsProvider(7).future);

    verify(
      () => refunds.list(
        status: RefundStatus.completed,
        salesOrderId: 7,
        skip: 0,
        limit: 1,
      ),
    ).called(1);
  });

  test('no completed refund is false', () async {
    stubList(() async => const RefundListResult(items: [], total: 0));
    final container = containerFor(canReadRefunds: true);

    expect(await container.read(orderHasRefundsProvider(7).future), isFalse);
  });

  test('a completed refund is true', () async {
    stubList(() async => const RefundListResult(items: [], total: 2));
    final container = containerFor(canReadRefunds: true);

    expect(await container.read(orderHasRefundsProvider(7).future), isTrue);
  });

  test('a failing lookup is false, never an error', () async {
    stubList(() async => throw const AppError.server());
    final container = containerFor(canReadRefunds: true);

    expect(await container.read(orderHasRefundsProvider(7).future), isFalse);
  });
}
