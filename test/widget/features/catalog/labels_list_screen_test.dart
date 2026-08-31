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

  Future<void> pumpScreen(
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
    'a row click opens the read-only detail view (constitution §VI)',
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

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, state) => Scaffold(
              body: LabelsListScreen(query: ListQuery.fromUri(state.uri)),
            ),
          ),
          GoRoute(
            path: '/labels/:labelId',
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
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

      expect(find.text('/labels/1?view=true'), findsOneWidget);
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
}
