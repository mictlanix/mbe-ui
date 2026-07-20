import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/core/widgets/user_menu_button.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockTokenStorage extends Mock implements TokenStorage {}

const _userWithSettings = User(
  userId: 'admin',
  email: 'eddy@mictlanix.com',
  administrator: true,
  disabled: false,
  sessionVersion: 1,
  privileges: [],
  // Ids only, no resolved names — the labeled-ID fallback path (FR-011).
  settings: UserSettings(facilityId: 51, pointSaleId: 18, cashDrawerId: 14),
);

const _userWithResolvedNames = User(
  userId: 'admin',
  email: 'eddy@mictlanix.com',
  administrator: true,
  disabled: false,
  sessionVersion: 1,
  privileges: [],
  // /auth/me now resolves names (mbe-api#79).
  settings: UserSettings(
    facilityId: 51,
    facilityName: 'CASA MAESTRA ZUMPANGO',
    pointSaleId: 18,
    pointSaleCode: '01',
    pointSaleName: 'PV ZUMPANGO',
    cashDrawerId: 14,
    cashDrawerCode: '01',
    cashDrawerName: 'CC ZUMPANGO',
  ),
);

const _userNoSettings = User(
  userId: 'admin',
  email: 'eddy@mictlanix.com',
  administrator: true,
  disabled: false,
  sessionVersion: 1,
  privileges: [],
);

void main() {
  late _MockAuthRepository authRepository;
  late _MockTokenStorage tokenStorage;

  setUp(() {
    authRepository = _MockAuthRepository();
    tokenStorage = _MockTokenStorage();
    when(() => tokenStorage.read()).thenAnswer((_) async => 'token');
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
  });

  Future<void> pumpMenu(WidgetTester tester, {required User user}) async {
    when(() => authRepository.me()).thenAnswer((_) async => user);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            appBar: AppBar(actions: const [UserMenuButton()]),
            body: const SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: '/auth/account/password',
          builder: (_, _) => const Scaffold(body: Text('CHANGE PW SCREEN')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('user_menu_button')));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'renders exactly one trailing trigger for an authenticated user',
    (tester) async {
      await pumpMenu(tester, user: _userWithSettings);
      expect(find.byKey(const Key('user_menu_button')), findsOneWidget);
    },
  );

  testWidgets('shows identity + the three location lines as labeled-ID '
      'fallbacks when names are unresolved (FR-011)', (tester) async {
    await pumpMenu(tester, user: _userWithSettings);
    await openMenu(tester);

    expect(find.text('eddy@mictlanix.com'), findsOneWidget);
    expect(find.byKey(const Key('user_menu_facility')), findsOneWidget);
    expect(find.text('Facility 51'), findsOneWidget);
    expect(find.text('POS 18'), findsOneWidget);
    expect(find.text('Drawer 14'), findsOneWidget);
  });

  testWidgets('shows resolved facility/POS/cash-drawer names — name only, no '
      'code suffix — once /auth/me resolves them (mbe-api#79, FR-011)', (
    tester,
  ) async {
    await pumpMenu(tester, user: _userWithResolvedNames);
    await openMenu(tester);

    expect(find.text('eddy@mictlanix.com'), findsOneWidget);
    expect(find.text('CASA MAESTRA ZUMPANGO'), findsOneWidget);
    expect(find.text('PV ZUMPANGO'), findsOneWidget);
    expect(find.text('CC ZUMPANGO'), findsOneWidget);
    // The labeled-ID fallback is not shown once names resolve.
    expect(find.text('Facility 51'), findsNothing);
  });

  testWidgets('omits location lines when the user has no settings (FR-014)', (
    tester,
  ) async {
    await pumpMenu(tester, user: _userNoSettings);
    await openMenu(tester);

    expect(find.text('eddy@mictlanix.com'), findsOneWidget);
    expect(find.byKey(const Key('user_menu_facility')), findsNothing);
    expect(find.byKey(const Key('user_menu_pos')), findsNothing);
    expect(find.byKey(const Key('user_menu_cash_drawer')), findsNothing);
    // Actions still present.
    expect(find.byKey(const Key('user_menu_change_password')), findsOneWidget);
    expect(find.byKey(const Key('user_menu_logout')), findsOneWidget);
  });

  testWidgets(
    'Change Password navigates to the change-password flow (FR-012)',
    (tester) async {
      await pumpMenu(tester, user: _userWithSettings);
      await openMenu(tester);

      await tester.tap(find.byKey(const Key('user_menu_change_password')));
      await tester.pumpAndSettle();

      expect(find.text('CHANGE PW SCREEN'), findsOneWidget);
    },
  );

  testWidgets('Logout signs the user out (FR-013)', (tester) async {
    await pumpMenu(tester, user: _userWithSettings);
    await openMenu(tester);

    await tester.tap(find.byKey(const Key('user_menu_logout')));
    await tester.pumpAndSettle();

    // signOut() clears the token; the button then hides (unauthenticated).
    verify(() => tokenStorage.clear()).called(1);
    expect(find.byKey(const Key('user_menu_button')), findsNothing);
  });
}
