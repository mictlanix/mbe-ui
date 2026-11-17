import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_transfer_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/inventory_transfer_detail_controller.dart';

import 'inventory_transfer_fixtures.dart';

class MockInventoryTransferRepository extends Mock
    implements InventoryTransferRepository {}

/// Spec 069 (T008).
void main() {
  late MockInventoryTransferRepository repository;
  late ProviderContainer container;
  final provider = inventoryTransferDetailControllerProvider(412);

  setUp(() {
    repository = MockInventoryTransferRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        inventoryTransferRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  void listen() => container.listen(provider, (_, _) {});

  test('loads the transfer by id', () async {
    when(() => repository.get(412)).thenAnswer((_) async => aTransfer());
    listen();

    expect(await container.read(provider.future), aTransfer());
    verify(() => repository.get(412)).called(1);
  });

  test('a missing transfer keeps its AppError', () async {
    when(
      () => repository.get(412),
    ).thenAnswer((_) async => throw const AppError.notFound());
    listen();

    await expectLater(
      container.read(provider.future),
      throwsA(isA<NotFoundError>()),
    );
    expect(container.read(provider).error, isA<NotFoundError>());
  });

  test('refresh() re-fetches and put() shows the given transfer', () async {
    when(() => repository.get(412)).thenAnswer((_) async => aTransfer());
    listen();
    await container.read(provider.future);
    when(() => repository.get(412)).thenAnswer(
      (_) async => aTransfer(status: InventoryTransferStatus.inTransit),
    );

    await container.read(provider.notifier).refresh();
    expect(
      container.read(provider).value?.status,
      InventoryTransferStatus.inTransit,
    );
    verify(() => repository.get(412)).called(2);

    container.read(provider.notifier).put(aTransfer(comment: 'put'));
    expect(container.read(provider).value?.comment, 'put');
  });
}
