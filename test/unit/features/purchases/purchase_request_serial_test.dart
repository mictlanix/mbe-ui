import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/purchases/data/purchase_request_repository_impl.dart';
import 'package:mbe_ui/features/purchases/domain/repositories/purchase_request_repository.dart';
import 'package:mbe_ui/features/purchases/presentation/orders/purchase_request_serial.dart';

import 'purchase_request_fixtures.dart';

class MockPurchaseRequestRepository extends Mock
    implements PurchaseRequestRepository {}

/// Spec 080 FR-016, research R8 (T010).
void main() {
  late MockPurchaseRequestRepository repository;
  late ProviderContainer container;

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

  test("resolves the request's folio", () async {
    when(
      () => repository.get(212),
    ).thenAnswer((_) async => aRequest(serial: 571));

    expect(
      await container.read(purchaseRequestSerialProvider(212).future),
      571,
    );
  });

  test('an unsubmitted draft has no folio', () async {
    when(() => repository.get(212)).thenAnswer((_) async => aRequest());

    expect(
      await container.read(purchaseRequestSerialProvider(212).future),
      isNull,
    );
  });

  for (final (name, error) in [
    ('a missing right (401)', const AppError.auth()),
    ('a missing right (403)', const AppError.server(statusCode: 403)),
    ('a request not found', const AppError.notFound()),
  ]) {
    test('$name resolves to null', () async {
      when(() => repository.get(212)).thenAnswer((_) async => throw error);

      expect(
        await container.read(purchaseRequestSerialProvider(212).future),
        isNull,
      );
    });
  }

  test('a transient failure is an error, and is not kept', () async {
    when(
      () => repository.get(212),
    ).thenAnswer((_) async => throw const AppError.network());

    await expectLater(
      container.read(purchaseRequestSerialProvider(212).future),
      throwsA(isA<NetworkError>()),
    );
    // Nobody watches it any more: it is dropped.
    await Future<void>.delayed(Duration.zero);
    expect(container.exists(purchaseRequestSerialProvider(212)), isFalse);

    when(
      () => repository.get(212),
    ).thenAnswer((_) async => aRequest(serial: 571));
    expect(
      await container.read(purchaseRequestSerialProvider(212).future),
      571,
    );
  });

  test('a fetched folio is kept once nobody watches it', () async {
    when(
      () => repository.get(212),
    ).thenAnswer((_) async => aRequest(serial: 571));

    await container.read(purchaseRequestSerialProvider(212).future);
    await Future<void>.delayed(Duration.zero);
    await container.read(purchaseRequestSerialProvider(212).future);

    verify(() => repository.get(212)).called(1);
  });

  test('two lookups of one id make one GET', () async {
    when(
      () => repository.get(212),
    ).thenAnswer((_) async => aRequest(serial: 571));

    await container.read(purchaseRequestSerialProvider(212).future);
    await container.read(purchaseRequestSerialProvider(212).future);

    verify(() => repository.get(212)).called(1);
  });
}
