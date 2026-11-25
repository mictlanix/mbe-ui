import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';

import 'commission_fixtures.dart';

void main() {
  group('CommissionMonth', () {
    test('January wraps to the previous December, December to January', () {
      const jan = CommissionMonth(year: 2026, month: 1);
      expect(jan.previous, const CommissionMonth(year: 2025, month: 12));
      expect(
        const CommissionMonth(year: 2025, month: 12).next,
        const CommissionMonth(year: 2026, month: 1),
      );
      expect(
        const CommissionMonth(year: 2026, month: 5).previous,
        const CommissionMonth(year: 2026, month: 4),
      );
      expect(
        const CommissionMonth(year: 2026, month: 5).next,
        const CommissionMonth(year: 2026, month: 6),
      );
    });

    test('orders chronologically across years', () {
      final sorted = [
        const CommissionMonth(year: 2026, month: 2),
        const CommissionMonth(year: 2025, month: 12),
        const CommissionMonth(year: 2026, month: 1),
      ]..sort();
      expect(sorted.map((m) => '${m.year}-${m.month}'), [
        '2025-12',
        '2026-1',
        '2026-2',
      ]);
      expect(
        const CommissionMonth(year: 2026, month: 1) >
            const CommissionMonth(year: 2025, month: 12),
        isTrue,
      );
    });

    test('isAfterCurrent compares with the month of now', () {
      final now = DateTime(2026, 11, 25);
      expect(
        const CommissionMonth(year: 2026, month: 12).isAfterCurrent(now),
        isTrue,
      );
      expect(
        const CommissionMonth(year: 2027, month: 1).isAfterCurrent(now),
        isTrue,
      );
      expect(
        const CommissionMonth(year: 2026, month: 11).isAfterCurrent(now),
        isFalse,
      );
      expect(
        const CommissionMonth(year: 2026, month: 10).isAfterCurrent(now),
        isFalse,
      );
    });
  });

  group('CommissionPeriod derived totals', () {
    final period = aPeriod(
      totals: [
        aTotal(agentId: 7, labelId: 3, lines: 2, commission: '100.10'),
        aTotal(
          agentId: 7,
          labelId: null,
          labelName: null,
          lines: 1,
          commission: '0.20',
        ),
        aTotal(agentId: 8, labelId: 3, lines: 4, commission: '50.05'),
      ],
    );

    test('grand total and line count sum the server totals', () {
      expect(period.grandTotal, d('150.35'));
      expect(period.lineCount, 7);
    });

    test('totalsByAgent folds per agent', () {
      final byAgent = period.totalsByAgent;
      expect(byAgent.map((a) => a.agentId), [7, 8]);
      expect(byAgent[0].lines, 3);
      expect(byAgent[0].commission, d('100.30'));
      expect(byAgent[1].commission, d('50.05'));
    });

    test('totalsByLabel returns one agent rows', () {
      expect(period.totalsByLabel(7), hasLength(2));
      expect(period.totalsByLabel(7).last.labelId, isNull);
      expect(period.totalsByLabel(99), isEmpty);
    });

    test('an empty period is zero', () {
      final empty = aPeriod(totals: [], lines: []);
      expect(empty.grandTotal, d('0'));
      expect(empty.lineCount, 0);
      expect(empty.totalsByAgent, isEmpty);
    });
  });
}
