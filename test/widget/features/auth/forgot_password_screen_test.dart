import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/auth/presentation/account/forgot_password_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

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
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
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
    expect(
      find.textContaining('administrator'),
      findsWidgets,
    );
  });

  testWidgets('shows required errors when fields are empty', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Set new password'));
    await tester.pump();

    expect(find.text('Required'), findsNWidgets(2));
    verifyNever(() => authRepository.recoverConfirm(
          recoveryToken: any(named: 'recoveryToken'),
          newPassword: any(named: 'newPassword'),
        ));
  });

  testWidgets('shows error for invalid/expired token (FR-010)', (tester) async {
    when(() => authRepository.recoverConfirm(
          recoveryToken: any(named: 'recoveryToken'),
          newPassword: any(named: 'newPassword'),
        )).thenThrow(const AppError.validation([
      FieldError(
        loc: ['body', 'recovery_token'],
        msg: 'Invalid or expired recovery token',
        type: 'value_error',
      ),
    ]));

    await pumpScreen(tester);

    await tester.enterText(
        find.byKey(const Key('recovery_token_field')), 'bad-token');
    await tester.enterText(
        find.byKey(const Key('new_password_field')), 'newpass1');
    await tester.tap(find.widgetWithText(FilledButton, 'Set new password'));
    await tester.pump();
    await tester.pump();

    expect(
        find.text('Invalid or expired recovery token'), findsOneWidget);
  });

  testWidgets('shows success message on valid recovery (FR-010)', (tester) async {
    when(() => authRepository.recoverConfirm(
          recoveryToken: any(named: 'recoveryToken'),
          newPassword: any(named: 'newPassword'),
        )).thenAnswer((_) async {});

    await pumpScreen(tester);

    await tester.enterText(
        find.byKey(const Key('recovery_token_field')), 'valid-token');
    await tester.enterText(
        find.byKey(const Key('new_password_field')), 'newpass1');
    await tester.tap(find.widgetWithText(FilledButton, 'Set new password'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Password reset successfully. You can now sign in.'),
        findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Set new password'), findsNothing);
  });
}
