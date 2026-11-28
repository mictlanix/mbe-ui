import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_order.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_order_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_actions.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_filter.dart';

import 'purchase_order_fixtures.dart';

class MockPurchaseOrderRepository extends Mock
    implements PurchaseOrderRepository {}

List<ToPurchaseGroup> _groups(int n) => [
  for (var i = 0; i < n; i++) aToPurchaseGroup(supplierId: i + 1),
];

/// Spec 080 FR-007–FR-009, FR-031, research R5 (T011).
void main() {
  late MockPurchaseOrderRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockPurchaseOrderRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        purchaseOrderRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  group('ToPurchaseFilter', () {
    test('reads the facility and the page from the URL', () {
      final filter = ToPurchaseFilter.fromQuery(
        const ListQuery(pageIndex: 2).withFacet('facility', '4'),
      );
      expect(filter, const ToPurchaseFilter(facilityId: 4, pageIndex: 2));
      expect(filter.activeFilterCount, 1);
      expect(ToPurchaseFilter.fromQuery(filter.toQuery()), filter);
    });

    test('ignores a non-numeric facility', () {
      final filter = ToPurchaseFilter.fromQuery(
        const ListQuery().withFacet('facility', 'x'),
      );
      expect(filter.facilityId, isNull);
      expect(filter.activeFilterCount, 0);
    });
  });

  test('sends the facility to the repository', () async {
    when(
      () => repository.toPurchase(facilityId: 4),
    ).thenAnswer((_) async => _groups(1));

    await container.read(toPurchaseControllerProvider(4).future);

    verify(() => repository.toPurchase(facilityId: 4)).called(1);
  });

  test("keeps the groups in the server's order", () async {
    final groups = [
      aToPurchaseGroup(supplierId: 9),
      aToPurchaseGroup(supplierId: null, supplierName: null),
      aToPurchaseGroup(supplierId: 3),
    ];
    when(
      () => repository.toPurchase(facilityId: null),
    ).thenAnswer((_) async => groups);

    expect(
      await container.read(toPurchaseControllerProvider(null).future),
      groups,
    );
  });

  test('keeps an error as an AppError', () async {
    when(
      () => repository.toPurchase(facilityId: null),
    ).thenAnswer((_) async => throw const AppError.network());

    await expectLater(
      container.read(toPurchaseControllerProvider(null).future),
      throwsA(isA<NetworkError>()),
    );
  });

  group('toPurchasePage', () {
    test('no groups: page 0, empty', () {
      final page = toPurchasePage(const [], 3);
      expect(page.items, isEmpty);
      expect(page.pageIndex, 0);
      expect(page.total, 0);
    });

    test('20 groups fit one page; page 1 clamps back to it', () {
      final groups = _groups(20);
      expect(toPurchasePage(groups, 0).items, groups);
      final clamped = toPurchasePage(groups, 1);
      expect(clamped.pageIndex, 0);
      expect(clamped.items, groups);
    });

    test('21 groups: 20 on page 0, one on page 1', () {
      final groups = _groups(21);
      expect(toPurchasePage(groups, 0).items, groups.sublist(0, 20));
      final second = toPurchasePage(groups, 1);
      expect(second.items, [groups[20]]);
      expect(second.total, 21);
      expect(second.pageSize, 20);
    });

    test('45 groups: page 2 holds 5; page 9 clamps to page 2', () {
      final groups = _groups(45);
      expect(toPurchasePage(groups, 1).items, groups.sublist(20, 40));
      expect(toPurchasePage(groups, 2).items, groups.sublist(40));
      final clamped = toPurchasePage(groups, 9);
      expect(clamped.pageIndex, 2);
      expect(clamped.items, groups.sublist(40));
    });
  });

  group('invalidated by the order actions', () {
    setUp(() async {
      when(
        () => repository.toPurchase(facilityId: null),
      ).thenAnswer((_) async => _groups(1));
      // The screen keeps it alive.
      container.listen(toPurchaseControllerProvider(null), (_, _) {});
      await container.read(toPurchaseControllerProvider(null).future);
    });

    Future<void> reloaded() async {
      await container.read(toPurchaseControllerProvider(null).future);
      verify(() => repository.toPurchase(facilityId: null)).called(2);
    }

    test('after createFromGroup', () async {
      when(
        () => repository.createFromGroup(supplierId: 1, facilityId: 2),
      ).thenAnswer((_) async => anOrder(id: 402));

      await container
          .read(purchaseOrderActionsProvider.notifier)
          .createFromGroup(supplierId: 1, facilityId: 2);

      await reloaded();
    });

    test('after cancel', () async {
      when(() => repository.cancel(310)).thenAnswer((_) async => anOrder());

      await container.read(purchaseOrderActionsProvider.notifier).cancel(310);

      await reloaded();
    });

    test('not after a refusal', () async {
      when(
        () => repository.cancel(310),
      ).thenAnswer((_) async => throw const AppError.network());

      await container.read(purchaseOrderActionsProvider.notifier).cancel(310);
      await container.read(toPurchaseControllerProvider(null).future);

      verify(() => repository.toPurchase(facilityId: null)).called(1);
    });
  });
}
