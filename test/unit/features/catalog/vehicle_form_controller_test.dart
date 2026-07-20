import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/vehicle_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_form_controller.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.vehicle, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.vehicle, rawValue: 15)],
);

const _existingVehicle = Vehicle(
  vehicleId: 1,
  licensePlate: 'ABC-123',
  name: 'Freightliner',
  nickname: 'Big Red',
  tonsCapacity: 5,
  active: true,
);

ProviderContainer _containerFor(User user, VehicleRepository repository) {
  return ProviderContainer(
    overrides: [
      vehicleRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
}

void main() {
  late MockVehicleRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockVehicleRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group('VehicleFormController field updates', () {
    test('licensePlateChanged updates state and clears prior errors', () {
      final notifier = container.read(vehicleFormControllerProvider.notifier);
      notifier.licensePlateChanged('ABC-123');
      expect(
        container.read(vehicleFormControllerProvider).licensePlate,
        'ABC-123',
      );
    });

    test('active defaults to true', () {
      expect(container.read(vehicleFormControllerProvider).active, isTrue);
    });
  });

  group('VehicleFormController.submitCreate validation (FR-012, FR-013)', () {
    test('empty required fields are rejected before submit', () async {
      final notifier = container.read(vehicleFormControllerProvider.notifier);

      await notifier.submitCreate();

      final state = container.read(vehicleFormControllerProvider);
      expect(
        state.fieldErrors['licensePlate'],
        VehicleFormErrorCode.licensePlateRequired,
      );
      expect(state.fieldErrors['name'], VehicleFormErrorCode.nameRequired);
      expect(
        state.fieldErrors['nickname'],
        VehicleFormErrorCode.nicknameRequired,
      );
      expect(
        state.fieldErrors['tonsCapacity'],
        VehicleFormErrorCode.tonsCapacityInvalid,
      );
      verifyNever(
        () => repository.create(
          licensePlate: any(named: 'licensePlate'),
          name: any(named: 'name'),
          nickname: any(named: 'nickname'),
          tonsCapacity: any(named: 'tonsCapacity'),
          active: any(named: 'active'),
        ),
      );
    });

    test('a negative tonsCapacity is rejected', () async {
      final notifier = container.read(vehicleFormControllerProvider.notifier);
      notifier.licensePlateChanged('ABC-123');
      notifier.nameChanged('Freightliner');
      notifier.nicknameChanged('Big Red');
      notifier.tonsCapacityChanged('-1');

      await notifier.submitCreate();

      final state = container.read(vehicleFormControllerProvider);
      expect(
        state.fieldErrors['tonsCapacity'],
        VehicleFormErrorCode.tonsCapacityInvalid,
      );
    });

    test(
      'a valid submission creates the vehicle and invalidates the list',
      () async {
        when(
          () => repository.create(
            licensePlate: 'ABC-123',
            name: 'Freightliner',
            nickname: 'Big Red',
            tonsCapacity: 5,
            active: true,
          ),
        ).thenAnswer((_) async => _existingVehicle);

        final notifier = container.read(vehicleFormControllerProvider.notifier);
        notifier.licensePlateChanged('ABC-123');
        notifier.nameChanged('Freightliner');
        notifier.nicknameChanged('Big Red');
        notifier.tonsCapacityChanged('5');

        await notifier.submitCreate();

        expect(container.read(vehicleFormControllerProvider).saved, isTrue);
      },
    );
  });

  group('VehicleFormController privilege checks', () {
    test('submitCreate is denied for a read-only user', () async {
      final readOnlyContainer = _containerFor(_readOnlyUser, repository);
      addTearDown(readOnlyContainer.dispose);
      final notifier = readOnlyContainer.read(
        vehicleFormControllerProvider.notifier,
      );
      notifier.licensePlateChanged('ABC-123');
      notifier.nameChanged('Freightliner');
      notifier.nicknameChanged('Big Red');
      notifier.tonsCapacityChanged('5');

      await notifier.submitCreate();

      final state = readOnlyContainer.read(vehicleFormControllerProvider);
      expect(state.error, VehicleFormErrorCode.createPermissionDenied);
      verifyNever(
        () => repository.create(
          licensePlate: any(named: 'licensePlate'),
          name: any(named: 'name'),
          nickname: any(named: 'nickname'),
          tonsCapacity: any(named: 'tonsCapacity'),
          active: any(named: 'active'),
        ),
      );
    });
  });

  group('VehicleFormController.submitUpdate', () {
    test('sends the changed fields when editing an existing vehicle', () async {
      when(
        () => repository.get(vehicleId: 1),
      ).thenAnswer((_) async => _existingVehicle);
      when(
        () => repository.update(
          vehicleId: 1,
          licensePlate: 'ABC-123',
          name: 'Freightliner',
          nickname: 'Red Beast',
          tonsCapacity: 5,
          active: true,
        ),
      ).thenAnswer(
        (_) async => _existingVehicle.copyWith(nickname: 'Red Beast'),
      );

      final notifier = container.read(vehicleFormControllerProvider.notifier);
      await notifier.loadForEdit(1);
      notifier.nicknameChanged('Red Beast');

      await notifier.submitUpdate();

      expect(container.read(vehicleFormControllerProvider).saved, isTrue);
    });
  });

  group('VehicleFormController.delete', () {
    test(
      'a still-referenced rejection is surfaced and the vehicle stays loaded',
      () async {
        when(
          () => repository.get(vehicleId: 1),
        ).thenAnswer((_) async => _existingVehicle);
        when(() => repository.delete(vehicleId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Vehicle is assigned to a route',
          ),
        );

        final notifier = container.read(vehicleFormControllerProvider.notifier);
        await notifier.loadForEdit(1);

        await notifier.delete();

        final state = container.read(vehicleFormControllerProvider);
        expect(state.deleted, isFalse);
        expect(state.error, VehicleFormErrorCode.deleteFailed);
        expect(state.errorDetail, 'Vehicle is assigned to a route');
      },
    );
  });
}
