import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/commissions/data/commission_repository_impl.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_periods_controller.dart';

import '../../../widget/features/commissions/commission_harness.dart';
import 'commission_fixtures.dart';

void main() {
  late MockCommissionRepository repo;

  ProviderContainer container() {
    final c = ProviderContainer(
      retry: (_, _) => null,
      overrides: [commissionRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() => repo = MockCommissionRepository());

  test('lists newest first, whatever order the server answers', () async {
    when(() => repo.listPeriods()).thenAnswer(
      (_) async => [
        aPeriodSummary(month: const CommissionMonth(year: 2026, month: 8)),
        aPeriodSummary(month: const CommissionMonth(year: 2026, month: 10)),
        aPeriodSummary(month: const CommissionMonth(year: 2025, month: 12)),
      ],
    );
    final c = container();
    final state = await c.read(commissionPeriodsControllerProvider.future);
    expect([for (final p in state.page.items) p.month.month], [10, 8, 12]);
  });

  test('the Estado facet narrows the rows and returns to page one', () async {
    when(() => repo.listPeriods()).thenAnswer(
      (_) async => [
        for (var m = 1; m <= 30; m++)
          aPeriodSummary(
            month: CommissionMonth(year: 2020 + m ~/ 12, month: m % 12 + 1),
            status: m == 3
                ? CommissionPeriodStatus.paid
                : CommissionPeriodStatus.closed,
          ),
      ],
    );
    final c = container();
    await c.read(commissionPeriodsControllerProvider.future);
    final controller = c.read(commissionPeriodsControllerProvider.notifier);
    controller.setPage(1);
    controller.setStatus(CommissionPeriodStatus.paid);
    final state = c.read(commissionPeriodsControllerProvider).requireValue;
    expect(state.pageIndex, 0);
    expect(state.page.total, 1);
    expect(state.page.items.single.status, CommissionPeriodStatus.paid);
    controller.setStatus(null);
    expect(
      c.read(commissionPeriodsControllerProvider).requireValue.page.total,
      30,
    );
  });

  test('pages hold 25 rows', () async {
    when(() => repo.listPeriods()).thenAnswer(
      (_) async => [
        for (var m = 0; m < 30; m++)
          aPeriodSummary(
            month: CommissionMonth(year: 2020 + m ~/ 12, month: m % 12 + 1),
          ),
      ],
    );
    final c = container();
    await c.read(commissionPeriodsControllerProvider.future);
    expect(
      c.read(commissionPeriodsControllerProvider).requireValue.page.items,
      hasLength(25),
    );
    c.read(commissionPeriodsControllerProvider.notifier).setPage(1);
    final page = c.read(commissionPeriodsControllerProvider).requireValue.page;
    expect(page.items, hasLength(5));
    expect(page.pageIndex, 1);
    expect(page.total, 30);
  });
}
