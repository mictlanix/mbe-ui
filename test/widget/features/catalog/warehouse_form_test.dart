import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouse_form.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouse_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.warehouses, rawValue: 15)],
);

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.warehouses, rawValue: 2)],
);

final _warehouse = Warehouse(
  warehouseId: 1,
  facilityId: 9,
  facilityName: 'Main Store',
  code: 'WH-1',
  name: 'Main Warehouse',
  status: EntityStatus.active,
);

Facility _facility(int id) => Facility(
  facilityId: id,
  code: 'FAC-$id',
  name: 'Facility $id',
  type: FacilityType.store,
  locationId: '55600',
  locationLabel: '55600',
  addressId: 1,
  addressLabel: 'Address',
  taxpayerRfc: 'AAA010101AAA',
  status: EntityStatus.active,
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockWarehouseRepository repository;
  late MockFacilityRepository facilityRepository;

  setUp(() {
    repository = MockWarehouseRepository();
    facilityRepository = MockFacilityRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? warehouseId,
    bool forceReadOnly = false,
  }) async {
    if (warehouseId != null) {
      when(
        () => repository.get(warehouseId: warehouseId),
      ).thenAnswer((_) async => _warehouse);
    }
    // Post-save invalidation resolves the affected facility's type
    // (018-nested-facility-management research §6) — stub a default so
    // save/delete flows don't need per-test wiring.
    when(
      () => facilityRepository.get(facilityId: any(named: 'facilityId')),
    ).thenAnswer((invocation) async {
      final id = invocation.namedArguments[#facilityId] as int;
      return _facility(id);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          warehouseRepositoryProvider.overrideWithValue(repository),
          facilityRepositoryProvider.overrideWithValue(facilityRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WarehouseForm(
              warehouseId: warehouseId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('view mode (forceReadOnly)', () {
    testWidgets(
      'read-only view has no editable fields or delete affordance, and the '
      'edit toggle appears in the record action area — this form has no '
      'AppBar of its own at all now (spec 035)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          warehouseId: 1,
          forceReadOnly: true,
        );

        final codeField = tester.widget<TextFormField>(
          find.byKey(const Key('code_field')),
        );
        expect(codeField.enabled, isFalse);
        expect(find.byKey(const Key('delete_warehouse_button')), findsNothing);
        expect(find.byKey(const Key('edit_warehouse_button')), findsOneWidget);
        expect(find.byType(AppBar), findsNothing);
      },
    );

    testWidgets('a user without update privilege gets no edit toggle', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _readOnlyUser,
        warehouseId: 1,
        forceReadOnly: true,
      );

      expect(find.byKey(const Key('edit_warehouse_button')), findsNothing);
    });
  });

  group('edit mode', () {
    testWidgets(
      'a user with delete privilege sees the Delete button, and confirming '
      'a still-referenced rejection leaves the form in place',
      (tester) async {
        when(() => repository.delete(warehouseId: 1)).thenThrow(
          const AppError.server(
            statusCode: 400,
            message: 'Warehouse is referenced by a purchase order',
          ),
        );

        await pumpScreen(tester, signedInAs: _fullAccessUser, warehouseId: 1);

        expect(
          find.byKey(const Key('delete_warehouse_button')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('delete_warehouse_button')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('confirm_delete_warehouse_button')),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('code_field')), findsOneWidget);
      },
    );

    testWidgets('cancelling the confirmation dialog does not delete', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser, warehouseId: 1);

      await tester.tap(find.byKey(const Key('delete_warehouse_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(
        () => repository.delete(warehouseId: any(named: 'warehouseId')),
      );
    });

    testWidgets('a duplicate-code server rejection is surfaced on the form '
        'without discarding input (FR-012)', (tester) async {
      when(
        () => repository.create(
          facilityId: any(named: 'facilityId'),
          code: any(named: 'code'),
          name: any(named: 'name'),
          comment: any(named: 'comment'),
          status: any(named: 'status'),
        ),
      ).thenThrow(
        AppError.validation([
          const FieldError(
            loc: ['code'],
            msg: 'Code already in use',
            type: 'value_error',
          ),
        ]),
      );

      final container = ProviderContainer(
        overrides: [
          warehouseRepositoryProvider.overrideWithValue(repository),
          facilityRepositoryProvider.overrideWithValue(facilityRepository),
          accessControlProvider.overrideWithValue(_accessFor(_fullAccessUser)),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: WarehouseForm()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Selecting the facility from the form's own picker widget is brittle
      // to drive through the Autocomplete overlay in a widget test; seed it
      // directly on the controller — client-side facility validation is
      // covered separately, this test targets the server-rejection path.
      container
          .read(warehouseFormControllerProvider.notifier)
          .facilitySelected(9, 'Main Store');
      await tester.enterText(find.byKey(const Key('code_field')), 'WH-1');
      await tester.enterText(find.byKey(const Key('name_field')), 'Duplicate');

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      verify(
        () => repository.create(
          facilityId: 9,
          code: 'WH-1',
          name: 'Duplicate',
          comment: any(named: 'comment'),
          status: any(named: 'status'),
        ),
      ).called(1);
      expect(find.text('WH-1'), findsOneWidget);
      expect(find.text('Duplicate'), findsOneWidget);
      expect(find.text('Code already in use'), findsOneWidget);
    });
  });

  group('create mode with a pre-selected facility (018-nested-facility-'
      'management FR-022/FR-023)', () {
    testWidgets('a facilityId cold load pre-selects the parent facility', (
      tester,
    ) async {
      when(
        () => facilityRepository.get(facilityId: 9),
      ).thenAnswer((_) async => _facility(9));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            warehouseRepositoryProvider.overrideWithValue(repository),
            facilityRepositoryProvider.overrideWithValue(facilityRepository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: WarehouseForm(facilityId: 9)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Facility 9'), findsOneWidget);
    });
  });

  group('in-panel Edit toggle (spec 035 FR-027/FR-028)', () {
    testWidgets(
      'pressing Edit on a read-only form makes it editable in place — no '
      'navigation, since there is no route to navigate to anymore',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          warehouseId: 1,
          forceReadOnly: true,
        );

        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('code_field')))
              .enabled,
          isFalse,
        );

        await tester.tap(find.byKey(const Key('edit_warehouse_button')));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<TextFormField>(find.byKey(const Key('code_field')))
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
      final key = GlobalKey<WarehouseFormPanelState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            warehouseRepositoryProvider.overrideWithValue(repository),
            facilityRepositoryProvider.overrideWithValue(facilityRepository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: WarehouseForm(key: key)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);
    });

    testWidgets('false until loading finishes, then true after a field edit', (
      tester,
    ) async {
      final key = GlobalKey<WarehouseFormPanelState>();
      when(
        () => repository.get(warehouseId: 1),
      ).thenAnswer((_) async => _warehouse);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            warehouseRepositoryProvider.overrideWithValue(repository),
            facilityRepositoryProvider.overrideWithValue(facilityRepository),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: WarehouseForm(key: key, warehouseId: 1)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(key.currentState!.isDirty(), isFalse);

      await tester.enterText(find.byKey(const Key('code_field')), 'WH-2');
      await tester.pump();

      expect(key.currentState!.isDirty(), isTrue);
    });
  });
}
