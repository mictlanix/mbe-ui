import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/password_policy.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/auth/presentation/account/change_password_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

const _serverDefault = PasswordPolicy(
  minLength: 8,
  requireUpper: true,
  requireLower: true,
  requireDigit: true,
  requireSymbol: false,
);

const _policyRejection = AppError.validation([
  FieldError(
    loc: ['body', 'new_password'],
    msg: 'Password does not meet the policy',
    type: 'password_policy',
    failedRules: ['min_length', 'require_digit'],
  ),
]);

/// Records what the forced screen asks of the session.
class _RecordingAuthNotifier extends AuthNotifier {
  int reloads = 0;
  int signOuts = 0;

  @override
  Future<AuthState> build() async => const AuthState.unauthenticated();

  @override
  Future<void> reloadCurrentUser() async => reloads++;

  @override
  Future<void> signOut() async => signOuts++;
}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRepository authRepository;
  late MockTokenStorage tokenStorage;

  setUp(() {
    authRepository = MockAuthRepository();
    tokenStorage = MockTokenStorage();
    when(() => tokenStorage.read()).thenAnswer((_) async => null);
    when(() => tokenStorage.write(any())).thenAnswer((_) async {});
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          passwordPolicyProvider.overrideWith((ref) => _serverDefault),
          tokenStorageProvider.overrideWithValue(tokenStorage),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChangePasswordScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows required error when fields are empty', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pump();

    expect(find.text('Required'), findsNWidgets(3));
    verifyNever(
      () => authRepository.changePassword(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });

  testWidgets('blocks a password that misses a rule of the policy', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('current_password_field')),
      'old123',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_field')),
      'abc12345',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_confirm_field')),
      'abc12345',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pump();

    // Once in the checklist, once in the banner.
    expect(find.text('An uppercase letter'), findsNWidgets(2));
    verifyNever(
      () => authRepository.changePassword(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });

  testWidgets('a 422 password_policy shows one message per failed rule', (
    tester,
  ) async {
    when(
      () => authRepository.changePassword(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenThrow(_policyRejection);
    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('current_password_field')),
      'old123',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_field')),
      'Newpass12',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_confirm_field')),
      'Newpass12',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Password does not meet the policy'), findsNothing);
    expect(find.text('At least 8 characters'), findsNWidgets(2));
    expect(find.text('A number'), findsNWidgets(2));
    expect(find.text('An uppercase letter'), findsOneWidget);
  });

  testWidgets('shows server error message on wrong current password (FR-009)', (
    tester,
  ) async {
    when(
      () => authRepository.changePassword(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenThrow(
      const AppError.validation([
        FieldError(
          loc: ['body', 'old_password'],
          msg: 'Incorrect password',
          type: 'value_error',
        ),
      ]),
    );

    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('current_password_field')),
      'wrong',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_field')),
      'Newpass12',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_confirm_field')),
      'Newpass12',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Incorrect password'), findsOneWidget);
  });

  testWidgets('shows success view on successful password change', (
    tester,
  ) async {
    when(
      () => authRepository.changePassword(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenAnswer((_) async {});

    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('current_password_field')),
      'old123',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_field')),
      'New123pass',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_confirm_field')),
      'New123pass',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Password changed successfully.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Change password'), findsNothing);
  });

  testWidgets('blocks submission when the confirmation differs', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('current_password_field')),
      'old123',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_field')),
      'New123pass',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_confirm_field')),
      'new123pasx',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pump();

    expect(find.text("Passwords don't match"), findsOneWidget);
    verifyNever(
      () => authRepository.changePassword(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });

  group('forced mode (spec 048 US5)', () {
    late _RecordingAuthNotifier session;

    Future<void> pumpForced(WidgetTester tester, {Size? size}) async {
      session = _RecordingAuthNotifier();
      if (size != null) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
      }
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            authRepositoryProvider.overrideWithValue(authRepository),
            passwordPolicyProvider.overrideWith((ref) => _serverDefault),
            tokenStorageProvider.overrideWithValue(tokenStorage),
            authProvider.overrideWith(() => session),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Text('previous')),
            // A route above 'previous', so a pop would be observable.
            builder: (context, child) => child!,
          ),
        ),
      );
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const ChangePasswordScreen(forced: true),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> fillAndSubmit(WidgetTester tester) async {
      await tester.enterText(
        find.byKey(const Key('current_password_field')),
        'old123',
      );
      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'New123pass',
      );
      await tester.enterText(
        find.byKey(const Key('new_password_confirm_field')),
        'New123pass',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('has no back button and cannot be popped', (tester) async {
      await pumpForced(tester);

      expect(find.byType(BackButton), findsNothing);
      expect(find.text('Change your password'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ChangePasswordScreen), findsOneWidget);
    });

    testWidgets('the logout button signs out', (tester) async {
      await pumpForced(tester);

      await tester.tap(find.byKey(const Key('forced_change_logout')));
      await tester.pump();

      expect(session.signOuts, 1);
    });

    testWidgets('a successful change reloads the user, with no success view', (
      tester,
    ) async {
      when(
        () => authRepository.changePassword(
          oldPassword: any(named: 'oldPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async {});
      await pumpForced(tester);

      await fillAndSubmit(tester);

      expect(session.reloads, 1);
      expect(find.text('Password changed successfully.'), findsNothing);
    });

    testWidgets('a 422 password_policy shows the rule messages', (
      tester,
    ) async {
      when(
        () => authRepository.changePassword(
          oldPassword: any(named: 'oldPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenThrow(_policyRejection);
      await pumpForced(tester);

      await fillAndSubmit(tester);

      expect(find.text('At least 8 characters'), findsNWidgets(2));
      expect(session.reloads, 0);
    });

    testWidgets('does not scroll horizontally at 390 px', (tester) async {
      await pumpForced(tester, size: const Size(390, 844));

      expect(tester.takeException(), isNull);
      // The text fields' own editable scrollables don't count: the page's
      // only scrollable is vertical.
      final pageScrollables = tester
          .widgetList<Scrollable>(find.byType(Scrollable).hitTestable())
          .where((s) => s.restorationId != 'editable');
      expect(
        pageScrollables.map((s) => s.axisDirection),
        everyElement(AxisDirection.down),
      );
    });
  });
}
