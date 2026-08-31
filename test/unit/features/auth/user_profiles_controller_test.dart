import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/data/user_profile_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/user_profile.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_profile_repository.dart';
import 'package:mbe_ui/features/auth/presentation/admin/user_profiles_controller.dart';

class MockUserProfileRepository extends Mock
    implements UserProfileRepository {}

void main() {
  setUpAll(() {
    // `UserProfileRepository.create`'s `status` parameter is non-nullable
    // (`EntityStatus status = EntityStatus.active`), so mocktail needs a
    // registered fallback to satisfy `any(named: 'status')` in the stubs
    // below.
    registerFallbackValue(EntityStatus.active);
  });

  late MockUserProfileRepository repository;

  setUp(() {
    repository = MockUserProfileRepository();
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [userProfileRepositoryProvider.overrideWithValue(repository)],
    );
  }

  group('UserProfileFilter.fromQuery', () {
    test('derives every field from a ListQuery', () {
      final filter = UserProfileFilter.fromQuery(
        const ListQuery(
          search: 'cash',
          pageIndex: 2,
          facets: {
            'status': ['inactive'],
          },
        ),
      );

      expect(filter.search, 'cash');
      expect(filter.status, EntityStatus.inactive);
      expect(filter.pageIndex, 2);
    });

    test('defaults from an empty ListQuery', () {
      final filter = UserProfileFilter.fromQuery(const ListQuery());

      expect(filter.search, '');
      // spec 035 FR-001/FR-002: an absent status facet now defaults to
      // Active, not "no filter" — the "All" choice is the explicit
      // `status=all` case, covered separately below.
      expect(filter.status, EntityStatus.active);
      expect(filter.pageIndex, 0);
    });

    test('an explicit "all" status clears the default (FR-004)', () {
      final filter = UserProfileFilter.fromQuery(
        const ListQuery(
          facets: {
            'status': ['all'],
          },
        ),
      );

      expect(filter.status, isNull);
    });

    test('an unparseable status degrades to the Active default, not a throw', () {
      final filter = UserProfileFilter.fromQuery(
        const ListQuery(
          facets: {
            'status': ['not-a-real-status'],
          },
        ),
      );

      expect(filter.status, EntityStatus.active);
    });
  });

  group('UserProfileFilterBadge.activeFilterCount', () {
    test('0 when nothing is set', () {
      expect(const UserProfileFilter().activeFilterCount, 0);
    });

    test('1 when status is set', () {
      expect(
        const UserProfileFilter(status: EntityStatus.inactive)
            .activeFilterCount,
        1,
      );
    });
  });

  group('UserProfilesController (a family keyed by UserProfileFilter)', () {
    UserProfileSummary profile(int id, String name) => UserProfileSummary(
      userProfileId: id,
      name: name,
      status: EntityStatus.active,
    );

    test('build(filter) fetches page 0 with the given filter', () async {
      when(
        () =>
            repository.list(search: null, status: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async =>
            UserProfileListResult(items: [profile(1, 'Cashier')], total: 1),
      );

      final container = makeContainer();
      addTearDown(container.dispose);

      const filter = UserProfileFilter();
      final page = await container.read(
        userProfilesControllerProvider(filter).future,
      );

      expect(page.items.single.name, 'Cashier');
      expect(page.pageIndex, 0);
      expect(page.total, 1);
    });

    test('a status facet in the filter is passed to the repository', () async {
      when(
        () => repository.list(
          search: null,
          status: EntityStatus.inactive,
          skip: 0,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async =>
            UserProfileListResult(items: [profile(1, 'Retired')], total: 1),
      );

      final container = makeContainer();
      addTearDown(container.dispose);

      const filter = UserProfileFilter(status: EntityStatus.inactive);
      final page = await container.read(
        userProfilesControllerProvider(filter).future,
      );

      expect(page.items.single.name, 'Retired');
      verify(
        () => repository.list(
          search: null,
          status: EntityStatus.inactive,
          skip: 0,
          limit: 20,
        ),
      ).called(1);
    });

    test('a different pageIndex maps to skip = pageIndex * pageSize', () async {
      when(
        () =>
            repository.list(search: null, status: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async =>
            UserProfileListResult(items: [profile(1, 'Cashier')], total: 21),
      );
      when(
        () =>
            repository.list(search: null, status: null, skip: 20, limit: 20),
      ).thenAnswer(
        (_) async => UserProfileListResult(
          items: [profile(2, 'Warehouse Clerk')],
          total: 21,
        ),
      );

      final container = makeContainer();
      addTearDown(container.dispose);

      final page0 = await container.read(
        userProfilesControllerProvider(const UserProfileFilter()).future,
      );
      final page1 = await container.read(
        userProfilesControllerProvider(
          const UserProfileFilter(pageIndex: 1),
        ).future,
      );

      expect(page0.items.single.name, 'Cashier');
      expect(page1.items.single.name, 'Warehouse Clerk');
      expect(page1.pageIndex, 1);
    });
  });

  group('UserProfileFormController.privilegeChanged', () {
    test('adds a new privilege when rawValue != 0', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        userProfileFormControllerProvider.notifier,
      );
      notifier.privilegeChanged(SystemObject.users, 2); // read

      final privileges = container
          .read(userProfileFormControllerProvider)
          .privileges;
      expect(privileges, hasLength(1));
      expect(privileges.single.systemObject, SystemObject.users);
      expect(privileges.single.rawValue, 2);
    });

    test('removes a privilege when rawValue is 0 — a profile stores an '
        'entry only for what it grants (FR-010)', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        userProfileFormControllerProvider.notifier,
      );
      notifier.privilegeChanged(SystemObject.users, 2);
      notifier.privilegeChanged(SystemObject.users, 0);

      final privileges = container
          .read(userProfileFormControllerProvider)
          .privileges;
      expect(privileges, isEmpty);
    });
  });

  group('UserProfileFormController.save (create mode)', () {
    test('shows nameRequired when name is empty', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(
        userProfileFormControllerProvider.notifier,
      );

      await notifier.save();

      expect(
        container.read(userProfileFormControllerProvider).error,
        UserProfileFormErrorCode.nameRequired,
      );
      verifyNever(
        () => repository.create(
          name: any(named: 'name'),
          description: any(named: 'description'),
          status: any(named: 'status'),
          privileges: any(named: 'privileges'),
        ),
      );
    });

    test('calls repository.create with the entered name and privileges', () async {
      when(
        () => repository.create(
          name: any(named: 'name'),
          description: any(named: 'description'),
          status: any(named: 'status'),
          privileges: any(named: 'privileges'),
        ),
      ).thenAnswer(
        (_) async => const UserProfile(
          userProfileId: 5,
          name: 'Cashier',
          status: EntityStatus.active,
          privileges: [],
        ),
      );

      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(
        userProfileFormControllerProvider.notifier,
      );

      notifier.nameChanged('Cashier');
      notifier.privilegeChanged(SystemObject.users, 2);

      await notifier.save();

      verify(
        () => repository.create(
          name: 'Cashier',
          description: any(named: 'description'),
          status: any(named: 'status'),
          privileges: any(named: 'privileges'),
        ),
      ).called(1);
      expect(container.read(userProfileFormControllerProvider).saved, isTrue);
    });

    test(
      'a duplicate-name conflict (case-insensitive) surfaces as a raw '
      'ValidationError message, input preserved (FR-013)',
      () async {
        when(
          () => repository.create(
            name: any(named: 'name'),
            description: any(named: 'description'),
            status: any(named: 'status'),
            privileges: any(named: 'privileges'),
          ),
        ).thenThrow(
          const AppError.validation([
            FieldError(loc: ['name'], msg: 'A profile named "Cashier" already exists', type: 'conflict'),
          ]),
        );

        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(
          userProfileFormControllerProvider.notifier,
        );
        notifier.nameChanged('cashier');

        await notifier.save();

        final state = container.read(userProfileFormControllerProvider);
        expect(state.error, 'A profile named "Cashier" already exists');
        expect(state.name, 'cashier');
      },
    );
  });

  group('UserProfileFormController.save (edit mode)', () {
    test('calls repository.update with the existing profileId', () async {
      when(
        () => repository.update(
          profileId: any(named: 'profileId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          status: any(named: 'status'),
          privileges: any(named: 'privileges'),
        ),
      ).thenAnswer(
        (_) async => const UserProfile(
          userProfileId: 5,
          name: 'Cashier',
          status: EntityStatus.inactive,
          privileges: [],
        ),
      );

      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(
        userProfileFormControllerProvider.notifier,
      );
      notifier.nameChanged('Cashier');
      notifier.statusChanged(EntityStatus.inactive);

      await notifier.save(existingProfileId: 5);

      verify(
        () => repository.update(
          profileId: 5,
          name: 'Cashier',
          description: any(named: 'description'),
          status: EntityStatus.inactive,
          privileges: any(named: 'privileges'),
        ),
      ).called(1);
      expect(container.read(userProfileFormControllerProvider).saved, isTrue);
    });
  });

  group('cache invalidation after a write (regression)', () {
    // Caught live during the 024 quickstart walkthrough: creating a profile
    // saved server-side but the catalog list still showed the old page,
    // because the list screen stays mounted underneath the pushed form —
    // its family provider keeps its listener and serves the cached page
    // until something invalidates it. `deleteProfile` did invalidate;
    // `save` did not, so a create/update looked like it had been lost.
    // Every other catalog form controller invalidates on all three writes.
    UserProfileSummary summary(int id, String name) => UserProfileSummary(
      userProfileId: id,
      name: name,
      status: EntityStatus.active,
    );

    /// Reads the list (establishing a cached page holding only `Cashier`),
    /// runs [write] against a server that now also has `Warehouse Clerk`,
    /// then reads again and returns what the list shows. Asserting on the
    /// visible rows rather than on a call count keeps this pinned to the
    /// behaviour the user reported — "the list didn't update" — instead of
    /// to Riverpod's internal refresh bookkeeping.
    Future<List<String>> listNamesAfter(
      Future<void> Function(UserProfileFormController notifier) write,
    ) async {
      var serverHasSecondProfile = false;
      when(
        () => repository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => UserProfileListResult(
          items: [
            summary(1, 'Cashier'),
            if (serverHasSecondProfile) summary(2, 'Warehouse Clerk'),
          ],
          total: serverHasSecondProfile ? 2 : 1,
        ),
      );

      final container = makeContainer();
      addTearDown(container.dispose);
      const filter = UserProfileFilter();
      final first = await container.read(
        userProfilesControllerProvider(filter).future,
      );
      expect(first.items.map((p) => p.name), ['Cashier']);

      serverHasSecondProfile = true;
      await write(
        container.read(userProfileFormControllerProvider.notifier),
      );

      final second = await container.read(
        userProfilesControllerProvider(filter).future,
      );
      return second.items.map((p) => p.name).toList();
    }

    test('a create invalidates the catalog list', () async {
      when(
        () => repository.create(
          name: any(named: 'name'),
          description: any(named: 'description'),
          status: any(named: 'status'),
          privileges: any(named: 'privileges'),
        ),
      ).thenAnswer(
        (_) async => const UserProfile(
          userProfileId: 5,
          name: 'Cashier',
          status: EntityStatus.active,
          privileges: [],
        ),
      );

      final names = await listNamesAfter((notifier) async {
        notifier.nameChanged('Cashier');
        await notifier.save();
      });

      expect(
        names,
        ['Cashier', 'Warehouse Clerk'],
        reason: 'the catalog list must show a newly created profile',
      );
    });

    test('an update invalidates the catalog list', () async {
      when(
        () => repository.update(
          profileId: any(named: 'profileId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          status: any(named: 'status'),
          privileges: any(named: 'privileges'),
        ),
      ).thenAnswer(
        (_) async => const UserProfile(
          userProfileId: 5,
          name: 'Cashier',
          status: EntityStatus.active,
          privileges: [],
        ),
      );

      final names = await listNamesAfter((notifier) async {
        notifier.nameChanged('Senior Cashier');
        await notifier.save(existingProfileId: 5);
      });

      expect(
        names,
        ['Cashier', 'Warehouse Clerk'],
        reason: 'the catalog list must re-read after an update',
      );
    });

    test('a delete invalidates the catalog list', () async {
      when(
        () => repository.delete(profileId: any(named: 'profileId')),
      ).thenAnswer((_) async {});

      final names = await listNamesAfter(
        (notifier) => notifier.deleteProfile(5),
      );

      expect(
        names,
        ['Cashier', 'Warehouse Clerk'],
        reason: 'the catalog list must re-read after a delete',
      );
    });

    test('a failed save does NOT invalidate — nothing changed server-side',
        () async {
      when(
        () => repository.create(
          name: any(named: 'name'),
          description: any(named: 'description'),
          status: any(named: 'status'),
          privileges: any(named: 'privileges'),
        ),
      ).thenThrow(const AppError.server(message: 'boom'));

      final names = await listNamesAfter((notifier) async {
        notifier.nameChanged('Cashier');
        await notifier.save();
      });

      expect(
        names,
        ['Cashier'],
        reason: 'a rejected save changed nothing, so the cached page stands',
      );
    });
  });

  group('UserProfileFormController.deleteProfile', () {
    test(
      'a referenced-by-users conflict leaves the profile in place and '
      'surfaces the server\'s reason (FR-014)',
      () async {
        when(() => repository.delete(profileId: any(named: 'profileId')))
            .thenThrow(
              const AppError.server(
                message: '3 users still reference this profile',
              ),
            );

        final container = makeContainer();
        addTearDown(container.dispose);
        final notifier = container.read(
          userProfileFormControllerProvider.notifier,
        );

        await notifier.deleteProfile(5);

        final state = container.read(userProfileFormControllerProvider);
        expect(state.deleted, isFalse);
        expect(state.error, UserProfileFormErrorCode.deleteFailed);
        expect(state.errorDetail, '3 users still reference this profile');
      },
    );

    test('a successful delete sets deleted', () async {
      when(
        () => repository.delete(profileId: any(named: 'profileId')),
      ).thenAnswer((_) async {});

      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(
        userProfileFormControllerProvider.notifier,
      );

      await notifier.deleteProfile(5);

      expect(container.read(userProfileFormControllerProvider).deleted, isTrue);
    });
  });
}
