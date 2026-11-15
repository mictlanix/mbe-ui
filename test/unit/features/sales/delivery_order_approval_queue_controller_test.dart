import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_order_approval/delivery_order_approval_queue_controller.dart';

class _MockRepository extends Mock implements DeliveryOrderAdminRepository {}

DeliveryOrderSummary _order(int id) => DeliveryOrderSummary(
  id: id,
  facilityId: 9,
  serial: 1500 + id,
  customerId: 7,
  priority: 0,
  status: DeliveryOrderStatus.pendingApproval,
  type: FulfillmentType.delivery,
);

/// Spec 062 R1, R3: the queue sends only the page window, never a facility
/// (the server scopes it), and steps back when an action empties a page.
void main() {
  late _MockRepository repository;

  setUp(() => repository = _MockRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        deliveryOrderAdminRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test(
    'the first page asks for skip 0 and limit 20 and maps the page',
    () async {
      when(
        () => repository.approvalQueue(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => DeliveryOrderPage(items: [_order(1), _order(2)], total: 2),
      );

      final page = await container().read(
        deliveryOrderApprovalQueueControllerProvider(0).future,
      );

      verify(() => repository.approvalQueue(skip: 0, limit: 20)).called(1);
      expect(page.items.map((o) => o.id), [1, 2]);
      expect(page.total, 2);
      expect(page.pageIndex, 0);
    },
  );

  test('a later page sends its offset', () async {
    when(
      () => repository.approvalQueue(
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => DeliveryOrderPage(items: [_order(30)], total: 60),
    );

    final page = await container().read(
      deliveryOrderApprovalQueueControllerProvider(1).future,
    );

    verify(() => repository.approvalQueue(skip: 20, limit: 20)).called(1);
    expect(page.pageIndex, 1);
    expect(page.total, 60);
  });

  test('a page left empty steps back to the last page with rows', () async {
    // Page index 2 was the last and its only row has just been approved: the
    // server now has 40 rows (2 pages), so index 2 comes back empty.
    when(
      () => repository.approvalQueue(skip: 40, limit: 20),
    ).thenAnswer((_) async => const DeliveryOrderPage(items: [], total: 40));
    when(() => repository.approvalQueue(skip: 20, limit: 20)).thenAnswer(
      (_) async => DeliveryOrderPage(items: [_order(30)], total: 40),
    );

    final page = await container().read(
      deliveryOrderApprovalQueueControllerProvider(2).future,
    );

    expect(page.pageIndex, 1);
    expect(page.items.single.id, 30);
  });

  test('an empty first page is empty, not clamped', () async {
    when(
      () => repository.approvalQueue(
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const DeliveryOrderPage(items: [], total: 0));

    final page = await container().read(
      deliveryOrderApprovalQueueControllerProvider(0).future,
    );

    expect(page.items, isEmpty);
    expect(page.total, 0);
    verify(() => repository.approvalQueue(skip: 0, limit: 20)).called(1);
  });
}
