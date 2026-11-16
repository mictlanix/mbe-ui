import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_receipt_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_filter.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipts_list_controller.dart';

import 'inventory_receipt_fixtures.dart';

class MockInventoryReceiptRepository extends Mock
    implements InventoryReceiptRepository {}

/// Spec 067 FR-002, research R9 (T009).
void main() {
  late MockInventoryReceiptRepository repository;

  setUp(() => repository = MockInventoryReceiptRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        inventoryReceiptRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  When<Future<InventoryReceiptPage>> whenList() => when(
    () => repository.list(
      status: any(named: 'status'),
      warehouseId: any(named: 'warehouseId'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  );

  /// A fake server holding [receipts], paged by `skip` and `limit`.
  void serve(List<InventoryReceiptSummary> receipts) {
    whenList().thenAnswer((invocation) async {
      final skip = invocation.namedArguments[#skip] as int;
      final limit = invocation.namedArguments[#limit] as int;
      final end = (skip + limit).clamp(0, receipts.length);
      return InventoryReceiptPage(
        items: skip >= receipts.length ? const [] : receipts.sublist(skip, end),
        total: receipts.length,
        pageIndex: skip ~/ limit,
        pageSize: limit,
      );
    });
  }

  test('the filter reaches the repository, 20 per page', () async {
    serve([for (var i = 50; i >= 1; i--) aReceiptSummary(id: i)]);
    const filter = InventoryReceiptsFilter(
      status: ReceiptStatus.completed,
      warehouseId: 3,
      pageIndex: 1,
    );

    final page = await container().read(
      inventoryReceiptsListControllerProvider(filter).future,
    );

    expect(page.items, hasLength(20));
    expect(page.items.first.id, 30);
    expect(page.total, 50);
    expect(page.pageIndex, 1);
    verify(
      () => repository.list(
        status: ReceiptStatus.completed,
        warehouseId: 3,
        skip: 20,
        limit: 20,
      ),
    ).called(1);
  });

  test('a page past the end is clamped to the last page', () async {
    serve([for (var i = 25; i >= 1; i--) aReceiptSummary(id: i)]);

    final page = await container().read(
      inventoryReceiptsListControllerProvider(
        const InventoryReceiptsFilter(pageIndex: 7),
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
    final provider = inventoryReceiptsListControllerProvider(
      const InventoryReceiptsFilter(),
    );
    c.listen(provider, (_, _) {});

    await expectLater(c.read(provider.future), throwsA(isA<NetworkError>()));
    expect(c.read(provider), isA<AsyncError<InventoryReceiptPage>>());
  });
}
