import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouses_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.warehouses, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.warehouses, rawValue: 15)],
);

final _testWarehouses = [
  Warehouse(
    warehouseId: 1,
    facilityId: 9,
    facilityName: 'Main Store',
    code: 'WH-1',
    name: 'Main Warehouse',
    status: EntityStatus.active,
  ),
  Warehouse(
    warehouseId: 2,
    facilityId: 10,
    facilityName: 'North Plant',
    code: 'WH-2',
    name: 'North Warehouse',
    status: EntityStatus.inactive,
  ),
];

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
    List<Warehouse> warehouses = const [],
  }) async {
    when(
      () => repository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          WarehouseListResult(items: warehouses, total: warehouses.length),
    );

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
          home: const Scaffold(body: WarehousesListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows facility name (not a raw id) for every warehouse (FR-015)', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      warehouses: _testWarehouses,
    );

    expect(find.text('Main Store'), findsOneWidget);
    expect(find.text('North Plant'), findsOneWidget);
  });

  testWidgets('shows an inactive badge for an inactive warehouse', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      warehouses: _testWarehouses,
    );

    expect(find.byKey(const Key('status_badge_inactive')), findsOneWidget);
  });

  testWidgets('search box, pagination, and filter button are present', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      warehouses: _testWarehouses,
    );

    expect(find.byKey(const Key('warehouses_search_field')), findsOneWidget);
    expect(find.byType(PaginatedDataTable2), findsOneWidget);
    expect(find.byKey(const Key('warehouses_filter_button')), findsOneWidget);
  });

  testWidgets(
    'the Edit row icon is hidden (not disabled) without update privilege '
    '(constitution §VI)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    },
  );

  testWidgets('the Create button is hidden without create privilege', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.byKey(const Key('new_warehouse_button')), findsNothing);
  });

  testWidgets(
    'a row click opens the read-only detail view (constitution §VI)',
    (tester) async {
      when(
        () => repository.list(
          search: any(named: 'search'),
          facilityId: any(named: 'facilityId'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => WarehouseListResult(
          items: _testWarehouses,
          total: _testWarehouses.length,
        ),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: WarehousesListScreen()),
          ),
          GoRoute(
            path: '/warehouses/:warehouseId',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
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

      await tester.tap(find.text('Main Warehouse'));
      await tester.pumpAndSettle();

      expect(find.text('/warehouses/1?view=true'), findsOneWidget);
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, warehouses: const []);

    expect(find.byKey(const Key('warehouses_table')), findsNothing);
  });
}
