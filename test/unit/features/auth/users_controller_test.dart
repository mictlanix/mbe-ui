import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
  disabled: false,
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
    return ProviderContainer(overrides: [
      userRepositoryProvider.overrideWithValue(userRepository),
      authRepositoryProvider.overrideWithValue(authRepository),
      tokenStorageProvider.overrideWithValue(tokenStorage),
    ]);
  }

  group('UserFormController.privilegeChanged', () {
    test('adds a new privilege when rawValue != 0', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userFormControllerProvider.notifier);
      notifier.privilegeChanged(SystemObject.users, 2); // read

      final privileges =
          container.read(userFormControllerProvider).privileges;
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

      final privileges =
          container.read(userFormControllerProvider).privileges;
      expect(privileges, hasLength(1));
      expect(privileges.single.rawValue, 6);
    });

    test('removes a privilege when rawValue is 0', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userFormControllerProvider.notifier);
      notifier.privilegeChanged(SystemObject.users, 2);
      notifier.privilegeChanged(SystemObject.users, 0);

      final privileges =
          container.read(userFormControllerProvider).privileges;
      expect(privileges, isEmpty);
    });
  });

  group('UserFormController.save (create mode)', () {
    test('calls create then update-with-privileges when privileges present',
        () async {
      when(() => userRepository.create(
            userId: any(named: 'userId'),
            password: any(named: 'password'),
            email: any(named: 'email'),
          )).thenAnswer((_) async => _testUser);
      when(() => userRepository.update(
            userId: any(named: 'userId'),
            privileges: any(named: 'privileges'),
          )).thenAnswer((_) async => _testUser);

      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(userFormControllerProvider.notifier);

      notifier.userIdChanged('jdoe');
      notifier.passwordChanged('secret1');
      notifier.emailChanged('jdoe@example.com');
      notifier.privilegeChanged(SystemObject.users, 2);

      await notifier.save();

      verify(() => userRepository.create(
            userId: 'jdoe',
            password: 'secret1',
            email: 'jdoe@example.com',
          )).called(1);
      verify(() => userRepository.update(
            userId: 'jdoe',
            privileges: any(named: 'privileges'),
          )).called(1);
      expect(container.read(userFormControllerProvider).saved, isTrue);
    });

    test('shows error when email is empty', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(userFormControllerProvider.notifier);

      notifier.userIdChanged('jdoe');
      notifier.passwordChanged('secret1');
      // email left empty

      await notifier.save();

      expect(container.read(userFormControllerProvider).error, isNotNull);
      verifyNever(() => userRepository.create(
            userId: any(named: 'userId'),
            password: any(named: 'password'),
            email: any(named: 'email'),
          ));
    });
  });

  group('UserFormController.save (edit mode)', () {
    test('calls update with correct fields', () async {
      when(() => userRepository.update(
            userId: any(named: 'userId'),
            email: any(named: 'email'),
            employeeId: any(named: 'employeeId'),
            administrator: any(named: 'administrator'),
            disabled: any(named: 'disabled'),
            privileges: any(named: 'privileges'),
            settings: any(named: 'settings'),
          )).thenAnswer((_) async => _testUser);

      final container = makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(userFormControllerProvider.notifier);

      notifier.emailChanged('updated@example.com');
      notifier.disabledChanged(true);

      await notifier.save(existingUserId: 'jdoe');

      verify(() => userRepository.update(
            userId: 'jdoe',
            email: 'updated@example.com',
            disabled: true,
            employeeId: any(named: 'employeeId'),
            administrator: any(named: 'administrator'),
            privileges: any(named: 'privileges'),
            settings: any(named: 'settings'),
          )).called(1);
      expect(container.read(userFormControllerProvider).saved, isTrue);
    });
  });
}
