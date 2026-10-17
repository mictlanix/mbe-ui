import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/presentation/pos_gate_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

CashSession _session() => CashSession(
  cashSessionId: 1,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashierId: 100,
  cashierName: 'Ana López',
  start: DateTime(2026, 8, 5, 9),
  openingAmount: '500',
);

void main() {
  late MockCashSessionRepository cashSessionRepository;

  setUp(() {
    cashSessionRepository = MockCashSessionRepository();
  });

  Future<void> pumpGate(
    WidgetTester tester,
    CurrentSession current, {
    Widget home = const PosGateScreen(),
  }) async {
    when(() => cashSessionRepository.getCurrent()).thenAnswer((_) async => current);

    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        cashSessionRepositoryProvider.overrideWithValue(cashSessionRepository),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/sales/pos',
      routes: [
        GoRoute(
          path: '/sales/pos',
          builder: (context, state) => Scaffold(body: home),
        ),
        GoRoute(
          path: '/sales/cash-sessions',
          builder: (context, state) => const Scaffold(body: Text('cash-sessions')),
        ),
        GoRoute(
          path: '/sales/cash-sessions/:cashSessionId',
          builder: (context, state) => Scaffold(
            body: Text('cash-session-${state.pathParameters['cashSessionId']}'),
          ),
        ),
      ],
    );

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

  group('PosGateScreen — no cash session (state == none)', () {
    testWidgets('shows the explanation and the link to cash sessions', (tester) async {
      await pumpGate(tester, const CurrentSession(state: SessionState.none));

      expect(find.byKey(const Key('pos_gate_no_session_title')), findsOneWidget);
      expect(find.byKey(const Key('pos_gate_open_session_button')), findsOneWidget);
    });

    testWidgets('the link navigates to /sales/cash-sessions', (tester) async {
      await pumpGate(tester, const CurrentSession(state: SessionState.none));

      await tester.tap(find.byKey(const Key('pos_gate_open_session_button')));
      await tester.pumpAndSettle();

      expect(find.text('cash-sessions'), findsOneWidget);
    });
  });

  group('PosGateScreen — session open (state == open)', () {
    testWidgets('proceeds — renders neither the gate explanation nor a banner', (
      tester,
    ) async {
      await pumpGate(
        tester,
        CurrentSession(state: SessionState.open, session: _session()),
      );

      expect(find.byKey(const Key('pos_gate_no_session_title')), findsNothing);
      expect(find.byKey(const Key('pos_stale_session_banner')), findsNothing);
    });
  });

  group('PosGateScreen — session stale (state == stale)', () {
    testWidgets('shows the blocking banner with its close-session action', (
      tester,
    ) async {
      await pumpGate(
        tester,
        CurrentSession(state: SessionState.stale, session: _session()),
      );

      expect(find.byKey(const Key('pos_gate_no_session_title')), findsNothing);
      expect(find.byKey(const Key('pos_session_blocked_banner')), findsOneWidget);
      expect(
        find.text('La sesión de caja está vencida. Ciérrala para cobrar.'),
        findsOneWidget,
      );
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('the action goes to that session\'s close screen', (tester) async {
      await pumpGate(
        tester,
        CurrentSession(state: SessionState.stale, session: _session()),
      );

      await tester.tap(find.byKey(const Key('pos_session_blocked_action')));
      await tester.pumpAndSettle();

      expect(find.text('cash-session-1'), findsOneWidget);
    });
  });

  group('PosSessionBlockedBanner — no session (state == none)', () {
    testWidgets('the action goes to /sales/cash-sessions', (tester) async {
      await pumpGate(
        tester,
        const CurrentSession(state: SessionState.none),
        home: const PosSessionBlockedBanner(),
      );

      expect(find.byKey(const Key('pos_session_blocked_banner')), findsOneWidget);
      await tester.tap(find.byKey(const Key('pos_session_blocked_action')));
      await tester.pumpAndSettle();

      expect(find.text('cash-sessions'), findsOneWidget);
    });

    testWidgets('renders nothing when the session is open', (tester) async {
      await pumpGate(
        tester,
        CurrentSession(state: SessionState.open, session: _session()),
        home: const PosSessionBlockedBanner(),
      );

      expect(find.byKey(const Key('pos_session_blocked_banner')), findsNothing);
    });
  });
}
