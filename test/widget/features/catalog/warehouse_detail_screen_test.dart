import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouse_detail_screen.dart';
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
            body: WarehouseDetailScreen(
              warehouseId: warehouseId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('read-only view has no editable fields or delete affordance', (
    tester,
  ) async {
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
  });

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

  testWidgets('delete requires a confirmation dialog before submit (FR-007)', (
    tester,
  ) async {
    when(
      () => repository.get(warehouseId: 1),
    ).thenAnswer((_) async => _warehouse);
    when(
      () => repository.delete(warehouseId: 1),
    ).thenAnswer((_) async {});

    // Router-wrapped so the post-delete `context.pop()` (constitution §VI —
    // return to the list on success) has somewhere to go, mirroring the list
    // screen's row-click test harness.
    final router = GoRouter(
      initialLocation: '/warehouses',
      routes: [
        GoRoute(
          path: '/warehouses',
          builder: (_, _) => const Scaffold(body: Text('warehouses list')),
        ),
        GoRoute(
          path: '/warehouses/:warehouseId',
          builder: (_, state) => WarehouseDetailScreen(
            warehouseId: int.parse(state.pathParameters['warehouseId']!),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          warehouseRepositoryProvider.overrideWithValue(repository),
          facilityRepositoryProvider.overrideWithValue(facilityRepository),
          accessControlProvider.overrideWithValue(
            _accessFor(_fullAccessUser),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.push('/warehouses/1');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete_warehouse_button')));
    await tester.pumpAndSettle();

    // The dialog is up, but delete() has NOT been called yet.
    expect(find.byType(AlertDialog), findsOneWidget);
    verifyNever(() => repository.delete(warehouseId: 1));

    await tester.tap(
      find.byKey(const Key('confirm_delete_warehouse_button')),
    );
    await tester.pumpAndSettle();

    verify(() => repository.delete(warehouseId: 1)).called(1);
    // Success `context.pop()` returns to the list (constitution §VI).
    expect(find.text('warehouses list'), findsOneWidget);
  });

  testWidgets('cancelling the confirmation dialog does not delete', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, warehouseId: 1);

    await tester.tap(find.byKey(const Key('delete_warehouse_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => repository.delete(warehouseId: any(named: 'warehouseId')));
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
          home: const Scaffold(body: WarehouseDetailScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Selecting the facility from the form's own picker widget is brittle to
    // drive through the Autocomplete overlay in a widget test; seed it
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
}
