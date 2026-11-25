import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_month_controller.dart';

import '../../../widget/features/commissions/commission_harness.dart';
import 'commission_fixtures.dart';

CommissionMonth m(int year, int month) =>
    CommissionMonth(year: year, month: month);

CommissionPeriodSummary summary(
  CommissionMonth month,
  CommissionPeriodStatus status,
) => aPeriodSummary(month: month, status: status);

void main() {
  late MockCommissionRepository repo;
  const closed = CommissionPeriodStatus.closed;
  const paid = CommissionPeriodStatus.paid;
  const open = CommissionPeriodStatus.open;
  // A fixed "now" in November 2026: October has ended, November has not.
  final now = DateTime(2026, 11, 25);

  setUp(() => repo = MockCommissionRepository());

  group('the period', () {
    ProviderContainer container() {
      final c = ProviderContainer(
        retry: (_, _) => null,
        overrides: [commissionRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      return c;
    }

    test(
      'the grand total and per-agent totals are sums of the totals',
      () async {
        when(() => repo.getPeriod(m(2026, 10), agentId: null)).thenAnswer(
          (_) async => aPeriod(
            totals: [
              aTotal(agentId: 7, labelId: 3, lines: 2, commission: '100.00'),
              aTotal(
                agentId: 7,
                labelId: null,
                labelName: null,
                lines: 1,
                commission: '20.50',
              ),
              aTotal(agentId: 8, lines: 4, commission: '300.25'),
            ],
          ),
        );
        final c = container();
        final period = await c.read(
          commissionMonthControllerProvider(m(2026, 10), null).future,
        );

        expect(period.grandTotal, d('420.75'));
        expect(period.lineCount, 7);
        final byAgent = {for (final t in period.totalsByAgent) t.agentId: t};
        expect(byAgent[7]!.commission, d('120.50'));
        expect(byAgent[7]!.lines, 3);
        expect(byAgent[8]!.commission, d('300.25'));
      },
    );

    test('an agent reads its own period with its by-label rows', () async {
      when(() => repo.getPeriod(m(2026, 10), agentId: 7)).thenAnswer(
        (_) async => aPeriod(
          agentId: 7,
          totals: [
            aTotal(agentId: 7, labelId: 3, commission: '100.00'),
            aTotal(
              agentId: 7,
              labelId: null,
              labelName: null,
              commission: '20.00',
            ),
          ],
        ),
      );
      final c = container();
      final period = await c.read(
        commissionMonthControllerProvider(m(2026, 10), 7).future,
      );

      final rows = period.totalsByLabel(7);
      expect(rows, hasLength(2));
      expect(rows.last.labelName, isNull);
      expect(period.totalsByLabel(8), isEmpty);
    });

    test(
      'an agent whose refunds outweigh their sales stays negative',
      () async {
        when(() => repo.getPeriod(m(2026, 10), agentId: 7)).thenAnswer(
          (_) async => aPeriod(
            agentId: 7,
            totals: [
              aTotal(agentId: 7, commission: '30.00'),
              aTotal(
                agentId: 7,
                labelId: 4,
                labelName: 'Otra',
                commission: '-80.00',
              ),
            ],
          ),
        );
        final c = container();
        final period = await c.read(
          commissionMonthControllerProvider(m(2026, 10), 7).future,
        );

        expect(period.grandTotal, d('-50.00'));
        expect(period.totalsByAgent.single.commission, d('-50.00'));
      },
    );
  });

  group('closeAvailability', () {
    test('the current month has not ended', () {
      expect(
        closeAvailability(m(2026, 11), const [], now),
        CommissionCloseAvailability.blockedNotEnded,
      );
      expect(
        closeAvailability(m(2026, 12), const [], now),
        CommissionCloseAvailability.blockedNotEnded,
      );
    });

    test('the first close, with nothing closed, is available', () {
      expect(
        closeAvailability(m(2026, 10), const [], now),
        CommissionCloseAvailability.available,
      );
      expect(
        closeAvailability(m(2026, 10), [summary(m(2026, 9), open)], now),
        CommissionCloseAvailability.available,
      );
    });

    test('the previous month must be closed once anything is', () {
      final months = [summary(m(2026, 8), closed)];
      expect(
        closeAvailability(m(2026, 10), months, now),
        CommissionCloseAvailability.blockedPrevious,
      );
      expect(
        closeAvailability(m(2026, 9), months, now),
        CommissionCloseAvailability.available,
      );
    });

    test('closed and paid both count as closed for the chain', () {
      for (final status in [closed, paid]) {
        expect(
          closeAvailability(m(2026, 10), [summary(m(2026, 9), status)], now),
          CommissionCloseAvailability.available,
        );
      }
    });

    test('a later closed or paid month blocks', () {
      for (final status in [closed, paid]) {
        expect(
          closeAvailability(m(2026, 9), [
            summary(m(2026, 8), closed),
            summary(m(2026, 10), status),
          ], now),
          CommissionCloseAvailability.blockedLater,
        );
      }
    });

    test('a month older than the closed chain is blocked by the later '
        'close, not by its own previous month (the server\'s order)', () {
      expect(
        closeAvailability(m(2026, 6), [
          summary(m(2026, 8), closed),
          summary(m(2026, 9), paid),
        ], now),
        CommissionCloseAvailability.blockedLater,
      );
    });

    test('a year boundary chains December to January', () {
      expect(
        closeAvailability(m(2026, 1), [summary(m(2025, 12), closed)], now),
        CommissionCloseAvailability.available,
      );
    });
  });

  group('reopen and pay availability', () {
    test('reopen: closed with no later closed or paid month', () {
      expect(canReopen(closed, m(2026, 10), const []), isTrue);
      expect(
        canReopen(closed, m(2026, 9), [summary(m(2026, 10), closed)]),
        isFalse,
      );
      expect(
        canReopen(closed, m(2026, 9), [summary(m(2026, 10), paid)]),
        isFalse,
      );
      expect(
        canReopen(closed, m(2026, 9), [summary(m(2026, 10), open)]),
        isTrue,
      );
    });

    test('open and paid months offer neither', () {
      expect(canReopen(open, m(2026, 10), const []), isFalse);
      expect(canReopen(paid, m(2026, 10), const []), isFalse);
      expect(canPay(open), isFalse);
      expect(canPay(paid), isFalse);
      expect(canPay(closed), isTrue);
    });

    test('pay does not depend on later months', () {
      expect(canPay(closed), isTrue);
    });
  });
}
