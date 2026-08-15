import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_right.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/data/user_profile_repository_impl.dart';
import 'package:mbe_ui/features/auth/domain/entities/user_profile.dart';
import 'package:mbe_ui/features/auth/domain/repositories/user_profile_repository.dart';
import 'package:mbe_ui/features/auth/presentation/admin/user_profile_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockUserProfileRepository extends Mock
    implements UserProfileRepository {}

const _sparseProfile = UserProfile(
  userProfileId: 5,
  name: 'Cashier',
  description: 'Front counter',
  status: EntityStatus.active,
  // Only 2 of ~110 system objects granted — the sparse-write case FR-012
  // requires renders as ticked-here/unticked-elsewhere.
  privileges: [
    Privilege(systemObject: SystemObject.products, rawValue: 2), // read
    Privilege(
      systemObject: SystemObject.salesOrders,
      rawValue: 3,
    ), // create+read
  ],
);

void main() {
  setUpAll(() {
    registerFallbackValue(EntityStatus.active);
  });

  late MockUserProfileRepository repository;

  setUp(() {
    repository = MockUserProfileRepository();
    when(
      () => repository.get(profileId: any(named: 'profileId')),
    ).thenAnswer((_) async => _sparseProfile);
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    int? profileId,
    bool forceReadOnly = false,
  }) async {
    // The form (name/description/status + the full PrivilegesGrid + action
    // row) is taller than the default 800x600 test surface, which leaves
    // Save/Delete/checkboxes below the fold and un-tappable — same fix as
    // privileges_grid_test.dart.
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // A real GoRouter with a list route behind the detail route: on a
    // successful save/delete the screen calls `context.pop()` (mirroring
    // UserDetailScreen), which needs somewhere to pop back to.
    final router = GoRouter(
      initialLocation: '/user-profiles',
      routes: [
        GoRoute(
          path: '/user-profiles',
          builder: (_, _) => const Scaffold(body: Text('user profiles list')),
        ),
        GoRoute(
          path: '/user-profiles/new',
          builder: (_, _) => const UserProfileDetailScreen(),
        ),
        GoRoute(
          path: '/user-profiles/:profileId',
          builder: (_, state) => UserProfileDetailScreen(
            profileId: int.tryParse(state.pathParameters['profileId'] ?? ''),
            forceReadOnly: state.uri.queryParameters['view'] == 'true',
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final location = profileId == null
        ? '/user-profiles/new'
        : '/user-profiles/$profileId${forceReadOnly ? '?view=true' : ''}';
    router.push(location);
    await tester.pumpAndSettle();
  }

  testWidgets('titles the app bar "New Profile" in create mode', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('New Profile'), findsOneWidget);
  });

  testWidgets(
    'a create with no name typed shows the required-name validation and '
    'never calls the repository (FR-006)',
    (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(const Key('save_user_profile_button')));
      await tester.pumpAndSettle();

      expect(find.text('Name is required.'), findsOneWidget);
      verifyNever(
        () => repository.create(
          name: any(named: 'name'),
          description: any(named: 'description'),
          status: any(named: 'status'),
          privileges: any(named: 'privileges'),
        ),
      );
    },
  );

  testWidgets(
    'a sparse profile renders ticked only on the objects it grants, '
    'unticked everywhere else in the grid (FR-012)',
    (tester) async {
      await pumpScreen(tester, profileId: 5);

      final productsCreate = tester.widget<Checkbox>(
        find.byKey(
          Key('privilege_${SystemObject.products.name}_${AccessRight.read.name}'),
        ),
      );
      expect(productsCreate.value, isTrue);

      final vehiclesRead = tester.widget<Checkbox>(
        find.byKey(
          Key('privilege_${SystemObject.labels.name}_${AccessRight.read.name}'),
        ),
      );
      expect(vehiclesRead.value, isFalse);
    },
  );

  testWidgets('titles the app bar "Edit Profile" in ordinary edit mode', (
    tester,
  ) async {
    await pumpScreen(tester, profileId: 5);

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('View Profile'), findsNothing);
  });

  testWidgets(
    'titles the app bar "View Profile" with an Edit affordance and '
    'disabled fields when forced read-only',
    (tester) async {
      await pumpScreen(tester, profileId: 5, forceReadOnly: true);

      expect(find.text('View Profile'), findsOneWidget);
      expect(find.byKey(const Key('edit_user_profile_button')), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const Key('user_profile_name_field')),
            )
            .enabled,
        isFalse,
      );
    },
  );

  testWidgets('hides Delete when forced read-only', (tester) async {
    await pumpScreen(tester, profileId: 5, forceReadOnly: true);

    expect(find.byKey(const Key('delete_user_profile_button')), findsNothing);
  });

  testWidgets(
    'editing the name and one permission persists both on save (FR-007)',
    (tester) async {
      when(
        () => repository.update(
          profileId: any(named: 'profileId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          status: any(named: 'status'),
          privileges: any(named: 'privileges'),
        ),
      ).thenAnswer((_) async => _sparseProfile);

      await pumpScreen(tester, profileId: 5);

      await tester.enterText(
        find.byKey(const Key('user_profile_name_field')),
        'Senior Cashier',
      );
      await tester.tap(
        find.byKey(
          Key(
            'privilege_${SystemObject.labels.name}_${AccessRight.read.name}',
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('save_user_profile_button')));
      await tester.pumpAndSettle();

      final captured = verify(
        () => repository.update(
          profileId: 5,
          name: 'Senior Cashier',
          description: any(named: 'description'),
          status: any(named: 'status'),
          privileges: captureAny(named: 'privileges'),
        ),
      ).captured.single as List<Privilege>;

      expect(
        captured.any((p) => p.systemObject == SystemObject.labels),
        isTrue,
      );
    },
  );

  testWidgets(
    'a delete confirmation blocks an accidental delete, and a 409 '
    'referenced-conflict leaves the profile in place with the server '
    'detail shown (FR-014)',
    (tester) async {
      when(
        () => repository.delete(profileId: any(named: 'profileId')),
      ).thenThrow(
        const AppError.server(
          message: '3 users still reference this profile',
        ),
      );

      await pumpScreen(tester, profileId: 5);

      await tester.tap(find.byKey(const Key('delete_user_profile_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('confirm_delete_user_profile')), findsOneWidget);

      await tester.tap(find.byKey(const Key('confirm_delete_user_profile')));
      await tester.pumpAndSettle();

      expect(find.text('Could not delete the profile.'), findsOneWidget);
      expect(
        find.text('3 users still reference this profile'),
        findsOneWidget,
      );
      // The screen is still showing the profile, not popped.
      expect(find.text('Edit Profile'), findsOneWidget);
    },
  );
}
