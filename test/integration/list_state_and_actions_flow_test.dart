import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/warehouse.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouse_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouses_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// End-to-end pin for 017-ui-consistency-filters (US3+US4 combined, FR-017,
/// FR-024, FR-025): filter a list, page it, open a record from that exact
/// filtered/paged view, edit and save it, and land back on the SAME
/// filtered/paged URL with the change visible — not just each piece
/// individually (`list_state_preservation_test.dart` already pins page-only
/// and filter-only round trips separately; this pins them **combined**,
/// matching how a user actually works). Uses Warehouses as the
/// representative screen (status facet + FK facet + conventional
/// create/edit/delete controller), with data sources mocked — no live
/// backend needed, mirroring `navigation_shell_flow_test.dart`.
class MockWarehouseRepository extends Mock implements WarehouseRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: true,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

Warehouse _warehouse(int id, {String name = 'Depot Norte'}) => Warehouse(
  warehouseId: id,
  facilityId: 9,
  facilityName: 'Main Store',
  code: 'WH-$id',
  name: name,
  status: EntityStatus.inactive,
);

void main() {
  late MockWarehouseRepository repository;
  late MockFacilityRepository facilityRepository;
  late GoRouter router;

  setUp(() {
    repository = MockWarehouseRepository();
    facilityRepository = MockFacilityRepository();
  });

  Future<void> pump(
    WidgetTester tester, {
    required String initialLocation,
  }) async {
    router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => shell,
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/warehouses',
                  builder: (_, state) => Scaffold(
                    body: WarehousesListScreen(
                      query: ListQuery.fromUri(state.uri),
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: ':warehouseId',
                      builder: (_, state) => WarehouseDetailScreen(
                        warehouseId: int.parse(
                          state.pathParameters['warehouseId']!,
                        ),
                        forceReadOnly:
                            state.uri.queryParameters['view'] == 'true',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          warehouseRepositoryProvider.overrideWithValue(repository),
          facilityRepositoryProvider.overrideWithValue(facilityRepository),
          accessControlProvider.overrideWithValue(_accessFor(_fullAccessUser)),
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

  testWidgets(
    'filter a list, page it, edit a record from that view, save, and land '
    'back on the same filtered+paged URL with the change visible',
    (tester) async {
      // Page 2 (pageIndex 1, skip=20) of the `status=inactive` filtered
      // list — the exact combination `list_state_preservation_test.dart`
      // only ever varies one axis of at a time.
      when(
        () => repository.list(
          search: any(named: 'search'),
          facilityId: any(named: 'facilityId'),
          status: EntityStatus.inactive,
          skip: 20,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => WarehouseListResult(items: [_warehouse(21)], total: 21),
      );
      when(
        () => repository.get(warehouseId: 21),
      ).thenAnswer((_) async => _warehouse(21));

      await pump(tester, initialLocation: '/warehouses?status=inactive&page=2');
      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/warehouses?status=inactive&page=2',
      );
      expect(find.text('Depot Norte'), findsOneWidget);

      // Open the record straight from this filtered+paged view via its Edit
      // row action (not a bare row tap, which would open read-only).
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(WarehouseDetailScreen), findsOneWidget);
      expect(
        (tester.widget(find.byKey(const Key('name_field'))) as TextFormField)
            .initialValue,
        'Depot Norte',
      );

      // After save, the SAME filtered+paged fetch must reflect the rename.
      when(
        () => repository.list(
          search: any(named: 'search'),
          facilityId: any(named: 'facilityId'),
          status: EntityStatus.inactive,
          skip: 20,
          limit: 20,
        ),
      ).thenAnswer(
        (_) async => WarehouseListResult(
          items: [_warehouse(21, name: 'Depot Sur')],
          total: 21,
        ),
      );
      when(
        () => repository.update(
          warehouseId: 21,
          facilityId: any(named: 'facilityId'),
          code: any(named: 'code'),
          name: any(named: 'name'),
          comment: any(named: 'comment'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => _warehouse(21, name: 'Depot Sur'));

      await tester.enterText(find.byKey(const Key('name_field')), 'Depot Sur');
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      // Back on the list, addressed at the SAME filter AND page — not reset
      // to the bare path, not reset to page 0 — with the edit visible.
      expect(find.byType(WarehousesListScreen), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/warehouses?status=inactive&page=2',
      );
      expect(find.text('Depot Sur'), findsOneWidget);
      expect(find.text('Depot Norte'), findsNothing);

      // The filter sheet still shows the facet as active — the URL wasn't
      // just visually unchanged, the filter state genuinely round-tripped.
      await tester.tap(find.byKey(const Key('warehouses_filter_button')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('warehouses_filter_status_inactive')),
        findsOneWidget,
      );
    },
  );
}
