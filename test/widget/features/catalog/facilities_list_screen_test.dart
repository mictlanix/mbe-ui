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
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/cash_drawer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/facilities_list_controller.dart';
import 'package:mbe_ui/features/catalog/presentation/facilities_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockFacilityRepository extends Mock implements FacilityRepository {}

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

class MockPointSaleRepository extends Mock implements PointSaleRepository {}

class MockCashDrawerRepository extends Mock implements CashDrawerRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.facilities, rawValue: 2),
    Privilege(systemObject: SystemObject.warehouses, rawValue: 2),
    Privilege(systemObject: SystemObject.pointsOfSale, rawValue: 2),
    Privilege(systemObject: SystemObject.cashDrawers, rawValue: 2),
  ],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.facilities, rawValue: 15),
    Privilege(systemObject: SystemObject.warehouses, rawValue: 15),
    Privilege(systemObject: SystemObject.pointsOfSale, rawValue: 15),
    Privilege(systemObject: SystemObject.cashDrawers, rawValue: 15),
  ],
);

const _store = FacilityListItem(
  facilityId: 1,
  code: 'FAC-1',
  name: 'Main Store',
  type: FacilityType.store,
  status: EntityStatus.active,
);

const _productionSite = FacilityListItem(
  facilityId: 2,
  code: 'FAC-2',
  name: 'North Plant',
  type: FacilityType.productionSite,
  status: EntityStatus.inactive,
);

Warehouse _warehouse(int id, int facilityId) => Warehouse(
  warehouseId: id,
  facilityId: facilityId,
  facilityName: 'Facility $facilityId',
  code: 'WH-$id',
  name: 'Warehouse $id',
  status: EntityStatus.active,
);

PointSale _pointSale(int id, int facilityId, int warehouseId) => PointSale(
  pointSaleId: id,
  facilityId: facilityId,
  facilityName: 'Facility $facilityId',
  code: 'PS-$id',
  name: 'Point of Sale $id',
  warehouseId: warehouseId,
  warehouseName: 'Warehouse $warehouseId',
  status: EntityStatus.active,
);

CashDrawer _cashDrawer(int id, int facilityId) => CashDrawer(
  cashDrawerId: id,
  facilityId: facilityId,
  facilityName: 'Facility $facilityId',
  code: 'CD-$id',
  name: 'Cash Drawer $id',
  status: EntityStatus.active,
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockFacilityRepository facilityRepository;
  late MockWarehouseRepository warehouseRepository;
  late MockPointSaleRepository pointSaleRepository;
  late MockCashDrawerRepository cashDrawerRepository;

  setUp(() {
    facilityRepository = MockFacilityRepository();
    warehouseRepository = MockWarehouseRepository();
    pointSaleRepository = MockPointSaleRepository();
    cashDrawerRepository = MockCashDrawerRepository();

    // Every card is non-lazy (research §1): default every child fetch to
    // empty so a test that doesn't care about children isn't forced to stub
    // three repositories just to render the list.
    when(
      () => warehouseRepository.list(
        facilityId: any(named: 'facilityId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));
    when(
      () => pointSaleRepository.list(
        facilityId: any(named: 'facilityId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const PointSaleListResult(items: [], total: 0));
    when(
      () => cashDrawerRepository.list(
        facilityId: any(named: 'facilityId'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const CashDrawerListResult(items: [], total: 0));
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<FacilityListItem> facilities = const [],
    ListQuery query = const ListQuery(),
  }) async {
    when(
      () => facilityRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          FacilityListResult(items: facilities, total: facilities.length),
    );

    // Mirrors production's shape (app_router.dart): the list lives inside
    // its own `StatefulShellBranch` with a route for every navigation
    // target this screen can push to, so `context.push` never 404s mid-test.
    final router = GoRouter(
      initialLocation: query.toUri('/facilities').toString(),
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => navigationShell,
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/facilities',
                  builder: (_, state) => Scaffold(
                    body: FacilitiesListScreen(
                      query: ListQuery.fromUri(state.uri),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/facilities/:facilityId',
          builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
        ),
        GoRoute(
          path: '/facilities/new',
          builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
        ),
        for (final path in [
          '/warehouses',
          '/points-of-sale',
          '/cash-drawers',
        ]) ...[
          GoRoute(
            path: '$path/new',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
          GoRoute(
            path: '$path/:id',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          facilityRepositoryProvider.overrideWithValue(facilityRepository),
          warehouseRepositoryProvider.overrideWithValue(warehouseRepository),
          pointSaleRepositoryProvider.overrideWithValue(pointSaleRepository),
          cashDrawerRepositoryProvider.overrideWithValue(cashDrawerRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('collapsed card (US1, FR-006)', () {
    testWidgets('shows name, code, type, status and child counts without '
        'expanding', (tester) async {
      when(
        () => warehouseRepository.list(
          facilityId: 1,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => WarehouseListResult(
          items: [_warehouse(1, 1), _warehouse(2, 1)],
          total: 2,
        ),
      );
      when(
        () => pointSaleRepository.list(
          facilityId: 1,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            PointSaleListResult(items: [_pointSale(1, 1, 1)], total: 1),
      );

      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_store],
      );

      expect(find.text('Main Store'), findsOneWidget);
      expect(find.text('FAC-1'), findsOneWidget);
      expect(find.text('Store'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // warehouse count
      expect(find.text('1'), findsOneWidget); // point-of-sale count
      expect(find.text('0'), findsOneWidget); // cash-drawer count
      // Expanded body not yet built.
      expect(
        find.byKey(const Key('facility_section_warehouses_1')),
        findsNothing,
      );
    });

    testWidgets('shows an inactive badge for an inactive facility', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_productionSite],
      );

      expect(find.byKey(const Key('status_badge_inactive')), findsOneWidget);
    });
  });

  group('expanded card (US1, FR-007/FR-008/FR-011)', () {
    testWidgets('reveals three sections with rows for a store', (tester) async {
      when(
        () => warehouseRepository.list(
          facilityId: 1,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => WarehouseListResult(items: [_warehouse(1, 1)], total: 1),
      );
      when(
        () => cashDrawerRepository.list(
          facilityId: 1,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => CashDrawerListResult(items: [_cashDrawer(1, 1)], total: 1),
      );

      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_store],
      );
      await tester.tap(find.byKey(const Key('facility_card_toggle_1')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('facility_section_warehouses_1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('facility_section_points_of_sale_1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('facility_section_cash_drawers_1')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('warehouse_row_1')), findsOneWidget);
      expect(find.byKey(const Key('cash_drawer_row_1')), findsOneWidget);
      expect(find.text('Warehouse 1'), findsOneWidget);
      expect(find.text('WH-1'), findsOneWidget);
      expect(find.text('Cash Drawer 1'), findsOneWidget);
    });

    testWidgets(
      'a production site shows only Warehouses plus the explanatory note',
      (tester) async {
        when(
          () => warehouseRepository.list(
            facilityId: 2,
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => WarehouseListResult(items: [_warehouse(1, 2)], total: 1),
        );

        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          facilities: [_productionSite],
        );
        await tester.tap(find.byKey(const Key('facility_card_toggle_2')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('facility_section_warehouses_2')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('facility_section_points_of_sale_2')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('facility_section_cash_drawers_2')),
          findsNothing,
        );
        expect(
          find.text(
            AppLocalizations.of(
              tester.element(find.byKey(const Key('facilities_search_field'))),
            )!.productionSiteChildrenNote,
          ),
          findsOneWidget,
        );
        // Never even requested for a production site (research §2).
        verifyNever(
          () => pointSaleRepository.list(
            facilityId: 2,
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        );
      },
    );

    testWidgets('an empty section shows its named placeholder', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_store],
      );
      await tester.tap(find.byKey(const Key('facility_card_toggle_1')));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byKey(const Key('facilities_search_field'))),
      )!;
      expect(find.text(l10n.noWarehousesInFacility), findsOneWidget);
      expect(find.text(l10n.noPointsOfSaleInFacility), findsOneWidget);
      expect(find.text(l10n.noCashDrawersInFacility), findsOneWidget);
    });

    testWidgets('a point of sale drawing stock from another facility is badged '
        '(FR-009, research §3)', (tester) async {
      when(
        () => warehouseRepository.list(
          facilityId: 1,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => WarehouseListResult(items: [_warehouse(1, 1)], total: 1),
      );
      when(
        () => pointSaleRepository.list(
          facilityId: 1,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        // Draws from warehouse 99, which is not among facility 1's own
        // warehouses (only warehouse 1 is).
        (_) async =>
            PointSaleListResult(items: [_pointSale(1, 1, 99)], total: 1),
      );

      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_store],
      );
      await tester.tap(find.byKey(const Key('facility_card_toggle_1')));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byKey(const Key('facilities_search_field'))),
      )!;
      expect(find.text(l10n.pointSaleForeignFacilityBadge), findsOneWidget);
    });

    testWidgets(
      'a failure loading one facility\'s children is isolated to that '
      'card, with a working retry (FR-020)',
      (tester) async {
        when(
          () => warehouseRepository.list(
            facilityId: 1,
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('boom'));

        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          facilities: [_store],
        );
        await tester.tap(find.byKey(const Key('facility_card_toggle_1')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('facility_children_retry_1')),
          findsOneWidget,
        );

        when(
          () => warehouseRepository.list(
            facilityId: 1,
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => WarehouseListResult(items: [_warehouse(1, 1)], total: 1),
        );
        await tester.tap(find.byKey(const Key('facility_children_retry_1')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('warehouse_row_1')), findsOneWidget);
      },
    );
  });

  group('expand-all toggle (FR-012)', () {
    testWidgets('expands every facility on the page and flips its label', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_store, _productionSite],
      );

      final l10n = AppLocalizations.of(
        tester.element(find.byKey(const Key('facilities_search_field'))),
      )!;
      expect(find.text(l10n.facilitiesExpandAll), findsOneWidget);

      await tester.tap(find.byKey(const Key('facilities_expand_all')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('facility_section_warehouses_1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('facility_section_warehouses_2')),
        findsOneWidget,
      );
      expect(find.text(l10n.facilitiesCollapseAll), findsOneWidget);
    });
  });

  group('RBAC (FR-028/FR-029)', () {
    testWidgets('Create actions are hidden without the create privilege', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser, facilities: [_store]);

      expect(find.byKey(const Key('new_facility_button')), findsNothing);

      await tester.tap(find.byKey(const Key('facility_card_toggle_1')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('facility_create_warehouse_1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('facility_create_point_sale_1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('facility_create_cash_drawer_1')),
        findsNothing,
      );
      expect(find.byKey(const Key('facility_edit_1')), findsNothing);
    });

    testWidgets(
      'a section is omitted entirely without read privilege on that object',
      (tester) async {
        const noPosUser = User(
          userId: 'no-pos',
          email: 'no-pos@example.com',
          administrator: false,
          status: EntityStatus.active,
          sessionVersion: 1,
          privileges: [
            Privilege(systemObject: SystemObject.facilities, rawValue: 15),
            Privilege(systemObject: SystemObject.warehouses, rawValue: 15),
            Privilege(systemObject: SystemObject.cashDrawers, rawValue: 15),
          ],
        );

        await pumpScreen(tester, signedInAs: noPosUser, facilities: [_store]);
        await tester.tap(find.byKey(const Key('facility_card_toggle_1')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('facility_section_warehouses_1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('facility_section_points_of_sale_1')),
          findsNothing,
        );
      },
    );
  });

  group('navigation (FR-022/FR-024/FR-025)', () {
    testWidgets('the header body opens the facility read-only', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_store],
      );

      await tester.tap(find.text('Main Store'));
      await tester.pumpAndSettle();

      expect(find.text('/facilities/1?view=true'), findsOneWidget);
    });

    testWidgets('a child row opens that record read-only', (tester) async {
      when(
        () => warehouseRepository.list(
          facilityId: 1,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => WarehouseListResult(items: [_warehouse(1, 1)], total: 1),
      );

      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_store],
      );
      await tester.tap(find.byKey(const Key('facility_card_toggle_1')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Warehouse 1'));
      await tester.pumpAndSettle();

      expect(find.text('/warehouses/1?view=true'), findsOneWidget);
    });

    testWidgets('a section create action opens the blank form with the parent '
        'facility pre-selected via the URL (FR-022/FR-023)', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_store],
      );
      await tester.tap(find.byKey(const Key('facility_card_toggle_1')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('facility_create_warehouse_1')));
      await tester.pumpAndSettle();

      expect(find.text('/warehouses/new?facility=1'), findsOneWidget);
    });
  });

  group('retained from before this feature (FR-014/FR-015/FR-016)', () {
    testWidgets('search box and filter button are present', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_store],
      );

      expect(find.byKey(const Key('facilities_search_field')), findsOneWidget);
      expect(find.byKey(const Key('facilities_filter_button')), findsOneWidget);
    });

    testWidgets('an empty result shows the empty state', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        facilities: const [],
      );

      expect(find.byKey(const Key('facilities_card_list')), findsNothing);
      expect(find.byKey(const Key('list_state_empty')), findsOneWidget);
    });

    testWidgets('a status facet in the URL is passed to the repository', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_store],
        query: const ListQuery(
          facets: {
            'status': ['inactive'],
          },
        ),
      );

      verify(
        () => facilityRepository.list(
          search: any(named: 'search'),
          status: EntityStatus.inactive,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets(
      'page and expansion survive a mutation elsewhere invalidating the '
      'facilities list (FR-027)',
      (tester) async {
        final page0 = List.generate(
          20,
          (i) => FacilityListItem(
            facilityId: i + 1,
            code: 'FAC-${i + 1}',
            name: 'Facility ${i + 1}',
            type: FacilityType.store,
            status: EntityStatus.active,
          ),
        );
        final page1 = List.generate(
          5,
          (i) => FacilityListItem(
            facilityId: i + 21,
            code: 'FAC-${i + 21}',
            name: 'Facility ${i + 21}',
            type: FacilityType.store,
            status: EntityStatus.active,
          ),
        );
        when(
          () => facilityRepository.list(
            search: any(named: 'search'),
            status: any(named: 'status'),
            skip: 0,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => FacilityListResult(items: page0, total: 25));
        when(
          () => facilityRepository.list(
            search: any(named: 'search'),
            status: any(named: 'status'),
            skip: 20,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => FacilityListResult(items: page1, total: 25));

        final container = ProviderContainer(
          overrides: [
            facilityRepositoryProvider.overrideWithValue(facilityRepository),
            warehouseRepositoryProvider.overrideWithValue(warehouseRepository),
            pointSaleRepositoryProvider.overrideWithValue(pointSaleRepository),
            cashDrawerRepositoryProvider.overrideWithValue(
              cashDrawerRepository,
            ),
            accessControlProvider.overrideWithValue(
              _accessFor(_fullAccessUser),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(
                body: FacilitiesListScreen(query: ListQuery(pageIndex: 1)),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Facility 21'), findsOneWidget);
        expect(find.text('Facility 1'), findsNothing);

        await tester.tap(find.byKey(const Key('facility_card_toggle_21')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('facility_section_warehouses_21')),
          findsOneWidget,
        );

        // Simulates the effect of a save elsewhere (a child form's
        // `_invalidateCaches`-style invalidation of the facilities list) —
        // the screen itself never resets pageIndex or expansion state.
        container.invalidate(
          facilitiesListControllerProvider(const FacilityFilter(pageIndex: 1)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Facility 21'), findsOneWidget);
        expect(find.text('Facility 1'), findsNothing);
        expect(
          find.byKey(const Key('facility_section_warehouses_21')),
          findsOneWidget,
        );
      },
    );
  });

  group('compact tier (US4, FR-031)', () {
    Future<void> pumpCompact(
      WidgetTester tester, {
      required User signedInAs,
      List<FacilityListItem> facilities = const [],
    }) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await pumpScreen(tester, signedInAs: signedInAs, facilities: facilities);
    }

    testWidgets('renders without horizontal overflow at 390px width', (
      tester,
    ) async {
      when(
        () => warehouseRepository.list(
          facilityId: 1,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => WarehouseListResult(items: [_warehouse(1, 1)], total: 1),
      );
      when(
        () => pointSaleRepository.list(
          facilityId: 1,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            PointSaleListResult(items: [_pointSale(1, 1, 1)], total: 1),
      );

      await pumpCompact(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_store],
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('facility_card_toggle_1')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the create-facility FAB is present and RBAC-gated', (
      tester,
    ) async {
      await pumpCompact(
        tester,
        signedInAs: _fullAccessUser,
        facilities: [_store],
      );
      expect(find.byKey(const Key('new_facility_fab')), findsOneWidget);
      // The wide-tier toolbar button is not also shown.
      expect(find.byKey(const Key('new_facility_button')), findsNothing);
    });

    testWidgets('the FAB is absent without facilities:create', (tester) async {
      await pumpCompact(
        tester,
        signedInAs: _readOnlyUser,
        facilities: [_store],
      );
      expect(find.byKey(const Key('new_facility_fab')), findsNothing);
    });

    testWidgets(
      "a section's create action is still reachable, grouped at the end "
      'of the expanded card (FR-031, contracts §6)',
      (tester) async {
        await pumpCompact(
          tester,
          signedInAs: _fullAccessUser,
          facilities: [_store],
        );
        await tester.tap(find.byKey(const Key('facility_card_toggle_1')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('facility_create_warehouse_1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('facility_create_point_sale_1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('facility_create_cash_drawer_1')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
