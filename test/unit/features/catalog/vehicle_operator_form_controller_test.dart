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
import 'package:mbe_ui/features/catalog/data/vehicle_operator_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle_operator.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/vehicle_operator_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operator_form_controller.dart';

class MockVehicleOperatorRepository extends Mock
    implements VehicleOperatorRepository {}

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

ProviderContainer _containerFor(
  User user,
  VehicleOperatorRepository repository,
) {
  return ProviderContainer(
    overrides: [
      vehicleOperatorRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

void main() {
  late MockVehicleOperatorRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockVehicleOperatorRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group('VehicleOperatorFormController field updates', () {
    test('driverSelected updates driverId and display text', () {
      final notifier = container.read(
        vehicleOperatorFormControllerProvider.notifier,
      );
      notifier.driverSelected(7, 'Jane Doe');

      final state = container.read(vehicleOperatorFormControllerProvider);
      expect(state.driverId, 7);
      expect(state.driverDisplayText, 'Jane Doe');
    });

    test('active defaults to true', () {
      expect(
        container.read(vehicleOperatorFormControllerProvider).status,
        EntityStatus.active,
      );
    });
  });

  group(
    'VehicleOperatorFormController.submitCreate validation (FR-015, FR-016)',
    () {
      test('empty required fields are rejected before submit', () async {
        final notifier = container.read(
          vehicleOperatorFormControllerProvider.notifier,
        );

        await notifier.submitCreate();

        final state = container.read(vehicleOperatorFormControllerProvider);
        expect(
          state.fieldErrors['driver'],
          VehicleOperatorFormErrorCode.driverRequired,
        );
        expect(
          state.fieldErrors['licenseType'],
          VehicleOperatorFormErrorCode.licenseTypeRequired,
        );
        expect(
          state.fieldErrors['driverLicenseNumber'],
          VehicleOperatorFormErrorCode.driverLicenseNumberRequired,
        );
        expect(
          state.fieldErrors['issueDate'],
          VehicleOperatorFormErrorCode.issueDateRequired,
        );
        expect(
          state.fieldErrors['expirationDate'],
          VehicleOperatorFormErrorCode.expirationDateRequired,
        );
        expect(
          state.fieldErrors['issuingLocation'],
          VehicleOperatorFormErrorCode.issuingLocationRequired,
        );
        verifyNever(
          () => repository.create(
            driverId: any(named: 'driverId'),
            licenseType: any(named: 'licenseType'),
            driverLicenseNumber: any(named: 'driverLicenseNumber'),
            issueDate: any(named: 'issueDate'),
            expirationDate: any(named: 'expirationDate'),
            issuingLocation: any(named: 'issuingLocation'),
            status: any(named: 'status'),
          ),
        );
      });

      test('an expiration date before the issue date is rejected '
          '(data-model.md §3 soft rule)', () async {
        final notifier = container.read(
          vehicleOperatorFormControllerProvider.notifier,
        );
        notifier.driverSelected(7, 'Jane Doe');
        notifier.licenseTypeChanged('A');
        notifier.driverLicenseNumberChanged('LN-1');
        notifier.issuingLocationChanged('CDMX');
        notifier.issueDateChanged(DateTime(2026, 6, 1));
        notifier.expirationDateChanged(DateTime(2026, 1, 1));

        await notifier.submitCreate();

        final state = container.read(vehicleOperatorFormControllerProvider);
        expect(
          state.fieldErrors['expirationDate'],
          VehicleOperatorFormErrorCode.expirationBeforeIssue,
        );
      });

      test(
        'a valid submission creates the operator and invalidates the list',
        () async {
          when(
            () => repository.create(
              driverId: 7,
              licenseType: 'A',
              driverLicenseNumber: 'LN-1',
              issueDate: DateTime(2026, 1, 1),
              expirationDate: DateTime(2030, 1, 1),
              issuingLocation: 'CDMX',
              status: EntityStatus.active,
            ),
          ).thenAnswer((_) async => _existing);

          final notifier = container.read(
            vehicleOperatorFormControllerProvider.notifier,
          );
          notifier.driverSelected(7, 'Jane Doe');
          notifier.licenseTypeChanged('A');
          notifier.driverLicenseNumberChanged('LN-1');
          notifier.issuingLocationChanged('CDMX');
          notifier.issueDateChanged(DateTime(2026, 1, 1));
          notifier.expirationDateChanged(DateTime(2030, 1, 1));

          await notifier.submitCreate();

          expect(
            container.read(vehicleOperatorFormControllerProvider).saved,
            isTrue,
          );
        },
      );
    },
  );

  group('VehicleOperatorFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        vehicleOperatorFormControllerProvider.notifier,
      );
      notifier.driverSelected(7, 'Jane Doe');
      notifier.licenseTypeChanged('A');
      notifier.driverLicenseNumberChanged('LN-1');
      notifier.issuingLocationChanged('CDMX');
      notifier.issueDateChanged(DateTime(2026, 1, 1));
      notifier.expirationDateChanged(DateTime(2030, 1, 1));

      await notifier.submitCreate();

      final state = readOnlyContainer.read(
        vehicleOperatorFormControllerProvider,
      );
      expect(state.error, VehicleOperatorFormErrorCode.createPermissionDenied);
      verifyNever(
        () => repository.create(
          driverId: any(named: 'driverId'),
          licenseType: any(named: 'licenseType'),
          driverLicenseNumber: any(named: 'driverLicenseNumber'),
          issueDate: any(named: 'issueDate'),
          expirationDate: any(named: 'expirationDate'),
          issuingLocation: any(named: 'issuingLocation'),
          status: any(named: 'status'),
        ),
      );
    });
  });

  group('VehicleOperatorFormController.delete', () {
    test(
      'a still-referenced rejection is surfaced and the record stays loaded',
      () async {
        when(
          () => repository.get(vehicleOperatorId: 1),
        ).thenAnswer((_) async => _existing);
        when(() => repository.delete(vehicleOperatorId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Vehicle operator is referenced by a service order',
          ),
        );

        final notifier = container.read(
          vehicleOperatorFormControllerProvider.notifier,
        );
        await notifier.loadForEdit(1);

        await notifier.delete();

        final state = container.read(vehicleOperatorFormControllerProvider);
        expect(state.deleted, isFalse);
        expect(state.error, VehicleOperatorFormErrorCode.deleteFailed);
        expect(
          state.errorDetail,
          'Vehicle operator is referenced by a service order',
        );
      },
    );
  });
}
