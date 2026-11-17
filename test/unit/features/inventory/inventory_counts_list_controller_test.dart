import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_count_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_count.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_count_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_counts_list_controller.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_documents_filter.dart';

import 'inventory_count_fixtures.dart';

class MockInventoryCountRepository extends Mock
    implements InventoryCountRepository {}

/// Spec 070 FR-002 (T007).
void main() {
  late MockInventoryCountRepository repository;

  setUp(() => repository = MockInventoryCountRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        inventoryCountRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  When<Future<InventoryCountPage>> whenList() => when(
    () => repository.list(
      status: any(named: 'status'),
      warehouseId: any(named: 'warehouseId'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  );

  /// A fake server holding [counts], paged by `skip` and `limit`.
  void serve(List<InventoryCountSummary> counts) {
    whenList().thenAnswer((invocation) async {
      final skip = invocation.namedArguments[#skip] as int;
      final limit = invocation.namedArguments[#limit] as int;
      final end = (skip + limit).clamp(0, counts.length);
      return InventoryCountPage(
        items: skip >= counts.length ? const [] : counts.sublist(skip, end),
        total: counts.length,
        pageIndex: skip ~/ limit,
        pageSize: limit,
      );
    });
  }

  test('the filter reaches the repository, 20 per page', () async {
    serve([for (var i = 50; i >= 1; i--) aCountSummary(id: i)]);
    const filter = InventoryDocumentsFilter(
      status: InventoryDocumentStatus.completed,
      warehouseId: 3,
      pageIndex: 1,
    );

    final page = await container().read(
      inventoryCountsListControllerProvider(filter).future,
    );

    expect(page.items, hasLength(20));
    expect(page.items.first.id, 30);
    expect(page.total, 50);
    expect(page.pageIndex, 1);
    verify(
      () => repository.list(
        status: InventoryDocumentStatus.completed,
        warehouseId: 3,
        skip: 20,
        limit: 20,
      ),
    ).called(1);
  });

  test('a page past the end is clamped to the last page', () async {
    serve([for (var i = 25; i >= 1; i--) aCountSummary(id: i)]);

    final page = await container().read(
      inventoryCountsListControllerProvider(
        const InventoryDocumentsFilter(pageIndex: 7),
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
    final provider = inventoryCountsListControllerProvider(
      const InventoryDocumentsFilter(),
    );
    c.listen(provider, (_, _) {});

    await expectLater(c.read(provider.future), throwsA(isA<NetworkError>()));
    expect(c.read(provider), isA<AsyncError<InventoryCountPage>>());
  });
}
