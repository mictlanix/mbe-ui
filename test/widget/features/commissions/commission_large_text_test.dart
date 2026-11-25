import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/design/text_scale.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

import '../../../unit/features/commissions/commission_fixtures.dart';
import 'commission_harness.dart';

/// Spec 078 T036 (constitution §V): at the largest text level the months
/// list, a month with an agent and lines, and the rate grid must not
/// overflow, and the key values must stay on screen. The platform scale
/// stands in for the user's extra-large level, as in the inventory
/// large-text tests.
void main() {
  const desktop = Size(1400, 1000);
  // The settings screen needs this width in the test font (as in
  // agent_rates_grid_test.dart).
  const settingsSurface = Size(2200, 1000);

  late CommissionHarness h;

  setUp(() {
    h = CommissionHarness();
  });

  void useExtraLargeText(WidgetTester tester) {
    tester.platformDispatcher.textScaleFactorTestValue =
        TextSizeLevel.extraLarge.factor;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  /// The widget is present, inside the viewport and hit-testable.
  void expectVisible(WidgetTester tester, Finder f, Size surface) {
    expect(f, findsWidgets);
    final rect = tester.getRect(f.first);
    expect(
      Offset.zero & surface,
      predicate<Rect>(
        (v) => v.contains(rect.topLeft) && v.contains(rect.bottomRight),
      ),
      reason: 'clipped: $rect outside $surface',
    );
    expect(f.hitTestable(), findsWidgets);
  }

  testWidgets('the months list at the largest text level', (tester) async {
    useExtraLargeText(tester);
    when(() => h.repo.listPeriods()).thenAnswer(
      (_) async => [
        aPeriodSummary(
          month: const CommissionMonth(year: 2026, month: 9),
          status: CommissionPeriodStatus.paid,
          total: '900.00',
        ),
        aPeriodSummary(
          month: const CommissionMonth(year: 2026, month: 10),
          status: CommissionPeriodStatus.closed,
          total: '1234.50',
        ),
      ],
    );
    await h.pump(tester, surface: desktop);

    expect(key('commission_periods_table'), findsOneWidget);
    expectVisible(tester, find.text(r'$1,234.50'), desktop);
    expectVisible(tester, find.text('Octubre de 2026'), desktop);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a month with an agent and lines at the largest text level', (
    tester,
  ) async {
    useExtraLargeText(tester);
    final refund = aLine().copyWith(
      movement: CommissionMovement.refund,
      commission: d('-5.00'),
    );
    when(() => h.repo.listPeriods()).thenAnswer((_) async => []);
    when(() => h.repo.listAgents()).thenAnswer((_) async => [anAgent()]);
    when(
      () => h.repo.getPeriod(
        const CommissionMonth(year: 2026, month: 10),
        agentId: 7,
      ),
    ).thenAnswer(
      (_) async => aPeriod(
        agentId: 7,
        totals: [
          aTotal(commission: '100.00'),
          aTotal(labelId: null, labelName: null, lines: 1, commission: '20.00'),
        ],
        lines: [aLine(), refund],
      ),
    );
    await h.pump(
      tester,
      location: '/commissions/2026/10?agent=7',
      surface: desktop,
    );

    expect(key('commission_lines_table'), findsOneWidget);
    expectVisible(tester, key('commission_agent_total'), desktop);
    expectVisible(tester, find.text(r'$120.00'), desktop);
    expectVisible(tester, find.text(r'$50.00'), desktop);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the rate grid at the largest text level', (tester) async {
    useExtraLargeText(tester);
    when(() => h.repo.listLabels()).thenAnswer(
      (_) async => [
        CommissionLabel(id: 2, name: 'Zeta', rate: d('0.04')),
        CommissionLabel(id: 1, name: 'Alfa', rate: d('0.002')),
      ],
    );
    when(() => h.repo.listParticipations()).thenAnswer(
      (_) async => const [
        CommissionParticipation(id: 3, name: 'CAMPO'),
        CommissionParticipation(id: 1, name: 'VITALICIO'),
      ],
    );
    when(() => h.repo.listAgents()).thenAnswer((_) async => [anAgent()]);
    when(() => h.repo.listAgentRates(agentId: 7)).thenAnswer(
      (_) async => [
        CommissionAgentRate(
          id: 50,
          agentId: 7,
          labelId: 1,
          participationId: 3,
          share: d('0.500000'),
        ),
      ],
    );
    await h.pump(
      tester,
      location: '/commissions/settings?section=rates&agent=7',
      surface: settingsSurface,
    );

    expectVisible(tester, key('commission_rate_field_1_3'), settingsSurface);
    expectVisible(tester, key('commission_rate_field_2_1'), settingsSurface);
    expect(tester.takeException(), isNull);
  });
}
