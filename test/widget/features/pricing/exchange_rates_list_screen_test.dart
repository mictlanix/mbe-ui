import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/pricing/data/exchange_rate_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/exchange_rate.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/exchange_rate_repository.dart';
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

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exchangeRateRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: ExchangeRatesListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

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
}
