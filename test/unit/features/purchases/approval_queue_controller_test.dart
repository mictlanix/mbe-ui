import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_request_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/approval/approval_queue_controller.dart';

import 'purchase_request_fixtures.dart';

class MockPurchaseRequestRepository extends Mock
    implements PurchaseRequestRepository {}

/// Spec 079 FR-019, research R10 (T020).
void main() {
  late MockPurchaseRequestRepository repository;

  setUp(() => repository = MockPurchaseRequestRepository());

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        purchaseRequestRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  When<Future<PurchaseRequestPage>> whenQueue() => when(
    () => repository.approvalQueue(
      facilityId: any(named: 'facilityId'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  );

  /// A fake server holding [requests], paged by `skip` and `limit`.
  void serve(List<PurchaseRequestSummary> requests) {
    whenQueue().thenAnswer((invocation) async {
      final skip = invocation.namedArguments[#skip] as int;
      final limit = invocation.namedArguments[#limit] as int;
      final end = (skip + limit).clamp(0, requests.length);
      return PurchaseRequestPage(
        items: skip >= requests.length ? const [] : requests.sublist(skip, end),
        total: requests.length,
        pageIndex: skip ~/ limit,
        pageSize: limit,
      );
    });
  }

  test('the facility and page reach the repository, 20 per page, in the '
      "server's order", () async {
    serve([for (var i = 1; i <= 30; i++) aRequestSummary(id: i)]);

    final page = await container().read(
      approvalQueueControllerProvider(
        const ApprovalQueueFilter(facilityId: 2, pageIndex: 1),
      ).future,
    );

    expect(page.items.map((r) => r.id), [for (var i = 21; i <= 30; i++) i]);
    expect(page.total, 30);
    expect(page.pageIndex, 1);
    verify(
      () => repository.approvalQueue(facilityId: 2, skip: 20, limit: 20),
    ).called(1);
  });

  test('a page emptied by an approval steps back to the last page', () async {
    serve([for (var i = 1; i <= 20; i++) aRequestSummary(id: i)]);

    final page = await container().read(
      approvalQueueControllerProvider(
        const ApprovalQueueFilter(pageIndex: 1),
      ).future,
    );

    expect(page.pageIndex, 0);
    expect(page.items, hasLength(20));
  });

  test('a failure becomes an AsyncError carrying the AppError', () async {
    whenQueue().thenAnswer((_) async => throw const AppError.network());
    final c = container();
    final provider = approvalQueueControllerProvider(
      const ApprovalQueueFilter(),
    );
    c.listen(provider, (_, _) {});

    await expectLater(c.read(provider.future), throwsA(isA<NetworkError>()));
  });

  group('ApprovalQueueFilter', () {
    test('reads the facility and page from the address', () {
      final filter = ApprovalQueueFilter.fromQuery(
        const ListQuery(pageIndex: 2).withFacet('facility', '5'),
      );

      expect(filter, const ApprovalQueueFilter(facilityId: 5, pageIndex: 2));
      expect(filter.activeFilterCount, 1);
    });

    test('ignores a non-numeric facility', () {
      final filter = ApprovalQueueFilter.fromQuery(
        const ListQuery().withFacet('facility', 'x'),
      );

      expect(filter, const ApprovalQueueFilter());
      expect(filter.activeFilterCount, 0);
    });
  });
}
