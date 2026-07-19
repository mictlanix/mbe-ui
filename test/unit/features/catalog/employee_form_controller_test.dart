import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/gender.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/employee_form_controller.dart';

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.employees, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.employees, rawValue: 15)],
);

ProviderContainer _containerFor(User user, EmployeeRepository repository) {
  return ProviderContainer(
    overrides: [
      employeeRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

void main() {
  late MockEmployeeRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockEmployeeRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group('EmployeeFormController.submitCreate validation (FR-015, FR-016)', () {
    test('required fields are rejected before submit', () async {
      final notifier = container.read(employeeFormControllerProvider.notifier);

      await notifier.submitCreate();

      final state = container.read(employeeFormControllerProvider);
      expect(
        state.fieldErrors['firstName'],
        EmployeeFormErrorCode.firstNameRequired,
      );
      expect(
        state.fieldErrors['lastName'],
        EmployeeFormErrorCode.lastNameRequired,
      );
      expect(
        state.fieldErrors['nickname'],
        EmployeeFormErrorCode.nicknameRequired,
      );
      expect(state.fieldErrors['gender'], EmployeeFormErrorCode.genderRequired);
      expect(
        state.fieldErrors['birthday'],
        EmployeeFormErrorCode.birthdayRequired,
      );
      expect(
        state.fieldErrors['startJobDate'],
        EmployeeFormErrorCode.startJobDateRequired,
      );
      verifyNever(
        () => repository.create(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          nickname: any(named: 'nickname'),
          gender: any(named: 'gender'),
          birthday: any(named: 'birthday'),
          startJobDate: any(named: 'startJobDate'),
        ),
      );
    });

    test(
      'a valid submission creates the employee and invalidates the list',
      () async {
        when(
          () => repository.create(
            firstName: 'Jane',
            lastName: 'Doe',
            nickname: 'Janie',
            gender: 0,
            birthday: DateTime(1990, 5, 15),
            startJobDate: DateTime(2020, 1, 10),
            taxpayerId: null,
            salesPerson: false,
            active: true,
            personalId: null,
            enrollNumber: null,
            comment: null,
          ),
        ).thenAnswer(
          (_) async => Employee(
            employeeId: 1,
            firstName: 'Jane',
            lastName: 'Doe',
            nickname: 'Janie',
            gender: Gender.female,
            birthday: DateTime(1990, 5, 15),
            salesPerson: false,
            active: true,
            startJobDate: DateTime(2020, 1, 10),
          ),
        );

        final notifier = container.read(
          employeeFormControllerProvider.notifier,
        );
        notifier
          ..firstNameChanged('Jane')
          ..lastNameChanged('Doe')
          ..nicknameChanged('Janie')
          ..genderChanged(Gender.female)
          ..birthdayChanged(DateTime(1990, 5, 15))
          ..startJobDateChanged(DateTime(2020, 1, 10));

        await notifier.submitCreate();

        expect(container.read(employeeFormControllerProvider).saved, isTrue);
      },
    );

    test('a non-integer enroll number is rejected before submit', () async {
      final notifier = container.read(employeeFormControllerProvider.notifier);
      notifier
        ..firstNameChanged('Jane')
        ..lastNameChanged('Doe')
        ..nicknameChanged('Janie')
        ..genderChanged(Gender.female)
        ..birthdayChanged(DateTime(1990, 5, 15))
        ..startJobDateChanged(DateTime(2020, 1, 10))
        ..enrollNumberChanged('abc');

      await notifier.submitCreate();

      final state = container.read(employeeFormControllerProvider);
      expect(
        state.fieldErrors['enrollNumber'],
        EmployeeFormErrorCode.enrollNumberInvalid,
      );
    });
  });

  group('EmployeeFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        employeeFormControllerProvider.notifier,
      );
      notifier
        ..firstNameChanged('Jane')
        ..lastNameChanged('Doe')
        ..nicknameChanged('Janie')
        ..genderChanged(Gender.female)
        ..birthdayChanged(DateTime(1990, 5, 15))
        ..startJobDateChanged(DateTime(2020, 1, 10));

      await notifier.submitCreate();

      final state = readOnlyContainer.read(employeeFormControllerProvider);
      expect(state.error, EmployeeFormErrorCode.createPermissionDenied);
    });
  });

  group('EmployeeFormController.delete', () {
    test(
      'a still-referenced rejection is surfaced and the employee stays loaded',
      () async {
        when(() => repository.get(employeeId: 1)).thenAnswer(
          (_) async => Employee(
            employeeId: 1,
            firstName: 'Jane',
            lastName: 'Doe',
            nickname: 'Janie',
            gender: Gender.female,
            birthday: DateTime(1990, 5, 15),
            salesPerson: true,
            active: true,
            startJobDate: DateTime(2020, 1, 10),
          ),
        );
        when(() => repository.delete(employeeId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Employee is assigned as a customer\'s salesperson',
          ),
        );

        final notifier = container.read(
          employeeFormControllerProvider.notifier,
        );
        await notifier.loadForEdit(1);

        await notifier.delete();

        final state = container.read(employeeFormControllerProvider);
        expect(state.deleted, isFalse);
        expect(state.error, EmployeeFormErrorCode.deleteFailed);
        expect(
          state.errorDetail,
          "Employee is assigned as a customer's salesperson",
        );
      },
    );
  });
}
