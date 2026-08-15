import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/data/user_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_repository.dart';
import 'package:mbe_ui/features/auth/presentation/admin/users_controller.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

const _testUser = User(
  userId: 'jdoe',
  email: 'jdoe@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

void main() {
  late MockUserRepository userRepository;
  late MockAuthRepository authRepository;
  late MockTokenStorage tokenStorage;

  setUp(() {
    userRepository = MockUserRepository();
    authRepository = MockAuthRepository();
    tokenStorage = MockTokenStorage();
    when(() => tokenStorage.read()).thenAnswer((_) async => null);
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(userRepository),
        authRepositoryProvider.overrideWithValue(authRepository),
        tokenStorageProvider.overrideWithValue(tokenStorage),
      ],
    );
  }

  group('UserFilter.fromQuery (017-ui-consistency-filters FR-011, FR-017)', () {
    test('derives every field from a ListQuery', () {
      final filter = UserFilter.fromQuery(
        const ListQuery(
          search: 'jdoe',
          pageIndex: 2,
          facets: {
            'status': ['inactive'],
          },
        ),
      );

      expect(filter.search, 'jdoe');
      expect(filter.status, EntityStatus.inactive);
      expect(filter.pageIndex, 2);
    });

    test('defaults from an empty ListQuery', () {
      final filter = UserFilter.fromQuery(const ListQuery());

      expect(filter.search, '');
      expect(filter.status, isNull);
      expect(filter.pageIndex, 0);
      expect(filter.profileId, isNull);
    });

    test(
      'decodes the profile facet into profileId (024-user-profiles FR-028)',
      () {
        final filter = UserFilter.fromQuery(
          const ListQuery(
            facets: {
              'profile': ['5'],
            },
          ),
        );

        expect(filter.profileId, 5);
      },
    );

    test('an unparseable profile facet degrades to null, not a throw', () {
      final filter = UserFilter.fromQuery(
        const ListQuery(
          facets: {
            'profile': ['not-a-number'],
          },
        ),
      );

      expect(filter.profileId, isNull);
    });
  });

  group('UserFilterBadge.activeFilterCount', () {
    test('0 when nothing is set', () {
      expect(const UserFilter().activeFilterCount, 0);
    });

    test('counts status and profileId independently', () {
      expect(
        const UserFilter(status: EntityStatus.inactive).activeFilterCount,
        1,
      );
      expect(const UserFilter(profileId: 5).activeFilterCount, 1);
      expect(
        const UserFilter(
          status: EntityStatus.inactive,
          profileId: 5,
        ).activeFilterCount,
        2,
      );
    });
  });

  group('UsersController (a family keyed by UserFilter)', () {
    UserSummary user(String userId) => UserSummary(
      userId: userId,
      email: '$userId@example.com',
      administrator: false,
      status: EntityStatus.active,
    );

    test('build(filter) fetches page 0 with the given filter', () async {
      when(
        () =>
            userRepository.list(search: null, status: null, profileId: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => UserListResult(items: [user('jdoe')], total: 1),
      );

      final container = makeContainer();
      addTearDown(container.dispose);

      const filter = UserFilter();
      final page = await container.read(usersControllerProvider(filter).future);

      expect(page.items.single.userId, 'jdoe');
      expect(page.pageIndex, 0);
      expect(page.total, 1);
    });

    test(
      'a status facet in the filter is passed to the repository (FR-011)',
      () async {
        when(
          () => userRepository.list(
            search: null,
            status: EntityStatus.inactive,
            profileId: null,
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => UserListResult(items: [user('jdoe')], total: 1),
        );

        final container = makeContainer();
        addTearDown(container.dispose);

        const filter = UserFilter(status: EntityStatus.inactive);
        final page = await container.read(
          usersControllerProvider(filter).future,
        );

        expect(page.items.single.userId, 'jdoe');
        verify(
          () => userRepository.list(
            search: null,
            status: EntityStatus.inactive,
            profileId: null,
            skip: 0,
            limit: 20,
          ),
        ).called(1);
      },
    );

    test(
      'a profile facet in the filter is passed to the repository '
      '(024-user-profiles FR-028)',
      () async {
        when(
          () => userRepository.list(
            search: null,
            status: null,
            profileId: 5,
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => UserListResult(items: [user('jdoe')], total: 1),
        );

        final container = makeContainer();
        addTearDown(container.dispose);

        const filter = UserFilter(profileId: 5);
        final page = await container.read(
          usersControllerProvider(filter).future,
        );

        expect(page.items.single.userId, 'jdoe');
        verify(
          () => userRepository.list(
            search: null,
            status: null,
            profileId: 5,
            skip: 0,
            limit: 20,
          ),
        ).called(1);
      },
    );

    test(
      'a different search maps to a different provider instance and query',
      () async {
        when(
          () => userRepository.list(
            search: null,
            status: null,
            profileId: null,
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => UserListResult(items: [user('jdoe')], total: 1),
        );
        when(
          () => userRepository.list(
            search: 'admin',
            status: null,
            profileId: null,
            skip: 0,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => UserListResult(items: [user('admin')], total: 1),
        );

        final container = makeContainer();
        addTearDown(container.dispose);

        final first = await container.read(
          usersControllerProvider(const UserFilter()).future,
        );
        final second = await container.read(
          usersControllerProvider(const UserFilter(search: 'admin')).future,
        );

        expect(first.items.single.userId, 'jdoe');
        expect(second.items.single.userId, 'admin');
      },
    );

    test('a different pageIndex maps to skip = pageIndex * pageSize', () async {
      when(
        () =>
            userRepository.list(search: null, status: null, profileId: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => UserListResult(items: [user('jdoe')], total: 21),
      );
      when(
        () => userRepository.list(
          search: null,
          status: null,
          profileId: null,
          skip: 20,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => UserListResult(items: [user('admin')], total: 21),
      );

      final container = makeContainer();
      addTearDown(container.dispose);

      final page0 = await container.read(
        usersControllerProvider(const UserFilter()).future,
      );
      final page1 = await container.read(
        usersControllerProvider(const UserFilter(pageIndex: 1)).future,
      );

      expect(page0.items.single.userId, 'jdoe');
      expect(page0.pageIndex, 0);
      expect(page1.items.single.userId, 'admin');
      expect(page1.pageIndex, 1);
    });

    test(
      'invalidating the provider re-fetches the SAME page rather than '
      'resetting to page 0 (017-ui-consistency-filters FR-025, research §3)',
      () async {
        const filter = UserFilter(pageIndex: 1);
        when(
          () => userRepository.list(
            search: null,
            status: null,
            profileId: null,
            skip: 20,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => UserListResult(items: [user('admin')], total: 21),
        );

        final container = makeContainer();
        addTearDown(container.dispose);
        await container.read(usersControllerProvider(filter).future);

        when(
          () => userRepository.list(
            search: null,
            status: null,
            profileId: null,
            skip: 20,
            limit: 20,
          ),
        ).thenAnswer(
          (_) async => UserListResult(items: [user('root')], total: 21),
        );
        container.invalidate(usersControllerProvider(filter));

        final refreshed = await container.read(
          usersControllerProvider(filter).future,
        );
        expect(refreshed.pageIndex, 1);
        expect(refreshed.items.single.userId, 'root');
      },
    );
  });

  group('UserFormController.privilegeChanged', () {
    test('adds a new privilege when rawValue != 0', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userFormControllerProvider.notifier);
      notifier.privilegeChanged(SystemObject.users, 2); // read

      final privileges = container.read(userFormControllerProvider).privileges;
      expect(privileges, hasLength(1));
      expect(privileges.single.systemObject, SystemObject.users);
      expect(privileges.single.rawValue, 2);
    });

    test('updates an existing privilege', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userFormControllerProvider.notifier);
      notifier.privilegeChanged(SystemObject.users, 2);
      notifier.privilegeChanged(SystemObject.users, 6); // read+update

      final privileges = container.read(userFormControllerProvider).privileges;
      expect(privileges, hasLength(1));
      expect(privileges.single.rawValue, 6);
    });

    test('removes a privilege when rawValue is 0', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userFormControllerProvider.notifier);
      notifier.privilegeChanged(SystemObject.users, 2);
      notifier.privilegeChanged(SystemObject.users, 0);

      final privileges = container.read(userFormControllerProvider).privileges;
      expect(privileges, isEmpty);
    });
  });

  group('users list cache invalidation after a write (regression)', () {
    // Found live during the 024 quickstart walkthrough: creating a user
    // saved server-side but the users list still showed the old page. The
    // list screen stays mounted underneath the pushed form, so its family
    // provider keeps its listener and serves the cached page until
    // something invalidates it. `deleteUser` and `applyProfile` did
    // invalidate; `save` did not — so a newly created account (and the
    // Perfil column that 024 added) looked like it had been lost.
    //
    // Pre-dates spec 024 (verified at f597768) but is asserted here
    // because 024's origin column is what makes it user-visible.
    UserSummary summary(String id) => UserSummary(
      userId: id,
      email: '$id@example.com',
      administrator: false,
      status: EntityStatus.active,
    );

    /// Reads the list (caching a page holding only `jdoe`), runs [write]
    /// against a server that now also has `newbie`, then reads again and
    /// returns what the list shows. Asserts on the visible rows rather
    /// than a call count, so it stays pinned to the observable symptom.
    Future<List<String>> listIdsAfter(
      Future<void> Function(UserFormController notifier) write,
    ) async {
      var serverHasSecondUser = false;
      when(
        () => userRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          profileId: any(named: 'profileId'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => UserListResult(
          items: [
            summary('jdoe'),
            if (serverHasSecondUser) summary('newbie'),
          ],
          total: serverHasSecondUser ? 2 : 1,
        ),
      );

      final container = makeContainer();
      addTearDown(container.dispose);
      const filter = UserFilter();
      final first = await container.read(
        usersControllerProvider(filter).future,
      );
      expect(first.items.map((u) => u.userId), ['jdoe']);

      serverHasSecondUser = true;
      await write(container.read(userFormControllerProvider.notifier));

      final second = await container.read(
        usersControllerProvider(filter).future,
      );
      return second.items.map((u) => u.userId).toList();
    }

    test('a create invalidates the users list', () async {
      when(
        () => userRepository.create(
          userId: any(named: 'userId'),
          password: any(named: 'password'),
          email: any(named: 'email'),
          employeeId: any(named: 'employeeId'),
          profileId: any(named: 'profileId'),
        ),
      ).thenAnswer((_) async => _testUser);

      final ids = await listIdsAfter((notifier) async {
        notifier.userIdChanged('newbie');
        notifier.passwordChanged('secret1');
        notifier.emailChanged('newbie@example.com');
        notifier.employeeSelected(7, 'Jane Doe');
        await notifier.save();
      });

      expect(
        ids,
        ['jdoe', 'newbie'],
        reason: 'the users list must show a newly created account',
      );
    });

    test('an update invalidates the users list', () async {
      when(
        () => userRepository.update(
          userId: any(named: 'userId'),
          email: any(named: 'email'),
          employeeId: any(named: 'employeeId'),
          administrator: any(named: 'administrator'),
          status: any(named: 'status'),
          privileges: any(named: 'privileges'),
          settings: any(named: 'settings'),
        ),
      ).thenAnswer((_) async => _testUser);

      final ids = await listIdsAfter((notifier) async {
        notifier.emailChanged('updated@example.com');
        await notifier.save(existingUserId: 'jdoe');
      });

      expect(
        ids,
        ['jdoe', 'newbie'],
        reason: 'the users list must re-read after an update',
      );
    });

    test('a failed save does NOT invalidate — nothing changed server-side',
        () async {
      when(
        () => userRepository.create(
          userId: any(named: 'userId'),
          password: any(named: 'password'),
          email: any(named: 'email'),
          employeeId: any(named: 'employeeId'),
          profileId: any(named: 'profileId'),
        ),
      ).thenThrow(const AppError.server(message: 'boom'));

      final ids = await listIdsAfter((notifier) async {
        notifier.userIdChanged('newbie');
        notifier.passwordChanged('secret1');
        notifier.emailChanged('newbie@example.com');
        notifier.employeeSelected(7, 'Jane Doe');
        await notifier.save();
      });

      expect(
        ids,
        ['jdoe'],
        reason: 'a rejected save changed nothing, so the cached page stands',
      );
    });
  });

  group('UserFormController.save (create mode)', () {
    test(
      'with no profile chosen, calls create then update-with-privileges '
      'when privileges present — unchanged from before 024-user-profiles',
      () async {
        when(
          () => userRepository.create(
            userId: any(named: 'userId'),
            password: any(named: 'password'),
            email: any(named: 'email'),
            employeeId: any(named: 'employeeId'),
            profileId: any(named: 'profileId'),
          ),
        ).thenAnswer((_) async => _testUser);
        when(
          () => userRepository.update(
            userId: any(named: 'userId'),
            privileges: any(named: 'privileges'),
          ),
        ).thenAnswer((_) async => _testUser);

        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(userFormControllerProvider.notifier);

        notifier.userIdChanged('jdoe');
        notifier.passwordChanged('secret1');
        notifier.emailChanged('jdoe@example.com');
        notifier.employeeSelected(7, 'Jane Doe');
        notifier.privilegeChanged(SystemObject.users, 2);

        await notifier.save();

        verify(
          () => userRepository.create(
            userId: 'jdoe',
            password: 'secret1',
            email: 'jdoe@example.com',
            employeeId: 7,
            profileId: null,
          ),
        ).called(1);
        verify(
          () => userRepository.update(
            userId: 'jdoe',
            privileges: any(named: 'privileges'),
          ),
        ).called(1);
        expect(container.read(userFormControllerProvider).saved, isTrue);
      },
    );

    test(
      'with a profile chosen, calls create with that profileId and skips '
      'the follow-up privileges PUT entirely, even with a non-empty grid '
      '(024-user-profiles research.md §7 — the single most damaging slip '
      'this feature could ship with)',
      () async {
        when(
          () => userRepository.create(
            userId: any(named: 'userId'),
            password: any(named: 'password'),
            email: any(named: 'email'),
            employeeId: any(named: 'employeeId'),
            profileId: any(named: 'profileId'),
          ),
        ).thenAnswer((_) async => _testUser);

        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(userFormControllerProvider.notifier);

        notifier.userIdChanged('jdoe');
        notifier.passwordChanged('secret1');
        notifier.emailChanged('jdoe@example.com');
        notifier.employeeSelected(7, 'Jane Doe');
        // Hand-ticked despite a profile being chosen — must not reach the
        // server, since the profile already determines the full set.
        notifier.privilegeChanged(SystemObject.users, 2);
        notifier.profileSelected(5, 'Cashier');

        await notifier.save();

        verify(
          () => userRepository.create(
            userId: 'jdoe',
            password: 'secret1',
            email: 'jdoe@example.com',
            employeeId: 7,
            profileId: 5,
          ),
        ).called(1);
        verifyNever(
          () => userRepository.update(
            userId: any(named: 'userId'),
            privileges: any(named: 'privileges'),
          ),
        );
        expect(container.read(userFormControllerProvider).saved, isTrue);
      },
    );

    test('shows error when email is empty', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(userFormControllerProvider.notifier);

      notifier.userIdChanged('jdoe');
      notifier.passwordChanged('secret1');
      // email left empty

      await notifier.save();

      expect(container.read(userFormControllerProvider).error, isNotNull);
      verifyNever(
        () => userRepository.create(
          userId: any(named: 'userId'),
          password: any(named: 'password'),
          email: any(named: 'email'),
          employeeId: any(named: 'employeeId'),
        ),
      );
    });
  });

  group('UserFormController.save (edit mode)', () {
    test('calls update with correct fields', () async {
      when(
        () => userRepository.update(
          userId: any(named: 'userId'),
          email: any(named: 'email'),
          employeeId: any(named: 'employeeId'),
          administrator: any(named: 'administrator'),
          status: any(named: 'status'),
          privileges: any(named: 'privileges'),
          settings: any(named: 'settings'),
        ),
      ).thenAnswer((_) async => _testUser);

      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(userFormControllerProvider.notifier);

      notifier.emailChanged('updated@example.com');
      notifier.statusChanged(EntityStatus.inactive);

      await notifier.save(existingUserId: 'jdoe');

      verify(
        () => userRepository.update(
          userId: 'jdoe',
          email: 'updated@example.com',
          status: EntityStatus.inactive,
          employeeId: any(named: 'employeeId'),
          administrator: any(named: 'administrator'),
          privileges: any(named: 'privileges'),
          settings: any(named: 'settings'),
        ),
      ).called(1);
      expect(container.read(userFormControllerProvider).saved, isTrue);
    });
  });
}
