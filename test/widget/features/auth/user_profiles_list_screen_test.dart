import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/data/user_profile_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/user_profile.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_profile_repository.dart';
import 'package:mbe_ui/features/auth/presentation/admin/user_profiles_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserProfileRepository extends Mock
    implements UserProfileRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

const _adminUser = User(
  userId: 'admin',
  email: 'admin@example.com',
  administrator: true,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

/// Holds Users:read, but not the administrator flag — the case that would
/// slip through if this screen were ever gated on a SystemObject instead of
/// `isAdministrator` (research.md §2).
const _nonAdminUser = User(
  userId: 'jdoe',
  email: 'jdoe@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

const _testProfiles = [
  UserProfileSummary(
    userProfileId: 1,
    name: 'Cashier',
    description: 'Front counter',
    status: EntityStatus.active,
  ),
  UserProfileSummary(
    userProfileId: 2,
    name: 'Warehouse Clerk',
    status: EntityStatus.active,
  ),
];

void main() {
  late MockAuthRepository authRepository;
  late MockUserProfileRepository userProfileRepository;
  late MockTokenStorage tokenStorage;

  setUp(() {
    authRepository = MockAuthRepository();
    userProfileRepository = MockUserProfileRepository();
    tokenStorage = MockTokenStorage();
    when(() => tokenStorage.read()).thenAnswer((_) async => 'test-token');
    when(
      () => userProfileRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          UserProfileListResult(items: _testProfiles, total: _testProfiles.length),
    );
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    ListQuery query = const ListQuery(),
  }) async {
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);

    final router = GoRouter(
      initialLocation: query.toUri('/user-profiles').toString(),
      routes: [
        GoRoute(
          path: '/user-profiles',
          builder: (_, state) => Scaffold(
            body: UserProfilesListScreen(query: ListQuery.fromUri(state.uri)),
          ),
        ),
        GoRoute(
          path: '/user-profiles/new',
          builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
        ),
        GoRoute(
          path: '/user-profiles/:profileId',
          builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          userProfileRepositoryProvider.overrideWithValue(
            userProfileRepository,
          ),
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

  testWidgets('shows the profile catalog for an administrator (FR-001)', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _adminUser);

    expect(find.text('Cashier'), findsOneWidget);
    expect(find.text('Warehouse Clerk'), findsOneWidget);
  });

  testWidgets('shows New profile button for an administrator', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _adminUser);

    expect(find.byKey(const Key('new_user_profile_button')), findsOneWidget);
  });

  testWidgets(
    'hides New profile button for a non-administrator '
    '(FR-034, SC-007)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _nonAdminUser);

      expect(find.byKey(const Key('new_user_profile_button')), findsNothing);
    },
  );

  testWidgets(
    'hides the Edit row action for a non-administrator',
    (tester) async {
      await pumpScreen(tester, signedInAs: _nonAdminUser);

      expect(
        find.descendant(
          of: find.byKey(const Key('user_profiles_table')),
          matching: find.byIcon(Icons.edit_outlined),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'an empty, genuinely unfiltered catalog (status=all) reads as "none '
    'yet", not an error',
    (tester) async {
      when(
        () => userProfileRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const UserProfileListResult(items: [], total: 0));

      // spec 035 FR-001/FR-002/FR-004: an empty query no longer means
      // "unfiltered" — it now carries the default-applied Active status.
      // Reaching the genuinely unfiltered state (every status) is the
      // explicit `status=all` case, tested next below for the empty-result
      // ambiguity that default introduces.
      await pumpScreen(
        tester,
        signedInAs: _adminUser,
        query: const ListQuery(
          facets: {
            'status': ['all'],
          },
        ),
      );

      expect(
        find.text('No user profiles yet — create the first one.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'an empty result under the default-applied Active status shows the '
    'shared "no matches" view, not "none yet" — the default filter could '
    'be hiding inactive/archived records the client cannot see (spec 035 '
    'FR-003/FR-006, Edge Cases)',
    (tester) async {
      when(
        () => userProfileRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const UserProfileListResult(items: [], total: 0));

      await pumpScreen(tester, signedInAs: _adminUser);

      expect(find.byKey(const Key('list_state_filtered_empty')), findsOneWidget);
      expect(
        find.text('No user profiles yet — create the first one.'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'an empty, filtered catalog shows the shared "no matches" view, not '
    'the plain "none yet" empty state (FR-001, list-state-views contract)',
    (tester) async {
      when(
        () => userProfileRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const UserProfileListResult(items: [], total: 0));

      await pumpScreen(
        tester,
        signedInAs: _adminUser,
        query: const ListQuery(search: 'nonexistent'),
      );

      expect(find.byKey(const Key('list_state_filtered_empty')), findsOneWidget);
      expect(
        find.text('No user profiles yet — create the first one.'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'tapping a row opens the profile read-only, not the editable form',
    (tester) async {
      await pumpScreen(tester, signedInAs: _adminUser);

      await tester.tap(find.text('Cashier'));
      await tester.pumpAndSettle();

      expect(find.text('/user-profiles/1?view=true'), findsOneWidget);
    },
  );

  testWidgets('the Edit row action opens the profile editable form', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _adminUser);

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();

    expect(find.text('/user-profiles/1'), findsOneWidget);
  });

  testWidgets('a status facet in the URL is passed to the repository', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _adminUser,
      query: const ListQuery(
        facets: {
          'status': ['inactive'],
        },
      ),
    );

    verify(
      () => userProfileRepository.list(
        search: any(named: 'search'),
        status: EntityStatus.inactive,
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).called(greaterThanOrEqualTo(1));
  });

  testWidgets(
    'searching by name queries only on submit, not on every keystroke',
    (tester) async {
      await pumpScreen(tester, signedInAs: _adminUser);
      clearInteractions(userProfileRepository);

      await tester.enterText(
        find.byKey(const Key('user_profiles_search_field')),
        'cash',
      );
      await tester.pump();

      verifyNever(
        () => userProfileRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      verify(
        () => userProfileRepository.list(
          search: 'cash',
          // spec 035 FR-001/FR-002: an unmodified status facet now defaults
          // to Active, not "no filter".
          status: EntityStatus.active,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    },
  );
}
