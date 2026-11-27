import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/entities/purchase_request.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_request_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/requests/purchase_request_detail_controller.dart';

import 'purchase_request_fixtures.dart';

class MockPurchaseRequestRepository extends Mock
    implements PurchaseRequestRepository {}

/// Spec 079 (T009).
void main() {
  late MockPurchaseRequestRepository repository;
  late ProviderContainer container;
  final provider = purchaseRequestDetailControllerProvider(212);

  setUp(() {
    repository = MockPurchaseRequestRepository();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        purchaseRequestRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  /// Keeps the autodispose family alive, as the screen does. Called after the
  /// stub, since listening builds the provider.
  void listen() => container.listen(provider, (_, _) {});

  test('loads the request by id', () async {
    when(() => repository.get(212)).thenAnswer((_) async => aRequest());
    listen();

    expect(await container.read(provider.future), aRequest());
    verify(() => repository.get(212)).called(1);
  });

  test('a missing request keeps its AppError', () async {
    when(
      () => repository.get(212),
    ).thenAnswer((_) async => throw const AppError.notFound());
    listen();

    await expectLater(
      container.read(provider.future),
      throwsA(isA<NotFoundError>()),
    );
    expect(container.read(provider).error, isA<NotFoundError>());
  });

  test('refresh() re-fetches the request', () async {
    when(() => repository.get(212)).thenAnswer((_) async => aRequest());
    listen();
    await container.read(provider.future);
    when(() => repository.get(212)).thenAnswer(
      (_) async => aRequest(status: PurchaseRequestStatus.submitted),
    );

    await container.read(provider.notifier).refresh();

    expect(
      container.read(provider).value?.status,
      PurchaseRequestStatus.submitted,
    );
    verify(() => repository.get(212)).called(2);
  });

  test('put() shows the server answer to a write', () async {
    when(() => repository.get(212)).thenAnswer((_) async => aRequest());
    listen();
    await container.read(provider.future);

    container
        .read(provider.notifier)
        .put(aRequest(status: PurchaseRequestStatus.approved, serial: 571));

    expect(container.read(provider).value?.serial, 571);
    expect(
      container.read(provider).value?.status,
      PurchaseRequestStatus.approved,
    );
    verify(() => repository.get(212)).called(1);
  });
}
