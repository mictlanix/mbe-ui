import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/purchases/data/purchase_order_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_order_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_order_detail_controller.dart';

import 'purchase_order_fixtures.dart';

class MockPurchaseOrderRepository extends Mock
    implements PurchaseOrderRepository {}

/// Spec 080 research R11 (T007).
void main() {
  late MockPurchaseOrderRepository repository;
  late ProviderContainer container;
  final provider = purchaseOrderDetailControllerProvider(310);

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

  /// Keeps the autodispose family alive, as the screen does. Called after the
  /// stub, since listening builds the provider.
  void listen() => container.listen(provider, (_, _) {});

  Future<void> loaded() async {
    when(() => repository.get(310)).thenAnswer((_) async => anOrder());
    listen();
    await container.read(provider.future);
  }

  test('loads the order by id, with no receipts', () async {
    await loaded();

    expect(container.read(provider).value, anOrder());
    expect(container.read(provider).value?.receipts, isEmpty);
    verify(() => repository.get(310)).called(1);
  });

  test('a missing order keeps its AppError', () async {
    when(
      () => repository.get(310),
    ).thenAnswer((_) async => throw const AppError.notFound());
    listen();

    await expectLater(
      container.read(provider.future),
      throwsA(isA<NotFoundError>()),
    );
    expect(container.read(provider).error, isA<NotFoundError>());
  });

  test('refresh() re-fetches the order and drops the receipts', () async {
    await loaded();
    container
        .read(provider.notifier)
        .put(
          anOrder(
            status: InventoryDocumentStatus.completed,
            receipts: [aReceipt()],
          ),
        );
    when(() => repository.get(310)).thenAnswer(
      (_) async => anOrder(status: InventoryDocumentStatus.completed),
    );

    await container.read(provider.notifier).refresh();

    expect(
      container.read(provider).value?.status,
      InventoryDocumentStatus.completed,
    );
    expect(container.read(provider).value?.receipts, isEmpty);
    verify(() => repository.get(310)).called(2);
  });

  test('put() keeps the receipts held when the response has none', () async {
    await loaded();
    container
        .read(provider.notifier)
        .put(
          anOrder(
            status: InventoryDocumentStatus.completed,
            receipts: [aReceipt()],
          ),
        );

    container
        .read(provider.notifier)
        .put(
          anOrder(
            status: InventoryDocumentStatus.completed,
            supplierName: 'Otro',
          ),
        );

    expect(container.read(provider).value?.supplierName, 'Otro');
    expect(container.read(provider).value?.receipts, [aReceipt()]);
    verify(() => repository.get(310)).called(1);
  });

  test('put() replaces the receipts when the response has some', () async {
    await loaded();
    container.read(provider.notifier).put(anOrder(receipts: [aReceipt()]));

    container
        .read(provider.notifier)
        .put(anOrder(receipts: [aReceipt(id: 71), aReceipt(id: 72)]));

    expect(container.read(provider).value?.receipts.map((r) => r.id), [71, 72]);
  });
}
