import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/config/app_settings_provider.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/nav_destination.dart';
import 'package:mbe_ui/core/navigation/nav_destinations.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';

/// Spec 049 FR-003/FR-004: the exchange-rates destination exists only on a
/// multi-currency deployment, on top of its privilege gate.
void main() {
  const exchangeRatesReader = Privilege(
    systemObject: SystemObject.exchangeRates,
    rawValue: 2,
  );

  Set<String> visibleIds({
    required bool multiCurrency,
    required bool administrator,
    List<Privilege> privileges = const [],
  }) {
    final user = User(
      userId: 'u',
      email: 'u@example.com',
      administrator: administrator,
      status: EntityStatus.active,
      sessionVersion: 1,
      privileges: privileges,
    );
    final container = ProviderContainer(
      overrides: [
        multiCurrencyEnabledProvider.overrideWithValue(multiCurrency),
        accessControlProvider.overrideWithValue(
          AccessControlService(AuthState.authenticated(token: 't', user: user)),
        ),
      ],
    );
    addTearDown(container.dispose);
    return {
      for (final item in container.read(navDestinationsProvider))
        ...switch (item) {
          NavDestination() => [item.id],
          NavGroup() => item.children.map((d) => d.id),
        },
    };
  }

  test('off: the entry is hidden even for an administrator', () {
    expect(
      visibleIds(multiCurrency: false, administrator: true),
      isNot(contains('exchange-rates')),
    );
  });

  test('on: an administrator sees it', () {
    expect(
      visibleIds(multiCurrency: true, administrator: true),
      contains('exchange-rates'),
    );
  });

  test('on: the privilege gate still applies', () {
    expect(
      visibleIds(multiCurrency: true, administrator: false),
      isNot(contains('exchange-rates')),
    );
    expect(
      visibleIds(
        multiCurrency: true,
        administrator: false,
        privileges: const [exchangeRatesReader],
      ),
      contains('exchange-rates'),
    );
  });

  test('the option does not hide other destinations', () {
    expect(
      visibleIds(multiCurrency: false, administrator: true),
      contains('price-lists'),
    );
  });

  test('routeRequiresMultiCurrency covers the destination and its records', () {
    expect(routeRequiresMultiCurrency('/exchange-rates'), isTrue);
    expect(routeRequiresMultiCurrency('/exchange-rates/new'), isTrue);
    expect(routeRequiresMultiCurrency('/exchange-rates/7'), isTrue);
    expect(routeRequiresMultiCurrency('/products'), isFalse);
    expect(routeRequiresMultiCurrency('/exchange-rates-archive'), isFalse);
  });
}
