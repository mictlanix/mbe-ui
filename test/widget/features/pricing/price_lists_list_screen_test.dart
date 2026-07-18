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
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/pricing/data/price_list_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/price_list.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/price_list_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/price_lists_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockPriceListRepository extends Mock implements PriceListRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.priceLists, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.priceLists, rawValue: 15)],
);

const _testLists = [
  PriceList(
    priceListId: 1,
    name: 'Retail',
    highProfitMargin: '0.40',
    lowProfitMargin: '0.10',
  ),
  PriceList(
    priceListId: 2,
    name: 'Wholesale',
    highProfitMargin: '0.20',
    lowProfitMargin: '0.05',
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockPriceListRepository repository;

  setUp(() {
    repository = MockPriceListRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<PriceList> lists = _testLists,
  }) async {
    when(
      () => repository.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => PriceListResult(items: lists, total: lists.length),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          priceListRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: PriceListsListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows name and margins as percentages for every list', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.text('Retail'), findsOneWidget);
    expect(find.text('Wholesale'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
  });

  testWidgets('search box and pagination are present', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byKey(const Key('price_lists_search_field')), findsOneWidget);
    expect(find.byType(PaginatedDataTable2), findsOneWidget);
  });

  testWidgets(
    'the Edit row icon is hidden (not disabled) without update privilege '
    '(constitution §VI)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    },
  );

  testWidgets('the Edit row icon appears with update privilege', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
  });

  testWidgets('the Create button is hidden without create privilege', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.byKey(const Key('new_price_list_button')), findsNothing);
  });

  testWidgets(
    'a row click opens the read-only detail view (constitution §VI)',
    (tester) async {
      when(
        () => repository.list(
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            PriceListResult(items: _testLists, total: _testLists.length),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: PriceListsListScreen()),
          ),
          GoRoute(
            path: '/price-lists/:priceListId',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            priceListRepositoryProvider.overrideWithValue(repository),
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

      await tester.tap(find.text('Retail'));
      await tester.pumpAndSettle();

      expect(find.text('/price-lists/1?view=true'), findsOneWidget);
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, lists: const []);

    expect(find.byKey(const Key('price_lists_table')), findsNothing);
  });
}
