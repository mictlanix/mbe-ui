import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_order_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_actions.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_controller.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_filter.dart';
import 'package:mbe_ui/features/purchases/presentation/to_purchase/to_purchase_selection.dart';

import 'purchase_order_fixtures.dart';

class MockPurchaseOrderRepository extends Mock
    implements PurchaseOrderRepository {}

/// Spec 080 research R5 (T011).
void main() {
  late MockPurchaseOrderRepository repository;
  late ProviderContainer container;
  const filter = ToPurchaseFilter();
  final selection = toPurchaseSelectionProvider(filter);

  setUp(() async {
    repository = MockPurchaseOrderRepository();
    when(
      () => repository.toPurchase(facilityId: any(named: 'facilityId')),
    ).thenAnswer((_) async => [aToPurchaseGroup()]);
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        purchaseOrderRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    // The screen keeps both alive.
    container.listen(selection, (_, _) {});
    await container.read(toPurchaseControllerProvider(null).future);
  });

  ToPurchaseSelection notifier() => container.read(selection.notifier);

  test('starts with nothing selected', () {
    expect(container.read(selection), isNull);
  });

  test('select picks a group, and another replaces it', () {
    notifier().select((supplierId: 12, facilityId: 2));
    expect(container.read(selection), (supplierId: 12, facilityId: 2));

    notifier().select((supplierId: 13, facilityId: 2));
    expect(container.read(selection), (supplierId: 13, facilityId: 2));
  });

  test('clear empties it', () {
    notifier().select((supplierId: 12, facilityId: 2));
    notifier().clear();
    expect(container.read(selection), isNull);
  });

  test('another page or facility starts with nothing selected', () {
    notifier().select((supplierId: 12, facilityId: 2));

    expect(
      container.read(
        toPurchaseSelectionProvider(const ToPurchaseFilter(pageIndex: 1)),
      ),
      isNull,
    );
    expect(
      container.read(
        toPurchaseSelectionProvider(const ToPurchaseFilter(facilityId: 2)),
      ),
      isNull,
    );
  });

  test('clears after a create, which reloads the groups', () async {
    when(
      () => repository.createFromGroup(supplierId: 12, facilityId: 2),
    ).thenAnswer((_) async => anOrder(id: 402));
    notifier().select((supplierId: 12, facilityId: 2));

    await container
        .read(purchaseOrderActionsProvider.notifier)
        .createFromGroup(supplierId: 12, facilityId: 2);
    await container.read(toPurchaseControllerProvider(null).future);

    expect(container.read(selection), isNull);
  });
}
