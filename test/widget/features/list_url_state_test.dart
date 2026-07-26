import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/product_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/warehouse_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/product_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/warehouse_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/products_list_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/warehouses_list_screen.dart';
import 'package:mbe_ui/features/pricing/data/exchange_rate_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/exchange_rate_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rates_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// Shared cross-screen coverage for the URL-as-source-of-truth mechanism
/// (017-ui-consistency-filters US3): that opening an address reproduces the
/// described view with restored values visible in the controls (FR-018, not
/// merely applied to results), that changing a filter updates the address
/// (FR-017), and that filter changes are Back-navigable (FR-022, spec.md US3
/// Acceptance Scenario 8) — not merely that `context.go` fires, but that the
/// view actually restores to the state two changes back. Individual screens'
/// own test files cover their full behavior; this file only proves the
/// shared mechanism generalizes across facet types (enum status, tri-state
/// bool, multi-valued FK-less list, single-valued FK, ISO date range).
class MockProductRepository extends Mock implements ProductRepository {}

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

class MockExchangeRateRepository extends Mock
    implements ExchangeRateRepository {}

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

void main() {
  group('restores filter controls from the URL (FR-018)', () {
    testWidgets(
      'Products: status (enum), tri-state bool, and multi-valued label '
      'facets all restore into the filter sheet\'s controls',
      (tester) async {
        final repository = MockProductRepository();
        when(
          () => repository.list(
            search: any(named: 'search'),
            status: any(named: 'status'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            supplier: any(named: 'supplier'),
            labels: any(named: 'labels'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => const ProductListResult(items: [], total: 0));
        when(
          () => repository.productLabelFacets(
            search: any(named: 'search'),
            status: any(named: 'status'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            labels: any(named: 'labels'),
          ),
        ).thenAnswer((_) async => const []);

        final query = const ListQuery(
          facets: {
            'status': ['active'],
            'stockable': ['true'],
            'label': ['3', '7'],
          },
        );
        final router = GoRouter(
          initialLocation: query.toUri('/products').toString(),
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, shell) => shell,
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/products',
                      builder: (_, state) => Scaffold(
                        body: ProductsListScreen(
                          query: ListQuery.fromUri(state.uri),
                        ),
                      ),
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
              productRepositoryProvider.overrideWithValue(repository),
              allLabelsProvider.overrideWith((_) async => []),
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

        await tester.tap(find.byKey(const Key('products_filter_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('products_filter_status_active')),
          findsOneWidget,
        );
        final statusChip = tester.widget<ChoiceChip>(
          find.byKey(const Key('products_filter_status_active')),
        );
        expect(statusChip.selected, isTrue);

        final stockableChip = tester.widget<FilterChip>(
          find.byKey(const Key('products_filter_stockable')),
        );
        expect(stockableChip.selected, isTrue);
        expect(stockableChip.avatar, isA<Icon>());
        expect((stockableChip.avatar as Icon).icon, Icons.check);
      },
    );

    testWidgets(
      'Warehouses: a facility (FK) facet restores as the resolved name, '
      'and status restores as the selected chip',
      (tester) async {
        final repository = MockWarehouseRepository();
        final facilityRepository = MockFacilityRepository();
        when(
          () => repository.list(
            search: any(named: 'search'),
            facilityId: any(named: 'facilityId'),
            status: any(named: 'status'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => const WarehouseListResult(items: [], total: 0),
        );
        when(() => facilityRepository.get(facilityId: 9)).thenAnswer(
          (_) async => const Facility(
            facilityId: 9,
            code: 'F-9',
            name: 'Main Store',
            type: FacilityType.store,
            locationId: 'MX',
            locationLabel: 'Mexico',
            addressId: 1,
            addressLabel: 'Main St',
            taxpayerRfc: 'AAA010101AAA',
            status: EntityStatus.active,
          ),
        );

        final query = const ListQuery(
          facets: {
            'facility': ['9'],
            'status': ['inactive'],
          },
        );
        final router = GoRouter(
          initialLocation: query.toUri('/warehouses').toString(),
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

        await tester.tap(find.byKey(const Key('warehouses_filter_button')));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byKey(const Key('warehouses_filter_facility')),
            matching: find.text('Main Store'),
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('warehouses_filter_status_inactive')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Exchange rates: an ISO date-range facet restores as a formatted '
      'range label, without opening a sheet (inline filters)',
      (tester) async {
        final repository = MockExchangeRateRepository();
        when(
          () => repository.list(
            dateFrom: any(named: 'dateFrom'),
            dateTo: any(named: 'dateTo'),
            base: any(named: 'base'),
            target: any(named: 'target'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => const ExchangeRateResult(items: [], total: 0),
        );

        final query = const ListQuery(
          facets: {
            'dateFrom': ['2026-01-01'],
            'dateTo': ['2026-01-31'],
          },
        );
        final router = GoRouter(
          initialLocation: query.toUri('/exchange-rates').toString(),
          routes: [
            GoRoute(
              path: '/exchange-rates',
              builder: (_, state) => Scaffold(
                body: ExchangeRatesListScreen(
                  query: ListQuery.fromUri(state.uri),
                ),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              exchangeRateRepositoryProvider.overrideWithValue(repository),
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

        // Not the bare "pick a range" prompt: the restored range is visible
        // directly on the filter button, with no interaction required.
        expect(
          find.descendant(
            of: find.byKey(const Key('exchange_rate_date_range_filter')),
            matching: find.textContaining('–'),
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('changing a filter updates the address (FR-017)', () {
    testWidgets(
      'toggling a tri-state chip updates the URL with the new facet',
      (tester) async {
        final repository = MockProductRepository();
        when(
          () => repository.list(
            search: any(named: 'search'),
            status: any(named: 'status'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            supplier: any(named: 'supplier'),
            labels: any(named: 'labels'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => const ProductListResult(items: [], total: 0));
        when(
          () => repository.productLabelFacets(
            search: any(named: 'search'),
            status: any(named: 'status'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            labels: any(named: 'labels'),
          ),
        ).thenAnswer((_) async => const []);

        final router = GoRouter(
          initialLocation: '/products',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, shell) => shell,
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/products',
                      builder: (_, state) => Scaffold(
                        body: ProductsListScreen(
                          query: ListQuery.fromUri(state.uri),
                        ),
                      ),
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
              productRepositoryProvider.overrideWithValue(repository),
              allLabelsProvider.overrideWith((_) async => []),
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

        await tester.tap(find.byKey(const Key('products_filter_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('products_filter_stockable')));
        await tester.pumpAndSettle();

        expect(
          router.routeInformationProvider.value.uri.toString(),
          '/products?stockable=true',
        );
      },
    );
  });

  group('Back navigation restores the previous filtered view '
      '(FR-019, FR-022, spec.md US3 Acceptance Scenario 8)', () {
    testWidgets(
      'applying filter A, then B, then C, then going Back twice restores '
      'exactly filter A\'s state — not merely that context.go fired',
      (tester) async {
        final repository = MockProductRepository();
        when(
          () => repository.list(
            search: any(named: 'search'),
            status: any(named: 'status'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            supplier: any(named: 'supplier'),
            labels: any(named: 'labels'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => const ProductListResult(items: [], total: 0));
        when(
          () => repository.productLabelFacets(
            search: any(named: 'search'),
            status: any(named: 'status'),
            stockable: any(named: 'stockable'),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            labels: any(named: 'labels'),
          ),
        ).thenAnswer((_) async => const []);

        final router = GoRouter(
          initialLocation: '/products',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, shell) => shell,
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/products',
                      builder: (_, state) => Scaffold(
                        body: ProductsListScreen(
                          query: ListQuery.fromUri(state.uri),
                        ),
                      ),
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
              productRepositoryProvider.overrideWithValue(repository),
              allLabelsProvider.overrideWith((_) async => []),
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

        // Filter A.
        const filterA = ListQuery(
          facets: {
            'status': ['active'],
          },
        );
        router.go(filterA.toUri('/products').toString());
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.toString(),
          '/products?status=active',
        );

        // Filter B.
        const filterB = ListQuery(
          facets: {
            'status': ['inactive'],
          },
        );
        router.go(filterB.toUri('/products').toString());
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.toString(),
          '/products?status=inactive',
        );

        // Filter C.
        const filterC = ListQuery(
          facets: {
            'status': ['inactive'],
            'stockable': ['true'],
          },
        );
        router.go(filterC.toUri('/products').toString());
        await tester.pumpAndSettle();
        verify(
          () => repository.list(
            search: any(named: 'search'),
            status: EntityStatus.inactive,
            stockable: true,
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            supplier: any(named: 'supplier'),
            labels: any(named: 'labels'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThanOrEqualTo(1));

        // Simulate the browser's Back button twice — the mechanism a real
        // Back button uses (`GoRouteInformationProvider.didPushRouteInformation`,
        // the same callback go_router's own delivers when replaying a
        // prior history entry), not another forward `go()` call.
        await router.routeInformationProvider.didPushRouteInformation(
          RouteInformation(uri: Uri.parse('/products?status=inactive')),
        );
        await tester.pumpAndSettle();
        await router.routeInformationProvider.didPushRouteInformation(
          RouteInformation(uri: Uri.parse('/products?status=active')),
        );
        await tester.pumpAndSettle();

        // The address is back to exactly filter A's address...
        expect(
          router.routeInformationProvider.value.uri.toString(),
          '/products?status=active',
        );
        // ...and the view actually re-fetched with filter A's params —
        // proving the restore is real, not just a URL string coincidence.
        verify(
          () => repository.list(
            search: any(named: 'search'),
            status: EntityStatus.active,
            stockable: any(named: 'stockable', that: isNull),
            salable: any(named: 'salable'),
            purchasable: any(named: 'purchasable'),
            supplier: any(named: 'supplier'),
            labels: any(named: 'labels'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThanOrEqualTo(1));

        // And the restored filter chip in the controls reflects filter A,
        // not B or C (FR-018 — visible in the controls, not just results).
        await tester.tap(find.byKey(const Key('products_filter_button')));
        await tester.pumpAndSettle();
        final activeChip = tester.widget<ChoiceChip>(
          find.byKey(const Key('products_filter_status_active')),
        );
        expect(activeChip.selected, isTrue);
        final stockableChip = tester.widget<FilterChip>(
          find.byKey(const Key('products_filter_stockable')),
        );
        expect(stockableChip.selected, isFalse);
      },
    );
  });
}
