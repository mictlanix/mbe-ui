import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';

import '../../../unit/features/commissions/commission_fixtures.dart';
import 'commission_harness.dart';

void main() {
  late CommissionHarness h;

  setUp(() => h = CommissionHarness());

  final periods = [
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
  ];

  testWidgets('lists the months newest first with status and total', (
    tester,
  ) async {
    when(() => h.repo.listPeriods()).thenAnswer((_) async => periods);
    await h.pump(tester);

    expect(key('commission_periods_table'), findsOneWidget);
    expect(find.text('Octubre de 2026'), findsOneWidget);
    expect(find.text('Septiembre de 2026'), findsOneWidget);
    expect(find.text(r'$1,234.50'), findsOneWidget);
    expect(find.text('Cerrado'), findsOneWidget);
    expect(find.text('Pagado'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Octubre de 2026')).dy,
      lessThan(tester.getTopLeft(find.text('Septiembre de 2026')).dy),
    );
    expect(key('commission_periods_filter_button'), findsOneWidget);
  });

  testWidgets('empty offers the previous month and hides the filters', (
    tester,
  ) async {
    when(() => h.repo.listPeriods()).thenAnswer((_) async => []);
    await h.pump(tester);

    expect(key('list_state_empty'), findsOneWidget);
    expect(key('commission_periods_filter_button'), findsNothing);
    expect(key('list_state_empty_create_button'), findsOneWidget);
    expect(find.textContaining('Ver '), findsOneWidget);
  });

  testWidgets('shows a spinner while loading', (tester) async {
    final never = Completer<List<CommissionPeriodSummary>>();
    when(() => h.repo.listPeriods()).thenAnswer((_) => never.future);
    await h.pump(tester, settle: false);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a failed load shows the error and retry', (tester) async {
    when(() => h.repo.listPeriods()).thenThrow(Exception('boom'));
    await h.pump(tester);

    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('boom'), findsNothing);
  });

  testWidgets('the Estado facet narrows the list', (tester) async {
    when(() => h.repo.listPeriods()).thenAnswer((_) async => periods);
    await h.pump(tester);

    await tester.tap(key('commission_periods_filter_button'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_periods_status_paid'));
    await tester.pumpAndSettle();
    await tester.tap(key('filter_sheet_apply_button'));
    await tester.pumpAndSettle();

    expect(find.text('Septiembre de 2026'), findsOneWidget);
    expect(find.text('Octubre de 2026'), findsNothing);
  });

  testWidgets('a row opens its month', (tester) async {
    when(() => h.repo.listPeriods()).thenAnswer((_) async => periods);
    final router = await h.pump(tester);

    await tester.tap(find.text('Octubre de 2026'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/commissions/2026/10');
  });

  testWidgets('Abrir mes opens the chosen month', (tester) async {
    when(() => h.repo.listPeriods()).thenAnswer((_) async => periods);
    final router = await h.pump(tester);

    await tester.tap(key('commission_periods_open_month_button'));
    await tester.pumpAndSettle();
    expect(key('commission_open_month_dialog'), findsOneWidget);
    await tester.tap(key('commission_open_month_confirm'));
    await tester.pumpAndSettle();

    final previous = CommissionMonth(
      year: DateTime.now().year,
      month: DateTime.now().month,
    ).previous;
    expect(
      router.state.uri.path,
      '/commissions/${previous.year}/${previous.month}',
    );
  });

  testWidgets('Abrir mes does not offer a month after the current one', (
    tester,
  ) async {
    when(() => h.repo.listPeriods()).thenAnswer((_) async => periods);
    await h.pump(tester);
    final now = DateTime.now();

    await tester.tap(key('commission_periods_open_month_button'));
    await tester.pumpAndSettle();
    // The current year, whichever year the default month fell in.
    await tester.tap(key('commission_open_month_year'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('${now.year}').last);
    await tester.pumpAndSettle();
    await tester.tap(key('commission_open_month_month'));
    await tester.pumpAndSettle();

    final fmt = h.container.read(formattersProvider).display;
    expect(find.text(fmt.monthName(now.month, capitalize: true)), findsWidgets);
    if (now.month < 12) {
      expect(
        find.text(fmt.monthName(now.month + 1, capitalize: true)),
        findsNothing,
      );
    }
  });

  testWidgets('Configuración goes to the settings route', (tester) async {
    when(() => h.repo.listPeriods()).thenAnswer((_) async => periods);
    when(() => h.repo.listLabels()).thenAnswer((_) async => []);
    // Wide: the settings screen's switch is wider in the test font.
    final router = await h.pump(tester, surface: const Size(2200, 1000));

    await tester.tap(key('commission_periods_settings_button'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/commissions/settings');
    expect(key('commission_settings_note'), findsOneWidget);
  });

  testWidgets('a reopened month reads Abierto and \$0.00', (tester) async {
    when(() => h.repo.listPeriods()).thenAnswer(
      (_) async => [
        aPeriodSummary(month: const CommissionMonth(year: 2026, month: 10)),
      ],
    );
    await h.pump(tester);

    expect(find.text('Abierto'), findsOneWidget);
    expect(find.text(r'$0.00'), findsOneWidget);
  });

  testWidgets('the compact tier shows the settings button as an icon only', (
    tester,
  ) async {
    when(() => h.repo.listPeriods()).thenAnswer((_) async => periods);
    await h.pump(tester, surface: const Size(400, 900));

    expect(key('commission_periods_settings_button'), findsOneWidget);
    expect(find.text('Configuración'), findsNothing);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  for (final path in [
    '/commissions/abc/10',
    '/commissions/2026/13',
    '/commissions/2026/0',
    '/commissions/${DateTime.now().year + 1}/1',
  ]) {
    testWidgets('$path redirects to the list', (tester) async {
      when(() => h.repo.listPeriods()).thenAnswer((_) async => periods);
      final router = await h.pump(tester, location: path);
      expect(router.state.uri.path, '/commissions');
    });
  }

  testWidgets('a valid month with an agent reaches the month screen', (
    tester,
  ) async {
    when(() => h.repo.listPeriods()).thenAnswer((_) async => periods);
    final router = await h.pump(
      tester,
      location: '/commissions/2026/10?agent=7',
    );

    expect(router.state.uri.path, '/commissions/2026/10');
    expect(find.text('Octubre de 2026'), findsOneWidget);
  });
}
