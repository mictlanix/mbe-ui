import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/gender.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/core/network/dio_client.dart';
import 'package:mbe_ui/core/storage/token_storage.dart';
import 'package:mbe_ui/features/auth/data/auth_repository_impl.dart';
import 'package:mbe_ui/features/auth/data/user_profile_repository_impl.dart';
import 'package:mbe_ui/features/auth/data/user_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/user_profile.dart';
import 'package:mbe_ui/features/auth/domain/repositories/auth_repository.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_profile_repository.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_repository.dart';
import 'package:mbe_ui/features/auth/presentation/admin/user_detail_screen.dart';
import 'package:mbe_ui/features/catalog/data/employee_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee.dart';
import 'package:mbe_ui/features/catalog/domain/entities/employee_list_item.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/employee_repository.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockUserRepository extends Mock implements UserRepository {}

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

class MockUserProfileRepository extends Mock
    implements UserProfileRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.users, rawValue: 2)],
);

const _editUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  // read (2) + update (4)
  privileges: [Privilege(systemObject: SystemObject.users, rawValue: 6)],
);

const _fullAccessUser = User(
  userId: 'admin',
  email: 'admin@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  // read (2) + update (4) + delete (8)
  privileges: [Privilege(systemObject: SystemObject.users, rawValue: 14)],
);

/// Administrator flag set — the gate the profile picker and apply action
/// actually check (024-user-profiles research.md §2), independent of any
/// privilege row.
const _adminUser = User(
  userId: 'admin',
  email: 'admin@example.com',
  administrator: true,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

const _targetUser = User(
  userId: 'jdoe',
  email: 'jdoe@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

const _targetUserWithEmployee = User(
  userId: 'jdoe',
  email: 'jdoe@example.com',
  employeeId: 7,
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

final _employee = Employee(
  employeeId: 7,
  firstName: 'Jane',
  lastName: 'Doe',
  nickname: 'Janie',
  gender: Gender.female,
  birthday: DateTime(1990, 1, 1),
  salesPerson: true,
  status: EntityStatus.active,
  startJobDate: DateTime(2020, 1, 1),
);

void main() {
  late MockAuthRepository authRepository;
  late MockTokenStorage tokenStorage;
  late MockUserRepository userRepository;
  late MockEmployeeRepository employeeRepository;
  late MockUserProfileRepository userProfileRepository;

  setUp(() {
    authRepository = MockAuthRepository();
    tokenStorage = MockTokenStorage();
    userRepository = MockUserRepository();
    employeeRepository = MockEmployeeRepository();
    userProfileRepository = MockUserProfileRepository();
    when(() => tokenStorage.read()).thenAnswer((_) async => 'test-token');
    when(
      () => userRepository.get(userId: any(named: 'userId')),
    ).thenAnswer((_) async => _targetUser);
    when(
      () => userProfileRepository.list(
        search: any(named: 'search'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => const UserProfileListResult(
        items: [
          UserProfileSummary(
            userProfileId: 5,
            name: 'Cashier',
            status: EntityStatus.active,
          ),
        ],
        total: 1,
      ),
    );
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    String? userId,
    bool forceReadOnly = false,
    Size? surfaceSize,
  }) async {
    when(() => authRepository.me()).thenAnswer((_) async => signedInAs);

    if (surfaceSize != null) {
      // The full form (with the profile picker/apply button/permissions
      // grid all present) is taller than the default 800x600 test surface,
      // which leaves controls below the fold un-tappable.
      tester.view.physicalSize = surfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          userRepositoryProvider.overrideWithValue(userRepository),
          employeeRepositoryProvider.overrideWithValue(employeeRepository),
          userProfileRepositoryProvider.overrideWithValue(
            userProfileRepository,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: UserDetailScreen(userId: userId, forceReadOnly: forceReadOnly),
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
        tester
            .widget<TextFormField>(find.byKey(const Key('email_field')))
            .enabled,
        isFalse,
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions, anyOf(isNull, isEmpty));
    },
  );

  testWidgets('titles the app bar "Edit User" with no Edit affordance in the '
      'ordinary editable case (FR-005, FR-006)', (tester) async {
    await pumpScreen(tester, signedInAs: _editUser, userId: 'jdoe');

    expect(find.text('Edit User'), findsOneWidget);
    expect(find.text('View User'), findsNothing);
    expect(find.byKey(const Key('edit_user_button')), findsNothing);
  });

  testWidgets(
    'shows Recover password above the shared Delete/Save action row, not in '
    'the app bar, in the editable case for a user with delete rights '
    '(017-ui-consistency-filters, constitution v1.10.0)',
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
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions, anyOf(isNull, isEmpty));

      expect(find.byKey(const Key('recover_password_button')), findsOneWidget);
      expect(find.byKey(const Key('delete_user_button')), findsOneWidget);
      expect(
        tester.widget(find.byKey(const Key('recover_password_button'))),
        isA<OutlinedButton>(),
      );
      // Delete is an OutlinedButton now too (contracts/record-form-actions.md
      // §2) — an error-colored filled block was the loudest thing on an
      // otherwise read-only-looking form; outlined-in-error stays
      // unmistakable without dominating.
      expect(
        tester.widget(find.byKey(const Key('delete_user_button'))),
        isA<OutlinedButton>(),
      );

      // Recover Password sits above the shared action row; within that row,
      // Delete is to the left of Save (contract §2 fixed order).
      final saveTopLeft = tester.getTopLeft(
        find.byKey(const Key('save_button')),
      );
      final recoverY = tester
          .getTopLeft(find.byKey(const Key('recover_password_button')))
          .dy;
      final deleteTopLeft = tester.getTopLeft(
        find.byKey(const Key('delete_user_button')),
      );
      expect(recoverY, lessThan(saveTopLeft.dy));
      expect(deleteTopLeft.dx, lessThan(saveTopLeft.dx));
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

  group('employee picker', () {
    testWidgets('renders an enabled autocomplete field in the editable case', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _editUser, userId: 'jdoe');

      expect(find.byKey(const Key('employee_id_field')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('employee_id_field')),
          matching: find.byType(Autocomplete<EmployeeListItem>),
        ),
        findsOneWidget,
      );
    });

    testWidgets('resolves the assigned employeeId to a display name via lookup '
        '(UserResponse.employeeId has no server-side expansion)', (
      tester,
    ) async {
      when(
        () => userRepository.get(userId: any(named: 'userId')),
      ).thenAnswer((_) async => _targetUserWithEmployee);
      when(
        () => employeeRepository.get(employeeId: 7),
      ).thenAnswer((_) async => _employee);

      await pumpScreen(
        tester,
        signedInAs: _editUser,
        userId: 'jdoe',
        forceReadOnly: true,
      );

      final field = tester.widget<TextFormField>(
        find.descendant(
          of: find.byKey(const Key('employee_id_field')),
          matching: find.byType(TextFormField),
        ),
      );
      expect(field.initialValue, 'Jane Doe');
    });

    testWidgets(
      'falls back to "#id" when the assigned employeeId is stale/orphaned',
      (tester) async {
        when(
          () => userRepository.get(userId: any(named: 'userId')),
        ).thenAnswer((_) async => _targetUserWithEmployee);
        when(
          () => employeeRepository.get(employeeId: 7),
        ).thenThrow(const NotFoundError());

        await pumpScreen(
          tester,
          signedInAs: _editUser,
          userId: 'jdoe',
          forceReadOnly: true,
        );

        final field = tester.widget<TextFormField>(
          find.descendant(
            of: find.byKey(const Key('employee_id_field')),
            matching: find.byType(TextFormField),
          ),
        );
        expect(field.initialValue, '#7');
      },
    );
  });

  group('024-user-profiles: profile picker (create mode)', () {
    testWidgets('appears for an administrator in create mode', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _adminUser);

      expect(find.byKey(const Key('user_profile_picker')), findsOneWidget);
    });

    testWidgets('is absent in edit mode', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _adminUser,
        userId: 'jdoe',
        surfaceSize: const Size(1400, 1600),
      );

      expect(find.byKey(const Key('user_profile_picker')), findsNothing);
    });

    testWidgets(
      'hides the permission grid once a profile is selected, since the '
      'profile already determines the full set (research.md §7)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _adminUser,
          surfaceSize: const Size(1400, 1600),
        );

        expect(find.byKey(const Key('privileges_grid')), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('user_profile_picker')),
          'Cash',
        );
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cashier').last);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('privileges_grid')), findsNothing);
        expect(
          find.byKey(const Key('clear_user_profile_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets('reads "no profiles yet" instead of an empty picker', (
      tester,
    ) async {
      when(
        () => userProfileRepository.list(
          search: any(named: 'search'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const UserProfileListResult(items: [], total: 0),
      );

      await pumpScreen(tester, signedInAs: _adminUser);

      expect(find.byKey(const Key('user_profile_picker')), findsNothing);
      expect(
        find.byKey(const Key('no_user_profiles_yet_on_create')),
        findsOneWidget,
      );
    });
  });

  group('024-user-profiles: Apply Profile action (edit mode)', () {
    testWidgets('appears for an administrator in edit mode', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _adminUser,
        userId: 'jdoe',
        surfaceSize: const Size(1400, 1600),
      );

      expect(find.byKey(const Key('apply_profile_button')), findsOneWidget);
    });

    testWidgets('is absent in read-only view mode', (tester) async {
      await pumpScreen(
        tester,
        signedInAs: _adminUser,
        userId: 'jdoe',
        forceReadOnly: true,
        surfaceSize: const Size(1400, 1600),
      );

      expect(find.byKey(const Key('apply_profile_button')), findsNothing);
    });

    testWidgets(
      'the dialog states both consequences and omits the self-apply '
      'warning for a different account (FR-020)',
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _adminUser,
          userId: 'jdoe',
          surfaceSize: const Size(1400, 1600),
        );

        await tester.tap(find.byKey(const Key('apply_profile_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('apply_profile_dialog')), findsOneWidget);
        expect(
          find.byKey(const Key('apply_profile_replace_warning')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('apply_profile_session_warning')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('apply_profile_self_warning')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'the dialog additionally warns when applying to the signed-in '
      "administrator's own account (FR-024)",
      (tester) async {
        await pumpScreen(
          tester,
          signedInAs: _adminUser,
          userId: _adminUser.userId,
          surfaceSize: const Size(1400, 1600),
        );

        await tester.tap(find.byKey(const Key('apply_profile_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('apply_profile_self_warning')),
          findsOneWidget,
        );
      },
    );

    testWidgets('cancelling the dialog sends nothing (FR-021)', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        signedInAs: _adminUser,
        userId: 'jdoe',
        surfaceSize: const Size(1400, 1600),
      );

      await tester.tap(find.byKey(const Key('apply_profile_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('apply_profile_picker')));
      await tester.enterText(
        find.byKey(const Key('apply_profile_picker')),
        'Cash',
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cashier').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('apply_profile_cancel')));
      await tester.pumpAndSettle();

      verifyNever(
        () => userProfileRepository.apply(
          profileId: any(named: 'profileId'),
          userId: any(named: 'userId'),
        ),
      );
    });

    testWidgets(
      'confirming updates the displayed permissions and origin without a '
      'manual reload (FR-022)',
      (tester) async {
        when(
          () => userProfileRepository.apply(
            profileId: any(named: 'profileId'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer(
          (_) async => const User(
            userId: 'jdoe',
            email: 'jdoe@example.com',
            administrator: false,
            status: EntityStatus.active,
            sessionVersion: 2,
            privileges: [
              Privilege(systemObject: SystemObject.products, rawValue: 2),
            ],
            profileId: 5,
            profileName: 'Cashier',
          ),
        );

        await pumpScreen(
          tester,
          signedInAs: _adminUser,
          userId: 'jdoe',
          surfaceSize: const Size(1400, 1600),
        );

        await tester.tap(find.byKey(const Key('apply_profile_button')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('apply_profile_picker')),
          'Cash',
        );
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cashier').last);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('apply_profile_confirm')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('apply_profile_dialog')), findsNothing);
        expect(
          find.text('Provisioned from Cashier'),
          findsOneWidget,
        );
      },
    );
  });
}
