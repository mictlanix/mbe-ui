import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

const testUser = User(
  userId: 'jdoe',
  email: 'jdoe@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

void main() {
  late MockAuthRepository authRepository;
  late MockTokenStorage tokenStorage;
  late ProviderContainer container;

  setUp(() {
    authRepository = MockAuthRepository();
    tokenStorage = MockTokenStorage();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        tokenStorageProvider.overrideWithValue(tokenStorage),
      ],
    );
    addTearDown(container.dispose);

    when(() => tokenStorage.write(any())).thenAnswer((_) async {});
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
  });

  test('app-start restore: no stored token starts unauthenticated', () async {
    when(() => tokenStorage.read()).thenAnswer((_) async => null);

    final state = await container.read(authNotifierProvider.future);

    expect(state, const AuthState.unauthenticated());
    verifyNever(() => authRepository.me());
  });

  test(
    'app-start restore: valid token restores an authenticated session',
    () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => 'token123');
      when(() => authRepository.me()).thenAnswer((_) async => testUser);

      final state = await container.read(authNotifierProvider.future);

      expect(
        state,
        const AuthState.authenticated(token: 'token123', user: testUser),
      );
    },
  );

  test(
    'app-start restore: invalid token clears storage and reports sessionInvalid',
    () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => 'stale-token');
      when(() => authRepository.me()).thenThrow(const AppError.auth());

      final state = await container.read(authNotifierProvider.future);

      expect(
        state,
        const AuthState.unauthenticated(reason: SignOutReason.sessionInvalid),
      );
      verify(() => tokenStorage.clear()).called(1);
    },
  );

  test(
    'signIn success transitions to authenticated and persists the token',
    () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => null);
      when(
        () => authRepository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => 'new-token');
      when(() => authRepository.me()).thenAnswer((_) async => testUser);

      await container.read(authNotifierProvider.future);
      await container
          .read(authNotifierProvider.notifier)
          .signIn(username: 'jdoe', password: 'secret');

      final state = container.read(authNotifierProvider).value;
      expect(
        state,
        const AuthState.authenticated(token: 'new-token', user: testUser),
      );
      verify(() => tokenStorage.write('new-token')).called(1);
    },
  );

  test(
    'signIn failure transitions to unauthenticated(invalidCredentials)',
    () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => null);
      when(
        () => authRepository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AppError.auth());

      await container.read(authNotifierProvider.future);
      await container
          .read(authNotifierProvider.notifier)
          .signIn(username: 'jdoe', password: 'wrong');

      final state = container.read(authNotifierProvider).value;
      expect(
        state,
        const AuthState.unauthenticated(
          reason: SignOutReason.invalidCredentials,
        ),
      );
    },
  );

  test(
    'signOut clears the token and transitions to unauthenticated(signedOut)',
    () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => 'token123');
      when(() => authRepository.me()).thenAnswer((_) async => testUser);

      await container.read(authNotifierProvider.future);
      await container.read(authNotifierProvider.notifier).signOut();

      final state = container.read(authNotifierProvider).value;
      expect(
        state,
        const AuthState.unauthenticated(reason: SignOutReason.signedOut),
      );
      verify(() => tokenStorage.clear()).called(1);
    },
  );

  test(
    'a 401 on any request transitions to unauthenticated(sessionInvalid)',
    () async {
      when(() => tokenStorage.read()).thenAnswer((_) async => 'token123');
      when(() => authRepository.me()).thenAnswer((_) async => testUser);

      await container.read(authNotifierProvider.future);
      container.read(authNotifierProvider.notifier).handleSessionInvalid();

      final state = container.read(authNotifierProvider).value;
      expect(
        state,
        const AuthState.unauthenticated(reason: SignOutReason.sessionInvalid),
      );
      verify(() => tokenStorage.clear()).called(1);
    },
  );
}
