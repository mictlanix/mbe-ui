import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_order_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_orders_filter.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_orders_list_controller.dart';

import 'purchase_order_fixtures.dart';

class MockPurchaseOrderRepository extends Mock
    implements PurchaseOrderRepository {}

/// Spec 080 FR-004, research R15 (T017).
void main() {
  late MockPurchaseOrderRepository repository;

  setUp(() => repository = MockPurchaseOrderRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        purchaseOrderRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  When<Future<PurchaseOrderPage>> whenList() => when(
    () => repository.list(
      all: any(named: 'all'),
      status: any(named: 'status'),
      supplierId: any(named: 'supplierId'),
      creatorId: any(named: 'creatorId'),
      orderId: any(named: 'orderId'),
      from: any(named: 'from'),
      to: any(named: 'to'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  );

  /// A fake server holding [orders], paged by `skip` and `limit`.
  void serve(List<PurchaseOrderSummary> orders) {
    whenList().thenAnswer((invocation) async {
      final skip = invocation.namedArguments[#skip] as int;
      final limit = invocation.namedArguments[#limit] as int;
      final end = (skip + limit).clamp(0, orders.length);
      return PurchaseOrderPage(
        items: skip >= orders.length ? const [] : orders.sublist(skip, end),
        total: orders.length,
        pageIndex: skip ~/ limit,
        pageSize: limit,
      );
    });
  }

  test('the filter reaches the repository, 20 per page', () async {
    serve([for (var i = 50; i >= 1; i--) anOrderSummary(id: i)]);
    final filter = PurchaseOrdersFilter(
      all: true,
      status: InventoryDocumentStatus.completed,
      supplierId: 12,
      creatorId: 5,
      from: DateTime(2026, 11, 1),
      to: DateTime(2026, 11, 30),
      orderId: 31,
      search: '31',
      pageIndex: 1,
    );

    final page = await container().read(
      purchaseOrdersListControllerProvider(filter).future,
    );

    expect(page.items, hasLength(20));
    expect(page.items.first.id, 30);
    expect(page.total, 50);
    expect(page.pageIndex, 1);
    verify(
      () => repository.list(
        all: true,
        status: InventoryDocumentStatus.completed,
        supplierId: 12,
        creatorId: 5,
        orderId: 31,
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 11, 30),
        skip: 20,
        limit: 20,
      ),
    ).called(1);
  });

  test('the default filter sends no scope widening and no facets', () async {
    serve([anOrderSummary()]);

    await container().read(
      purchaseOrdersListControllerProvider(const PurchaseOrdersFilter()).future,
    );

    verify(
      () => repository.list(
        all: false,
        status: null,
        supplierId: null,
        creatorId: null,
        orderId: null,
        from: null,
        to: null,
        skip: 0,
        limit: 20,
      ),
    ).called(1);
  });

  test('a page past the end is clamped to the last page', () async {
    serve([for (var i = 25; i >= 1; i--) anOrderSummary(id: i)]);

    final page = await container().read(
      purchaseOrdersListControllerProvider(
        const PurchaseOrdersFilter(pageIndex: 7),
      ).future,
    );

    expect(page.pageIndex, 1);
    expect(page.items, hasLength(5));
  });

  test('a failure becomes an AsyncError carrying the AppError', () async {
    whenList().thenAnswer((_) async => throw const AppError.network());
    final c = container();
    final provider = purchaseOrdersListControllerProvider(
      const PurchaseOrdersFilter(),
    );
    c.listen(provider, (_, _) {});

    await expectLater(c.read(provider.future), throwsA(isA<NetworkError>()));
    expect(c.read(provider), isA<AsyncError<PurchaseOrderPage>>());
  });
}
