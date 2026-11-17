import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/inventory/data/inventory_transfer_repository_impl.dart';
import 'package:mbe_ui/features/inventory/domain/repositories/inventory_transfer_repository.dart';
import 'package:mbe_ui/features/inventory/presentation/transfers/in_transit_controller.dart';

import 'inventory_transfer_fixtures.dart';

class MockInventoryTransferRepository extends Mock
    implements InventoryTransferRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

/// Spec 069 research R9 (T008, T031).
void main() {
  late MockInventoryTransferRepository repository;
  late ProviderContainer container;
  final provider = inTransitControllerProvider(2);

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

  test('loads the view for the facility', () async {
    when(
      () => repository.inTransit(facilityId: 2),
    ).thenAnswer((_) async => anInTransitView());
    listen();

    expect(await container.read(provider.future), anInTransitView());
    verify(() => repository.inTransit(facilityId: 2)).called(1);
  });

  test('a failure keeps its AppError', () async {
    when(
      () => repository.inTransit(facilityId: 2),
    ).thenAnswer((_) async => throw const AppError.network());
    listen();

    await expectLater(
      container.read(provider.future),
      throwsA(isA<NetworkError>()),
    );
    expect(container.read(provider).error, isA<NetworkError>());
  });

  test('refresh() re-fetches', () async {
    when(
      () => repository.inTransit(facilityId: 2),
    ).thenAnswer((_) async => anInTransitView());
    listen();
    await container.read(provider.future);
    when(
      () => repository.inTransit(facilityId: 2),
    ).thenAnswer((_) async => anInTransitView(facilityId: 9));

    await container.read(provider.notifier).refresh();

    expect(container.read(provider).value?.facilityId, 9);
    verify(() => repository.inTransit(facilityId: 2)).called(2);
  });

  group('inTransitFacilityProvider', () {
    Future<ProviderContainer> containerFor(int? facilityId) async {
      final c = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          authProvider.overrideWith(
            () => _FixedAuthNotifier(
              AuthState.authenticated(
                token: 't',
                user: User(
                  userId: 'u',
                  email: 'u@example.com',
                  administrator: false,
                  status: EntityStatus.active,
                  sessionVersion: 1,
                  settings: UserSettings(facilityId: facilityId),
                  privileges: const [],
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(c.dispose);
      await c.read(authProvider.future);
      return c;
    }

    test('starts on the facility from the session settings', () async {
      final c = await containerFor(2);
      expect(c.read(inTransitFacilityProvider), 2);
    });

    test('is null when the user has no facility', () async {
      final c = await containerFor(null);
      expect(c.read(inTransitFacilityProvider), isNull);
    });

    test('select changes it and reset returns to the own facility', () async {
      final c = await containerFor(2);
      c.listen(inTransitFacilityProvider, (_, _) {});

      c.read(inTransitFacilityProvider.notifier).select(9);
      expect(c.read(inTransitFacilityProvider), 9);

      c.read(inTransitFacilityProvider.notifier).reset();
      expect(c.read(inTransitFacilityProvider), 2);
    });
  });
}
