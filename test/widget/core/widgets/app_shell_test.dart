import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/widgets/app_navigation.dart';
import 'package:mbe_ui/core/widgets/app_shell.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

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

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

GoRouter _shellRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (_, _) => const Text('HOME BODY')),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/users',
              builder: (_, _) => const Text('USERS BODY'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/products',
              builder: (_, _) => const Text('PRODUCTS BODY'),
            ),
          ],
        ),
      ],
    ),
  ],
);

Future<void> _pumpShell(WidgetTester tester, {required Size size}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accessControlProvider.overrideWithValue(_accessFor(_bothUser)),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _shellRouter(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('at wide width the rail is persistent and there is no drawer '
      'menu button', (tester) async {
    await _pumpShell(tester, size: const Size(1200, 800));

    // Rail destinations are on screen without opening anything.
    expect(find.byKey(const Key('nav_dest_home')), findsOneWidget);
    expect(find.byKey(const Key('nav_dest_products')), findsOneWidget);
    // No hamburger menu button in the app bar.
    expect(find.byIcon(Icons.menu), findsNothing);
    expect(find.text('HOME BODY'), findsOneWidget);
  });

  testWidgets('at narrow width navigation lives behind a drawer menu button', (
    tester,
  ) async {
    await _pumpShell(tester, size: const Size(500, 900));

    // Not persistently on screen.
    expect(find.byKey(const Key('nav_dest_home')), findsNothing);
    // Opened from the app-bar menu button.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nav_dest_home')), findsOneWidget);
    expect(find.byKey(const Key('nav_dest_products')), findsOneWidget);
  });

  testWidgets('the app-bar title tracks the active destination', (
    tester,
  ) async {
    await _pumpShell(tester, size: const Size(1200, 800));

    final title = find.descendant(
      of: find.byType(AppBar),
      matching: find.text('Home'),
    );
    expect(title, findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_dest_products')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Products')),
      findsOneWidget,
    );
    expect(find.text('PRODUCTS BODY'), findsOneWidget);
  });

  testWidgets('selecting a rail destination switches the branch (goBranch)', (
    tester,
  ) async {
    await _pumpShell(tester, size: const Size(1200, 800));

    expect(find.text('HOME BODY'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_dest_users')));
    await tester.pumpAndSettle();

    expect(find.text('USERS BODY'), findsOneWidget);
    expect(find.text('HOME BODY'), findsNothing);
  });

  testWidgets('renders one AppNavigation (rail) at wide width', (tester) async {
    await _pumpShell(tester, size: const Size(1200, 800));
    final nav = tester.widget<AppNavigation>(find.byType(AppNavigation));
    expect(nav.mode, AppNavigationMode.rail);
  });
}
