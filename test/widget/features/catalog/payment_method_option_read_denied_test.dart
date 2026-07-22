import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/nav_destination.dart';
import 'package:mbe_ui/core/navigation/nav_destinations.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';

const _noPmoReadUser = User(
  userId: 'u',
  email: 'u@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [], // deliberately no paymentMethodOptions privilege
);

const _pmoReaderUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.paymentMethodOptions, rawValue: 2),
  ],
);

/// Finds every leaf [NavDestination] in a filtered nav tree.
Iterable<NavDestination> _allDestinations(List<NavItem> tree) sync* {
  for (final item in tree) {
    switch (item) {
      case NavDestination():
        yield item;
      case NavGroup():
        yield* _allDestinations(item.children);
    }
  }
}

void main() {
  // FR-009, FR-028, SC-007: a user lacking read on `paymentMethodOptions`
  // never sees the Payment Method Options destination in the (filtered) nav
  // tree the app actually renders from.

  test('the Payment Method Options destination is absent without read '
      'privilege (SC-007)', () {
    final container = ProviderContainer(
      overrides: [
        accessControlProvider.overrideWithValue(
          AccessControlService(
            AuthState.authenticated(token: 't', user: _noPmoReadUser),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final tree = container.read(navDestinationsProvider);
    final ids = _allDestinations(tree).map((d) => d.id);

    expect(ids, isNot(contains('payment-method-options')));
  });

  test('the Payment Method Options destination appears with read privilege', () {
    final container = ProviderContainer(
      overrides: [
        accessControlProvider.overrideWithValue(
          AccessControlService(
            AuthState.authenticated(token: 't', user: _pmoReaderUser),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final tree = container.read(navDestinationsProvider);
    final ids = _allDestinations(tree).map((d) => d.id);

    expect(ids, contains('payment-method-options'));
  });
}
