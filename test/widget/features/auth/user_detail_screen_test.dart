import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/data/user_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_repository.dart';
import 'package:mbe_ui/features/auth/presentation/admin/user_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockUserRepository extends Mock implements UserRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.users, rawValue: 2)],
);

const _editUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  // read (2) + update (4)
  privileges: [Privilege(systemObject: SystemObject.users, rawValue: 6)],
);

const _fullAccessUser = User(
  userId: 'admin',
  email: 'admin@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  // read (2) + update (4) + delete (8)
  privileges: [Privilege(systemObject: SystemObject.users, rawValue: 14)],
);

const _targetUser = User(
  userId: 'jdoe',
  email: 'jdoe@example.com',
  administrator: false,
  disabled: false,
  sessionVersion: 1,
  privileges: [],
);

void main() {
  late MockAuthRepository authRepository;
  late MockTokenStorage tokenStorage;
  late MockUserRepository userRepository;

  setUp(() {
    authRepository = MockAuthRepository();
    tokenStorage = MockTokenStorage();
    userRepository = MockUserRepository();
    when(() => tokenStorage.read()).thenAnswer((_) async => 'test-token');
    when(
      () => userRepository.get(userId: any(named: 'userId')),
    ).thenAnswer((_) async => _targetUser);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    String? userId,
    bool forceReadOnly = false,
  }) async {
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          userRepositoryProvider.overrideWithValue(userRepository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: UserDetailScreen(
            userId: userId,
            forceReadOnly: forceReadOnly,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'titles the app bar "View User" when read-only via lack of update '
    'rights, with no Edit affordance (FR-005, FR-006)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser, userId: 'jdoe');

      expect(find.text('View User'), findsOneWidget);
      expect(find.text('Edit User'), findsNothing);
      expect(find.byKey(const Key('edit_user_button')), findsNothing);
    },
  );

  testWidgets(
    'titles the app bar "View User" and shows an Edit affordance when '
    'read-only via row click for a user with update rights (FR-005, '
    'FR-006)',
    (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _editUser,
        userId: 'jdoe',
        forceReadOnly: true,
      );

      expect(find.text('View User'), findsOneWidget);
      expect(find.byKey(const Key('edit_user_button')), findsOneWidget);
      expect(
        tester.widget<TextFormField>(find.byKey(const Key('email_field'))).enabled,
        isFalse,
      );
    },
  );

  testWidgets(
    'titles the app bar "Edit User" with no Edit affordance in the '
    'ordinary editable case (FR-005, FR-006)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _editUser, userId: 'jdoe');

      expect(find.text('Edit User'), findsOneWidget);
      expect(find.text('View User'), findsNothing);
      expect(find.byKey(const Key('edit_user_button')), findsNothing);
    },
  );

  testWidgets(
    'shows Recover password and Delete as buttons below Save, not in the '
    'app bar, in the editable case for a user with delete rights',
    (tester) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser, userId: 'jdoe');

      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byKey(const Key('recover_password_button')),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byKey(const Key('delete_user_button')),
        ),
        findsNothing,
      );

      // Both render as full labeled buttons, below Save.
      expect(find.byKey(const Key('recover_password_button')), findsOneWidget);
      expect(find.byKey(const Key('delete_user_button')), findsOneWidget);
      expect(
        tester.widget(find.byKey(const Key('recover_password_button'))),
        isA<OutlinedButton>(),
      );
      expect(
        tester.widget(find.byKey(const Key('delete_user_button'))),
        isA<FilledButton>(),
      );

      final saveY = tester.getTopLeft(find.byKey(const Key('save_button'))).dy;
      final recoverY = tester
          .getTopLeft(find.byKey(const Key('recover_password_button')))
          .dy;
      final deleteY =
          tester.getTopLeft(find.byKey(const Key('delete_user_button'))).dy;
      expect(recoverY, greaterThan(saveY));
      expect(deleteY, greaterThan(recoverY));
    },
  );

  testWidgets(
    'hides Recover password and Delete for a user without update/delete '
    'rights (read-only view)',
    (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _editUser,
        userId: 'jdoe',
        forceReadOnly: true,
      );

      expect(find.byKey(const Key('recover_password_button')), findsNothing);
      expect(find.byKey(const Key('delete_user_button')), findsNothing);
    },
  );
}
