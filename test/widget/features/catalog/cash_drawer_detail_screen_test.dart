import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/errors/app_error.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/facility_repository_impl.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/cash_drawer.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/facility_repository.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/cash_drawer_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/cash_drawer_detail_screen.dart';
import 'package:mbe_ui/features/catalog/presentation/cash_drawer_form_controller.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCashDrawerRepository extends Mock implements CashDrawerRepository {}

class MockFacilityRepository extends Mock implements FacilityRepository {}

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.cashDrawers, rawValue: 15)],
);

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.cashDrawers, rawValue: 2)],
);

final _cashDrawer = CashDrawer(
  cashDrawerId: 1,
  facilityId: 9,
  facilityName: 'Main Store',
  code: 'CD-1',
  name: 'Main CashDrawer',
  status: EntityStatus.active,
);

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockCashDrawerRepository repository;
  late MockFacilityRepository facilityRepository;

  setUp(() {
    repository = MockCashDrawerRepository();
    facilityRepository = MockFacilityRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    int? cashDrawerId,
    bool forceReadOnly = false,
  }) async {
    if (cashDrawerId != null) {
      when(
        () => repository.get(cashDrawerId: cashDrawerId),
      ).thenAnswer((_) async => _cashDrawer);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cashDrawerRepositoryProvider.overrideWithValue(repository),
          facilityRepositoryProvider.overrideWithValue(facilityRepository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CashDrawerDetailScreen(
              cashDrawerId: cashDrawerId,
              forceReadOnly: forceReadOnly,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('read-only view has no editable fields or delete affordance', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _fullAccessUser,
      cashDrawerId: 1,
      forceReadOnly: true,
    );

    final codeField = tester.widget<TextFormField>(
      find.byKey(const Key('code_field')),
    );
    expect(codeField.enabled, isFalse);
    expect(find.byKey(const Key('delete_cash_drawer_button')), findsNothing);
    expect(find.byKey(const Key('edit_cash_drawer_button')), findsOneWidget);
  });

  testWidgets('a user without update privilege gets no edit toggle', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      signedInAs: _readOnlyUser,
      cashDrawerId: 1,
      forceReadOnly: true,
    );

    expect(find.byKey(const Key('edit_cash_drawer_button')), findsNothing);
  });

  testWidgets('delete requires a confirmation dialog before submit (FR-007)', (
    tester,
  ) async {
    when(
      () => repository.get(cashDrawerId: 1),
    ).thenAnswer((_) async => _cashDrawer);
    when(
      () => repository.delete(cashDrawerId: 1),
    ).thenAnswer((_) async {});

    // Router-wrapped so the post-delete `context.pop()` (constitution §VI —
    // return to the list on success) has somewhere to go, mirroring the list
    // screen's row-click test harness.
    final router = GoRouter(
      initialLocation: '/cash-drawers',
      routes: [
        GoRoute(
          path: '/cash-drawers',
          builder: (_, _) => const Scaffold(body: Text('cash drawers list')),
        ),
        GoRoute(
          path: '/cash-drawers/:cashDrawerId',
          builder: (_, state) => CashDrawerDetailScreen(
            cashDrawerId: int.parse(state.pathParameters['cashDrawerId']!),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cashDrawerRepositoryProvider.overrideWithValue(repository),
          facilityRepositoryProvider.overrideWithValue(facilityRepository),
          accessControlProvider.overrideWithValue(
            _accessFor(_fullAccessUser),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.push('/cash-drawers/1');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('delete_cash_drawer_button')));
    await tester.pumpAndSettle();

    // The dialog is up, but delete() has NOT been called yet.
    expect(find.byType(AlertDialog), findsOneWidget);
    verifyNever(() => repository.delete(cashDrawerId: 1));

    await tester.tap(
      find.byKey(const Key('confirm_delete_cash_drawer_button')),
    );
    await tester.pumpAndSettle();

    verify(() => repository.delete(cashDrawerId: 1)).called(1);
    // Success `context.pop()` returns to the list (constitution §VI).
    expect(find.text('cash drawers list'), findsOneWidget);
  });

  testWidgets('cancelling the confirmation dialog does not delete', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, cashDrawerId: 1);

    await tester.tap(find.byKey(const Key('delete_cash_drawer_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => repository.delete(cashDrawerId: any(named: 'cashDrawerId')));
  });

  testWidgets('a duplicate-code server rejection is surfaced on the form '
      'without discarding input (FR-012)', (tester) async {
    when(
      () => repository.create(
        facilityId: any(named: 'facilityId'),
        code: any(named: 'code'),
        name: any(named: 'name'),
        comment: any(named: 'comment'),
        status: any(named: 'status'),
      ),
    ).thenThrow(
      AppError.validation([
        const FieldError(
          loc: ['code'],
          msg: 'Code already in use',
          type: 'value_error',
        ),
      ]),
    );

    final container = ProviderContainer(
      overrides: [
        cashDrawerRepositoryProvider.overrideWithValue(repository),
        facilityRepositoryProvider.overrideWithValue(facilityRepository),
        accessControlProvider.overrideWithValue(_accessFor(_fullAccessUser)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CashDrawerDetailScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Selecting the facility from the form's own picker widget is brittle to
    // drive through the Autocomplete overlay in a widget test; seed it
    // directly on the controller — client-side facility validation is
    // covered separately, this test targets the server-rejection path.
    container
        .read(cashDrawerFormControllerProvider.notifier)
        .facilitySelected(9, 'Main Store');
    await tester.enterText(find.byKey(const Key('code_field')), 'CD-1');
    await tester.enterText(find.byKey(const Key('name_field')), 'Duplicate');

    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    verify(
      () => repository.create(
        facilityId: 9,
        code: 'CD-1',
        name: 'Duplicate',
        comment: any(named: 'comment'),
        status: any(named: 'status'),
      ),
    ).called(1);
    expect(find.text('CD-1'), findsOneWidget);
    expect(find.text('Duplicate'), findsOneWidget);
    expect(find.text('Code already in use'), findsOneWidget);
  });
}
