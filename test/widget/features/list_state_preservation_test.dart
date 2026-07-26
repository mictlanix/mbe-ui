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

/// 017-ui-consistency-filters US4: navigating from a list into a record and
/// back must restore the list's search/filters/page exactly as they were
/// left (FR-024, already true today via GoRouter push/pop — this is a
/// regression pin so Phase 4's URL-driven-filter refactor cannot quietly
/// break it), and returning after a mutation must show the SAME page
/// refreshed (FR-025) — clamping to the nearest valid page if that page no
/// longer exists (FR-026). Uses Warehouses as the representative screen: it
/// has both a status facet and an FK facet, and a conventional
/// create/edit/delete form controller shared by every other converted
/// catalog.
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

Warehouse _warehouse(int id, {String name = 'Main Warehouse'}) => Warehouse(
  warehouseId: id,
  facilityId: 9,
  facilityName: 'Main Store',
  code: 'WH-$id',
  name: name,
  status: EntityStatus.active,
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

  group('viewing a record and going back preserves the list (FR-024) — '
      'already true today via GoRouter push/pop; pinned so Phase 4 cannot '
      'regress it', () {
    testWidgets(
      'the address, and the selected status facet, survive a round trip '
      'into a record and back',
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
          (_) async => WarehouseListResult(items: [_warehouse(1)], total: 1),
        );
        when(
          () => repository.get(warehouseId: 1),
        ).thenAnswer((_) async => _warehouse(1));

        await pump(tester, initialLocation: '/warehouses?status=inactive');
        expect(
          router.routeInformationProvider.value.uri.toString(),
          '/warehouses?status=inactive',
        );

        await tester.tap(find.text('Main Warehouse'));
        await tester.pumpAndSettle();
        expect(find.byType(WarehouseDetailScreen), findsOneWidget);

        router.pop();
        await tester.pumpAndSettle();

        expect(find.byType(WarehousesListScreen), findsOneWidget);
        expect(
          router.routeInformationProvider.value.uri.toString(),
          '/warehouses?status=inactive',
        );

        await tester.tap(find.byKey(const Key('warehouses_filter_button')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('warehouses_filter_status_inactive')),
          findsOneWidget,
        );
      },
    );
  });

  group(
    'returning after a mutation shows the same page refreshed (FR-025)',
    () {
      testWidgets(
        'updating a record on page 2 returns to page 2 with the change '
        'reflected, without resetting to page 0',
        (tester) async {
          when(
            () => repository.list(
              search: any(named: 'search'),
              facilityId: any(named: 'facilityId'),
              status: any(named: 'status'),
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async =>
                WarehouseListResult(items: [_warehouse(21)], total: 21),
          );
          when(
            () => repository.get(warehouseId: 21),
          ).thenAnswer((_) async => _warehouse(21));
          when(
            () => repository.update(
              warehouseId: 21,
              facilityId: any(named: 'facilityId'),
              code: any(named: 'code'),
              name: any(named: 'name'),
              comment: any(named: 'comment'),
              status: any(named: 'status'),
            ),
          ).thenAnswer((_) async => _warehouse(21, name: 'Renamed Warehouse'));

          await pump(tester, initialLocation: '/warehouses?page=2');
          expect(find.text('Main Warehouse'), findsOneWidget);

          await tester.tap(find.byIcon(Icons.edit_outlined));
          await tester.pumpAndSettle();
          expect(find.byType(WarehouseDetailScreen), findsOneWidget);

          // The edit form loaded — confirm the correct record (21, from
          // page 2) was loaded, not page 0's.
          expect(
            (tester.widget(find.byKey(const Key('name_field')))
                    as TextFormField)
                .initialValue,
            'Main Warehouse',
          );

          // Mutate and save: after this succeeds, subsequent list fetches
          // for the SAME skip=20 must reflect the rename.
          when(
            () => repository.list(
              search: any(named: 'search'),
              facilityId: any(named: 'facilityId'),
              status: any(named: 'status'),
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async => WarehouseListResult(
              items: [_warehouse(21, name: 'Renamed Warehouse')],
              total: 21,
            ),
          );

          await tester.enterText(
            find.byKey(const Key('name_field')),
            'Renamed Warehouse',
          );
          await tester.tap(find.byKey(const Key('save_button')));
          await tester.pumpAndSettle();

          // Back on the list, still addressed at page 2, showing the
          // renamed item — not reset to page 0, not stale.
          expect(find.byType(WarehousesListScreen), findsOneWidget);
          expect(
            router.routeInformationProvider.value.uri.toString(),
            '/warehouses?page=2',
          );
          expect(find.text('Renamed Warehouse'), findsOneWidget);
          expect(find.text('Main Warehouse'), findsNothing);
        },
      );

      testWidgets(
        'deleting the only item on the last page clamps to the nearest '
        'valid page rather than showing an empty view (FR-026)',
        (tester) async {
          when(
            () => repository.list(
              search: any(named: 'search'),
              facilityId: any(named: 'facilityId'),
              status: any(named: 'status'),
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async =>
                WarehouseListResult(items: [_warehouse(21)], total: 21),
          );
          when(
            () => repository.get(warehouseId: 21),
          ).thenAnswer((_) async => _warehouse(21));
          when(
            () => repository.delete(warehouseId: 21),
          ).thenAnswer((_) async {});

          await pump(tester, initialLocation: '/warehouses?page=2');
          expect(find.text('Main Warehouse'), findsOneWidget);

          await tester.tap(find.byIcon(Icons.edit_outlined));
          await tester.pumpAndSettle();
          expect(find.byType(WarehouseDetailScreen), findsOneWidget);

          // After the delete, the page-2 slot (skip=20) is empty — but 20
          // items remain on page 1 (skip=0). fetchClampedPage must land
          // there instead of showing an empty view.
          when(
            () => repository.list(
              search: any(named: 'search'),
              facilityId: any(named: 'facilityId'),
              status: any(named: 'status'),
              skip: 20,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async => const WarehouseListResult(items: [], total: 20),
          );
          when(
            () => repository.list(
              search: any(named: 'search'),
              facilityId: any(named: 'facilityId'),
              status: any(named: 'status'),
              skip: 0,
              limit: 20,
            ),
          ).thenAnswer(
            (_) async => WarehouseListResult(
              items: List.generate(20, (i) => _warehouse(i)),
              total: 20,
            ),
          );

          await tester.tap(find.byKey(const Key('delete_warehouse_button')));
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const Key('confirm_delete_warehouse_button')),
          );
          await tester.pumpAndSettle();

          expect(find.byType(WarehousesListScreen), findsOneWidget);
          expect(find.byKey(const Key('warehouses_table')), findsOneWidget);
          verify(
            () => repository.list(
              search: any(named: 'search'),
              facilityId: any(named: 'facilityId'),
              status: any(named: 'status'),
              skip: 0,
              limit: 20,
            ),
          ).called(greaterThanOrEqualTo(1));
        },
      );
    },
  );
}
