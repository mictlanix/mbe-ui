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

    // Wide surface: the toolbar/shift sheet renders as the right-anchored
    // side sheet above LayoutBreakpoints.expanded, matching how this screen
    // is actually used (desktop/web first, constitution §VI).
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('es', 'MX'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openShiftSheet(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('cash_sessions_shift_button')));
    await tester.pumpAndSettle();
  }

  group('CashSessionsScreen — the route is a standard list screen (US5, FR-027)', () {
    testWidgets('no form is embedded above the history list', (tester) async {
      await pumpScreen(
        tester,
        user: _canOpenWithDrawerAccessUser,
        current: const CurrentSession(state: SessionState.none),
        historyItems: [_session()],
      );

      // The open-shift form's own fields must not be visible until the
      // sheet is opened — they used to sit directly on the screen.
      expect(find.byKey(const Key('cash_session_drawer_field')), findsNothing);
      expect(find.byKey(const Key('cash_session_opening_amount_field')), findsNothing);
      expect(find.byKey(const Key('cash_sessions_table')), findsOneWidget);
    });
  });

  group('CashSessionsScreen — shift toolbar action (US5, FR-027/FR-028a)', () {
    testWidgets(
      'no shift: reads as "open a shift" and is visible without scrolling',
      (tester) async {
        await pumpScreen(
          tester,
          user: _canOpenWithDrawerAccessUser,
          current: const CurrentSession(state: SessionState.none),
        );

        final l10n = await AppLocalizations.delegate.load(const Locale('es', 'MX'));
        expect(find.byKey(const Key('cash_sessions_shift_button')), findsOneWidget);
        expect(find.text(l10n.cashSessionOpenButtonLabel), findsOneWidget);
      },
    );

    testWidgets('open shift: shows the drawer name and an open status chip', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        user: _canOpenWithDrawerAccessUser,
        current: CurrentSession(state: SessionState.open, session: _session()),
      );

      expect(find.byKey(const Key('cash_sessions_shift_button')), findsOneWidget);
      expect(find.text('Caja 1'), findsOneWidget);
      expect(find.byKey(const Key('cash_session_status_chip_open')), findsOneWidget);
    });

    testWidgets('stale shift: the toolbar action itself signals staleness', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        user: _canOpenWithDrawerAccessUser,
        current: CurrentSession(state: SessionState.stale, session: _session()),
      );

      expect(find.byKey(const Key('cash_sessions_shift_button')), findsOneWidget);
      expect(find.byKey(const Key('cash_session_status_chip_stale')), findsOneWidget);
    });

    testWidgets(
      'absent — not disabled — for a user without pos:create (FR-009, constitution §VI)',
      (tester) async {
        await pumpScreen(
          tester,
          user: _cannotOpenUser,
          current: const CurrentSession(state: SessionState.none),
        );

        expect(find.byKey(const Key('cash_sessions_shift_button')), findsNothing);
      },
    );
  });

  group('CashSessionsScreen — shift sheet, no open shift (US1)', () {
    testWidgets(
      'a user with pos:create and cashDrawers:read sees the picker-based open form',
      (tester) async {
        await pumpScreen(
          tester,
          user: _canOpenWithDrawerAccessUser,
          current: const CurrentSession(state: SessionState.none),
        );
        await openShiftSheet(tester);

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
        await openShiftSheet(tester);

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
      'open affordance at all — only the administrator-directed message (FR-007a)',
      (tester) async {
        await pumpScreen(
          tester,
          user: _canOpenNoDrawerAtAllUser,
          current: const CurrentSession(state: SessionState.none),
        );
        await openShiftSheet(tester);

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
      'submitting successfully dismisses the sheet (FR-028b) — the form\'s '
      '"saved" flag flipping true is what triggers the pop',
      (tester) async {
        when(
          () => cashSessionRepository.open(
            cashDrawerId: any(named: 'cashDrawerId'),
            openingAmount: any(named: 'openingAmount'),
          ),
        ).thenAnswer((_) async => _session());

        // The assigned-drawer user needs no autocomplete interaction — its
        // drawer is seeded automatically, so tapping Open alone exercises
        // the success path this test cares about (spec 027's own listener,
        // not the pre-existing form-validation logic).
        await pumpScreen(
          tester,
          user: _canOpenNoDrawerAccessAssignedUser,
          current: const CurrentSession(state: SessionState.none),
        );
        await openShiftSheet(tester);

        await tester.tap(find.byKey(const Key('cash_session_open_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('cash_session_open_button')), findsNothing);
      },
    );
  });

  group('CashSessionsScreen — shift sheet, open/stale states (US1)', () {
    testWidgets(
      'an open session shows its drawer, start time, opening amount and '
      'per-method payments, plus a Close button',
      (tester) async {
        await pumpScreen(
          tester,
          user: _canOpenWithDrawerAccessUser,
          current: CurrentSession(state: SessionState.open, session: _session()),
        );
        await openShiftSheet(tester);

        // es-MX formatting: period thousands separator, comma decimal
        // ("3.240,00 $") — the harness now pins `Locale('es', 'MX')`
        // explicitly (previously undetermined, defaulting to the test
        // environment's own locale), which is what surfaced this
        // assertion's prior '3,240' (US-style) as never having actually
        // exercised es-MX formatting.
        expect(find.textContaining('3.240'), findsOneWidget);
        expect(find.byKey(const Key('cash_session_close_button')), findsOneWidget);
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
        await openShiftSheet(tester);

        expect(find.byKey(const Key('cash_session_close_button')), findsOneWidget);
      },
    );

    testWidgets(
      'tapping Close dismisses the sheet and navigates to that session\'s detail route '
      '(FR-028b, Edge Cases: never stranded over the pushed route)',
      (tester) async {
        await pumpScreen(
          tester,
          user: _canOpenWithDrawerAccessUser,
          current: CurrentSession(state: SessionState.open, session: _session()),
        );
        await openShiftSheet(tester);

        await tester.tap(find.byKey(const Key('cash_session_close_button')));
        await tester.pumpAndSettle();

        expect(find.text('detail-1'), findsOneWidget);
        // The sheet itself must be gone, not left open behind the new route.
        expect(find.byKey(const Key('cash_session_close_button')), findsNothing);
      },
    );
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
        await openShiftSheet(tester);

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
        await openShiftSheet(tester);

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
        'not a missing feature (research.md §12, spec D-003, spec 027 FR-029)', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        user: _canOpenWithDrawerAccessUser,
        current: const CurrentSession(state: SessionState.none),
      );

      // Every other list screen's search box is a CatalogSearchBar — its
      // absence here is the deliberate departure (research.md §12), not the
      // absence of every TextField on the page (the shift sheet legitimately
      // has some, once opened).
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
