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

const _noTaxpayersReadUser = User(
  userId: 'u',
  email: 'u@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [], // deliberately no taxpayers privilege
);

const _taxpayersReaderUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.taxpayers, rawValue: 2)],
);

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
  // FR-018, FR-028, SC-007: a user lacking read on `taxpayers` never sees
  // the Taxpayer Issuers destination — and, since the Certificates section
  // (US3) is reachable only through that same issuer detail screen, it is
  // covered by the same gate (no separate destination exists for it).

  test('the Taxpayer Issuers destination is absent without read privilege '
      '(SC-007)', () {
    final container = ProviderContainer(
      overrides: [
        accessControlProvider.overrideWithValue(
          AccessControlService(
            AuthState.authenticated(token: 't', user: _noTaxpayersReadUser),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final tree = container.read(navDestinationsProvider);
    final ids = _allDestinations(tree).map((d) => d.id);

    expect(ids, isNot(contains('taxpayer-issuers')));
  });

  test('the Taxpayer Issuers destination appears with read privilege', () {
    final container = ProviderContainer(
      overrides: [
        accessControlProvider.overrideWithValue(
          AccessControlService(
            AuthState.authenticated(token: 't', user: _taxpayersReaderUser),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final tree = container.read(navDestinationsProvider);
    final ids = _allDestinations(tree).map((d) => d.id);

    expect(ids, contains('taxpayer-issuers'));
  });
}
