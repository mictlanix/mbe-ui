import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/gender.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/employee_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

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

final _existing = Employee(
  employeeId: 1,
  firstName: 'Jane',
  lastName: 'Doe',
  nickname: 'Janie',
  gender: Gender.female,
  birthday: DateTime(1990, 5, 15),
  salesPerson: true,
  active: true,
  startJobDate: DateTime(2020, 1, 10),
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockEmployeeRepository repository;

  setUp(() {
    repository = MockEmployeeRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? employeeId,
    bool forceReadOnly = false,
  }) async {
    if (employeeId != null) {
      when(
        () => repository.get(employeeId: employeeId),
      ).thenAnswer((_) async => _existing);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          employeeRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: EmployeeDetailScreen(
              employeeId: employeeId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('create mode', () {
    testWidgets('shows an empty form with Save and no Delete', (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('first_name_field')), findsOneWidget);
      expect(find.byKey(const Key('gender_field')), findsOneWidget);
      expect(find.byKey(const Key('birthday_field')), findsOneWidget);
      expect(find.byKey(const Key('start_job_date_field')), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsOneWidget);
      expect(find.byKey(const Key('delete_employee_button')), findsNothing);
    });

    testWidgets('tapping the birthday field opens a date picker', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      await tester.tap(find.byKey(const Key('birthday_field')));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });

  group('view mode (forceReadOnly)', () {
    testWidgets(
      'renders fields disabled with no Save/Delete, and the AppBar carries '
      'only the edit toggle (constitution v1.8.0)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          employeeId: 1,
          forceReadOnly: true,
        );

        final firstNameField = tester.widget<TextFormField>(
          find.byKey(const Key('first_name_field')),
        );
        expect(firstNameField.enabled, isFalse);
        expect(find.byKey(const Key('save_button')), findsNothing);
        expect(find.byKey(const Key('delete_employee_button')), findsNothing);
        expect(find.byKey(const Key('edit_employee_button')), findsOneWidget);
      },
    );

    testWidgets('the loaded gender/dates render correctly', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        employeeId: 1,
        forceReadOnly: true,
      );

      expect(find.text('Female'), findsOneWidget);
    });
  });

  group('edit mode', () {
    testWidgets('a read-only user sees disabled fields and no Delete', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser, employeeId: 1);

      final firstNameField = tester.widget<TextFormField>(
        find.byKey(const Key('first_name_field')),
      );
      expect(firstNameField.enabled, isFalse);
      expect(find.byKey(const Key('delete_employee_button')), findsNothing);
    });

    testWidgets(
      'a user with delete privilege sees the Delete button and confirming '
      'opens the confirm dialog',
      (tester) async {
        await pumpScreen(tester, signedInAs: _fullAccessUser, employeeId: 1);

        expect(
          find.byKey(const Key('delete_employee_button')),
          findsOneWidget,
        );
        await tester.ensureVisible(
          find.byKey(const Key('delete_employee_button')),
        );
        await tester.tap(find.byKey(const Key('delete_employee_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('confirm_delete_employee_button')),
          findsOneWidget,
        );
      },
    );
  });
}
