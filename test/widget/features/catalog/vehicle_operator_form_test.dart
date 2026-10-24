import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operator_form.dart';
import 'package:mbe_ui/features/catalog/presentation/vehicle_operator_form_controller.dart';
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

// Create (1) + Read (2): can open and create, but not update.
const _createOnlyUser = User(
  userId: 'creator',
  email: 'creator@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.vehicleOperators, rawValue: 3),
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

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(EntityStatus.active);
  });

  setUp(() {
    repository = MockVehicleOperatorRepository();
    employeeRepository = MockEmployeeRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? vehicleOperatorId,
    bool forceReadOnly = false,
    VehicleOperator? operator,
    // False while something on screen animates forever (a progress
    // indicator), which `pumpAndSettle` would wait on until it times out.
    bool settle = true,
  }) async {
    if (vehicleOperatorId != null) {
      when(
        () => repository.get(vehicleOperatorId: vehicleOperatorId),
      ).thenAnswer((_) async => operator ?? _existing);
    }

    // The real host (the record side sheet) scrolls; this bare Scaffold does
    // not, and the license photo section makes the form taller than the
    // default 600 px surface, which would push Edit/Delete out of reach.
    await tester.binding.setSurfaceSize(const Size(1024, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          vehicleOperatorRepositoryProvider.overrideWithValue(repository),
          employeeRepositoryProvider.overrideWithValue(employeeRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: VehicleOperatorForm(
              vehicleOperatorId: vehicleOperatorId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump();
    }
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
      'Save/Delete, and the edit toggle appears in the record action area — '
      'this form has no AppBar of its own at all now (spec 035)',
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

        expect(find.byType(AppBar), findsNothing);
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

  group('in-panel Edit toggle (spec 035 FR-027/FR-028)', () {
    testWidgets(
      'pressing Edit on a read-only form makes it editable in place — no '
      'navigation, since there is no route to navigate to anymore',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          vehicleOperatorId: 1,
          forceReadOnly: true,
        );

        expect(
          tester
              .widget<TextFormField>(
                find.byKey(const Key('license_type_field')),
              )
              .enabled,
          isFalse,
        );

        await tester.tap(find.byKey(const Key('edit_vehicle_operator_button')));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<TextFormField>(
                find.byKey(const Key('license_type_field')),
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
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final key = GlobalKey<VehicleOperatorFormPanelState>();
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            vehicleOperatorRepositoryProvider.overrideWithValue(repository),
            employeeRepositoryProvider.overrideWithValue(employeeRepository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: VehicleOperatorForm(key: key)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);
    });

    testWidgets('false until loading finishes, then true after a field edit', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final key = GlobalKey<VehicleOperatorFormPanelState>();
      when(
        () => repository.get(vehicleOperatorId: 1),
      ).thenAnswer((_) async => _existing);

      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            vehicleOperatorRepositoryProvider.overrideWithValue(repository),
            employeeRepositoryProvider.overrideWithValue(employeeRepository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: VehicleOperatorForm(key: key, vehicleOperatorId: 1),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);

      await tester.enterText(find.byKey(const Key('license_type_field')), 'B');
      await tester.pump();

      expect(key.currentState!.isDirty(), isTrue);
    });
  });

  group('license photo — attaching (051 US1)', () {
    final png = Uint8List.fromList(const [0x89, 0x50, 0x4E, 0x47, 1, 2, 3]);

    VehicleOperatorFormController controllerOf(WidgetTester tester) =>
        ProviderScope.containerOf(
          tester.element(find.byType(VehicleOperatorForm)),
        ).read(vehicleOperatorFormControllerProvider.notifier);

    testWidgets('an edit user sees the section with a placeholder and an '
        'Upload button, and no Replace or Remove', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        vehicleOperatorId: 1,
      );

      expect(find.byKey(const Key('license_photo_section')), findsOneWidget);
      expect(find.text('License photo'), findsOneWidget);
      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
      expect(
        find.byKey(const Key('upload_license_photo_button')),
        findsOneWidget,
      );
      verifyNever(
        () => repository.getLicensePhoto(
          vehicleOperatorId: any(named: 'vehicleOperatorId'),
        ),
      );
    });

    testWidgets('picking an image shows it in the form and marks the form '
        'dirty (FR-007, FR-010)', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        vehicleOperatorId: 1,
      );
      final form = tester.state<VehicleOperatorFormPanelState>(
        find.byType(VehicleOperatorForm),
      );
      expect(form.isDirty(), isFalse);

      controllerOf(tester).licensePhotoPicked(_tinyPng, 'license.png');
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const Key('license_photo_section')),
          matching: find.byType(Image),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.badge_outlined), findsNothing);
      expect(form.isDirty(), isTrue);
    });

    testWidgets('a staged file that is not really an image falls back to the '
        'placeholder instead of painting an error in the thumbnail', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        vehicleOperatorId: 1,
      );

      // Right extension and size, but the bytes are garbage.
      controllerOf(tester).licensePhotoPicked(png, 'license.png');
      // Decoding happens on the real event loop, not the fake-async one.
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)),
        );
        await tester.pump();
      }

      expect(tester.takeException(), isNull);
      expect(find.byType(Placeholder), findsNothing);
      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
    });

    testWidgets('a rejected pick shows its message under the section and '
        'stages nothing', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        vehicleOperatorId: 1,
      );

      controllerOf(tester).licensePhotoPicked(png, 'license.pdf');
      await tester.pump();

      expect(find.text('Photo must be a JPEG or PNG file.'), findsOneWidget);
      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
    });

    testWidgets('create mode shows the section to a user who may update', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);

      expect(find.byKey(const Key('license_photo_section')), findsOneWidget);
      expect(
        find.byKey(const Key('upload_license_photo_button')),
        findsOneWidget,
      );
    });

    testWidgets('create mode hides the section from a user who can create but '
        'not update — the server would refuse the photo (R5)', (tester) async {
      await pumpScreen(tester, signedInAs: _createOnlyUser);

      expect(find.byKey(const Key('license_photo_section')), findsNothing);
      expect(find.byKey(const Key('save_button')), findsOneWidget);
    });

    testWidgets('when the photo step fails after the fields saved, the panel '
        'stays open with the error, and Save again updates instead of '
        'creating a duplicate (FR-012)', (tester) async {
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
      when(
        () => repository.uploadLicensePhoto(
          vehicleOperatorId: any(named: 'vehicleOperatorId'),
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).thenThrow(const AppError.server(statusCode: 500, message: 'disk full'));
      await pumpScreen(tester, signedInAs: _fullAccessUser);
      controllerOf(tester)
        ..driverSelected(7, 'Jane Doe')
        ..licenseTypeChanged('A')
        ..driverLicenseNumberChanged('LN-1')
        ..issuingLocationChanged('CDMX')
        ..issueDateChanged(DateTime(2026, 1, 1))
        ..expirationDateChanged(DateTime(2030, 1, 1))
        ..licensePhotoPicked(_tinyPng, 'license.png');
      await tester.pump();

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('license photo could not be saved'),
        findsOneWidget,
      );
      expect(find.text('disk full'), findsOneWidget);
      expect(find.byKey(const Key('license_type_field')), findsOneWidget);
      expect(find.byType(Image), findsWidgets);

      // The photo step now works; the retry must not create a second operator.
      when(
        () => repository.uploadLicensePhoto(
          vehicleOperatorId: any(named: 'vehicleOperatorId'),
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
        ),
      ).thenAnswer((_) async => _existing.copyWith(hasLicensePhoto: true));
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

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
      // The retry succeeded, so the panel closed itself.
      expect(find.byType(VehicleOperatorForm), findsNothing);
    });
  });

  group('license photo — viewing (051 US2)', () {
    final withPhoto = _existing.copyWith(hasLicensePhoto: true);

    void stubPhoto(Future<Uint8List> Function() answer) => when(
      () => repository.getLicensePhoto(vehicleOperatorId: 1),
    ).thenAnswer((_) => answer());

    testWidgets('an operator with a photo shows it as a thumbnail that opens '
        'enlarged, titled with the driver, and closes again (FR-002, FR-003)', (
      tester,
    ) async {
      stubPhoto(() async => _tinyPng);
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        vehicleOperatorId: 1,
        operator: withPhoto,
      );

      expect(find.byKey(const Key('license_photo_thumbnail')), findsOneWidget);
      expect(find.byKey(const Key('license_photo_unavailable')), findsNothing);
      verify(() => repository.getLicensePhoto(vehicleOperatorId: 1)).called(1);

      await tester.tap(find.byKey(const Key('license_photo_thumbnail')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('photo_preview_dialog')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('photo_preview_dialog')),
          matching: find.text('Jane Doe'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('photo_preview_close')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('photo_preview_dialog')), findsNothing);
    });

    testWidgets('shows a progress indicator while the photo is being read, '
        'with the fields already usable', (tester) async {
      final pending = Completer<Uint8List>();
      stubPhoto(() => pending.future);
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        vehicleOperatorId: 1,
        operator: withPhoto,
        settle: false,
      );

      expect(
        find.descendant(
          of: find.byKey(const Key('license_photo_section')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('license_photo_thumbnail')), findsNothing);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('license_type_field')))
            .enabled,
        isTrue,
      );

      pending.complete(_tinyPng);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('license_photo_thumbnail')), findsOneWidget);
    });

    testWidgets('a photo that cannot be read shows "Photo unavailable" and '
        'leaves the form usable (FR-014)', (tester) async {
      stubPhoto(() async => throw const AppError.notFound('missing'));
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        vehicleOperatorId: 1,
        operator: withPhoto,
      );

      expect(
        find.byKey(const Key('license_photo_unavailable')),
        findsOneWidget,
      );
      expect(find.text('Photo unavailable'), findsOneWidget);
      expect(find.byKey(const Key('license_photo_thumbnail')), findsNothing);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('license_type_field')))
            .enabled,
        isTrue,
      );
      expect(find.byKey(const Key('save_button')), findsOneWidget);
    });

    testWidgets('a user who can only read sees the photo but none of the '
        'Upload, Replace or Remove controls (FR-013)', (tester) async {
      stubPhoto(() async => _tinyPng);
      await pumpScreen(
        tester,
        signedInAs: _readOnlyUser,
        vehicleOperatorId: 1,
        operator: withPhoto,
      );

      expect(find.byKey(const Key('license_photo_thumbnail')), findsOneWidget);
      expect(
        find.byKey(const Key('upload_license_photo_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('replace_license_photo_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('remove_license_photo_button')),
        findsNothing,
      );
    });

    testWidgets('the read-only view of an editor shows the photo without '
        'controls until Edit is pressed', (tester) async {
      stubPhoto(() async => _tinyPng);
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        vehicleOperatorId: 1,
        forceReadOnly: true,
        operator: withPhoto,
      );

      expect(find.byKey(const Key('license_photo_thumbnail')), findsOneWidget);
      expect(
        find.byKey(const Key('upload_license_photo_button')),
        findsNothing,
      );

      await tester.tap(find.byKey(const Key('edit_vehicle_operator_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('license_photo_thumbnail')), findsOneWidget);
    });
  });

  group('license photo — replacing and removing (051 US3)', () {
    final withPhoto = _existing.copyWith(hasLicensePhoto: true);

    VehicleOperatorFormController controllerOf(WidgetTester tester) =>
        ProviderScope.containerOf(
          tester.element(find.byType(VehicleOperatorForm)),
        ).read(vehicleOperatorFormControllerProvider.notifier);

    Future<void> pumpWithPhoto(WidgetTester tester) async {
      when(
        () => repository.getLicensePhoto(vehicleOperatorId: 1),
      ).thenAnswer((_) async => _tinyPng);
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        vehicleOperatorId: 1,
        operator: withPhoto,
      );
    }

    void stubUpdate() => when(
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
    ).thenAnswer((_) async => withPhoto);

    testWidgets('a stored photo offers Replace and Remove instead of Upload', (
      tester,
    ) async {
      await pumpWithPhoto(tester);

      expect(
        find.byKey(const Key('replace_license_photo_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('remove_license_photo_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('upload_license_photo_button')),
        findsNothing,
      );
    });

    testWidgets('Remove shows the placeholder and the Upload button, marks '
        'the form dirty, and removes nothing yet (FR-008, FR-010)', (
      tester,
    ) async {
      await pumpWithPhoto(tester);
      final form = tester.state<VehicleOperatorFormPanelState>(
        find.byType(VehicleOperatorForm),
      );
      expect(form.isDirty(), isFalse);

      await tester.tap(find.byKey(const Key('remove_license_photo_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('license_photo_thumbnail')), findsNothing);
      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
      expect(
        find.byKey(const Key('upload_license_photo_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('remove_license_photo_button')),
        findsNothing,
      );
      expect(form.isDirty(), isTrue);
      verifyNever(
        () => repository.removeLicensePhoto(
          vehicleOperatorId: any(named: 'vehicleOperatorId'),
        ),
      );
    });

    testWidgets('picking a new image after Remove stages it and cancels the '
        'removal (FR-009)', (tester) async {
      await pumpWithPhoto(tester);
      await tester.tap(find.byKey(const Key('remove_license_photo_button')));
      await tester.pumpAndSettle();

      controllerOf(tester).licensePhotoPicked(_tinyPng, 'new.png');
      await tester.pump();

      expect(
        find.byKey(const Key('replace_license_photo_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('remove_license_photo_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('upload_license_photo_button')),
        findsNothing,
      );
    });

    testWidgets('saving after Remove deletes the photo and closes the panel', (
      tester,
    ) async {
      stubUpdate();
      when(
        () => repository.removeLicensePhoto(vehicleOperatorId: 1),
      ).thenAnswer((_) async {});
      await pumpWithPhoto(tester);
      await tester.tap(find.byKey(const Key('remove_license_photo_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      verify(
        () => repository.removeLicensePhoto(vehicleOperatorId: 1),
      ).called(1);
      expect(find.byType(VehicleOperatorForm), findsNothing);
    });

    testWidgets('saving a replacement uploads it and never deletes', (
      tester,
    ) async {
      stubUpdate();
      when(
        () => repository.uploadLicensePhoto(
          vehicleOperatorId: 1,
          bytes: any(named: 'bytes'),
          filename: 'new.png',
        ),
      ).thenAnswer((_) async => withPhoto);
      await pumpWithPhoto(tester);
      controllerOf(tester).licensePhotoPicked(_tinyPng, 'new.png');
      await tester.pump();

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      verify(
        () => repository.uploadLicensePhoto(
          vehicleOperatorId: 1,
          bytes: any(named: 'bytes'),
          filename: 'new.png',
        ),
      ).called(1);
      verifyNever(
        () => repository.removeLicensePhoto(
          vehicleOperatorId: any(named: 'vehicleOperatorId'),
        ),
      );
      expect(find.byType(VehicleOperatorForm), findsNothing);
    });
  });
}

/// A valid 1×1 PNG that `Image.memory` can really decode. (The repo's
/// `kTinyPng` in `document_fakes.dart` is not one — its IDAT chunk has a bad
/// CRC — which made decoding fail and surface as "Photo unavailable".)
final _tinyPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0,
  0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);
