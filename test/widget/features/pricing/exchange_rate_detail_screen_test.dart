import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/pricing/data/exchange_rate_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/exchange_rate.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/exchange_rate_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rate_detail_screen.dart';
import 'package:mbe_ui/features/pricing/presentation/pricing_formatters.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockExchangeRateRepository extends Mock
    implements ExchangeRateRepository {}

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

final _existing = ExchangeRate(
  exchangeRateId: 1,
  date: DateTime(2026, 7, 17),
  rate: '17.50',
  rawBase: 1,
  rawTarget: 0,
  base: Currency.usd,
  target: Currency.mxn,
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
    int? exchangeRateId,
    bool forceReadOnly = false,
  }) async {
    if (exchangeRateId != null) {
      when(
        () => repository.get(exchangeRateId: exchangeRateId),
      ).thenAnswer((_) async => _existing);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exchangeRateRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(_fullAccessUser)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ExchangeRateDetailScreen(
              exchangeRateId: exchangeRateId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('create mode shows currency pickers, not raw ints (FR-018)', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.byKey(const Key('exchange_rate_base_field')), findsOneWidget);
    expect(find.byKey(const Key('exchange_rate_target_field')), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<Currency>), findsNWidgets(2));
  });

  testWidgets(
    'the date field opens showDatePicker and displays the selected date '
    'formatted per locale',
    (tester) async {
      await pumpScreen(tester, exchangeRateId: 1);

      expect(
        find.text(PricingFormatters.date(DateTime(2026, 7, 17))),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('exchange_rate_date_field')));
      await tester.pumpAndSettle();

      // showDatePicker's dialog is now open.
      expect(find.byType(DatePickerDialog), findsOneWidget);
    },
  );

  testWidgets('duplicate date+pair surfaces the server response clearly '
      '(research.md §8)', (tester) async {
    when(
      () => repository.get(exchangeRateId: 1),
    ).thenAnswer((_) async => _existing);
    when(
      () => repository.update(
        exchangeRateId: 1,
        date: any(named: 'date'),
        rate: any(named: 'rate'),
        base: any(named: 'base'),
        target: any(named: 'target'),
      ),
    ).thenThrow(
      const AppError.server(
        statusCode: 400,
        message:
            'An exchange rate for this date and currency pair already exists',
      ),
    );

    await pumpScreen(tester, exchangeRateId: 1);
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'An exchange rate for this date and currency pair already exists',
      ),
      findsOneWidget,
    );
  });
}
