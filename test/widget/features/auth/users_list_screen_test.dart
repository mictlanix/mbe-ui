import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/core/widgets/catalog_filter_bar.dart';
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
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

const _limitedUser = User(
  userId: 'jdoe',
  email: 'jdoe@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.users, rawValue: 2)],
);

const _testUsers = [
  UserSummary(
    userId: 'admin',
    email: 'admin@example.com',
    administrator: true,
    status: EntityStatus.active,
  ),
  UserSummary(
    userId: 'jdoe',
    email: 'jdoe@example.com',
    administrator: false,
    status: EntityStatus.active,
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
    when(
      () => userRepository.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => UserListResult(items: _testUsers, total: _testUsers.length),
    );
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
          // The shell owns the Scaffold in the app; the screen is body-only.
          home: const Scaffold(body: UsersListScreen()),
        ),
      ),
    );
    // Let AuthNotifier.build() restore session + UsersController.build() load
    await tester.pumpAndSettle();
  }

  /// Like [pumpScreen], but backed by a real `GoRouter` so tests can assert
  /// on where a row click/action navigates.
  Future<void> pumpScreenWithRouter(
    WidgetTester tester, {
    required User signedInAs,
  }) async {
    when(() => tokenStorage.read()).thenAnswer((_) async => 'test-token');
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: UsersListScreen()),
        ),
        GoRoute(
          path: '/users/:userId',
          builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          userRepositoryProvider.overrideWithValue(userRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows list of users for an administrator (FR-011)', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _adminUser);

    expect(find.text('admin'), findsOneWidget);
    expect(find.text('jdoe'), findsOneWidget);
  });

  testWidgets('shows New user button for administrator with create right', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _adminUser);

    expect(find.byKey(const Key('new_user_button')), findsOneWidget);
  });

  testWidgets(
    'the New user action sits beside the search bar as the primary action '
    '(spec 010 US4)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _adminUser);

      // Emphasised as primary (FilledButton) and rendered inside the filter
      // bar region, not the app bar (there is no app bar — shell owns it).
      expect(
        find.descendant(
          of: find.byType(CatalogFilterBar),
          matching: find.byKey(const Key('new_user_button')),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget(find.byKey(const Key('new_user_button'))),
        isA<FilledButton>(),
      );
    },
  );

  testWidgets(
    'hides New user button for user without Users.create permission',
    (tester) async {
      // _limitedUser has Users.read (rawValue=2) but not create
      await pumpScreen(tester, signedInAs: _limitedUser);

      expect(find.byKey(const Key('new_user_button')), findsNothing);
    },
  );

  testWidgets(
    'does not re-query while typing; queries only on submit (FR-010)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _adminUser);
      clearInteractions(userRepository);

      await tester.enterText(
        find.byKey(const Key('users_search_field')),
        'jdoe',
      );
      await tester.pump();

      verifyNever(
        () => userRepository.list(
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      verify(
        () => userRepository.list(search: 'jdoe', skip: 0, limit: 20),
      ).called(1);
    },
  );

  testWidgets('navigating to the next page fetches skip=20 (FR-002)', (
    tester,
  ) async {
    final fullPage = List.generate(
      20,
      (i) => UserSummary(
        userId: 'user$i',
        email: 'user$i@example.com',
        administrator: false,
        status: EntityStatus.active,
      ),
    );
    when(
      () => userRepository.list(
        search: any(named: 'search'),
        skip: 0,
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => UserListResult(items: fullPage, total: 21));
    when(
      () => userRepository.list(
        search: any(named: 'search'),
        skip: 20,
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => UserListResult(items: _testUsers, total: 21));

    await pumpScreen(tester, signedInAs: _adminUser);

    await tester.tap(find.byTooltip('Next page'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    verify(
      () => userRepository.list(search: null, skip: 20, limit: 20),
    ).called(1);
  });

  testWidgets(
    'shows only the Edit row action for an administrator (FR-001, FR-002)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _adminUser);

      final rowActionIcons = {Icons.edit_outlined, Icons.delete_outline};
      final icons = tester
          .widgetList<IconButton>(
            find.descendant(
              of: find.byKey(const Key('users_table')),
              matching: find.byType(IconButton),
            ),
          )
          .map((b) => (b.icon as Icon).icon)
          .where(rowActionIcons.contains)
          .toList();

      expect(icons, [Icons.edit_outlined, Icons.edit_outlined]);
    },
  );

  testWidgets('omits the Edit row action for a read-only user (FR-004)', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _limitedUser);

    final rowActionIcons = {Icons.edit_outlined, Icons.delete_outline};
    final icons = tester
        .widgetList<IconButton>(
          find.descendant(
            of: find.byKey(const Key('users_table')),
            matching: find.byType(IconButton),
          ),
        )
        .map((b) => (b.icon as Icon).icon)
        .where(rowActionIcons.contains)
        .toList();

    expect(icons, isEmpty);
  });

  testWidgets(
    'tapping a row opens the user read-only, not the editable form (FR-003)',
    (tester) async {
      await pumpScreenWithRouter(tester, signedInAs: _adminUser);

      await tester.tap(find.text('jdoe'));
      await tester.pumpAndSettle();

      expect(find.text('/users/jdoe?view=true'), findsOneWidget);
    },
  );

  testWidgets('the Edit row action opens the user editable form (FR-004)', (
    tester,
  ) async {
    await pumpScreenWithRouter(tester, signedInAs: _adminUser);

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();

    expect(find.text('/users/admin'), findsOneWidget);
  });
}
