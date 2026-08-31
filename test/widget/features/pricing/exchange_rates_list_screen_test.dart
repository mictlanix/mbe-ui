import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/pricing/data/exchange_rate_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/exchange_rate.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/exchange_rate_repository.dart';
import 'package:mbe_ui/core/storage/shared_preferences_provider.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rates_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockExchangeRateRepository extends Mock
    implements ExchangeRateRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.exchangeRates, rawValue: 2),
  ],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.exchangeRates, rawValue: 15),
  ],
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockExchangeRateRepository repository;

  setUp(() {
    repository = MockExchangeRateRepository();
  });

  Future<GoRouter> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    ListQuery query = const ListQuery(),
  }) async {
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
      (_) async => ExchangeRateResult(
        items: [
          ExchangeRate(
            exchangeRateId: 1,
            date: DateTime(2026, 7, 17),
            rate: '17.50',
            rawBase: 1,
            rawTarget: 0,
          ),
        ],
        total: 1,
      ),
    );

    final router = GoRouter(
      initialLocation: query.toUri('/exchange-rates').toString(),
      routes: [
        GoRoute(
          path: '/exchange-rates',
          builder: (_, state) => Scaffold(
            body: ExchangeRatesListScreen(query: ListQuery.fromUri(state.uri)),
          ),
        ),
      ],
    );

    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          exchangeRateRepositoryProvider.overrideWithValue(repository),
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
    return router;
  }

  testWidgets(
    'a row click opens the record read-only in a panel over the list — no '
    'navigation, since there is no per-record route anymore (spec 035 US5)',
    (tester) async {
      when(
        () => repository.get(exchangeRateId: 1),
      ).thenAnswer(
        (_) async => ExchangeRate(
          exchangeRateId: 1,
          date: DateTime(2026, 7, 17),
          rate: '17.50',
          rawBase: 1,
          rawTarget: 0,
        ),
      );

      final router = await pumpScreen(tester, signedInAs: _fullAccessUser);

      await tester.tap(find.text('17.50'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/exchange-rates');
      final rateField = tester.widget<TextFormField>(
        find.byKey(const Key('exchange_rate_rate_field')),
      );
      expect(rateField.initialValue, '17.50');
      expect(rateField.enabled, isFalse);
      expect(
        find.byKey(const Key('edit_exchange_rate_button')),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows date/base/target/rate columns and filters', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.text('17.50'), findsOneWidget);
    expect(
      find.byKey(const Key('exchange_rate_date_range_filter')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('exchange_rate_base_filter')), findsOneWidget);
  });

  testWidgets('Edit icon is hidden without update privilege', (tester) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.byIcon(Icons.edit_outlined), findsNothing);
  });

  testWidgets('Edit icon appears with update privilege', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
  });

  testWidgets('Create button hidden without create privilege', (tester) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.byKey(const Key('new_exchange_rate_button')), findsNothing);
  });

  group('URL-driven filters (017-ui-consistency-filters US3)', () {
    testWidgets(
      'a base currency facet in the URL is passed to the repository',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _fullAccessUser,
          query: const ListQuery(
            facets: {
              'base': ['1'],
            },
          ),
        );

        verify(
          () => repository.list(
            dateFrom: any(named: 'dateFrom'),
            dateTo: any(named: 'dateTo'),
            base: 1,
            target: any(named: 'target'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    testWidgets('a date range facet in the URL is passed to the repository', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        query: const ListQuery(
          facets: {
            'dateFrom': ['2026-01-01'],
            'dateTo': ['2026-12-31'],
          },
        ),
      );

      verify(
        () => repository.list(
          dateFrom: DateTime(2026, 1, 1),
          dateTo: DateTime(2026, 12, 31),
          base: any(named: 'base'),
          target: any(named: 'target'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets(
      'selecting a base currency navigates to a URL carrying that facet',
      (tester) async {
        await pumpScreen(tester, signedInAs: _fullAccessUser);

        await tester.tap(find.byKey(const Key('exchange_rate_base_filter')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('USD — US Dollar').last);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('exchange_rate_base_filter')),
          findsOneWidget,
        );
        verify(
          () => repository.list(
            dateFrom: any(named: 'dateFrom'),
            dateTo: any(named: 'dateTo'),
            base: any(named: 'base', that: isNotNull),
            target: any(named: 'target'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).called(greaterThanOrEqualTo(1));
      },
    );
  });
}
