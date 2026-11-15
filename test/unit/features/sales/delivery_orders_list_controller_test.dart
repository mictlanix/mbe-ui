import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/sales/data/delivery_order_admin_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/delivery_order.dart';
import 'package:mbe_ui/features/sales/domain/entities/destination.dart';
import 'package:mbe_ui/features/sales/domain/repositories/delivery_order_admin_repository.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_filter.dart';
import 'package:mbe_ui/features/sales/presentation/delivery_orders/delivery_orders_list_controller.dart';
import 'package:mbe_ui/features/sales/presentation/register_controller.dart';

class MockDeliveryOrderAdminRepository extends Mock
    implements DeliveryOrderAdminRepository {}

DeliveryOrderSummary _order(int id) => DeliveryOrderSummary(
  id: id,
  facilityId: 3,
  customerId: 77,
  priority: 0,
  status: DeliveryOrderStatus.draft,
  type: FulfillmentType.delivery,
);

void main() {
  late MockDeliveryOrderAdminRepository repository;

  setUp(() => repository = MockDeliveryOrderAdminRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        deliveryOrderAdminRepositoryProvider.overrideWithValue(repository),
        accessControlProvider.overrideWithValue(
          const AccessControlService(AuthState.unauthenticated()),
        ),
        userFacilityIdProvider.overrideWithValue(3),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  When<Future<DeliveryOrderPage>> whenList() => when(
    () => repository.list(
      statuses: any(named: 'statuses'),
      customer: any(named: 'customer'),
      facility: any(named: 'facility'),
      type: any(named: 'type'),
      salesOrder: any(named: 'salesOrder'),
      dateFrom: any(named: 'dateFrom'),
      dateTo: any(named: 'dateTo'),
      search: any(named: 'search'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  );

  /// A fake server holding [orders], paged by `skip` and `limit`.
  void serve(List<DeliveryOrderSummary> orders) {
    whenList().thenAnswer((invocation) async {
      final skip = invocation.namedArguments[#skip] as int;
      final limit = invocation.namedArguments[#limit] as int;
      final end = (skip + limit).clamp(0, orders.length);
      return DeliveryOrderPage(
        items: skip >= orders.length ? const [] : orders.sublist(skip, end),
        total: orders.length,
      );
    });
  }

  test('the filter reaches the repository, 20 per page', () async {
    serve([for (var i = 50; i >= 1; i--) _order(i)]);
    final filter = DeliveryOrdersFilter(
      search: '12',
      status: DeliveryOrderStatus.failed,
      type: FulfillmentType.counterPickup,
      dateFrom: DateTime(2026, 11, 1),
      dateTo: DateTime(2026, 11, 30),
      customerId: 77,
      salesOrderId: 501,
      pageIndex: 1,
    );

    final page = await container().read(
      deliveryOrdersListControllerProvider(filter).future,
    );

    expect(page.items, hasLength(20));
    expect(page.total, 50);
    expect(page.pageIndex, 1);
    verify(
      () => repository.list(
        statuses: [DeliveryOrderStatus.failed],
        customer: 77,
        facility: null,
        type: FulfillmentType.counterPickup,
        salesOrder: 501,
        dateFrom: DateTime(2026, 11, 1),
        dateTo: DateTime(2026, 11, 30),
        search: '12',
        skip: 20,
        limit: 20,
      ),
    ).called(1);
  });

  test('the opening filter asks for the active statuses, "Todas" for every '
      'status (FR-003, mbe-api#312)', () async {
    serve(const []);
    final c = container();

    await c.read(
      deliveryOrdersListControllerProvider(const DeliveryOrdersFilter()).future,
    );
    await c.read(
      deliveryOrdersListControllerProvider(
        const DeliveryOrdersFilter(everyStatus: true),
      ).future,
    );

    final sent = verify(
      () => repository.list(
        statuses: captureAny(named: 'statuses'),
        customer: any(named: 'customer'),
        facility: any(named: 'facility'),
        type: any(named: 'type'),
        salesOrder: any(named: 'salesOrder'),
        dateFrom: any(named: 'dateFrom'),
        dateTo: any(named: 'dateTo'),
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).captured;
    expect(sent, [DeliveryOrderStatus.active, null]);
  });

  test('a page emptied by its last row going is clamped to the last page '
      'that has rows', () async {
    serve([for (var i = 20; i >= 1; i--) _order(i)]);

    final page = await container().read(
      deliveryOrdersListControllerProvider(
        const DeliveryOrdersFilter(pageIndex: 1),
      ).future,
    );

    expect(page.pageIndex, 0);
    expect(page.items, hasLength(20));
    expect(page.total, 20);
  });

  test('a repository error surfaces as the provider error', () async {
    whenList().thenThrow(const AppError.server(statusCode: 500));

    final c = container();
    await expectLater(
      c.read(
        deliveryOrdersListControllerProvider(
          const DeliveryOrdersFilter(),
        ).future,
      ),
      throwsA(isA<ServerError>()),
    );
  });
}
