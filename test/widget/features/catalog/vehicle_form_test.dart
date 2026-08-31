import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/widgets/entity_status_controls.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/vehicle_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/vehicle.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/vehicle_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_form.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.vehicle, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.vehicle, rawValue: 15)],
);

const _existing = Vehicle(
  vehicleId: 1,
  licensePlate: 'ABC-123',
  name: 'Freightliner',
  nickname: 'Big Red',
  tonsCapacity: 10,
  status: EntityStatus.active,
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockVehicleRepository repository;

  setUp(() {
    repository = MockVehicleRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? vehicleId,
    bool forceReadOnly = false,
  }) async {
    if (vehicleId != null) {
      when(
        () => repository.get(vehicleId: vehicleId),
      ).thenAnswer((_) async => _existing);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehicleRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: VehicleForm(
              vehicleId: vehicleId,
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
      'shows an empty form with Save, status Active by default, and no Delete',
      (tester) async {
        await pumpScreen(tester, signedInAs: _fullAccessUser);

        expect(
          find.byKey(const Key('vehicle_license_plate_field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('vehicle_tons_capacity_field')),
          findsOneWidget,
        );
        final statusField = tester.widget<EntityStatusFormField>(
          find.byType(EntityStatusFormField),
        );
        expect(statusField.value, EntityStatus.active);
        expect(find.byKey(const Key('save_button')), findsOneWidget);
        expect(find.byKey(const Key('delete_vehicle_button')), findsNothing);
      },
    );
  });

  group('view mode (forceReadOnly)', () {
    testWidgets(
      'renders fields disabled with no Save/Delete, and the edit toggle '
      'appears in the record action area — this form has no AppBar of its '
      'own at all now (spec 035)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          vehicleId: 1,
          forceReadOnly: true,
        );

        final plateField = tester.widget<TextFormField>(
          find.byKey(const Key('vehicle_license_plate_field')),
        );
        expect(plateField.enabled, isFalse);
        expect(find.byKey(const Key('save_button')), findsNothing);
        expect(find.byKey(const Key('delete_vehicle_button')), findsNothing);
        expect(find.byKey(const Key('edit_vehicle_button')), findsOneWidget);

        expect(find.byType(AppBar), findsNothing);
      },
    );
  });

  group('edit mode', () {
    testWidgets('a read-only user sees disabled fields and no Delete', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser, vehicleId: 1);

      final plateField = tester.widget<TextFormField>(
        find.byKey(const Key('vehicle_license_plate_field')),
      );
      expect(plateField.enabled, isFalse);
      expect(find.byKey(const Key('delete_vehicle_button')), findsNothing);
    });

    testWidgets(
      'a user with delete privilege sees the Delete button, and confirming '
      'a still-referenced rejection leaves the form in place',
      (tester) async {
        when(() => repository.delete(vehicleId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Vehicle is assigned to a route',
          ),
        );

        await pumpScreen(tester, signedInAs: _fullAccessUser, vehicleId: 1);

        expect(find.byKey(const Key('delete_vehicle_button')), findsOneWidget);
        await tester.tap(find.byKey(const Key('delete_vehicle_button')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('confirm_delete_vehicle_button')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('vehicle_license_plate_field')),
          findsOneWidget,
        );
      },
    );
  });

  group('in-panel Edit toggle (spec 035 FR-027/FR-028)', () {
    testWidgets(
      'pressing Edit on a read-only form makes it editable in place — no '
      'navigation, since there is no route to navigate to anymore',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          vehicleId: 1,
          forceReadOnly: true,
        );

        expect(
          tester
              .widget<TextFormField>(
                find.byKey(const Key('vehicle_license_plate_field')),
              )
              .enabled,
          isFalse,
        );

        await tester.tap(find.byKey(const Key('edit_vehicle_button')));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<TextFormField>(
                find.byKey(const Key('vehicle_license_plate_field')),
              )
              .enabled,
          isTrue,
        );
        expect(find.byKey(const Key('save_button')), findsOneWidget);
      },
    );
  });

  group('isDirty (spec 035 FR-032, data-model.md §3)', () {
    testWidgets('false immediately after a create-mode form mounts', (
      tester,
    ) async {
      final key = GlobalKey<VehicleFormPanelState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleRepositoryProvider.overrideWithValue(repository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: VehicleForm(key: key)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);
    });

    testWidgets('false until loading finishes, then true after a field edit', (
      tester,
    ) async {
      final key = GlobalKey<VehicleFormPanelState>();
      when(
        () => repository.get(vehicleId: 1),
      ).thenAnswer((_) async => _existing);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleRepositoryProvider.overrideWithValue(repository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: VehicleForm(key: key, vehicleId: 1)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);

      await tester.enterText(
        find.byKey(const Key('vehicle_license_plate_field')),
        'XYZ-999',
      );
      await tester.pump();

      expect(key.currentState!.isDirty(), isTrue);
    });
  });
}
