import 'package:data_table_2/data_table_2.dart';
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
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/payment_method_option_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/payment_method_option.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/payment_method_option_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/payment_method_options_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockPaymentMethodOptionRepository extends Mock
    implements PaymentMethodOptionRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.paymentMethodOptions, rawValue: 2),
  ],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.paymentMethodOptions, rawValue: 15),
  ],
);

final _testOptions = [
  PaymentMethodOption(
    paymentMethodOptionId: 1,
    facilityId: 9,
    facilityName: 'Main Store',
    name: 'Cash tender',
    numberOfPayments: 1,
    displayOnTicket: true,
    paymentMethod: 1,
    status: EntityStatus.active,
  ),
  PaymentMethodOption(
    paymentMethodOptionId: 2,
    facilityId: 10,
    facilityName: 'North Plant',
    name: 'Credit card, 6 months',
    numberOfPayments: 6,
    displayOnTicket: false,
    paymentMethod: 4,
    status: EntityStatus.inactive,
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockPaymentMethodOptionRepository repository;
  late MockFacilityRepository facilityRepository;

  setUp(() {
    repository = MockPaymentMethodOptionRepository();
    facilityRepository = MockFacilityRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<PaymentMethodOption> options = const [],
    ListQuery query = const ListQuery(),
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
          PaymentMethodOptionPage(items: options, total: options.length),
    );

    // Mirrors production's shape (app_router.dart): the list lives inside
    // its own `StatefulShellBranch`, with its own nested Navigator distinct
    // from the outer/root one. The filter sheet attaches to the root
    // Navigator (`useRootNavigator: true`, catalog_filter_sheet.dart) so it
    // survives a same-branch `context.go` on every live filter change — a
    // flat single-Navigator router would conflate the two and tear the
    // sheet down after the first change.
    final router = GoRouter(
      initialLocation: query.toUri('/payment-method-options').toString(),
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => navigationShell,
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/payment-method-options',
                  builder: (_, state) => Scaffold(
                    body: PaymentMethodOptionsListScreen(
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
          paymentMethodOptionRepositoryProvider.overrideWithValue(repository),
          facilityRepositoryProvider.overrideWithValue(facilityRepository),
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

  testWidgets('shows facility name (not a raw id) for every option (FR-004)', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      options: _testOptions,
    );

    expect(find.text('Main Store'), findsOneWidget);
    expect(find.text('North Plant'), findsOneWidget);
  });

  testWidgets('shows an inactive badge for an inactive option', (tester) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      options: _testOptions,
    );

    expect(find.byKey(const Key('status_badge_inactive')), findsOneWidget);
  });

  testWidgets(
    'search box, pagination, and filter button are present (FR-002, FR-031)',
    (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        options: _testOptions,
      );

      expect(
        find.byKey(const Key('payment_method_options_search_field')),
        findsOneWidget,
      );
      expect(find.byType(PaginatedDataTable2), findsOneWidget);
      expect(
        find.byKey(const Key('payment_method_options_filter_button')),
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

    expect(
      find.byKey(const Key('new_payment_method_option_button')),
      findsNothing,
    );
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
        (_) async => PaymentMethodOptionPage(
          items: _testOptions,
          total: _testOptions.length,
        ),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, state) => Scaffold(
              body: PaymentMethodOptionsListScreen(
                query: ListQuery.fromUri(state.uri),
              ),
            ),
          ),
          GoRoute(
            path: '/payment-method-options/:paymentMethodOptionId',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            paymentMethodOptionRepositoryProvider.overrideWithValue(repository),
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

      await tester.tap(find.text('Cash tender'));
      await tester.pumpAndSettle();

      expect(find.text('/payment-method-options/1?view=true'), findsOneWidget);
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, options: const []);

    expect(find.byKey(const Key('payment_method_options_table')), findsNothing);
  });

  testWidgets(
    'a status facet in the URL is passed to the repository '
    '(017-ui-consistency-filters US3)',
    (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        options: _testOptions,
        query: const ListQuery(
          facets: {
            'status': ['inactive'],
          },
        ),
      );

      verify(
        () => repository.list(
          search: any(named: 'search'),
          facilityId: any(named: 'facilityId'),
          status: EntityStatus.inactive,
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).called(greaterThanOrEqualTo(1));
    },
  );
}
