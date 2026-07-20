import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/vehicle_operator_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operator_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockVehicleOperatorRepository extends Mock
    implements VehicleOperatorRepository {}

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.vehicleOperators, rawValue: 2),
  ],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.vehicleOperators, rawValue: 15),
  ],
);

final _existing = VehicleOperator(
  vehicleOperatorId: 1,
  driverId: 7,
  driverName: 'Jane Doe',
  licenseType: 'A',
  driverLicenseNumber: 'LN-1',
  issueDate: DateTime(2026, 1, 1),
  expirationDate: DateTime(2030, 1, 1),
  issuingLocation: 'CDMX',
  status: EntityStatus.active,
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockVehicleOperatorRepository repository;
  late MockEmployeeRepository employeeRepository;

  setUp(() {
    repository = MockVehicleOperatorRepository();
    employeeRepository = MockEmployeeRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? vehicleOperatorId,
    bool forceReadOnly = false,
  }) async {
    if (vehicleOperatorId != null) {
      when(
        () => repository.get(vehicleOperatorId: vehicleOperatorId),
      ).thenAnswer((_) async => _existing);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehicleOperatorRepositoryProvider.overrideWithValue(repository),
          employeeRepositoryProvider.overrideWithValue(employeeRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: VehicleOperatorDetailScreen(
              vehicleOperatorId: vehicleOperatorId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('create mode', () {
    testWidgets(
      'shows an empty form with the driver picker, Save, and no Delete',
      (tester) async {
        await pumpScreen(tester, signedInAs: _fullAccessUser);

        expect(find.byKey(const Key('driver_field')), findsOneWidget);
        expect(find.byKey(const Key('license_type_field')), findsOneWidget);
        expect(find.byKey(const Key('issue_date_field')), findsOneWidget);
        expect(find.byKey(const Key('expiration_date_field')), findsOneWidget);
        expect(find.byKey(const Key('save_button')), findsOneWidget);
        expect(
          find.byKey(const Key('delete_vehicle_operator_button')),
          findsNothing,
        );
      },
    );
  });

  group('view mode (forceReadOnly)', () {
    testWidgets(
      'renders the driver name (not a raw id), fields disabled with no '
      'Save/Delete, and the AppBar carries only the edit toggle '
      '(constitution v1.8.0)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          vehicleOperatorId: 1,
          forceReadOnly: true,
        );

        final driverField = tester.widget<TextFormField>(
          find.descendant(
            of: find.byKey(const Key('driver_field')),
            matching: find.byType(TextFormField),
          ),
        );
        expect(driverField.initialValue, 'Jane Doe');
        final licenseTypeField = tester.widget<TextFormField>(
          find.byKey(const Key('license_type_field')),
        );
        expect(licenseTypeField.enabled, isFalse);
        expect(find.byKey(const Key('save_button')), findsNothing);
        expect(
          find.byKey(const Key('delete_vehicle_operator_button')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('edit_vehicle_operator_button')),
          findsOneWidget,
        );
      },
    );
  });

  group('edit mode', () {
    testWidgets('a read-only user sees disabled fields and no Delete', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser, vehicleOperatorId: 1);

      final licenseTypeField = tester.widget<TextFormField>(
        find.byKey(const Key('license_type_field')),
      );
      expect(licenseTypeField.enabled, isFalse);
      expect(
        find.byKey(const Key('delete_vehicle_operator_button')),
        findsNothing,
      );
    });

    testWidgets(
      'a user with delete privilege sees the Delete button, and confirming '
      'a still-referenced rejection leaves the form in place',
      (tester) async {
        when(() => repository.delete(vehicleOperatorId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Vehicle operator is referenced by a service order',
          ),
        );

        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          vehicleOperatorId: 1,
        );

        expect(
          find.byKey(const Key('delete_vehicle_operator_button')),
          findsOneWidget,
        );
        await tester.tap(
          find.byKey(const Key('delete_vehicle_operator_button')),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('confirm_delete_vehicle_operator_button')),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('license_type_field')), findsOneWidget);
      },
    );
  });
}
