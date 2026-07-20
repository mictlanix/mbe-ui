import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
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

  group('UserFilterController', () {
    test('starts with an empty search', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      expect(container.read(userFilterControllerProvider).search, '');
    });

    test('searchChanged updates the search field', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      container
          .read(userFilterControllerProvider.notifier)
          .searchChanged('jdoe');

      expect(container.read(userFilterControllerProvider).search, 'jdoe');
    });
  });

  group('UsersController', () {
    UserSummary user(String userId) => UserSummary(
      userId: userId,
      email: '$userId@example.com',
      administrator: false,
      status: EntityStatus.active,
    );

    test('build() fetches page 0 with the current filter', () async {
      when(
        () => userRepository.list(search: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => UserListResult(items: [user('jdoe')], total: 1),
      );

      final container = makeContainer();
      addTearDown(container.dispose);

      final page = await container.read(usersControllerProvider.future);

      expect(page.items.single.userId, 'jdoe');
      expect(page.pageIndex, 0);
      expect(page.total, 1);
    });

    test('changing the filter re-fetches page 0 with the new search', () async {
      when(
        () => userRepository.list(search: null, skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => UserListResult(items: [user('jdoe')], total: 1),
      );

      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(usersControllerProvider.future);

      when(
        () => userRepository.list(search: 'admin', skip: 0, limit: 20),
      ).thenAnswer(
        (_) async => UserListResult(items: [user('admin')], total: 1),
      );
      container
          .read(userFilterControllerProvider.notifier)
          .searchChanged('admin');

      final page = await container.read(usersControllerProvider.future);
      expect(page.items.single.userId, 'admin');
    });

    test(
      'goToPage fetches the requested page with skip = pageIndex * 20',
      () async {
        when(
          () => userRepository.list(search: null, skip: 0, limit: 20),
        ).thenAnswer(
          (_) async => UserListResult(items: [user('jdoe')], total: 21),
        );

        final container = makeContainer();
        addTearDown(container.dispose);
        await container.read(usersControllerProvider.future);

        when(
          () => userRepository.list(search: null, skip: 20, limit: 20),
        ).thenAnswer(
          (_) async => UserListResult(items: [user('admin')], total: 21),
        );

        await container.read(usersControllerProvider.notifier).goToPage(1);

        final page = container.read(usersControllerProvider).value!;
        expect(page.items.single.userId, 'admin');
        expect(page.pageIndex, 1);
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

  group('UserFormController.save (create mode)', () {
    test(
      'calls create then update-with-privileges when privileges present',
      () async {
        when(
          () => userRepository.create(
            userId: any(named: 'userId'),
            password: any(named: 'password'),
            email: any(named: 'email'),
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
        notifier.privilegeChanged(SystemObject.users, 2);

        await notifier.save();

        verify(
          () => userRepository.create(
            userId: 'jdoe',
            password: 'secret1',
            email: 'jdoe@example.com',
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
