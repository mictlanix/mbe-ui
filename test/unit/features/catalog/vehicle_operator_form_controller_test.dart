import 'dart:typed_data';

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
import 'package:mbe_ui/features/catalog/presentation/license_photo_provider.dart';
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
    retry: (_, _) => null,
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

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(EntityStatus.active);
  });

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

  group('VehicleOperatorFormController license photo (051)', () {
    final png = Uint8List.fromList(const [0x89, 0x50, 0x4E, 0x47, 1, 2, 3]);
    final withPhoto = _existing.copyWith(hasLicensePhoto: true);

    VehicleOperatorFormController notifierOf(ProviderContainer c) =>
        c.read(vehicleOperatorFormControllerProvider.notifier);

    VehicleOperatorFormState stateOf(ProviderContainer c) =>
        c.read(vehicleOperatorFormControllerProvider);

    void fillValid(VehicleOperatorFormController n) {
      n.driverSelected(7, 'Jane Doe');
      n.licenseTypeChanged('A');
      n.driverLicenseNumberChanged('LN-1');
      n.issuingLocationChanged('CDMX');
      n.issueDateChanged(DateTime(2026, 1, 1));
      n.expirationDateChanged(DateTime(2030, 1, 1));
    }

    void stubCreate() {
      when(
        () => repository.create(
          driverId: any(named: 'driverId'),
          licenseType: any(named: 'licenseType'),
          driverLicenseNumber: any(named: 'driverLicenseNumber'),
          issueDate: any(named: 'issueDate'),
          expirationDate: any(named: 'expirationDate'),
          issuingLocation: any(named: 'issuingLocation'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => _existing);
    }

    void stubUpdate() {
      when(
        () => repository.update(
          vehicleOperatorId: any(named: 'vehicleOperatorId'),
          driverId: any(named: 'driverId'),
          licenseType: any(named: 'licenseType'),
          driverLicenseNumber: any(named: 'driverLicenseNumber'),
          issueDate: any(named: 'issueDate'),
          expirationDate: any(named: 'expirationDate'),
          issuingLocation: any(named: 'issuingLocation'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => _existing);
    }

    void stubUpload({Object? error}) {
      final call = when(
        () => repository.uploadLicensePhoto(
          vehicleOperatorId: 1,
          bytes: png,
          filename: 'license.png',
        ),
      );
      if (error != null) {
        call.thenThrow(error);
      } else {
        call.thenAnswer((_) async => withPhoto);
      }
    }

    test('loadForEdit reflects whether the server holds a photo', () async {
      when(
        () => repository.get(vehicleOperatorId: 1),
      ).thenAnswer((_) async => withPhoto);

      await notifierOf(container).loadForEdit(1);

      expect(stateOf(container).hasLicensePhoto, isTrue);
    });

    test('a valid pick is staged, with no error', () {
      final notifier = notifierOf(container);

      notifier.licensePhotoPicked(png, 'license.PNG');

      final state = stateOf(container);
      expect(state.pendingLicensePhotoBytes, png);
      expect(state.pendingLicensePhotoFilename, 'license.PNG');
      expect(state.fieldErrors['licensePhoto'], isNull);
    });

    test('a wrong file type is rejected and the staged photo is kept', () {
      final notifier = notifierOf(container);
      notifier.licensePhotoPicked(png, 'license.png');

      notifier.licensePhotoPicked(Uint8List(3), 'license.pdf');

      final state = stateOf(container);
      expect(
        state.fieldErrors['licensePhoto'],
        VehicleOperatorFormErrorCode.licensePhotoInvalidType,
      );
      expect(state.pendingLicensePhotoBytes, png);
    });

    test('a file over 2 MB is rejected and the staged photo is kept', () {
      final notifier = notifierOf(container);
      notifier.licensePhotoPicked(png, 'license.png');

      notifier.licensePhotoPicked(
        Uint8List(2 * 1024 * 1024 + 1),
        'license.jpg',
      );

      final state = stateOf(container);
      expect(
        state.fieldErrors['licensePhoto'],
        VehicleOperatorFormErrorCode.licensePhotoTooLarge,
      );
      expect(state.pendingLicensePhotoBytes, png);
    });

    test('a file of exactly 2 MB is accepted', () {
      notifierOf(
        container,
      ).licensePhotoPicked(Uint8List(2 * 1024 * 1024), 'license.jpeg');

      expect(stateOf(container).pendingLicensePhotoBytes, isNotNull);
      expect(stateOf(container).fieldErrors['licensePhoto'], isNull);
    });

    test('saving an edit with a staged photo uploads it, then closes the '
        'panel and refreshes the photo', () async {
      when(
        () => repository.get(vehicleOperatorId: 1),
      ).thenAnswer((_) async => _existing);
      when(
        () => repository.getLicensePhoto(vehicleOperatorId: 1),
      ).thenAnswer((_) async => png);
      stubUpdate();
      stubUpload();
      final notifier = notifierOf(container);
      await notifier.loadForEdit(1);
      // Held open like the form's own watch, so invalidation is observable.
      container.listen(licensePhotoProvider(1), (_, _) {});
      await container.read(licensePhotoProvider(1).future);
      notifier.licensePhotoPicked(png, 'license.png');

      await notifier.submitUpdate();

      final state = stateOf(container);
      expect(state.saved, isTrue);
      expect(state.error, isNull);
      expect(state.hasLicensePhoto, isTrue);
      expect(state.pendingLicensePhotoBytes, isNull);
      expect(state.pendingLicensePhotoFilename, isNull);
      verifyInOrder([
        () => repository.update(
          vehicleOperatorId: 1,
          driverId: any(named: 'driverId'),
          licenseType: any(named: 'licenseType'),
          driverLicenseNumber: any(named: 'driverLicenseNumber'),
          issueDate: any(named: 'issueDate'),
          expirationDate: any(named: 'expirationDate'),
          issuingLocation: any(named: 'issuingLocation'),
          status: any(named: 'status'),
        ),
        () => repository.uploadLicensePhoto(
          vehicleOperatorId: 1,
          bytes: png,
          filename: 'license.png',
        ),
      ]);
      await container.read(licensePhotoProvider(1).future);
      verify(() => repository.getLicensePhoto(vehicleOperatorId: 1)).called(2);
    });

    test('saving with nothing staged makes no photo call', () async {
      when(
        () => repository.get(vehicleOperatorId: 1),
      ).thenAnswer((_) async => withPhoto);
      stubUpdate();
      final notifier = notifierOf(container);
      await notifier.loadForEdit(1);

      await notifier.submitUpdate();

      expect(stateOf(container).saved, isTrue);
      verifyNever(
        () => repository.uploadLicensePhoto(
          vehicleOperatorId: any(named: 'vehicleOperatorId'),
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      );
      verifyNever(
        () => repository.removeLicensePhoto(
          vehicleOperatorId: any(named: 'vehicleOperatorId'),
        ),
      );
    });

    test('a create with a staged photo creates the operator first and then '
        'attaches the photo to the new id (FR-011)', () async {
      stubCreate();
      stubUpload();
      final notifier = notifierOf(container);
      fillValid(notifier);
      notifier.licensePhotoPicked(png, 'license.png');

      await notifier.submitCreate();

      final state = stateOf(container);
      expect(state.saved, isTrue);
      expect(state.vehicleOperatorId, 1);
      expect(state.hasLicensePhoto, isTrue);
      verifyInOrder([
        () => repository.create(
          driverId: 7,
          licenseType: 'A',
          driverLicenseNumber: 'LN-1',
          issueDate: DateTime(2026, 1, 1),
          expirationDate: DateTime(2030, 1, 1),
          issuingLocation: 'CDMX',
          status: EntityStatus.active,
        ),
        () => repository.uploadLicensePhoto(
          vehicleOperatorId: 1,
          bytes: png,
          filename: 'license.png',
        ),
      ]);
    });

    test('when the upload fails after a create, the panel stays open with the '
        'photo still staged and the new id kept (FR-012)', () async {
      stubCreate();
      stubUpload(
        error: const AppError.server(
          statusCode: 422,
          message: 'Image could not be read',
        ),
      );
      final notifier = notifierOf(container);
      fillValid(notifier);
      notifier.licensePhotoPicked(png, 'license.png');

      await notifier.submitCreate();

      final state = stateOf(container);
      expect(state.saved, isFalse);
      expect(state.submitting, isFalse);
      expect(state.vehicleOperatorId, 1);
      expect(state.pendingLicensePhotoBytes, png);
      expect(state.pendingLicensePhotoFilename, 'license.png');
      expect(state.hasLicensePhoto, isFalse);
      expect(state.error, VehicleOperatorFormErrorCode.licensePhotoSaveFailed);
      expect(state.errorDetail, 'Image could not be read');
    });

    test('saving again after that failure updates the operator instead of '
        'creating a duplicate, and re-sends the photo', () async {
      stubCreate();
      stubUpdate();
      stubUpload(
        error: const AppError.server(statusCode: 500, message: 'disk full'),
      );
      final notifier = notifierOf(container);
      fillValid(notifier);
      notifier.licensePhotoPicked(png, 'license.png');
      await notifier.submitCreate();
      expect(stateOf(container).saved, isFalse);

      // The form's Save dispatches on vehicleOperatorId, which is now set.
      stubUpload();
      await notifier.submitUpdate();

      final state = stateOf(container);
      expect(state.saved, isTrue);
      expect(state.error, isNull);
      expect(state.pendingLicensePhotoBytes, isNull);
      verify(
        () => repository.create(
          driverId: any(named: 'driverId'),
          licenseType: any(named: 'licenseType'),
          driverLicenseNumber: any(named: 'driverLicenseNumber'),
          issueDate: any(named: 'issueDate'),
          expirationDate: any(named: 'expirationDate'),
          issuingLocation: any(named: 'issuingLocation'),
          status: any(named: 'status'),
        ),
      ).called(1);
      verify(
        () => repository.update(
          vehicleOperatorId: 1,
          driverId: any(named: 'driverId'),
          licenseType: any(named: 'licenseType'),
          driverLicenseNumber: any(named: 'driverLicenseNumber'),
          issueDate: any(named: 'issueDate'),
          expirationDate: any(named: 'expirationDate'),
          issuingLocation: any(named: 'issuingLocation'),
          status: any(named: 'status'),
        ),
      ).called(1);
    });

    group('replacing and removing (051 US3)', () {
      Future<VehicleOperatorFormController> loadedWithPhoto() async {
        when(
          () => repository.get(vehicleOperatorId: 1),
        ).thenAnswer((_) async => withPhoto);
        final notifier = notifierOf(container);
        await notifier.loadForEdit(1);
        return notifier;
      }

      void stubRemove({Object? error}) {
        final call = when(
          () => repository.removeLicensePhoto(vehicleOperatorId: 1),
        );
        if (error != null) {
          call.thenThrow(error);
        } else {
          call.thenAnswer((_) async {});
        }
      }

      test('removing a stored photo marks it for removal without touching '
          'the server yet', () async {
        final notifier = await loadedWithPhoto();

        notifier.licensePhotoRemoveRequested();

        final state = stateOf(container);
        expect(state.licensePhotoMarkedForRemoval, isTrue);
        expect(state.hasLicensePhoto, isTrue);
        verifyNever(
          () => repository.removeLicensePhoto(
            vehicleOperatorId: any(named: 'vehicleOperatorId'),
          ),
        );
      });

      test('removing with nothing saved or staged does nothing', () {
        final notifier = notifierOf(container);
        final before = stateOf(container);

        notifier.licensePhotoRemoveRequested();

        expect(stateOf(container), before);
      });

      test('removing a staged-only image just unstages it, with no mark', () {
        final notifier = notifierOf(container);
        notifier.licensePhotoPicked(png, 'license.png');

        notifier.licensePhotoRemoveRequested();

        final state = stateOf(container);
        expect(state.pendingLicensePhotoBytes, isNull);
        expect(state.pendingLicensePhotoFilename, isNull);
        expect(state.licensePhotoMarkedForRemoval, isFalse);
      });

      test('removing while a replacement is staged drops it and marks the '
          'stored photo for removal', () async {
        final notifier = await loadedWithPhoto();
        notifier.licensePhotoPicked(png, 'license.png');

        notifier.licensePhotoRemoveRequested();

        final state = stateOf(container);
        expect(state.pendingLicensePhotoBytes, isNull);
        expect(state.licensePhotoMarkedForRemoval, isTrue);
      });

      test('picking a new image cancels a pending removal (FR-009)', () async {
        final notifier = await loadedWithPhoto();
        notifier.licensePhotoRemoveRequested();

        notifier.licensePhotoPicked(png, 'license.png');

        final state = stateOf(container);
        expect(state.licensePhotoMarkedForRemoval, isFalse);
        expect(state.pendingLicensePhotoBytes, png);
      });

      test('saving with a pending removal deletes the photo, refreshes it '
          'and closes the panel', () async {
        when(
          () => repository.getLicensePhoto(vehicleOperatorId: 1),
        ).thenAnswer((_) async => png);
        stubUpdate();
        stubRemove();
        final notifier = await loadedWithPhoto();
        container.listen(licensePhotoProvider(1), (_, _) {});
        await container.read(licensePhotoProvider(1).future);
        notifier.licensePhotoRemoveRequested();

        await notifier.submitUpdate();

        final state = stateOf(container);
        expect(state.saved, isTrue);
        expect(state.error, isNull);
        expect(state.hasLicensePhoto, isFalse);
        expect(state.licensePhotoMarkedForRemoval, isFalse);
        verify(
          () => repository.removeLicensePhoto(vehicleOperatorId: 1),
        ).called(1);
        await container.read(licensePhotoProvider(1).future);
        verify(
          () => repository.getLicensePhoto(vehicleOperatorId: 1),
        ).called(2);
      });

      test(
        'replacing uploads the new image and never asks for a delete',
        () async {
          stubUpdate();
          stubUpload();
          final notifier = await loadedWithPhoto();
          notifier.licensePhotoPicked(png, 'license.png');

          await notifier.submitUpdate();

          expect(stateOf(container).saved, isTrue);
          expect(stateOf(container).hasLicensePhoto, isTrue);
          verify(
            () => repository.uploadLicensePhoto(
              vehicleOperatorId: 1,
              bytes: png,
              filename: 'license.png',
            ),
          ).called(1);
          verifyNever(
            () => repository.removeLicensePhoto(
              vehicleOperatorId: any(named: 'vehicleOperatorId'),
            ),
          );
        },
      );

      test(
        'a failed removal keeps the mark, stays open and reports it',
        () async {
          stubUpdate();
          stubRemove(
            error: const AppError.server(
              statusCode: 500,
              message: 'disk error',
            ),
          );
          final notifier = await loadedWithPhoto();
          notifier.licensePhotoRemoveRequested();

          await notifier.submitUpdate();

          final state = stateOf(container);
          expect(state.saved, isFalse);
          expect(state.submitting, isFalse);
          expect(state.licensePhotoMarkedForRemoval, isTrue);
          expect(state.hasLicensePhoto, isTrue);
          expect(
            state.error,
            VehicleOperatorFormErrorCode.licensePhotoSaveFailed,
          );
          expect(state.errorDetail, 'disk error');
        },
      );
    });
  });
}
