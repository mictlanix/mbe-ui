import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/point_sale_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/cash_drawer_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/point_sale_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/cash_drawers_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/points_of_sale_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouses_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

class MockCashDrawerRepository extends Mock implements CashDrawerRepository {}

class MockPointSaleRepository extends Mock implements PointSaleRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

/// A user who can read all three operational catalogs but NOT facilities.
const _noFacilityReadUser = User(
  userId: 'u',
  email: 'u@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.warehouses, rawValue: 2),
    Privilege(systemObject: SystemObject.cashDrawers, rawValue: 2),
    Privilege(systemObject: SystemObject.pointsOfSale, rawValue: 2),
    // deliberately no facilities privilege
  ],
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  // FR-025: when the current user cannot read facilities, the facility
  // picker/filter degrades to its empty state (CatalogEntityPicker swallows
  // the read denial and returns no options) rather than failing the screen.
  // These assert the three operational list screens still render.

  testWidgets('the Warehouses list still renders when facilities are '
      'unreadable (FR-025)', (tester) async {
    final warehouseRepo = MockWarehouseRepository();
    final facilityRepo = MockFacilityRepository();
    when(
      () => warehouseRepo.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const WarehouseListResult(items: [], total: 0));
    when(
      () => facilityRepo.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(const AppError.server(statusCode: 403));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          warehouseRepositoryProvider.overrideWithValue(warehouseRepo),
          facilityRepositoryProvider.overrideWithValue(facilityRepo),
          accessControlProvider.overrideWithValue(
            _accessFor(_noFacilityReadUser),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: WarehousesListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('warehouses_search_field')), findsOneWidget);
    expect(find.byKey(const Key('warehouses_filter_button')), findsOneWidget);
  });

  testWidgets('the Cash Drawers list still renders when facilities are '
      'unreadable (FR-025)', (tester) async {
    final cashDrawerRepo = MockCashDrawerRepository();
    final facilityRepo = MockFacilityRepository();
    when(
      () => cashDrawerRepo.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const CashDrawerListResult(items: [], total: 0));
    when(
      () => facilityRepo.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(const AppError.server(statusCode: 403));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cashDrawerRepositoryProvider.overrideWithValue(cashDrawerRepo),
          facilityRepositoryProvider.overrideWithValue(facilityRepo),
          accessControlProvider.overrideWithValue(
            _accessFor(_noFacilityReadUser),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CashDrawersListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('cash_drawers_search_field')), findsOneWidget);
  });

  testWidgets('the Points of Sale list still renders when facilities are '
      'unreadable (FR-025)', (tester) async {
    final pointSaleRepo = MockPointSaleRepository();
    final facilityRepo = MockFacilityRepository();
    final warehouseRepo = MockWarehouseRepository();
    when(
      () => pointSaleRepo.list(
        search: any(named: 'search'),
        facilityId: any(named: 'facilityId'),
        warehouseId: any(named: 'warehouseId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => const PointSaleListResult(items: [], total: 0));
    when(
      () => facilityRepo.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenThrow(const AppError.server(statusCode: 403));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pointSaleRepositoryProvider.overrideWithValue(pointSaleRepo),
          facilityRepositoryProvider.overrideWithValue(facilityRepo),
          warehouseRepositoryProvider.overrideWithValue(warehouseRepo),
          accessControlProvider.overrideWithValue(
            _accessFor(_noFacilityReadUser),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: PointsOfSaleListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const Key('points_of_sale_search_field')),
      findsOneWidget,
    );
  });
}
