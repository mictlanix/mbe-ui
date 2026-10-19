import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/password_policy.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/auth/presentation/account/forgot_password_screen.dart';
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
          home: const ForgotPasswordScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows informational help message (FR-010)', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Set new password'), findsOneWidget);
    expect(find.textContaining('administrator'), findsWidgets);
  });

  testWidgets('shows required errors when fields are empty', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Set new password'));
    await tester.pump();

    expect(find.text('Required'), findsNWidgets(3));
    verifyNever(
      () => authRepository.recoverConfirm(
        recoveryToken: any(named: 'recoveryToken'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });

  testWidgets('shows error for invalid/expired token (FR-010)', (tester) async {
    when(
      () => authRepository.recoverConfirm(
        recoveryToken: any(named: 'recoveryToken'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenThrow(
      const AppError.validation([
        FieldError(
          loc: ['body', 'recovery_token'],
          msg: 'Invalid or expired recovery token',
          type: 'value_error',
        ),
      ]),
    );

    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('recovery_token_field')),
      'bad-token',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_field')),
      'Newpass12',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_confirm_field')),
      'Newpass12',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Set new password'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Invalid or expired recovery token'), findsOneWidget);
  });

  testWidgets('shows success message on valid recovery (FR-010)', (
    tester,
  ) async {
    when(
      () => authRepository.recoverConfirm(
        recoveryToken: any(named: 'recoveryToken'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenAnswer((_) async {});

    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('recovery_token_field')),
      'valid-token',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_field')),
      'Newpass12',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_confirm_field')),
      'Newpass12',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Set new password'));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Password reset successfully. You can now sign in.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Set new password'), findsNothing);
  });

  testWidgets('blocks submission when the confirmation differs', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('recovery_token_field')),
      'valid-token',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_field')),
      'Newpass12',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_confirm_field')),
      'Newpass13',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Set new password'));
    await tester.pump();

    expect(find.text("Passwords don't match"), findsOneWidget);
    verifyNever(
      () => authRepository.recoverConfirm(
        recoveryToken: any(named: 'recoveryToken'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });

  testWidgets('blocks a password that misses a rule of the policy', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('recovery_token_field')),
      'valid-token',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_field')),
      'abc12345',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_confirm_field')),
      'abc12345',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Set new password'));
    await tester.pump();

    expect(find.text('An uppercase letter'), findsNWidgets(2));
    verifyNever(
      () => authRepository.recoverConfirm(
        recoveryToken: any(named: 'recoveryToken'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });

  testWidgets('a 422 password_policy shows one message per failed rule', (
    tester,
  ) async {
    when(
      () => authRepository.recoverConfirm(
        recoveryToken: any(named: 'recoveryToken'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenThrow(_policyRejection);
    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('recovery_token_field')),
      'valid-token',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_field')),
      'Newpass12',
    );
    await tester.enterText(
      find.byKey(const Key('new_password_confirm_field')),
      'Newpass12',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Set new password'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Password does not meet the policy'), findsNothing);
    expect(find.text('At least 8 characters'), findsNWidgets(2));
    expect(find.text('A number'), findsNWidgets(2));
    expect(find.text('An uppercase letter'), findsOneWidget);
  });
}
