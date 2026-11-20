import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/branding/brand_config.dart';
import 'package:mbe_ui/core/branding/brand_config_provider.dart';
import 'package:mbe_ui/core/widgets/app_navigation.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

/// A user with `read` on both catalogs, so Users + Products are both visible.
const _bothUser = User(
  userId: 'both',
  email: 'both@example.com',
  administrator: false,
  status: EntityStatus.active,
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
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.users, rawValue: 2)],
);

/// No privileges — every section must disappear.
const _noCatalogsUser = User(
  userId: 'none',
  email: 'none@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

/// Only `pricing` (106) read — Pricing visible, Price Lists and Exchange
/// Rates absent (spec 011 quickstart §5, T047: pricing without priceLists).
const _pricingOnlyUser = User(
  userId: 'pricing-only',
  email: 'pricing-only@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.pricing, rawValue: 2)],
);

/// Only `priceLists` (5) read — the Price Lists entry (Inventario) is visible,
/// but no `pricing` privilege means Operación must not appear (spec 011; the
/// sections are spec 077's).
const _priceListsOnlyUser = User(
  userId: 'price-lists-only',
  email: 'price-lists-only@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.priceLists, rawValue: 2)],
);

/// No pricing-related privileges at all (spec 011 quickstart §5: "no
/// privileges → no nav entries").
const _noPricingUser = User(
  userId: 'no-pricing',
  email: 'no-pricing@example.com',
  administrator: false,
  status: EntityStatus.active,
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
    BrandConfig? brand,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          accessControlProvider.overrideWithValue(_accessFor(user)),
          if (brand != null) brandConfigProvider.overrideWithValue(brand),
        ],
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
      // Users sit in Sistema, Products in Inventario (spec 077 FR-018).
      expect(find.byKey(const Key('nav_group_system')), findsOneWidget);
      expect(find.byKey(const Key('nav_group_inventory')), findsOneWidget);
      expect(find.byKey(const Key('nav_dest_users')), findsOneWidget);
      expect(find.byKey(const Key('nav_dest_products')), findsOneWidget);
    });

    testWidgets('[$mode] hides Products for a user without products.read', (
      tester,
    ) async {
      await pumpNav(tester, user: _usersOnlyUser, mode: mode);

      expect(find.byKey(const Key('nav_dest_users')), findsOneWidget);
      expect(find.byKey(const Key('nav_dest_products')), findsNothing);
      // Sistema survives because it still has one visible child; Inventario
      // (Products' section) has none left and goes.
      expect(find.byKey(const Key('nav_group_system')), findsOneWidget);
      expect(find.byKey(const Key('nav_group_inventory')), findsNothing);
    });

    testWidgets('[$mode] hides every empty section entirely (FR-006)', (
      tester,
    ) async {
      await pumpNav(tester, user: _noCatalogsUser, mode: mode);

      expect(find.byKey(const Key('nav_dest_home')), findsOneWidget);
      for (final group in ['operation', 'inventory', 'finance', 'system']) {
        expect(
          find.byKey(Key('nav_group_$group')),
          findsNothing,
          reason: group,
        );
      }
      expect(find.byKey(const Key('nav_dest_users')), findsNothing);
      expect(find.byKey(const Key('nav_dest_products')), findsNothing);
    });

    testWidgets(
      '[$mode] pricing without priceLists: Operación (Pricing) is visible, '
      'Price Lists and Exchange Rates absent (spec 011 T047, sections per '
      'spec 077)',
      (tester) async {
        await pumpNav(tester, user: _pricingOnlyUser, mode: mode);

        expect(find.byKey(const Key('nav_group_operation')), findsOneWidget);
        expect(find.byKey(const Key('nav_dest_pricing')), findsOneWidget);
        expect(find.byKey(const Key('nav_dest_price-lists')), findsNothing);
        expect(find.byKey(const Key('nav_dest_exchange-rates')), findsNothing);
        // Inventario (Price Lists) and Finanzas (Exchange Rates) survive only
        // if another of their children is visible; here none are, so both
        // must be dropped too (FR-006).
        expect(find.byKey(const Key('nav_group_inventory')), findsNothing);
        expect(find.byKey(const Key('nav_group_finance')), findsNothing);
      },
    );

    testWidgets('[$mode] no pricing privileges: neither Operación nor '
        'any of the three pricing nav entries appear (spec 011 T047)', (
      tester,
    ) async {
      await pumpNav(tester, user: _noPricingUser, mode: mode);

      expect(find.byKey(const Key('nav_group_operation')), findsNothing);
      expect(find.byKey(const Key('nav_dest_price-lists')), findsNothing);
      expect(find.byKey(const Key('nav_dest_pricing')), findsNothing);
      expect(find.byKey(const Key('nav_dest_exchange-rates')), findsNothing);
    });

    testWidgets(
      '[$mode] a user with only priceLists (no pricing) sees Inventario but '
      'not Operación — the two sections are independently visible '
      '(spec 011, sections per spec 077)',
      (tester) async {
        await pumpNav(tester, user: _priceListsOnlyUser, mode: mode);

        expect(find.byKey(const Key('nav_group_inventory')), findsOneWidget);
        expect(find.byKey(const Key('nav_dest_price-lists')), findsOneWidget);
        expect(find.byKey(const Key('nav_group_operation')), findsNothing);
        expect(find.byKey(const Key('nav_dest_pricing')), findsNothing);
      },
    );
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

  testWidgets(
    'an overridden brand shows its own display name, not the XBE default (spec 019 US5, FR-007)',
    (tester) async {
      // The rail no longer carries the brand header itself (it's fixed in
      // AppShell's app bar instead — see app_shell_test.dart); the drawer
      // still renders it via BrandNavHeader, so that's exercised here. The
      // name shows from 840px up (spec 077 FR-012), so pump a wide view.
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpNav(
        tester,
        user: _bothUser,
        mode: AppNavigationMode.drawer,
        brand: const BrandConfig(
          displayName: 'CASA MAESTRA',
          usesDefaultPalette: false,
        ),
      );

      expect(find.text('CASA MAESTRA'), findsOneWidget);
      expect(find.text('Mictlanix Business Essentials'), findsNothing);
    },
  );

  testWidgets('below 840px the header is the mark alone, whatever the brand '
      '(spec 077 FR-012)', (tester) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpNav(
      tester,
      user: _bothUser,
      mode: AppNavigationMode.drawer,
      brand: const BrandConfig(
        displayName: 'CASA MAESTRA',
        usesDefaultPalette: false,
      ),
    );

    expect(find.text('CASA MAESTRA'), findsNothing);
  });
}
