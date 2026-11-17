import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_count_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_document_status.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_count_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/counts/inventory_count_detail_controller.dart';

import 'inventory_count_fixtures.dart';

class MockInventoryCountRepository extends Mock
    implements InventoryCountRepository {}

/// Spec 070 (T008).
void main() {
  late MockInventoryCountRepository repository;
  late ProviderContainer container;
  final provider = inventoryCountDetailControllerProvider(412);

  setUp(() {
    repository = MockInventoryCountRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        inventoryCountRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Keeps the autodispose family alive, as the screen does. Called after the
  /// stub, since listening builds the provider.
  void listen() => container.listen(provider, (_, _) {});

  test('loads the count by id', () async {
    when(() => repository.get(412)).thenAnswer((_) async => aCount());
    listen();

    expect(await container.read(provider.future), aCount());
    verify(() => repository.get(412)).called(1);
  });

  test('a missing count keeps its AppError', () async {
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

  test('refresh() re-fetches the count', () async {
    when(() => repository.get(412)).thenAnswer((_) async => aCount());
    listen();
    await container.read(provider.future);
    when(() => repository.get(412)).thenAnswer(
      (_) async => aCount(status: InventoryDocumentStatus.completed),
    );

    await container.read(provider.notifier).refresh();

    expect(
      container.read(provider).value?.status,
      InventoryDocumentStatus.completed,
    );
    verify(() => repository.get(412)).called(2);
  });
}
