import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/domain/facility_type.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/facility_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/facilities_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockFacilityRepository extends Mock implements FacilityRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.facilities, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.facilities, rawValue: 15)],
);

const _testFacilities = [
  FacilityListItem(
    facilityId: 1,
    code: 'FAC-1',
    name: 'Main Store',
    type: FacilityType.store,
    status: EntityStatus.active,
  ),
  FacilityListItem(
    facilityId: 2,
    code: 'FAC-2',
    name: 'North Plant',
    type: FacilityType.productionSite,
    status: EntityStatus.inactive,
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockFacilityRepository repository;

  setUp(() => repository = MockFacilityRepository());

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<FacilityListItem> facilities = const [],
    ListQuery query = const ListQuery(),
  }) async {
    when(
      () => repository.list(
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
    // its own `StatefulShellBranch`, with its own nested Navigator distinct
    // from the outer/root one. The filter sheet attaches to the root
    // Navigator (`useRootNavigator: true`, catalog_filter_sheet.dart) so it
    // survives a same-branch `context.go` on every live filter change — a
    // flat single-Navigator router would conflate the two and tear the
    // sheet down after the first change.
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
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          facilityRepositoryProvider.overrideWithValue(repository),
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

  testWidgets('shows code, name, type, and status for every facility', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      facilities: _testFacilities,
    );

    expect(find.text('Main Store'), findsOneWidget);
    expect(find.text('North Plant'), findsOneWidget);
    // Type rendered by name, not a raw number (FR-024/FR-026).
    expect(find.text('Store'), findsOneWidget);
    expect(find.text('Production Site'), findsOneWidget);
  });

  testWidgets('shows an inactive badge for an inactive facility', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      facilities: _testFacilities,
    );

    expect(find.byKey(const Key('status_badge_inactive')), findsOneWidget);
  });

  testWidgets('search box, pagination, and status filter are present', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      facilities: _testFacilities,
    );

    expect(find.byKey(const Key('facilities_search_field')), findsOneWidget);
    expect(find.byType(PaginatedDataTable2), findsOneWidget);
    expect(find.byKey(const Key('facilities_filter_button')), findsOneWidget);
  });

  testWidgets('Create and Edit are hidden without the matching privilege', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _readOnlyUser,
      facilities: _testFacilities,
    );

    expect(find.byKey(const Key('new_facility_button')), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets(
    'a row click opens the read-only detail view (constitution §VI)',
    (tester) async {
      when(
        () => repository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const FacilityListResult(items: _testFacilities, total: 2),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, state) => Scaffold(
              body: FacilitiesListScreen(query: ListQuery.fromUri(state.uri)),
            ),
          ),
          GoRoute(
            path: '/facilities/:facilityId',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            facilityRepositoryProvider.overrideWithValue(repository),
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

      await tester.tap(find.text('Main Store'));
      await tester.pumpAndSettle();

      expect(find.text('/facilities/1?view=true'), findsOneWidget);
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, facilities: const []);

    expect(find.byKey(const Key('facilities_table')), findsNothing);
  });

  testWidgets('a status facet in the URL is passed to the repository '
      '(017-ui-consistency-filters US3)', (tester) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      facilities: _testFacilities,
      query: const ListQuery(
        facets: {
          'status': ['inactive'],
        },
      ),
    );

    verify(
      () => repository.list(
        search: any(named: 'search'),
        status: EntityStatus.inactive,
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).called(greaterThanOrEqualTo(1));
  });
}
