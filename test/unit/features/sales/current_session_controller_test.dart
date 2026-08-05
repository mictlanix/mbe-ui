import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/sales/data/cash_session_repository_impl.dart';
import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';
import 'package:mbe_ui/features/sales/domain/entities/current_session.dart';
import 'package:mbe_ui/features/sales/domain/repositories/cash_session_repository.dart';
import 'package:mbe_ui/features/sales/presentation/current_session_controller.dart';

class MockCashSessionRepository extends Mock implements CashSessionRepository {}

CashSession _session({
  int cashSessionId = 1,
  int cashierId = 100,
  DateTime? start,
  DateTime? end,
}) => CashSession(
  cashSessionId: cashSessionId,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashierId: cashierId,
  cashierName: 'Ana López',
  start: start ?? DateTime(2026, 8, 5, 9),
  end: end,
  openingAmount: '500',
);

void main() {
  late MockCashSessionRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockCashSessionRepository();
    container = ProviderContainer(
      overrides: [cashSessionRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('CurrentSessionController', () {
    test('surfaces state=none with no session', () async {
      when(() => repository.getCurrent()).thenAnswer(
        (_) async => const CurrentSession(state: SessionState.none),
      );

      final result = await container.read(currentSessionControllerProvider.future);

      expect(result.state, SessionState.none);
      expect(result.session, isNull);
    });

    test('surfaces state=open with the session', () async {
      when(() => repository.getCurrent()).thenAnswer(
        (_) async => CurrentSession(state: SessionState.open, session: _session()),
      );

      final result = await container.read(currentSessionControllerProvider.future);

      expect(result.state, SessionState.open);
      expect(result.session!.cashSessionId, 1);
    });

    test('surfaces state=stale with the session', () async {
      when(() => repository.getCurrent()).thenAnswer(
        (_) async => CurrentSession(
          state: SessionState.stale,
          session: _session(start: DateTime(2026, 8, 1, 9)),
        ),
      );

      final result = await container.read(currentSessionControllerProvider.future);

      expect(result.state, SessionState.stale);
    });

    test('performs exactly one getCurrent call', () async {
      when(() => repository.getCurrent()).thenAnswer(
        (_) async => const CurrentSession(state: SessionState.none),
      );

      await container.read(currentSessionControllerProvider.future);

      verify(() => repository.getCurrent()).called(1);
    });
  });

  group('hasOtherOpenSessionsProvider (FR-004, research.md §17 — a direct '
      'cashier+status query, not the superseded same-drawer heuristic §16 '
      'described)', () {
    test('false when the caller has no open session at all — the query is '
        'never issued, since there is no cashierId to query with', () async {
      when(() => repository.getCurrent()).thenAnswer(
        (_) async => const CurrentSession(state: SessionState.none),
      );

      final result = await container.read(hasOtherOpenSessionsProvider.future);

      expect(result, isFalse);
      verifyNever(
        () => repository.list(
          cashDrawerId: any(named: 'cashDrawerId'),
          cashierId: any(named: 'cashierId'),
          status: any(named: 'status'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test('false when the exact query finds only the current session '
        'itself (total == 1)', () async {
      when(() => repository.getCurrent()).thenAnswer(
        (_) async => CurrentSession(state: SessionState.open, session: _session()),
      );
      when(
        () => repository.list(
          cashierId: 100,
          status: CashSessionStatus.open,
          limit: 100,
        ),
      ).thenAnswer(
        (_) async => CashSessionListResult(items: [_session()], total: 1),
      );

      final result = await container.read(hasOtherOpenSessionsProvider.future);

      expect(result, isFalse);
    });

    test('true when the exact query finds more than one open session for '
        'this cashier — exhaustive across every drawer, unlike the '
        'superseded same-drawer heuristic', () async {
      when(() => repository.getCurrent()).thenAnswer(
        (_) async => CurrentSession(state: SessionState.open, session: _session()),
      );
      when(
        () => repository.list(
          cashierId: 100,
          status: CashSessionStatus.open,
          limit: 100,
        ),
      ).thenAnswer(
        (_) async => CashSessionListResult(
          items: [_session(), _session(cashSessionId: 2)],
          total: 2,
        ),
      );

      final result = await container.read(hasOtherOpenSessionsProvider.future);

      expect(result, isTrue);
    });

    test('the check runs for a stale session too, not just open', () async {
      when(() => repository.getCurrent()).thenAnswer(
        (_) async => CurrentSession(
          state: SessionState.stale,
          session: _session(start: DateTime(2026, 8, 1, 9)),
        ),
      );
      when(
        () => repository.list(
          cashierId: 100,
          status: CashSessionStatus.open,
          limit: 100,
        ),
      ).thenAnswer(
        (_) async => CashSessionListResult(
          items: [_session(), _session(cashSessionId: 2)],
          total: 2,
        ),
      );

      final result = await container.read(hasOtherOpenSessionsProvider.future);

      expect(result, isTrue);
    });
  });
}
