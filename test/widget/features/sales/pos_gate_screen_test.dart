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

  Future<void> pumpGate(WidgetTester tester, CurrentSession current) async {
    when(() => cashSessionRepository.getCurrent()).thenAnswer((_) async => current);

    final container = ProviderContainer(
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
          builder: (context, state) => const Scaffold(body: PosGateScreen()),
        ),
        GoRoute(
          path: '/sales/cash-sessions',
          builder: (context, state) => const Scaffold(body: Text('cash-sessions')),
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
    testWidgets('proceeds with the stale-session banner shown', (tester) async {
      await pumpGate(
        tester,
        CurrentSession(state: SessionState.stale, session: _session()),
      );

      expect(find.byKey(const Key('pos_gate_no_session_title')), findsNothing);
      expect(find.byKey(const Key('pos_stale_session_banner')), findsOneWidget);
    });
  });
}
