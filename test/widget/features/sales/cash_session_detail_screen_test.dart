import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/access/access_control.dart';
import 'package:mbe_ui/core/access/privilege.dart';
import 'package:mbe_ui/core/access/system_object.dart';
import 'package:mbe_ui/core/access/user.dart';
import 'package:mbe_ui/core/domain/entity_status.dart';
import 'package:mbe_ui/features/auth/domain/entities/auth_session.dart';
import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/presentation/cash_session_detail_screen.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

const _canCloseUser = User(
  userId: 'supervisor',
  email: 'supervisor@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [Privilege(systemObject: SystemObject.cashSessionClose, rawValue: 4)],
);

const _cannotCloseUser = User(
  userId: 'cashier',
  email: 'cashier@example.com',
  administrator: false,
  status: EntityStatus.active,
  sessionVersion: 1,
  privileges: [],
);

CashSession _openSession() => CashSession(
  cashSessionId: 1,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashierId: 100,
  cashierName: 'Ana López',
  start: DateTime.now(),
  openingAmount: '500',
  paymentsByMethod: const [PaymentMethodTotal(method: 1, total: '3240')],
);

CashSession _closedSession() => CashSession(
  cashSessionId: 2,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashierId: 100,
  cashierName: 'Ana López',
  start: DateTime(2026, 8, 4, 9),
  end: DateTime(2026, 8, 4, 18),
  cashSupervisorId: 200,
  cashSupervisorName: 'Luis Reyes',
  openingAmount: '500',
);

void main() {
  late MockCashSessionRepository repository;

  setUp(() {
    repository = MockCashSessionRepository();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    required User user,
    required CashSession session,
  }) async {
    when(
      () => repository.get(cashSessionId: session.cashSessionId),
    ).thenAnswer((_) async => session);

    final container = ProviderContainer(
      overrides: [
        cashSessionRepositoryProvider.overrideWithValue(repository),
        accessControlProvider.overrideWithValue(
          AccessControlService(AuthState.authenticated(token: 't', user: user)),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CashSessionDetailScreen(cashSessionId: session.cashSessionId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CashSessionDetailScreen — summary (US2)', () {
    testWidgets('shows drawer, cashier, opening amount and per-method '
        'payments for an open session', (tester) async {
      await pumpScreen(tester, user: _canCloseUser, session: _openSession());

      expect(find.text('Caja 1'), findsWidgets);
      expect(find.text('Ana López'), findsOneWidget);
      expect(find.byKey(const Key('cash_session_status_chip_open')), findsOneWidget);
      expect(find.textContaining('3,240'), findsOneWidget);
    });

    testWidgets('a closed session shows who closed it and no count/close '
        'region at all', (tester) async {
      await pumpScreen(tester, user: _canCloseUser, session: _closedSession());

      expect(find.text('Luis Reyes'), findsOneWidget);
      expect(find.byKey(const Key('cash_session_status_chip_closed')), findsOneWidget);
      expect(find.byKey(const Key('cash_session_close_button')), findsNothing);
      expect(
        find.byKey(const Key('cash_session_denomination_field_500')),
        findsNothing,
      );
    });
  });

  group('CashSessionDetailScreen — close region gating (US2)', () {
    testWidgets(
      'an open session with cashSessionClose:update shows the count table '
      'and Close button',
      (tester) async {
        await pumpScreen(tester, user: _canCloseUser, session: _openSession());

        expect(
          find.byKey(const Key('cash_session_denomination_field_500')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('cash_session_close_button')), findsOneWidget);
      },
    );

    testWidgets(
      'an open session without cashSessionClose:update shows the '
      'supervisor-required message instead — absent, not disabled (FR-025)',
      (tester) async {
        await pumpScreen(tester, user: _cannotCloseUser, session: _openSession());

        expect(
          find.byKey(const Key('cash_session_supervisor_required_message')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('cash_session_close_button')), findsNothing);
        expect(
          find.byKey(const Key('cash_session_denomination_field_500')),
          findsNothing,
        );
      },
    );
  });

  group('CashSessionDetailScreen — counting (US2)', () {
    testWidgets('entering a quantity updates the counted total and '
        'difference live', (tester) async {
      await pumpScreen(tester, user: _canCloseUser, session: _openSession());

      await tester.enterText(
        find.byKey(const Key('cash_session_denomination_field_500')),
        '3',
      );
      await tester.pump();

      // 500*3 = 1500 counted; expected 500 (opening) + 3240 (cash) = 3740.
      expect(find.textContaining('1,500'), findsWidgets);
    });

    testWidgets('a non-zero difference does not block Close — no dialog, '
        'submits immediately (FR-019)', (tester) async {
      when(
        () => repository.close(cashSessionId: 1, counts: any(named: 'counts')),
      ).thenAnswer((_) async => _openSession());

      await pumpScreen(tester, user: _canCloseUser, session: _openSession());

      await tester.enterText(
        find.byKey(const Key('cash_session_denomination_field_500')),
        '3',
      );
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('cash_session_close_button')));
      await tester.tap(find.byKey(const Key('cash_session_close_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('cash_session_confirm_empty_count_button')),
        findsNothing,
      );
      verify(
        () => repository.close(cashSessionId: 1, counts: any(named: 'counts')),
      ).called(1);
      expect(find.text('Session closed'), findsOneWidget);
    });

    testWidgets('an all-zero count requires the empty-count confirmation '
        'before closing (FR-021)', (tester) async {
      when(
        () => repository.close(cashSessionId: 1, counts: const []),
      ).thenAnswer((_) async => _openSession());

      await pumpScreen(tester, user: _canCloseUser, session: _openSession());

      await tester.ensureVisible(find.byKey(const Key('cash_session_close_button')));
      await tester.tap(find.byKey(const Key('cash_session_close_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('cash_session_confirm_empty_count_button')),
        findsOneWidget,
      );
      verifyNever(
        () => repository.close(
          cashSessionId: any(named: 'cashSessionId'),
          counts: any(named: 'counts'),
        ),
      );

      await tester.tap(find.byKey(const Key('cash_session_confirm_empty_count_button')));
      await tester.pumpAndSettle();

      verify(() => repository.close(cashSessionId: 1, counts: const [])).called(1);
    });
  });
}
