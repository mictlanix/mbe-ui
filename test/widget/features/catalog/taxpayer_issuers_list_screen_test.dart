import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart'
    show FiscalCertificationProvider;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/taxpayer_issuer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/sat_catalog_item.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_issuer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_issuer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_issuers_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockTaxpayerIssuerRepository extends Mock
    implements TaxpayerIssuerRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.taxpayers, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.taxpayers, rawValue: 15)],
);

final _testIssuers = [
  TaxpayerIssuer(
    rfc: 'XAXX010101000',
    name: 'Acme Corp',
    provider: FiscalCertificationProvider.number1,
    postalCode: const SatCatalogItem(code: '06000', description: 'Centro'),
    regime: const SatCatalogItem(code: '601', description: 'General de Ley'),
  ),
  TaxpayerIssuer(
    rfc: 'BBB010101B01',
    name: 'North Supplies',
    provider: FiscalCertificationProvider.number1,
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockTaxpayerIssuerRepository repository;

  setUp(() {
    repository = MockTaxpayerIssuerRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<TaxpayerIssuer> issuers = const [],
    ListQuery query = const ListQuery(),
  }) async {
    when(
      () => repository.listDetail(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => TaxpayerIssuerPage(items: issuers, total: issuers.length),
    );

    final router = GoRouter(
      initialLocation: query.toUri('/taxpayer-issuers').toString(),
      routes: [
        GoRoute(
          path: '/taxpayer-issuers',
          builder: (_, state) => Scaffold(
            body: TaxpayerIssuersListScreen(
              query: ListQuery.fromUri(state.uri),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taxpayerIssuerRepositoryProvider.overrideWithValue(repository),
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

  testWidgets('shows RFC and name for every issuer (FR-010)', (tester) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      issuers: _testIssuers,
    );

    expect(find.text('XAXX010101000'), findsOneWidget);
    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('North Supplies'), findsOneWidget);
  });

  testWidgets(
    'shows postal code and fiscal regime columns too, matching the legacy '
    'screen (FR-010) — both arrive pre-expanded, no per-row lookup',
    (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _fullAccessUser,
        issuers: _testIssuers,
      );

      expect(find.text('Centro'), findsOneWidget);
      expect(find.text('General de Ley'), findsOneWidget);
      verifyNever(() => repository.get(any()));
      verifyNever(() => repository.getDetail(any()));
    },
  );

  testWidgets('a functional search box is present, with no filter drawer '
      '(search-only catalog, contracts/mbe-api-catalogs.md §2)', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      issuers: _testIssuers,
    );

    expect(
      find.byKey(const Key('taxpayer_issuers_search_field')),
      findsOneWidget,
    );
    expect(find.byType(PaginatedDataTable2), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsNothing);
  });

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

    expect(find.byKey(const Key('new_taxpayer_issuer_button')), findsNothing);
  });

  testWidgets(
    'a row click opens the read-only detail view (constitution §VI)',
    (tester) async {
      when(
        () => repository.listDetail(
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async =>
            TaxpayerIssuerPage(items: _testIssuers, total: _testIssuers.length),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, state) => Scaffold(
              body: TaxpayerIssuersListScreen(
                query: ListQuery.fromUri(state.uri),
              ),
            ),
          ),
          GoRoute(
            path: '/taxpayer-issuers/:rfc',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taxpayerIssuerRepositoryProvider.overrideWithValue(repository),
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

      await tester.tap(find.text('Acme Corp'));
      await tester.pumpAndSettle();

      expect(
        find.text('/taxpayer-issuers/XAXX010101000?view=true'),
        findsOneWidget,
      );
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, issuers: const []);

    expect(find.byKey(const Key('taxpayer_issuers_table')), findsNothing);
  });
}
