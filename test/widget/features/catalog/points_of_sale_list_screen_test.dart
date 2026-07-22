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
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/point_sale.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/points_of_sale_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockPointSaleRepository extends Mock implements PointSaleRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.pointsOfSale, rawValue: 2),
  ],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.pointsOfSale, rawValue: 15),
  ],
);

final _testPointsOfSale = [
  PointSale(
    pointSaleId: 1,
    facilityId: 9,
    facilityName: 'Main Store',
    code: 'POS-1',
    name: 'Front Counter',
    warehouseId: 5,
    warehouseName: 'Main Warehouse',
    status: EntityStatus.active,
  ),
  PointSale(
    pointSaleId: 2,
    facilityId: 10,
    facilityName: 'North Plant',
    code: 'POS-2',
    name: 'Back Counter',
    warehouseId: 6,
    warehouseName: 'North Warehouse',
    status: EntityStatus.inactive,
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockPointSaleRepository repository;
  late MockFacilityRepository facilityRepository;
  late MockWarehouseRepository warehouseRepository;

  setUp(() {
    repository = MockPointSaleRepository();
    facilityRepository = MockFacilityRepository();
    warehouseRepository = MockWarehouseRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<PointSale> pointsOfSale = const [],
  }) async {
    when(
      () => repository.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        warehouseId: any(named: 'warehouseId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => PointSaleListResult(
        items: pointsOfSale,
        total: pointsOfSale.length,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pointSaleRepositoryProvider.overrideWithValue(repository),
          facilityRepositoryProvider.overrideWithValue(facilityRepository),
          warehouseRepositoryProvider.overrideWithValue(warehouseRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: PointsOfSaleListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows both facility and warehouse by name (not raw ids) for every '
    'record (FR-021)',
    (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        pointsOfSale: _testPointsOfSale,
      );

      expect(find.text('Main Store'), findsOneWidget);
      expect(find.text('Main Warehouse'), findsOneWidget);
      expect(find.text('North Plant'), findsOneWidget);
      expect(find.text('North Warehouse'), findsOneWidget);
    },
  );

  testWidgets('shows an inactive badge for an inactive record', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      pointsOfSale: _testPointsOfSale,
    );

    expect(find.byKey(const Key('status_badge_inactive')), findsOneWidget);
  });

  testWidgets(
    'search box, pagination, and the three-facet filter button are present',
    (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        pointsOfSale: _testPointsOfSale,
      );

      expect(
        find.byKey(const Key('points_of_sale_search_field')),
        findsOneWidget,
      );
      expect(find.byType(PaginatedDataTable2), findsOneWidget);
      expect(
        find.byKey(const Key('points_of_sale_filter_button')),
        findsOneWidget,
      );
    },
  );

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

    expect(find.byKey(const Key('new_point_sale_button')), findsNothing);
  });

  testWidgets(
    'a row click opens the read-only detail view (constitution §VI)',
    (tester) async {
      when(
        () => repository.list(
          search: any(named: 'search'),
          facilityId: any(named: 'facilityId'),
          warehouseId: any(named: 'warehouseId'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => PointSaleListResult(
          items: _testPointsOfSale,
          total: _testPointsOfSale.length,
        ),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: PointsOfSaleListScreen()),
          ),
          GoRoute(
            path: '/points-of-sale/:pointSaleId',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pointSaleRepositoryProvider.overrideWithValue(repository),
            facilityRepositoryProvider.overrideWithValue(facilityRepository),
            warehouseRepositoryProvider.overrideWithValue(
              warehouseRepository,
            ),
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

      await tester.tap(find.text('Front Counter'));
      await tester.pumpAndSettle();

      expect(find.text('/points-of-sale/1?view=true'), findsOneWidget);
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      pointsOfSale: const [],
    );

    expect(find.byKey(const Key('points_of_sale_table')), findsNothing);
  });
}
