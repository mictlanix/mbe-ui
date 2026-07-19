import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/auth/presentation/account/change_password_screen.dart';
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

    expect(find.text('Required'), findsNWidgets(2));
    verifyNever(
      () => authRepository.changePassword(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });

  testWidgets('shows error when new password is too short', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('current_password_field')),
      'old123',
    );
    await tester.enterText(find.byKey(const Key('new_password_field')), 'abc');
    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pump();

    expect(find.text('Must be at least 6 characters'), findsOneWidget);
    verifyNever(
      () => authRepository.changePassword(
        oldPassword: any(named: 'oldPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    );
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
      'newpass1',
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
      'new123pass',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Password changed successfully.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Change password'), findsNothing);
  });
}
