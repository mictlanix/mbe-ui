import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/data/user_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_repository.dart';
import 'package:mbe_ui/features/auth/presentation/admin/users_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

const _adminUser = User(
  userId: 'admin',
  email: 'admin@example.com',
  administrator: true,
  disabled: false,
  sessionVersion: 1,
  privileges: [],
);

const _limitedUser = User(
  userId: 'jdoe',
  email: 'jdoe@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.users, rawValue: 2)],
);

const _testUsers = [
  UserSummary(
    userId: 'admin',
    email: 'admin@example.com',
    administrator: true,
    disabled: false,
  ),
  UserSummary(
    userId: 'jdoe',
    email: 'jdoe@example.com',
    administrator: false,
    disabled: false,
  ),
];

void main() {
  late MockAuthRepository authRepository;
  late MockUserRepository userRepository;
  late MockTokenStorage tokenStorage;

  setUp(() {
    authRepository = MockAuthRepository();
    userRepository = MockUserRepository();
    tokenStorage = MockTokenStorage();
    when(() => tokenStorage.read()).thenAnswer((_) async => null);
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
    when(() => userRepository.list()).thenAnswer((_) async => _testUsers);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
  }) async {
    final token = 'test-token';
    when(() => tokenStorage.read()).thenAnswer((_) async => token);
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          userRepositoryProvider.overrideWithValue(userRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UsersListScreen(),
        ),
      ),
    );
    // Let AuthNotifier.build() restore session + UsersController.build() load
    await tester.pumpAndSettle();
  }

  testWidgets('shows list of users for an administrator (FR-011)',
      (tester) async {
    await pumpScreen(tester, signedInAs: _adminUser);

    expect(find.text('admin'), findsOneWidget);
    expect(find.text('jdoe'), findsOneWidget);
  });

  testWidgets('shows New user button for administrator with create right',
      (tester) async {
    await pumpScreen(tester, signedInAs: _adminUser);

    expect(find.byKey(const Key('new_user_button')), findsOneWidget);
  });

  testWidgets(
      'hides New user button for user without Users.create permission',
      (tester) async {
    // _limitedUser has Users.read (rawValue=2) but not create
    await pumpScreen(tester, signedInAs: _limitedUser);

    expect(find.byKey(const Key('new_user_button')), findsNothing);
  });
}
