import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_request_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_filter.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_requests_list_controller.dart';

import 'purchase_request_fixtures.dart';

class MockPurchaseRequestRepository extends Mock
    implements PurchaseRequestRepository {}

/// Spec 079 FR-002, research R9 (T008).
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

  When<Future<PurchaseRequestPage>> whenList() => when(
    () => repository.list(
      all: any(named: 'all'),
      status: any(named: 'status'),
      facilityId: any(named: 'facilityId'),
      warehouseId: any(named: 'warehouseId'),
      creatorId: any(named: 'creatorId'),
      serial: any(named: 'serial'),
      from: any(named: 'from'),
      to: any(named: 'to'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  );

  /// A fake server holding [requests], paged by `skip` and `limit`.
  void serve(List<PurchaseRequestSummary> requests) {
    whenList().thenAnswer((invocation) async {
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

  test('the filter reaches the repository, 20 per page', () async {
    serve([for (var i = 50; i >= 1; i--) aRequestSummary(id: i)]);
    final filter = PurchaseRequestsFilter(
      all: true,
      status: PurchaseRequestStatus.submitted,
      facilityId: 2,
      warehouseId: 3,
      creatorId: 5,
      from: DateTime(2026, 11, 1),
      to: DateTime(2026, 11, 30),
      serial: 571,
      pageIndex: 1,
    );

    final page = await container().read(
      purchaseRequestsListControllerProvider(filter).future,
    );

    expect(page.items, hasLength(20));
    expect(page.items.first.id, 30);
    expect(page.total, 50);
    expect(page.pageIndex, 1);
    verify(
      () => repository.list(
        all: true,
        status: PurchaseRequestStatus.submitted,
        facilityId: 2,
        warehouseId: 3,
        creatorId: 5,
        serial: 571,
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 11, 30),
        skip: 20,
        limit: 20,
      ),
    ).called(1);
  });

  test('a page past the end is clamped to the last page', () async {
    serve([for (var i = 25; i >= 1; i--) aRequestSummary(id: i)]);

    final page = await container().read(
      purchaseRequestsListControllerProvider(
        const PurchaseRequestsFilter(pageIndex: 7),
      ).future,
    );

    expect(page.pageIndex, 1);
    expect(page.items, hasLength(5));
  });

  test('a failure becomes an AsyncError carrying the AppError', () async {
    whenList().thenAnswer((_) async => throw const AppError.network());
    final c = container();
    final provider = purchaseRequestsListControllerProvider(
      const PurchaseRequestsFilter(),
    );
    c.listen(provider, (_, _) {});

    await expectLater(c.read(provider.future), throwsA(isA<NetworkError>()));
    expect(c.read(provider), isA<AsyncError<PurchaseRequestPage>>());
  });
}
