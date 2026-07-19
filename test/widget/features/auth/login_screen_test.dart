import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/auth/presentation/login/login_screen.dart';
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

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginScreen(),
        ),
      ),
    );
    // Let `AuthNotifier.build()`'s session restore resolve.
    await tester.pump();
  }

  testWidgets('shows a required-field error for each empty field', (
    tester,
  ) async {
    await pumpLoginScreen(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Required'), findsNWidgets(2));
    verifyNever(
      () => authRepository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('shows a single generic error on invalid credentials (FR-008)', (
    tester,
  ) async {
    when(
      () => authRepository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AppError.auth());

    await pumpLoginScreen(tester);

    await tester.enterText(
      find.byKey(const Key('login_username_field')),
      'jdoe',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'wrong',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Invalid username or password.'), findsOneWidget);
    expect(find.text('Required'), findsNothing);
  });

  testWidgets('shows the same generic error on a 422 response', (tester) async {
    when(
      () => authRepository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      const AppError.validation([
        FieldError(
          loc: ['body', 'username'],
          msg: 'field required',
          type: 'missing',
        ),
      ]),
    );

    await pumpLoginScreen(tester);

    await tester.enterText(
      find.byKey(const Key('login_username_field')),
      'jdoe',
    );
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      'wrong',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Invalid username or password.'), findsOneWidget);
    expect(find.text('field required'), findsNothing);
  });
}
