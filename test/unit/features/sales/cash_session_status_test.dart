import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/domain/cash_session_status.dart';
import 'package:mbe_ui/features/sales/domain/entities/cash_session.dart';

CashSession _sessionWith({required DateTime start, DateTime? end}) => CashSession(
  cashSessionId: 1,
  cashDrawerId: 1,
  cashDrawerName: 'Caja 1',
  cashDrawerCode: 'CJ1',
  cashierId: 1,
  cashierName: 'Ana López',
  start: start,
  end: end,
  openingAmount: '0',
);

void main() {
  group('cashSessionStatusOf', () {
    test('a session with an end time is closed, regardless of when it '
        'started', () {
      final session = _sessionWith(
        start: DateTime(2026, 8, 1, 9),
        end: DateTime(2026, 8, 1, 17),
      );
      final status = cashSessionStatusOf(session, today: DateTime(2026, 8, 1));
      expect(status, CashSessionStatus.closed);
    });

    test('an open session started today is open', () {
      final session = _sessionWith(start: DateTime(2026, 8, 5, 9));
      final status = cashSessionStatusOf(session, today: DateTime(2026, 8, 5, 23, 59));
      expect(status, CashSessionStatus.open);
    });

    test('an open session started yesterday is stale', () {
      final session = _sessionWith(start: DateTime(2026, 8, 4, 9));
      final status = cashSessionStatusOf(session, today: DateTime(2026, 8, 5));
      expect(status, CashSessionStatus.stale);
    });

    test('a session started one second before midnight is stale when '
        'viewed the next morning — the exact edge case the derivation must '
        'get right, per date not per elapsed duration', () {
      final session = _sessionWith(start: DateTime(2026, 8, 4, 23, 59, 59));
      final status = cashSessionStatusOf(session, today: DateTime(2026, 8, 5, 0, 0, 1));
      expect(status, CashSessionStatus.stale);
    });

    test('a session started at the first instant of today is open, not '
        'stale', () {
      final session = _sessionWith(start: DateTime(2026, 8, 5, 0, 0, 0));
      final status = cashSessionStatusOf(session, today: DateTime(2026, 8, 5, 0, 0, 1));
      expect(status, CashSessionStatus.open);
    });

    test('a session started many days ago and never closed is stale, not '
        'some fourth state', () {
      final session = _sessionWith(start: DateTime(2026, 7, 1, 9));
      final status = cashSessionStatusOf(session, today: DateTime(2026, 8, 5));
      expect(status, CashSessionStatus.stale);
    });
  });
}
