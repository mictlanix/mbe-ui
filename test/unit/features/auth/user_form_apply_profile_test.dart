import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/data/user_profile_repository_impl.dart';
import 'package:mbe_ui/features/auth/data/user_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_profile_repository.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_repository.dart';
import 'package:mbe_ui/features/auth/presentation/admin/users_controller.dart';

class MockUserProfileRepository extends Mock
    implements UserProfileRepository {}

class MockUserRepository extends Mock implements UserRepository {}

/// A minimal fake so `usersControllerProvider`'s invalidation has a
/// repository behind it — `applyProfile` invalidates the list, and Riverpod
/// eagerly re-fetches any provider instance that already has a listener, so
/// the fake must answer rather than throw even though nothing in this file
/// reads the list itself.
UserListResult _emptyUserList() => const UserListResult(items: [], total: 0);

void main() {
  late MockUserProfileRepository userProfileRepository;
  late MockUserRepository userRepository;

  setUp(() {
    userProfileRepository = MockUserProfileRepository();
    userRepository = MockUserRepository();
    when(
      () => userRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => _emptyUserList());
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        userProfileRepositoryProvider.overrideWithValue(
          userProfileRepository,
        ),
        userRepositoryProvider.overrideWithValue(userRepository),
      ],
    );
  }

  const appliedUser = User(
    userId: 'jdoe',
    email: 'jdoe@example.com',
    administrator: false,
    status: EntityStatus.active,
    sessionVersion: 2,
    privileges: [
      Privilege(systemObject: SystemObject.products, rawValue: 2), // read
    ],
    profileId: 5,
    profileName: 'Cashier',
  );

  test(
    'on success, replaces form privileges/status/administrator/profileId/'
    'profileName wholesale from the response rather than merging with '
    'prior state (024-user-profiles data-model.md §4)',
    () async {
      when(
        () => userProfileRepository.apply(
          profileId: any(named: 'profileId'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => appliedUser);

      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(userFormControllerProvider.notifier);

      // Prior state the account held before the apply — none of this
      // should survive a successful apply.
      notifier.administratorChanged(true);
      notifier.privilegeChanged(SystemObject.vehicle, 15);
      notifier.privilegeChanged(SystemObject.warehouses, 15);

      await notifier.applyProfile(userId: 'jdoe', profileId: 5);

      final state = container.read(userFormControllerProvider);
      expect(state.administrator, isFalse);
      expect(state.profileId, 5);
      expect(state.profileName, 'Cashier');
      expect(state.privileges, hasLength(1));
      expect(state.privileges.single.systemObject, SystemObject.products);
      expect(state.error, isNull);
    },
  );

  test(
    'invalidates usersControllerProvider on success, so the next read '
    'genuinely re-fetches rather than serving a cached page',
    () async {
      when(
        () => userProfileRepository.apply(
          profileId: any(named: 'profileId'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => appliedUser);

      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(
        usersControllerProvider(const UserFilter()).future,
      );

      final notifier = container.read(userFormControllerProvider.notifier);
      await notifier.applyProfile(userId: 'jdoe', profileId: 5);

      // `invalidate` alone only marks the provider stale; reading it again
      // is what proves a real re-fetch happens rather than a cached page.
      await container.read(
        usersControllerProvider(const UserFilter()).future,
      );

      verify(
        () => userRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).called(2); // once on first read, once after invalidation
    },
  );

  test(
    'does NOT set `saved` on success — an apply stays on the same screen '
    '(FR-022), unlike an ordinary save which pops',
    () async {
      when(
        () => userProfileRepository.apply(
          profileId: any(named: 'profileId'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => appliedUser);

      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(userFormControllerProvider.notifier);

      await notifier.applyProfile(userId: 'jdoe', profileId: 5);

      expect(container.read(userFormControllerProvider).saved, isFalse);
    },
  );

  test(
    'on failure (e.g. inactive/missing profile), leaves prior state '
    'untouched (FR-023)',
    () async {
      when(
        () => userProfileRepository.apply(
          profileId: any(named: 'profileId'),
          userId: any(named: 'userId'),
        ),
      ).thenThrow(const AppError.notFound('Profile is inactive'));

      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(userFormControllerProvider.notifier);
      notifier.privilegeChanged(SystemObject.products, 2);

      await notifier.applyProfile(userId: 'jdoe', profileId: 999);

      final state = container.read(userFormControllerProvider);
      expect(state.privileges, hasLength(1));
      expect(state.privileges.single.systemObject, SystemObject.products);
      expect(state.error, UserFormErrorCode.applyFailed);
      expect(state.errorDetail, 'Profile is inactive');
    },
  );
}
