import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/widgets/app_navigation.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A user with `read` on both catalogs, so Users + Products are both visible.
const _bothUser = User(
  userId: 'both',
  email: 'both@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.users, rawValue: 2),
    Privilege(systemObject: SystemObject.products, rawValue: 2),
  ],
);

/// Only Users read — Products must be hidden.
const _usersOnlyUser = User(
  userId: 'users',
  email: 'users@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.users, rawValue: 2)],
);

/// No catalog privileges — the whole Catalogs group must disappear.
const _noCatalogsUser = User(
  userId: 'none',
  email: 'none@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [],
);

/// Only `pricing` (106) read — Pricing visible, Price Lists and Exchange
/// Rates absent (spec 011 quickstart §5, T047: pricing without priceLists).
const _pricingOnlyUser = User(
  userId: 'pricing-only',
  email: 'pricing-only@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.pricing, rawValue: 2)],
);

/// No pricing-related privileges at all (spec 011 quickstart §5: "no
/// privileges → no nav entries").
const _noPricingUser = User(
  userId: 'no-pricing',
  email: 'no-pricing@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [],
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  Future<void> pumpNav(
    WidgetTester tester, {
    required User user,
    AppNavigationMode mode = AppNavigationMode.rail,
    int currentIndex = 0,
    ValueChanged<int>? onSelected,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [accessControlProvider.overrideWithValue(_accessFor(user))],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: AppNavigation(
                mode: mode,
                currentIndex: currentIndex,
                onDestinationSelected: onSelected ?? (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final mode in AppNavigationMode.values) {
    testWidgets('[$mode] shows Home + grouped Users/Products for a full user', (
      tester,
    ) async {
      await pumpNav(tester, user: _bothUser, mode: mode);

      expect(find.byKey(const Key('nav_dest_home')), findsOneWidget);
      expect(find.byKey(const Key('nav_group_catalogs')), findsOneWidget);
      expect(find.byKey(const Key('nav_dest_users')), findsOneWidget);
      expect(find.byKey(const Key('nav_dest_products')), findsOneWidget);
    });

    testWidgets('[$mode] hides Products for a user without products.read', (
      tester,
    ) async {
      await pumpNav(tester, user: _usersOnlyUser, mode: mode);

      expect(find.byKey(const Key('nav_dest_users')), findsOneWidget);
      expect(find.byKey(const Key('nav_dest_products')), findsNothing);
      // The group header survives because it still has one visible child.
      expect(find.byKey(const Key('nav_group_catalogs')), findsOneWidget);
    });

    testWidgets('[$mode] hides the empty Catalogs group entirely (FR-006)', (
      tester,
    ) async {
      await pumpNav(tester, user: _noCatalogsUser, mode: mode);

      expect(find.byKey(const Key('nav_dest_home')), findsOneWidget);
      expect(find.byKey(const Key('nav_group_catalogs')), findsNothing);
      expect(find.byKey(const Key('nav_dest_users')), findsNothing);
      expect(find.byKey(const Key('nav_dest_products')), findsNothing);
    });

    testWidgets(
      '[$mode] pricing without priceLists: Pricing visible, Price Lists '
      'and Exchange Rates absent (spec 011 T047)',
      (tester) async {
        await pumpNav(tester, user: _pricingOnlyUser, mode: mode);

        expect(find.byKey(const Key('nav_dest_pricing')), findsOneWidget);
        expect(find.byKey(const Key('nav_dest_price-lists')), findsNothing);
        expect(find.byKey(const Key('nav_dest_exchange-rates')), findsNothing);
      },
    );

    testWidgets('[$mode] no pricing privileges: none of the three pricing nav '
        'entries appear (spec 011 T047)', (tester) async {
      await pumpNav(tester, user: _noPricingUser, mode: mode);

      expect(find.byKey(const Key('nav_dest_price-lists')), findsNothing);
      expect(find.byKey(const Key('nav_dest_pricing')), findsNothing);
      expect(find.byKey(const Key('nav_dest_exchange-rates')), findsNothing);
    });
  }

  testWidgets('selecting Products reports its branch index (2)', (
    tester,
  ) async {
    int? selected;
    await pumpNav(tester, user: _bothUser, onSelected: (i) => selected = i);

    await tester.tap(find.byKey(const Key('nav_dest_products')));
    expect(selected, 2);
  });

  testWidgets('the active destination renders with its selected icon', (
    tester,
  ) async {
    await pumpNav(tester, user: _bothUser, currentIndex: 2);

    // Products is active -> filled icon; Home is not -> outlined icon.
    expect(
      find.descendant(
        of: find.byKey(const Key('nav_dest_products')),
        matching: find.byIcon(Icons.inventory_2),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('nav_dest_home')),
        matching: find.byIcon(Icons.home_outlined),
      ),
      findsOneWidget,
    );
  });
}
