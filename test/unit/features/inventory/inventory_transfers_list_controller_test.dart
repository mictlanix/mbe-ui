import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_transfer_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_filter.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfers_list_controller.dart';

import 'inventory_transfer_fixtures.dart';

class MockInventoryTransferRepository extends Mock
    implements InventoryTransferRepository {}

/// Spec 069 FR-002 (T007).
void main() {
  late MockInventoryTransferRepository repository;

  setUp(() => repository = MockInventoryTransferRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        inventoryTransferRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  When<Future<InventoryTransferPage>> whenList() => when(
    () => repository.list(
      status: any(named: 'status'),
      warehouseId: any(named: 'warehouseId'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  );

  void serve(List<InventoryTransferSummary> transfers) {
    whenList().thenAnswer((invocation) async {
      final skip = invocation.namedArguments[#skip] as int;
      final limit = invocation.namedArguments[#limit] as int;
      final end = (skip + limit).clamp(0, transfers.length);
      return InventoryTransferPage(
        items: skip >= transfers.length
            ? const []
            : transfers.sublist(skip, end),
        total: transfers.length,
        pageIndex: skip ~/ limit,
        pageSize: limit,
      );
    });
  }

  test('the filter reaches the repository, 20 per page', () async {
    serve([for (var i = 50; i >= 1; i--) aTransferSummary(id: i)]);
    const filter = InventoryTransfersFilter(
      status: InventoryTransferStatus.inTransit,
      warehouseId: 3,
      pageIndex: 1,
    );

    final page = await container().read(
      inventoryTransfersListControllerProvider(filter).future,
    );

    expect(page.items, hasLength(20));
    expect(page.items.first.id, 30);
    expect(page.total, 50);
    expect(page.pageIndex, 1);
    verify(
      () => repository.list(
        status: InventoryTransferStatus.inTransit,
        warehouseId: 3,
        skip: 20,
        limit: 20,
      ),
    ).called(1);
  });

  test('a page past the end is clamped to the last page', () async {
    serve([for (var i = 25; i >= 1; i--) aTransferSummary(id: i)]);

    final page = await container().read(
      inventoryTransfersListControllerProvider(
        const InventoryTransfersFilter(pageIndex: 7),
      ).future,
    );

    expect(page.pageIndex, 1);
    expect(page.items, hasLength(5));
    verify(
      () =>
          repository.list(status: null, warehouseId: null, skip: 20, limit: 20),
    ).called(1);
  });

  test('a failure becomes an AsyncError carrying the AppError', () async {
    whenList().thenAnswer((_) async => throw const AppError.network());
    final c = container();
    final provider = inventoryTransfersListControllerProvider(
      const InventoryTransfersFilter(),
    );
    c.listen(provider, (_, _) {});

    await expectLater(c.read(provider.future), throwsA(isA<NetworkError>()));
    expect(c.read(provider), isA<AsyncError<InventoryTransferPage>>());
  });
}
