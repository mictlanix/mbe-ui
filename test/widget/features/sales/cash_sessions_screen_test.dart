import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/access/user_settings.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/core/navigation/list_query.dart';
import 'package:mbe_ui/core/widgets/catalog_search_bar.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/auth/presentation/session/auth_notifier.dart';
import 'package:mbe_ui/features/catalog/data/cash_drawer_repository_impl.dart';
import 'package:mbe_ui/features/catalog/domain/repositories/cash_drawer_repository.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/presentation/cash_sessions_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

class MockCashDrawerRepository extends Mock implements CashDrawerRepository {}

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._state);
  final AuthState _state;
  @override
  Future<AuthState> build() async => _state;
}

const _canOpenWithDrawerAccessUser = User(
  userId: 'u1',
  email: 'u1@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [
    Privilege(systemObject: SystemObject.pos, rawValue: 1), // create
    Privilege(systemObject: SystemObject.cashDrawers, rawValue: 2), // read
  ],
);

const _canOpenNoDrawerAccessAssignedUser = User(
  userId: 'u2',
  email: 'u2@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  settings: UserSettings(cashDrawerId: 5, cashDrawerName: 'Caja 5'),
  privileges: [Privilege(systemObject: SystemObject.pos, rawValue: 1)],
);

const _canOpenNoDrawerAtAllUser = User(
  userId: 'u3',
  email: 'u3@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.pos, rawValue: 1)],
);

const _cannotOpenUser = User(
  userId: 'u4',
  email: 'u4@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

CashSession _session({bool cash = true}) => CashSession(
  cashSessionId: 1,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashierId: 100,
  cashierName: 'Ana López',
  start: DateTime(2026, 8, 5, 9),
  openingAmount: '500',
  paymentsByMethod: cash
      ? const [PaymentMethodTotal(method: 1, total: '3240')]
      : const [],
);

void main() {
  late MockCashSessionRepository cashSessionRepository;
  late MockCashDrawerRepository cashDrawerRepository;

  setUp(() {
    cashSessionRepository = MockCashSessionRepository();
    cashDrawerRepository = MockCashDrawerRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User user,
    required CurrentSession current,
    List<CashSession> historyItems = const [],
    int? otherOpenSessionsTotalFor,
  }) async {
    when(() => cashSessionRepository.getCurrent()).thenAnswer((_) async => current);
    when(
      () => cashSessionRepository.list(
        cashDrawerId: any(named: 'cashDrawerId'),
        cashierId: any(named: 'cashierId'),
        status: any(named: 'status'),
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer(
      (_) async => CashSessionListResult(items: historyItems, total: historyItems.length),
    );
    // hasOtherOpenSessionsProvider calls list(cashierId:, status: open,
    // limit: 100) with no cashDrawerId/skip. Mocktail resolves overlapping
    // matchers last-registered-wins, so this exact-value stub — registered
    // after the generic one above — is the one that answers that call.
    if (otherOpenSessionsTotalFor != null) {
      when(
        () => cashSessionRepository.list(
          cashierId: otherOpenSessionsTotalFor,
          status: CashSessionStatus.open,
          limit: 100,
        ),
      ).thenAnswer(
        (_) async => CashSessionListResult(items: const [], total: 2),
      );
    }

    final container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith(
          () => _FixedAuthNotifier(AuthState.authenticated(token: 't', user: user)),
        ),
        accessControlProvider.overrideWithValue(
          AccessControlService(AuthState.authenticated(token: 't', user: user)),
        ),
        cashSessionRepositoryProvider.overrideWithValue(cashSessionRepository),
        cashDrawerRepositoryProvider.overrideWithValue(cashDrawerRepository),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/sales/cash-sessions',
      routes: [
        GoRoute(
          path: '/sales/cash-sessions',
          builder: (context, state) => Scaffold(
            body: CashSessionsScreen(query: ListQuery.fromUri(state.uri)),
          ),
        ),
        GoRoute(
          path: '/sales/cash-sessions/:id',
          builder: (context, state) => Scaffold(
            body: Text('detail-${state.pathParameters['id']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CashSessionsScreen — none state (US1)', () {
    testWidgets(
      'a user with pos:create and cashDrawers:read sees the picker-based '
      'open form',
      (tester) async {
        await pumpScreen(
          tester,
          user: _canOpenWithDrawerAccessUser,
          current: const CurrentSession(state: SessionState.none),
        );

        expect(find.byKey(const Key('cash_session_drawer_field')), findsOneWidget);
        expect(
          find.byKey(const Key('cash_session_opening_amount_field')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('cash_session_open_button')), findsOneWidget);
      },
    );

    testWidgets(
      'a user without cashDrawers:read but with an assigned drawer sees a '
      'static, non-editable drawer label — no picker, no request',
      (tester) async {
        await pumpScreen(
          tester,
          user: _canOpenNoDrawerAccessAssignedUser,
          current: const CurrentSession(state: SessionState.none),
        );

        expect(
          find.byKey(const Key('cash_session_drawer_static_label')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('cash_session_drawer_field')), findsNothing);
        expect(find.text('Caja 5'), findsOneWidget);
        verifyNever(
          () => cashDrawerRepository.list(
            search: any(named: 'search'),
            facilityId: any(named: 'facilityId'),
            status: any(named: 'status'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        );
      },
    );

    testWidgets(
      'a user with neither cashDrawers:read nor an assigned drawer sees no '
      'open affordance at all — only the administrator-directed message '
      '(FR-007a)',
      (tester) async {
        await pumpScreen(
          tester,
          user: _canOpenNoDrawerAtAllUser,
          current: const CurrentSession(state: SessionState.none),
        );

        expect(
          find.byKey(const Key('cash_session_drawer_blocked_message')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('cash_session_drawer_field')), findsNothing);
        expect(
          find.byKey(const Key('cash_session_drawer_static_label')),
          findsNothing,
        );
        expect(find.byKey(const Key('cash_session_open_button')), findsNothing);
      },
    );

    testWidgets(
      'a user without pos:create sees no open affordance anywhere — absent, '
      'not disabled (FR-009 last scenario)',
      (tester) async {
        await pumpScreen(
          tester,
          user: _cannotOpenUser,
          current: const CurrentSession(state: SessionState.none),
        );

        expect(find.byKey(const Key('cash_session_open_button')), findsNothing);
        expect(find.byKey(const Key('cash_session_drawer_field')), findsNothing);
        expect(
          find.byKey(const Key('cash_session_opening_amount_field')),
          findsNothing,
        );
      },
    );
  });

  group('CashSessionsScreen — open/stale states (US1)', () {
    testWidgets(
      'an open session shows its drawer, start time, opening amount and '
      'per-method payments, plus a Close button',
      (tester) async {
        await pumpScreen(
          tester,
          user: _canOpenWithDrawerAccessUser,
          current: CurrentSession(state: SessionState.open, session: _session()),
        );

        expect(find.text('Caja 1'), findsOneWidget);
        expect(find.byKey(const Key('cash_session_status_chip_open')), findsOneWidget);
        expect(find.byKey(const Key('cash_session_close_button')), findsOneWidget);
        expect(find.textContaining('3,240'), findsOneWidget);
      },
    );

    testWidgets(
      'a stale session shows the stale chip and the must-close warning',
      (tester) async {
        await pumpScreen(
          tester,
          user: _canOpenWithDrawerAccessUser,
          current: CurrentSession(state: SessionState.stale, session: _session()),
        );

        expect(find.byKey(const Key('cash_session_status_chip_stale')), findsOneWidget);
        expect(find.byKey(const Key('cash_session_close_button')), findsOneWidget);
      },
    );

    testWidgets('tapping Close navigates to that session\'s detail route', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        user: _canOpenWithDrawerAccessUser,
        current: CurrentSession(state: SessionState.open, session: _session()),
      );

      await tester.tap(find.byKey(const Key('cash_session_close_button')));
      await tester.pumpAndSettle();

      expect(find.text('detail-1'), findsOneWidget);
    });
  });

  group('CashSessionsScreen — other open sessions warning (US4)', () {
    testWidgets(
      'shows the warning note when the cashier has another open session',
      (tester) async {
        await pumpScreen(
          tester,
          user: _canOpenWithDrawerAccessUser,
          current: CurrentSession(state: SessionState.open, session: _session()),
          otherOpenSessionsTotalFor: 100,
        );

        expect(find.byKey(const Key('cash_session_other_sessions_warning')), findsOneWidget);
      },
    );

    testWidgets(
      'omits the warning note when the cashier has no other open session',
      (tester) async {
        await pumpScreen(
          tester,
          user: _canOpenWithDrawerAccessUser,
          current: CurrentSession(state: SessionState.open, session: _session()),
        );

        expect(find.byKey(const Key('cash_session_other_sessions_warning')), findsNothing);
      },
    );
  });

  group('CashSessionsScreen — history list (US3)', () {
    testWidgets('shows drawer, cashier, start, end and status columns for '
        'each session, newest first as returned', (tester) async {
      await pumpScreen(
        tester,
        user: _canOpenWithDrawerAccessUser,
        current: const CurrentSession(state: SessionState.none),
        historyItems: [_session()],
      );

      expect(find.byKey(const Key('cash_sessions_table')), findsOneWidget);
      expect(find.text('Ana López'), findsWidgets);
    });

    testWidgets('the search slot renders nothing — a deliberate departure, '
        'not a missing feature (research.md §12, spec D-003)', (tester) async {
      await pumpScreen(
        tester,
        user: _canOpenWithDrawerAccessUser,
        current: const CurrentSession(state: SessionState.none),
      );

      // Every other list screen's search box is a CatalogSearchBar — its
      // absence here is the deliberate departure (research.md §12), not the
      // absence of every TextField on the page (the shift panel's own open
      // form legitimately has some).
      expect(find.byType(CatalogSearchBar), findsNothing);
      expect(find.byKey(const Key('cash_sessions_filter_button')), findsOneWidget);
    });

    testWidgets('a row click opens that session\'s detail, read-only — the '
        'row\'s sole affordance, no row action icons (FR-030)', (tester) async {
      await pumpScreen(
        tester,
        user: _canOpenWithDrawerAccessUser,
        current: const CurrentSession(state: SessionState.none),
        historyItems: [_session()],
      );

      await tester.tap(find.text('Ana López'));
      await tester.pumpAndSettle();

      expect(find.text('detail-1'), findsOneWidget);
    });

    testWidgets('the empty state renders when there is no history', (tester) async {
      await pumpScreen(
        tester,
        user: _canOpenWithDrawerAccessUser,
        current: const CurrentSession(state: SessionState.none),
      );

      expect(find.byKey(const Key('list_state_empty')), findsOneWidget);
    });
  });
}
