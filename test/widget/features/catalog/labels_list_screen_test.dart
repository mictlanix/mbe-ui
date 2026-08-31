import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/catalog/data/label_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/entities/label.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/label_repository.dart';
import 'package:mbe_ui/features/catalog/presentation/labels_list_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockLabelRepository extends Mock implements LabelRepository {}

const _readOnlyUser = User(
  userId: 'reader',
  email: 'reader@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.labels, rawValue: 2)],
);

const _fullAccessUser = User(
  userId: 'editor',
  email: 'editor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.labels, rawValue: 15)],
);

const _testLabels = [
  Label(labelId: 1, name: 'Clearance', comment: 'Sale'),
  Label(labelId: 2, name: 'Featured'),
];

AccessControlService _accessFor(User user) =>
    AccessControlService(AuthState.authenticated(token: 't', user: user));

void main() {
  late MockLabelRepository repository;

  setUp(() {
    repository = MockLabelRepository();
  });

  Future<GoRouter> pumpScreen(
    WidgetTester tester, {
    required User signedInAs,
    List<Label> labels = _testLabels,
    ListQuery query = const ListQuery(),
  }) async {
    when(
      () => repository.listDetailed(
        search: any(named: 'search'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => LabelPage(items: labels, total: labels.length));

    final router = GoRouter(
      initialLocation: query.toUri('/labels').toString(),
      routes: [
        GoRoute(
          path: '/labels',
          builder: (_, state) => Scaffold(
            body: LabelsListScreen(query: ListQuery.fromUri(state.uri)),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          labelRepositoryProvider.overrideWithValue(repository),
          accessControlProvider.overrideWithValue(_accessFor(signedInAs)),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('shows name and comment for every label', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.text('Clearance'), findsOneWidget);
    expect(find.text('Sale'), findsOneWidget);
    expect(find.text('Featured'), findsOneWidget);
  });

  testWidgets('search box and pagination are present', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser);

    expect(find.byKey(const Key('labels_search_field')), findsOneWidget);
    expect(find.byType(PaginatedDataTable2), findsOneWidget);
  });

  testWidgets(
    'the Edit row icon is hidden (not disabled) without update privilege '
    '(constitution §VI)',
    (tester) async {
      await pumpScreen(tester, signedInAs: _readOnlyUser);

      expect(find.byIcon(Icons.edit_outlined), findsNothing);
    },
  );

  testWidgets('the Create button is hidden without create privilege', (
    tester,
  ) async {
    await pumpScreen(tester, signedInAs: _readOnlyUser);

    expect(find.byKey(const Key('new_label_button')), findsNothing);
  });

  testWidgets(
    'a row click opens the record read-only in a panel over the list — no '
    'navigation, since there is no per-record route anymore (spec 035 US5, '
    'constitution §VI amended)',
    (tester) async {
      when(
        () => repository.listDetailed(
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => LabelPage(items: _testLabels, total: _testLabels.length),
      );
      when(() => repository.get(labelId: 1)).thenAnswer(
        (_) async => const Label(labelId: 1, name: 'Clearance', comment: 'Sale'),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, state) => Scaffold(
              body: LabelsListScreen(query: ListQuery.fromUri(state.uri)),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            labelRepositoryProvider.overrideWithValue(repository),
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

      await tester.tap(find.text('Clearance'));
      await tester.pumpAndSettle();

      // Still on the list route — the sheet is an overlay, not a navigation.
      expect(router.state.uri.path, '/');
      // The panel is open, showing the clicked record read-only.
      final nameField = tester.widget<TextFormField>(
        find.byKey(const Key('label_name_field')),
      );
      expect(nameField.initialValue, 'Clearance');
      expect(nameField.enabled, isFalse);
      expect(find.byKey(const Key('edit_label_button')), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsNothing);
    },
  );

  testWidgets('an empty result shows the empty state', (tester) async {
    await pumpScreen(tester, signedInAs: _fullAccessUser, labels: const []);

    expect(find.byKey(const Key('labels_table')), findsNothing);
  });

  group('search always refetches (spec 035 FR-008/FR-009/FR-010/FR-011)', () {
    testWidgets(
      'submitting an UNCHANGED term still re-fetches, and the previous rows '
      'stay visible while it does',
      (tester) async {
        await pumpScreen(tester, signedInAs: _fullAccessUser);
        clearInteractions(repository);

        // Confirm a change without editing the term — the exact user
        // action this feature fixes.
        await tester.tap(find.byTooltip('Search'));
        await tester.pump();

        // Rows from the prior fetch are still on screen mid-refresh — the
        // list must not blank out (FR-012).
        expect(find.text('Clearance'), findsOneWidget);

        await tester.pumpAndSettle();

        verify(
          () => repository.listDetailed(
            search: null,
            skip: 0,
            limit: 20,
          ),
        ).called(1);
      },
    );

    testWidgets(
      'submitting a CHANGED term issues exactly one fetch, not a refresh '
      'plus a navigation fetch',
      (tester) async {
        await pumpScreen(tester, signedInAs: _fullAccessUser);
        clearInteractions(repository);

        await tester.enterText(
          find.byKey(const Key('labels_search_field')),
          'clear',
        );
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        verify(
          () => repository.listDetailed(search: 'clear', skip: 0, limit: 20),
        ).called(1);
      },
    );

    testWidgets('typing alone, without submitting, issues no request', (
      tester,
    ) async {
      await pumpScreen(tester, signedInAs: _fullAccessUser);
      clearInteractions(repository);

      await tester.enterText(
        find.byKey(const Key('labels_search_field')),
        'clear',
      );
      await tester.pump();

      verifyNever(
        () => repository.listDetailed(
          search: any(named: 'search'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );
    });
  });

  group(
    'the full US5 round trip (spec 035 T045): create, view, edit, delete, '
    'all from the list screen',
    () {
      testWidgets(
        'create → save keeps the list\'s query and closes the panel',
        (tester) async {
          when(
            () => repository.create(name: 'Sale', comment: null),
          ).thenAnswer((_) async => const Label(labelId: 3, name: 'Sale'));
          final router = await pumpScreen(
            tester,
            signedInAs: _fullAccessUser,
            query: const ListQuery(search: 'clear'),
          );
          final locationBefore = router.state.uri.toString();

          await tester.tap(find.byKey(const Key('new_label_button')));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const Key('label_name_field')),
            'Sale',
          );
          await tester.tap(find.byKey(const Key('save_button')));
          await tester.pumpAndSettle();

          // Panel closed — the field is gone.
          expect(find.byKey(const Key('label_name_field')), findsNothing);
          // The list's own query is exactly what it was; save never
          // navigated the list route itself.
          expect(router.state.uri.toString(), locationBefore);
        },
      );

      testWidgets(
        'view → Edit → save round-trips through a single panel instance, '
        'and the reopened panel for a different record starts clean — not '
        'showing the previous record\'s stale values (plan.md Risks: the '
        'form controller is a global singleton, not a family)',
        (tester) async {
          when(() => repository.get(labelId: 1)).thenAnswer(
            (_) async => const Label(labelId: 1, name: 'Clearance', comment: 'Sale'),
          );
          when(() => repository.get(labelId: 2)).thenAnswer(
            (_) async => const Label(labelId: 2, name: 'Featured'),
          );
          when(
            () => repository.update(
              labelId: 1,
              name: 'Clearance Sale',
              comment: 'Sale',
            ),
          ).thenAnswer(
            (_) async => const Label(
              labelId: 1,
              name: 'Clearance Sale',
              comment: 'Sale',
            ),
          );
          await pumpScreen(tester, signedInAs: _fullAccessUser);

          // Open record 1 read-only, switch to Edit, change the name, save.
          await tester.tap(find.text('Clearance'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('edit_label_button')));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const Key('label_name_field')),
            'Clearance Sale',
          );
          await tester.tap(find.byKey(const Key('save_button')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('label_name_field')), findsNothing);

          // Now open record 2 — must show record 2's own values, not
          // record 1's just-edited ones.
          await tester.tap(find.text('Featured'));
          await tester.pumpAndSettle();

          final nameField = tester.widget<TextFormField>(
            find.byKey(const Key('label_name_field')),
          );
          expect(nameField.initialValue, 'Featured');
        },
      );

      testWidgets(
        'delete closes the panel and the record is gone from the list',
        (tester) async {
          when(() => repository.get(labelId: 2)).thenAnswer(
            (_) async => const Label(labelId: 2, name: 'Featured'),
          );
          when(() => repository.delete(labelId: 2)).thenAnswer((_) async {});
          when(
            () => repository.listDetailed(
              search: any(named: 'search'),
              skip: any(named: 'skip'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer((_) async => const LabelPage(items: _testLabels, total: 2));

          await pumpScreen(tester, signedInAs: _fullAccessUser);

          await tester.tap(find.byIcon(Icons.edit_outlined).at(1)); // 'Featured' row
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('delete_label_button')));
          await tester.pumpAndSettle();

          // Now stub the post-delete refetch to reflect the deletion, since
          // the panel's own delete call invalidates the list controller.
          when(
            () => repository.listDetailed(
              search: any(named: 'search'),
              skip: any(named: 'skip'),
              limit: any(named: 'limit'),
            ),
          ).thenAnswer(
            (_) async => const LabelPage(
              items: [Label(labelId: 1, name: 'Clearance', comment: 'Sale')],
              total: 1,
            ),
          );
          await tester.tap(find.byKey(const Key('confirm_delete_label_button')));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('label_name_field')), findsNothing);
          expect(find.text('Featured'), findsNothing);
        },
      );

      testWidgets(
        'dismissing a dirty panel by tapping outside it warns before '
        'discarding the edit (spec 035 FR-032)',
        (tester) async {
          when(() => repository.get(labelId: 1)).thenAnswer(
            (_) async => const Label(labelId: 1, name: 'Clearance', comment: 'Sale'),
          );
          tester.view.physicalSize = const Size(1200, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await pumpScreen(tester, signedInAs: _fullAccessUser);

          await tester.tap(find.byIcon(Icons.edit_outlined).at(0)); // 'Clearance' row
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byKey(const Key('label_name_field')),
            'Changed',
          );
          await tester.pump();

          // Tap well outside the side sheet (which is right-anchored and
          // 640 px wide) to hit the modal barrier.
          await tester.tapAt(const Offset(20, 20));
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('record_sheet_discard_dialog')),
            findsOneWidget,
          );
          // Cancelling the discard leaves the edit in place.
          await tester.tap(find.byKey(const Key('record_sheet_discard_cancel')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('label_name_field')), findsOneWidget);
        },
      );
    },
  );
}
