import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/inventory/data/inventory_receipt_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/entities/inventory_receipt.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_receipt_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/receipts/inventory_receipt_detail_controller.dart';

import 'inventory_receipt_fixtures.dart';

class MockInventoryReceiptRepository extends Mock
    implements InventoryReceiptRepository {}

/// Spec 067 (T010).
void main() {
  late MockInventoryReceiptRepository repository;
  late ProviderContainer container;
  final provider = inventoryReceiptDetailControllerProvider(318);

  setUp(() {
    repository = MockInventoryReceiptRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        inventoryReceiptRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Keeps the autodispose family alive, as the screen does. Called after the
  /// stub, since listening builds the provider.
  void listen() => container.listen(provider, (_, _) {});

  test('loads the receipt by id', () async {
    when(() => repository.get(318)).thenAnswer((_) async => aReceipt());
    listen();

    expect(await container.read(provider.future), aReceipt());
    verify(() => repository.get(318)).called(1);
  });

  test('a missing receipt keeps its AppError', () async {
    when(
      () => repository.get(318),
    ).thenAnswer((_) async => throw const AppError.notFound());
    listen();

    await expectLater(
      container.read(provider.future),
      throwsA(isA<NotFoundError>()),
    );
    expect(container.read(provider).error, isA<NotFoundError>());
  });

  test('refresh() re-fetches the receipt', () async {
    when(() => repository.get(318)).thenAnswer((_) async => aReceipt());
    listen();
    await container.read(provider.future);
    when(
      () => repository.get(318),
    ).thenAnswer((_) async => aReceipt(status: ReceiptStatus.completed));

    await container.read(provider.notifier).refresh();

    expect(container.read(provider).value?.status, ReceiptStatus.completed);
    verify(() => repository.get(318)).called(2);
  });
}
