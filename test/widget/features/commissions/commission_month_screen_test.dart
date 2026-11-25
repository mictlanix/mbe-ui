import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/core/formatting/formatters_provider.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';

import '../../../unit/features/commissions/commission_fixtures.dart';
import 'commission_harness.dart';

const _oct = CommissionMonth(year: 2026, month: 10);
const _octPath = '/commissions/2026/10';

void main() {
  late CommissionHarness h;
  var status = CommissionPeriodStatus.open;
  var months = <CommissionPeriodSummary>[];
  CommissionPeriod? reopenedStamp;

  CommissionPeriod periodOf(
    CommissionPeriodStatus s, {
    int? agentId,
    List<CommissionTotal>? totals,
    List<CommissionLine>? lines,
    CommissionMonth month = _oct,
  }) {
    final base = aPeriod(
      status: s,
      agentId: agentId,
      totals: totals,
      lines: lines,
    ).copyWith(month: month);
    return switch (s) {
      CommissionPeriodStatus.open =>
        reopenedStamp == null
            ? base
            : base.copyWith(
                reopenedAt: DateTime(2026, 11, 5, 9),
                reopenedBy: 5,
              ),
      CommissionPeriodStatus.closed => base.copyWith(
        closedAt: DateTime(2026, 11, 2, 9),
        closedBy: 4,
      ),
      CommissionPeriodStatus.paid => base.copyWith(
        closedAt: DateTime(2026, 11, 2, 9),
        closedBy: 4,
        paidAt: DateTime(2026, 11, 4, 9),
        paidBy: 6,
      ),
    };
  }

  final allTotals = [
    aTotal(agentId: 7, labelId: 3, lines: 2, commission: '100.00'),
    aTotal(
      agentId: 7,
      labelId: null,
      labelName: null,
      lines: 1,
      commission: '20.00',
    ),
    aTotal(agentId: 8, lines: 3, commission: '300.00'),
  ];
  final agentTotals = allTotals.take(2).toList();
  final refund = aLine().copyWith(
    movement: CommissionMovement.refund,
    commission: d('-5.00'),
  );
  final unlabelled = aLine().copyWith(labelId: null, labelName: null);

  setUp(() {
    h = CommissionHarness();
    status = CommissionPeriodStatus.open;
    months = [];
    reopenedStamp = null;
    when(() => h.repo.getPeriod(_oct)).thenAnswer(
      (_) async => periodOf(status, totals: allTotals, lines: const []),
    );
    when(() => h.repo.getPeriod(_oct, agentId: 7)).thenAnswer(
      (_) async => periodOf(
        status,
        agentId: 7,
        totals: agentTotals,
        lines: [aLine(), refund, unlabelled],
      ),
    );
    when(() => h.repo.listPeriods()).thenAnswer((_) async => months);
    when(() => h.repo.listAgents()).thenAnswer((_) async => [anAgent()]);
  });

  String uri(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.toString();

  testWidgets('no agent: the totals only, with the live banner', (
    tester,
  ) async {
    await h.pump(tester, location: _octPath);

    expect(find.text('Comisiones · Octubre de 2026'), findsOneWidget);
    expect(key('commission_live_notice'), findsOneWidget);
    expect(find.text('Total del mes'), findsOneWidget);
    expect(find.text(r'$420.00'), findsOneWidget);
    expect(key('commission_agents_table'), findsOneWidget);
    expect(find.text('Ana Ruiz'), findsOneWidget);
    expect(find.text('Pago total'), findsOneWidget);
    expect(find.text(r'$120.00'), findsOneWidget);
    expect(key('commission_lines_table'), findsNothing);
    expect(key('commission_close_button'), findsOneWidget);
    // No app bar actions (constitution §VI).
    expect(
      tester.widget<AppBar>(find.byType(AppBar)).actions ?? const [],
      isEmpty,
    );
  });

  testWidgets('a former agent shows by number', (tester) async {
    await h.pump(tester, location: _octPath, namesFail: true);

    expect(find.text('Agente #8'), findsOneWidget);
  });

  testWidgets('choosing an agent from the table writes ?agent=', (
    tester,
  ) async {
    final router = await h.pump(tester, location: _octPath);

    await tester.tap(find.text('Ana Ruiz'));
    await tester.pumpAndSettle();

    expect(uri(router), '$_octPath?agent=7');
    expect(find.text('Total de Ana Ruiz'), findsOneWidget);
    expect(key('commission_agent_chip'), findsOneWidget);
    expect(key('commission_lines_table'), findsOneWidget);
    expect(key('commission_agents_table'), findsNothing);
  });

  testWidgets('choosing an agent from the drawer writes ?agent=', (
    tester,
  ) async {
    final router = await h.pump(tester, location: _octPath);

    await tester.tap(key('commission_month_filter_button'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: key('commission_agent_filter'),
        matching: find.byType(TextField),
      ),
      'Ana',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    // The option list is the topmost match.
    await tester.tap(find.text('Ana Ruiz').last);
    await tester.pumpAndSettle();

    expect(uri(router), '$_octPath?agent=7');
  });

  testWidgets('the agent view: total, scheme, by-label rows and lines', (
    tester,
  ) async {
    await h.pump(tester, location: '$_octPath?agent=7');

    expect(find.text(r'$120.00'), findsWidgets);
    expect(key('commission_agent_total'), findsOneWidget);
    expect(key('commission_labels_table'), findsOneWidget);
    expect(find.text('Premium'), findsWidgets);
    // The unlabelled total; the unlabelled line offers Asignar… on this open
    // month (FR-016a).
    expect(find.text('Sin etiqueta'), findsOneWidget);
    expect(find.text('Asignar…'), findsOneWidget);
    expect(key('commission_lines_table'), findsOneWidget);
    expect(find.text('Pedido'), findsOneWidget);
    expect(find.text('Participación'), findsOneWidget);
    expect(find.text('2.50 %'), findsWidgets);
    expect(find.text('Tornillo'), findsWidgets);
  });

  testWidgets('a refund row has the arrow, labelled Devolución', (
    tester,
  ) async {
    await h.pump(tester, location: '$_octPath?agent=7');

    expect(key('commission_refund_icon'), findsOneWidget);
    expect(find.byTooltip('Devolución'), findsOneWidget);
    expect(find.text('-\$5.00'), findsOneWidget);
  });

  testWidgets('a row tap opens the read-only line panel', (tester) async {
    await h.pump(tester, location: '$_octPath?agent=7');

    await tester.tap(find.text('Tornillo').first);
    await tester.pumpAndSettle();

    expect(find.text('Línea del pedido 61'), findsOneWidget);
    expect(key('commission_line_effective_rate'), findsOneWidget);
  });

  testWidgets('clearing the agent returns to the totals', (tester) async {
    final router = await h.pump(tester, location: '$_octPath?agent=7');

    await tester.tap(find.byTooltip('Quitar filtro de agente'));
    await tester.pumpAndSettle();

    expect(uri(router), _octPath);
    expect(key('commission_agents_table'), findsOneWidget);
  });

  testWidgets('a negative agent total stays negative', (tester) async {
    when(() => h.repo.getPeriod(_oct, agentId: 7)).thenAnswer(
      (_) async => periodOf(
        status,
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
        lines: [refund],
      ),
    );
    await h.pump(tester, location: '$_octPath?agent=7');

    final negative = h.container
        .read(formattersProvider)
        .display
        .currency('-50.00');
    expect(negative, contains('-'));
    expect(tester.widget<Text>(key('commission_agent_total')).data, negative);
  });

  testWidgets('the steppers move month and keep the agent; next hides at '
      'the current month', (tester) async {
    final router = await h.pump(tester, location: '$_octPath?agent=7');
    when(
      () => h.repo.getPeriod(
        const CommissionMonth(year: 2026, month: 9),
        agentId: 7,
      ),
    ).thenAnswer((_) async => periodOf(status, agentId: 7));

    await tester.tap(key('commission_previous_month'));
    await tester.pumpAndSettle();
    expect(uri(router), '/commissions/2026/9?agent=7');

    final now = DateTime.now();
    final current = CommissionMonth(year: now.year, month: now.month);
    when(() => h.repo.getPeriod(current)).thenAnswer(
      (_) async => periodOf(status, totals: allTotals, month: current),
    );
    await tester.pumpWidget(const SizedBox());
    await h.pump(
      tester,
      location: '/commissions/${current.year}/${current.month}',
    );
    expect(key('commission_next_month'), findsNothing);
    expect(key('commission_previous_month'), findsOneWidget);
  });

  testWidgets('closing with confirm refreshes to Cerrado with the audit line', (
    tester,
  ) async {
    when(() => h.repo.closePeriod(_oct)).thenAnswer((_) async {
      status = CommissionPeriodStatus.closed;
      months = [aPeriodSummary(status: status)];
      return aPeriodSummary(status: status);
    });
    await h.pump(tester, location: _octPath);

    await tester.tap(key('commission_close_button'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Se guardarán 6 líneas por \$420.00.'),
      findsOneWidget,
    );
    await tester.tap(key('commission_close_submit'));
    await tester.pumpAndSettle();

    verify(() => h.repo.closePeriod(_oct)).called(1);
    expect(find.text('Cerrado'), findsOneWidget);
    expect(key('commission_live_notice'), findsNothing);
    expect(find.textContaining('Cerrado el'), findsOneWidget);
    expect(find.textContaining('por Empleado 4'), findsOneWidget);
    expect(key('commission_close_button'), findsNothing);
    expect(key('commission_action_refusal'), findsNothing);
  });

  testWidgets('Cancelar on the close prompt closes nothing', (tester) async {
    await h.pump(tester, location: _octPath);

    await tester.tap(key('commission_close_button'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_close_cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => h.repo.closePeriod(_oct));
    expect(find.text('Abierto'), findsOneWidget);
  });

  testWidgets('the close prompt shows the whole month while an agent is '
      'chosen', (tester) async {
    await h.pump(tester, location: '$_octPath?agent=7');

    await tester.tap(key('commission_close_button'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Se guardarán 6 líneas por \$420.00.'),
      findsOneWidget,
    );
  });

  testWidgets('a refused close shows its translated message and re-reads', (
    tester,
  ) async {
    when(() => h.repo.closePeriod(_oct)).thenThrow(
      aRefusal(
        api.ErrorCode.commissionPeriodPeriodNotEnded,
        'commission_period.not_ended',
        {'year': 2026, 'month': 10},
      ),
    );
    await h.pump(tester, location: _octPath);

    await tester.tap(key('commission_close_button'));
    await tester.pumpAndSettle();
    await tester.tap(key('commission_close_submit'));
    await tester.pumpAndSettle();

    expect(key('commission_action_refusal'), findsOneWidget);
    expect(
      find.text('Todavía no termina octubre de 2026; no se puede cerrar.'),
      findsOneWidget,
    );
    expect(find.text('SERVER TEXT'), findsNothing);
    // initial read + the re-read after the refusal.
    verify(() => h.repo.getPeriod(_oct)).called(greaterThanOrEqualTo(2));
    verify(() => h.repo.listPeriods()).called(greaterThanOrEqualTo(2));
  });

  group('a blocked close shows the reason, with no button', () {
    testWidgets('the month has not ended', (tester) async {
      final now = DateTime.now();
      final current = CommissionMonth(year: now.year, month: now.month);
      when(() => h.repo.getPeriod(current)).thenAnswer(
        (_) async => periodOf(status, totals: allTotals, month: current),
      );
      await h.pump(
        tester,
        location: '/commissions/${current.year}/${current.month}',
      );

      expect(
        find.text('No se puede cerrar: el mes aún no termina.'),
        findsOneWidget,
      );
      expect(key('commission_close_button'), findsNothing);
    });

    testWidgets('the previous month is not closed', (tester) async {
      months = [
        aPeriodSummary(
          month: const CommissionMonth(year: 2026, month: 8),
          status: CommissionPeriodStatus.closed,
        ),
      ];
      await h.pump(tester, location: _octPath);

      expect(
        find.text(
          'No se puede cerrar: primero hay que cerrar septiembre de 2026.',
        ),
        findsOneWidget,
      );
      expect(key('commission_close_button'), findsNothing);
    });

    testWidgets('a later month is closed', (tester) async {
      months = [
        aPeriodSummary(
          month: const CommissionMonth(year: 2026, month: 9),
          status: CommissionPeriodStatus.closed,
        ),
        aPeriodSummary(
          month: const CommissionMonth(year: 2026, month: 11),
          status: CommissionPeriodStatus.paid,
        ),
      ];
      await h.pump(tester, location: _octPath);

      expect(
        find.text('No se puede cerrar: ya hay un mes posterior cerrado.'),
        findsOneWidget,
      );
      expect(key('commission_close_button'), findsNothing);
    });
  });

  group('closed and paid months', () {
    testWidgets('the latest closed month offers Reabrir and Marcar pagado', (
      tester,
    ) async {
      status = CommissionPeriodStatus.closed;
      months = [aPeriodSummary(status: status)];
      await h.pump(tester, location: _octPath);

      expect(key('commission_reopen_button'), findsOneWidget);
      expect(key('commission_pay_button'), findsOneWidget);
      expect(key('commission_close_button'), findsNothing);
      expect(find.byType(OutlinedButton), findsOneWidget);
      // Reabrir sits left of the primary button.
      expect(
        tester.getTopLeft(key('commission_reopen_button')).dx,
        lessThan(tester.getTopLeft(key('commission_pay_button')).dx),
      );
    });

    testWidgets('a closed month that is not the latest offers only Pagar', (
      tester,
    ) async {
      status = CommissionPeriodStatus.closed;
      months = [
        aPeriodSummary(status: status),
        aPeriodSummary(
          month: const CommissionMonth(year: 2026, month: 11),
          status: CommissionPeriodStatus.closed,
        ),
      ];
      await h.pump(tester, location: _octPath);

      expect(key('commission_reopen_button'), findsNothing);
      expect(key('commission_pay_button'), findsOneWidget);
    });

    testWidgets('a paid month offers neither, and shows both audit stamps', (
      tester,
    ) async {
      status = CommissionPeriodStatus.paid;
      months = [aPeriodSummary(status: status)];
      await h.pump(tester, location: _octPath);

      expect(key('commission_reopen_button'), findsNothing);
      expect(key('commission_pay_button'), findsNothing);
      expect(find.textContaining('Cerrado el'), findsOneWidget);
      expect(find.textContaining('Pagado el'), findsWidgets);
      expect(find.textContaining('por Empleado 6'), findsOneWidget);
    });

    testWidgets('reopening returns to Abierto with the live banner', (
      tester,
    ) async {
      status = CommissionPeriodStatus.closed;
      months = [aPeriodSummary(status: status)];
      when(() => h.repo.reopenPeriod(_oct)).thenAnswer((_) async {
        status = CommissionPeriodStatus.open;
        reopenedStamp = periodOf(status);
        months = [aPeriodSummary(status: status)];
        return aPeriodSummary(status: status);
      });
      await h.pump(tester, location: _octPath);

      await tester.tap(key('commission_reopen_button'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Se descartarán las líneas guardadas'),
        findsOneWidget,
      );
      await tester.tap(key('commission_reopen_submit'));
      await tester.pumpAndSettle();

      expect(find.text('Abierto'), findsOneWidget);
      expect(key('commission_live_notice'), findsOneWidget);
      expect(find.textContaining('Reabierto el'), findsOneWidget);
      expect(find.textContaining('por Empleado 5'), findsOneWidget);
      expect(key('commission_close_button'), findsOneWidget);
    });

    testWidgets('paying warns it is final, then shows Pagado', (tester) async {
      status = CommissionPeriodStatus.closed;
      months = [aPeriodSummary(status: status)];
      when(() => h.repo.payPeriod(_oct)).thenAnswer((_) async {
        status = CommissionPeriodStatus.paid;
        months = [aPeriodSummary(status: status)];
        return aPeriodSummary(status: status);
      });
      await h.pump(tester, location: _octPath);

      await tester.tap(key('commission_pay_button'));
      await tester.pumpAndSettle();
      expect(find.textContaining('es definitivo'), findsOneWidget);
      expect(find.textContaining(r'Total $420.00.'), findsOneWidget);
      await tester.tap(key('commission_pay_submit'));
      await tester.pumpAndSettle();

      expect(find.text('Pagado'), findsOneWidget);
      expect(find.textContaining('Pagado el'), findsWidgets);
      expect(key('commission_pay_button'), findsNothing);
      expect(key('commission_reopen_button'), findsNothing);
    });

    testWidgets('a refused reopen shows its message', (tester) async {
      status = CommissionPeriodStatus.closed;
      months = [aPeriodSummary(status: status)];
      when(() => h.repo.reopenPeriod(_oct)).thenThrow(
        aRefusal(
          api.ErrorCode.commissionPeriodPeriodPaidCannotReopen,
          'commission_period.paid_cannot_reopen',
          {'year': 2026, 'month': 10},
        ),
      );
      await h.pump(tester, location: _octPath);

      await tester.tap(key('commission_reopen_button'));
      await tester.pumpAndSettle();
      await tester.tap(key('commission_reopen_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'El mes de octubre de 2026 ya está pagado y no se puede reabrir.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a refused pay shows its message', (tester) async {
      status = CommissionPeriodStatus.closed;
      months = [aPeriodSummary(status: status)];
      when(() => h.repo.payPeriod(_oct)).thenThrow(
        aRefusal(
          api.ErrorCode.commissionPeriodPeriodNotClosed,
          'commission_period.not_closed',
          {'year': 2026, 'month': 10},
        ),
      );
      await h.pump(tester, location: _octPath);

      await tester.tap(key('commission_pay_button'));
      await tester.pumpAndSettle();
      await tester.tap(key('commission_pay_submit'));
      await tester.pumpAndSettle();

      expect(
        find.text('El mes de octubre de 2026 no está cerrado.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('a user with Read only sees no action at all', (tester) async {
    status = CommissionPeriodStatus.closed;
    months = [aPeriodSummary(status: status)];
    await h.pump(
      tester,
      who: CommissionHarness.readOnlyUser(),
      location: _octPath,
    );

    expect(find.text('Total del mes'), findsOneWidget);
    expect(key('commission_actions'), findsNothing);
    expect(key('commission_pay_button'), findsNothing);
    expect(key('commission_reopen_button'), findsNothing);
  });

  testWidgets('a Read only user gets no blocked reason either', (tester) async {
    await h.pump(
      tester,
      who: CommissionHarness.readOnlyUser(),
      location: _octPath,
    );

    expect(key('commission_close_button'), findsNothing);
    expect(key('commission_close_blocked'), findsNothing);
  });

  testWidgets('loading keeps the header', (tester) async {
    final never = Completer<CommissionPeriod>();
    when(() => h.repo.getPeriod(_oct)).thenAnswer((_) => never.future);
    await h.pump(tester, location: _octPath, settle: false);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(key('commission_month_strip'), findsOneWidget);
    expect(key('commission_month_name'), findsOneWidget);
  });

  testWidgets('a load error keeps the header and offers retry', (tester) async {
    when(() => h.repo.getPeriod(_oct)).thenThrow(Exception('boom'));
    await h.pump(tester, location: _octPath);

    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('boom'), findsNothing);
    expect(key('commission_month_strip'), findsOneWidget);
  });

  testWidgets('compact: agents become rows and lines stacked cards', (
    tester,
  ) async {
    final router = await h.pump(
      tester,
      location: _octPath,
      surface: const Size(400, 900),
    );
    expect(key('commission_agent_row_7'), findsOneWidget);

    await tester.tap(key('commission_agent_row_7'));
    await tester.pumpAndSettle();

    expect(uri(router), '$_octPath?agent=7');
    expect(key('commission_lines_cards'), findsOneWidget);
    expect(find.textContaining('× 2.50 %'), findsWidgets);
    expect(find.textContaining('Devolución'), findsOneWidget);
  });

  group('Asignar… on an unlabelled line (FR-016a)', () {
    const agentPath = '$_octPath?agent=7';

    setUp(() {
      when(() => h.repo.listLabels()).thenAnswer(
        (_) async => [CommissionLabel(id: 3, name: 'Premium', rate: d('0.05'))],
      );
      when(() => h.repo.listParticipations()).thenAnswer((_) async => []);
    });

    testWidgets('on an open month it assigns the product a label and the '
        'month is read again', (tester) async {
      var reads = 0;
      when(() => h.repo.getPeriod(_oct, agentId: 7)).thenAnswer((_) async {
        reads++;
        return periodOf(
          status,
          agentId: 7,
          totals: agentTotals,
          lines: [aLine(), refund, unlabelled],
        );
      });
      when(() => h.repo.setProductLabel(5, 3)).thenAnswer(
        (_) async => const CommissionProductLabel(
          productId: 5,
          productCode: 'T-5',
          productName: 'Tornillo',
          labelId: 3,
        ),
      );
      await h.pump(tester, location: agentPath);
      expect(reads, 1);

      await tester.tap(key('commission_assign_610'));
      await tester.pumpAndSettle();
      expect(key('commission_assign_label_note'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(key('commission_assign_label_submit'))
            .onPressed,
        isNull,
      );
      await tester.tap(key('commission_assign_label_label'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Premium').last);
      await tester.pumpAndSettle();
      await tester.tap(key('commission_assign_label_submit'));
      await tester.pumpAndSettle();

      verify(() => h.repo.setProductLabel(5, 3)).called(1);
      expect(key('commission_assign_label_dialog'), findsNothing);
      expect(reads, 2);
    });

    testWidgets('a refusal lands in the month banner', (tester) async {
      when(() => h.repo.setProductLabel(5, 3)).thenThrow(
        aRefusal(api.ErrorCode.authPeriodForbidden, 'auth.forbidden'),
      );
      await h.pump(tester, location: agentPath);

      await tester.tap(key('commission_assign_610'));
      await tester.pumpAndSettle();
      await tester.tap(key('commission_assign_label_label'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Premium').last);
      await tester.pumpAndSettle();
      await tester.tap(key('commission_assign_label_submit'));
      await tester.pumpAndSettle();

      expect(key('commission_action_refusal'), findsOneWidget);
      expect(find.text('SERVER TEXT'), findsNothing);
    });

    for (final closed in [
      CommissionPeriodStatus.closed,
      CommissionPeriodStatus.paid,
    ]) {
      testWidgets('a ${closed.name} month does not offer it', (tester) async {
        status = closed;
        await h.pump(tester, location: agentPath);

        expect(key('commission_assign_610'), findsNothing);
        expect(find.text('Sin etiqueta'), findsWidgets);
      });
    }

    for (final rights in [2, 3]) {
      testWidgets('without Update (rights $rights) it is absent', (
        tester,
      ) async {
        await h.pump(
          tester,
          who: CommissionHarness.user(commissions: rights),
          location: agentPath,
        );

        expect(key('commission_assign_610'), findsNothing);
        expect(find.text('Sin etiqueta'), findsWidgets);
      });
    }

    testWidgets('a labelled line has no action', (tester) async {
      await h.pump(tester, location: agentPath);

      // Three lines, one of them unlabelled.
      expect(find.text('Asignar…'), findsOneWidget);
    });

    testWidgets('compact: the card offers it too', (tester) async {
      await h.pump(tester, location: agentPath, surface: const Size(400, 900));

      expect(key('commission_assign_610'), findsOneWidget);
    });
  });
}
