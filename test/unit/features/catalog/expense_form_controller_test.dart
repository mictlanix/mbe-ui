import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/expense_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/expense.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/expense_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/expense_form_controller.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.expenses, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.expenses, rawValue: 15)],
);

ProviderContainer _containerFor(User user, ExpenseRepository repository) {
  return ProviderContainer(
    overrides: [
      expenseRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

void main() {
  late MockExpenseRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockExpenseRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group('ExpenseFormController field updates', () {
    test('nameChanged updates state and clears prior errors', () {
      final notifier = container.read(expenseFormControllerProvider.notifier);
      notifier.nameChanged('Rent');
      expect(container.read(expenseFormControllerProvider).name, 'Rent');
    });
  });

  group('ExpenseFormController.submitCreate validation (FR-010, FR-011)', () {
    test('an empty name is rejected before submit', () async {
      final notifier = container.read(expenseFormControllerProvider.notifier);

      await notifier.submitCreate();

      final state = container.read(expenseFormControllerProvider);
      expect(state.fieldErrors['name'], ExpenseFormErrorCode.nameRequired);
      verifyNever(
        () => repository.create(
          name: any(named: 'name'),
          comment: any(named: 'comment'),
        ),
      );
    });

    test(
      'a valid submission creates the expense and invalidates the list',
      () async {
        when(
          () => repository.create(name: 'Rent', comment: null),
        ).thenAnswer((_) async => const Expense(expenseId: 1, name: 'Rent'));

        final notifier = container.read(expenseFormControllerProvider.notifier);
        notifier.nameChanged('Rent');

        await notifier.submitCreate();

        expect(container.read(expenseFormControllerProvider).saved, isTrue);
      },
    );

    test('a server validation error surfaces as field errors', () async {
      when(
        () => repository.create(
          name: 'Rent',
          comment: any(named: 'comment'),
        ),
      ).thenThrow(
        const AppError.validation([
          FieldError(
            loc: ['body', 'name'],
            msg: 'Name already in use',
            type: 'value_error',
          ),
        ]),
      );

      final notifier = container.read(expenseFormControllerProvider.notifier);
      notifier.nameChanged('Rent');

      await notifier.submitCreate();

      final state = container.read(expenseFormControllerProvider);
      expect(state.fieldErrors['name'], 'Name already in use');
    });
  });

  group('ExpenseFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        expenseFormControllerProvider.notifier,
      );
      notifier.nameChanged('Rent');

      await notifier.submitCreate();

      final state = readOnlyContainer.read(expenseFormControllerProvider);
      expect(state.error, ExpenseFormErrorCode.createPermissionDenied);
      verifyNever(
        () => repository.create(
          name: any(named: 'name'),
          comment: any(named: 'comment'),
        ),
      );
    });
  });

  group('ExpenseFormController.submitUpdate', () {
    test('sends the changed fields when editing an existing expense', () async {
      when(
        () => repository.get(expenseId: 1),
      ).thenAnswer((_) async => const Expense(expenseId: 1, name: 'Rent'));
      when(
        () =>
            repository.update(expenseId: 1, name: 'Rent Increase', comment: ''),
      ).thenAnswer(
        (_) async => const Expense(expenseId: 1, name: 'Rent Increase'),
      );

      final notifier = container.read(expenseFormControllerProvider.notifier);
      await notifier.loadForEdit(1);
      notifier.nameChanged('Rent Increase');

      await notifier.submitUpdate();

      expect(container.read(expenseFormControllerProvider).saved, isTrue);
    });
  });

  group('ExpenseFormController.delete', () {
    test(
      'a still-referenced rejection is surfaced and the expense stays loaded',
      () async {
        when(
          () => repository.get(expenseId: 1),
        ).thenAnswer((_) async => const Expense(expenseId: 1, name: 'Rent'));
        when(() => repository.delete(expenseId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Expense is used by an expense ticket',
          ),
        );

        final notifier = container.read(expenseFormControllerProvider.notifier);
        await notifier.loadForEdit(1);

        await notifier.delete();

        final state = container.read(expenseFormControllerProvider);
        expect(state.deleted, isFalse);
        expect(state.error, ExpenseFormErrorCode.deleteFailed);
        expect(state.errorDetail, 'Expense is used by an expense ticket');
      },
    );
  });
}
