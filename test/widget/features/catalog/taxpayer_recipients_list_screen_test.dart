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
import 'package:mbe_ui/features/catalog/data/taxpayer_recipient_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/taxpayer_recipient_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/taxpayer_recipient_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/taxpayer_recipients_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockTaxpayerRecipientRepository extends Mock
    implements TaxpayerRecipientRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.taxpayerRecipients, rawValue: 2),
  ],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.taxpayerRecipients, rawValue: 15),
  ],
);

const _testTaxpayers = [
  TaxpayerRecipientListItem(
    taxpayerRecipientId: 'XAXX010101000',
    name: 'Acme Corp',
    email: 'acme@example.com',
  ),
  TaxpayerRecipientListItem(
    taxpayerRecipientId: 'BETA020202000',
    name: 'Beta LLC',
    email: 'beta@example.com',
  ),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockTaxpayerRecipientRepository repository;

  setUp(() {
    repository = MockTaxpayerRecipientRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<TaxpayerRecipientListItem> taxpayers = _testTaxpayers,
  }) async {
    when(
      () => repository.list(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async =>
          TaxpayerRecipientPage(items: taxpayers, total: taxpayers.length),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taxpayerRecipientRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: TaxpayerRecipientsListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows tax id, name, and email for every recipient', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.text('XAXX010101000'), findsOneWidget);
    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('acme@example.com'), findsOneWidget);
  });

  testWidgets('search box and pagination are present', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(
      find.byKey(const Key('taxpayer_recipients_search_field')),
      findsOneWidget,
    );
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

  testWidgets('the Create button is hidden without create privilege', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(
      find.byKey(const Key('new_taxpayer_recipient_button')),
      findsNothing,
    );
  });

  testWidgets(
    'a row click opens the read-only detail view with the String id in '
    'the route (constitution §VI)',
    (tester) async {
      when(
        () => repository.list(
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => TaxpayerRecipientPage(
          items: _testTaxpayers,
          total: _testTaxpayers.length,
        ),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                const Scaffold(body: TaxpayerRecipientsListScreen()),
          ),
          GoRoute(
            path: '/taxpayer-recipients/:taxpayerRecipientId',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taxpayerRecipientRepositoryProvider.overrideWithValue(repository),
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
        find.text('/taxpayer-recipients/XAXX010101000?view=true'),
        findsOneWidget,
      );
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, taxpayers: const []);

    expect(find.byKey(const Key('taxpayer_recipients_table')), findsNothing);
  });
}
