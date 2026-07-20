import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/currency.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/pricing/data/exchange_rate_repository_impl.dart';
import 'package:mbe_ui/features/pricing/domain/entities/exchange_rate.dart';
import 'package:mbe_ui/features/pricing/domain/repositories/exchange_rate_repository.dart';
import 'package:mbe_ui/features/pricing/presentation/exchange_rate_form_controller.dart';

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

ProviderContainer _containerFor(User user, ExchangeRateRepository repository) {
  final c = ProviderContainer(
    overrides: [
      exchangeRateRepositoryProvider.overrideWithValue(repository),
      accessControlProvider.overrideWithValue(
        AccessControlService(AuthState.authenticated(token: 't', user: user)),
      ),
    ],
  );
  return c;
}

void main() {
  late MockExchangeRateRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockExchangeRateRepository();
    container = _containerFor(_fullAccessUser, repository);
    addTearDown(container.dispose);
  });

  group('validation (FR-016, FR-018)', () {
    test('an empty date is rejected before submit', () async {
      final notifier = container.read(
        exchangeRateFormControllerProvider.notifier,
      );
      notifier
        ..rateChanged('17.50')
        ..baseChanged(Currency.usd)
        ..targetChanged(Currency.mxn);

      await notifier.submitCreate();

      final state = container.read(exchangeRateFormControllerProvider);
      expect(state.fieldErrors['date'], ExchangeRateFormErrorCode.dateRequired);
    });

    test(
      'a zero rate is rejected — unlike prices, a rate cannot be zero',
      () async {
        final notifier = container.read(
          exchangeRateFormControllerProvider.notifier,
        );
        notifier
          ..dateChanged(DateTime(2026, 7, 17))
          ..rateChanged('0')
          ..baseChanged(Currency.usd)
          ..targetChanged(Currency.mxn);

        await notifier.submitCreate();

        final state = container.read(exchangeRateFormControllerProvider);
        expect(
          state.fieldErrors['rate'],
          ExchangeRateFormErrorCode.rateInvalid,
        );
      },
    );

    test('missing currencies are rejected', () async {
      final notifier = container.read(
        exchangeRateFormControllerProvider.notifier,
      );
      notifier
        ..dateChanged(DateTime(2026, 7, 17))
        ..rateChanged('17.50');

      await notifier.submitCreate();

      final state = container.read(exchangeRateFormControllerProvider);
      expect(
        state.fieldErrors['base'],
        ExchangeRateFormErrorCode.currencyRequired,
      );
      expect(
        state.fieldErrors['target'],
        ExchangeRateFormErrorCode.currencyRequired,
      );
    });
  });

  group('submitCreate', () {
    test('a valid submission creates the exchange rate', () async {
      when(
        () => repository.create(
          date: DateTime(2026, 7, 17),
          rate: '17.50',
          base: Currency.usd.value,
          target: Currency.mxn.value,
        ),
      ).thenAnswer(
        (_) async => ExchangeRate(
          exchangeRateId: 1,
          date: DateTime(2026, 7, 17),
          rate: '17.50',
          rawBase: 1,
          rawTarget: 0,
          base: Currency.usd,
          target: Currency.mxn,
        ),
      );

      final notifier = container.read(
        exchangeRateFormControllerProvider.notifier,
      );
      notifier
        ..dateChanged(DateTime(2026, 7, 17))
        ..rateChanged('17.50')
        ..baseChanged(Currency.usd)
        ..targetChanged(Currency.mxn);

      await notifier.submitCreate();

      expect(container.read(exchangeRateFormControllerProvider).saved, isTrue);
    });
  });
}
