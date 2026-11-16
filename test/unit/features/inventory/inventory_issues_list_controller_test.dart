import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_issue_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_issue.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_issue_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/shared/inventory_documents_filter.dart';
import 'package:mbe_ui/features/inventory/presentation/issues/inventory_issues_list_controller.dart';

import 'inventory_issue_fixtures.dart';

class MockInventoryIssueRepository extends Mock
    implements InventoryIssueRepository {}

/// Spec 068 FR-002 (T010).
void main() {
  late MockInventoryIssueRepository repository;

  setUp(() => repository = MockInventoryIssueRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        inventoryIssueRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  When<Future<InventoryIssuePage>> whenList() => when(
    () => repository.list(
      status: any(named: 'status'),
      warehouseId: any(named: 'warehouseId'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  );

  /// A fake server holding [issues], paged by `skip` and `limit`.
  void serve(List<InventoryIssueSummary> issues) {
    whenList().thenAnswer((invocation) async {
      final skip = invocation.namedArguments[#skip] as int;
      final limit = invocation.namedArguments[#limit] as int;
      final end = (skip + limit).clamp(0, issues.length);
      return InventoryIssuePage(
        items: skip >= issues.length ? const [] : issues.sublist(skip, end),
        total: issues.length,
        pageIndex: skip ~/ limit,
        pageSize: limit,
      );
    });
  }

  test('the filter reaches the repository, 20 per page', () async {
    serve([for (var i = 50; i >= 1; i--) anIssueSummary(id: i)]);
    const filter = InventoryDocumentsFilter(
      status: InventoryDocumentStatus.completed,
      warehouseId: 3,
      pageIndex: 1,
    );

    final page = await container().read(
      inventoryIssuesListControllerProvider(filter).future,
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
    serve([for (var i = 25; i >= 1; i--) anIssueSummary(id: i)]);

    final page = await container().read(
      inventoryIssuesListControllerProvider(
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
    final provider = inventoryIssuesListControllerProvider(
      const InventoryDocumentsFilter(),
    );
    c.listen(provider, (_, _) {});

    await expectLater(c.read(provider.future), throwsA(isA<NetworkError>()));
    expect(c.read(provider), isA<AsyncError<InventoryIssuePage>>());
  });
}
