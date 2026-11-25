import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mbe_api_client/mbe_api_client.dart' as api;
import 'package:mocktail/mocktail.dart';

import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/period_dialogs.dart';

import '../../../unit/features/commissions/commission_fixtures.dart';
import 'commission_harness.dart';

void main() {
  late CommissionHarness h;
  const month = CommissionMonth(year: 2026, month: 10);
  CommissionActionResult? answer;
  var answered = false;

  setUp(() {
    h = CommissionHarness();
    answer = null;
    answered = false;
    when(() => h.repo.listPeriods()).thenAnswer((_) async => []);
  });

  /// A page with one button that opens the dialog under test.
  Future<void> pumpWith(
    WidgetTester tester,
    Future<CommissionActionResult?> Function(BuildContext context) open,
  ) async {
    await h.pump(
      tester,
      location: '/dialogs',
      extraRoutes: [
        GoRoute(
          path: '/dialogs',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                key: const Key('open'),
                onPressed: () async {
                  answer = await open(context);
                  answered = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ],
    );
    await tester.tap(key('open'));
    await tester.pumpAndSettle();
  }

  Future<CommissionActionResult?> close(BuildContext context) =>
      showCloseCommissionPeriodDialog(
        context,
        month: month,
        lineCount: 6,
        total: d('420.00'),
      );

  testWidgets('the close prompt shows the line count and total', (
    tester,
  ) async {
    await pumpWith(tester, close);

    expect(find.text('Cerrar octubre de 2026'), findsOneWidget);
    expect(
      find.textContaining('Se guardarán 6 líneas por \$420.00.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('el mes no cambiará aunque cambien'),
      findsOneWidget,
    );
    expect(find.text('Cerrar mes'), findsOneWidget);
  });

  testWidgets('the close prompt reads singular for one line', (tester) async {
    await pumpWith(
      tester,
      (context) => showCloseCommissionPeriodDialog(
        context,
        month: month,
        lineCount: 1,
        total: d('5.00'),
      ),
    );

    expect(find.textContaining('Se guardará 1 línea por'), findsOneWidget);
  });

  testWidgets('Cancelar changes nothing', (tester) async {
    await pumpWith(tester, close);

    await tester.tap(key('commission_close_cancel'));
    await tester.pumpAndSettle();

    expect(key('commission_close_dialog'), findsNothing);
    expect(answered, isTrue);
    expect(answer, isNull);
    verifyNever(() => h.repo.closePeriod(month));
  });

  testWidgets('shows a spinner and cannot be dismissed while closing', (
    tester,
  ) async {
    final inFlight = Completer<CommissionPeriodSummary>();
    when(() => h.repo.closePeriod(month)).thenAnswer((_) => inFlight.future);
    await pumpWith(tester, close);

    await tester.tap(key('commission_close_submit'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(
            find.ancestor(
              of: find.text('Cancelar'),
              matching: find.byType(TextButton),
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(key('commission_close_dialog'), findsOneWidget);

    inFlight.complete(aPeriodSummary());
    await tester.pumpAndSettle();
    expect(key('commission_close_dialog'), findsNothing);
    expect(answer?.error, isNull);
    expect(answered, isTrue);
    expect(answer, isNotNull);
  });

  testWidgets('a refusal closes the prompt and is handed back', (tester) async {
    when(() => h.repo.closePeriod(month)).thenThrow(
      aRefusal(
        api.ErrorCode.commissionPeriodPeriodNotEnded,
        'commission_period.not_ended',
        {'year': 2026, 'month': 10},
      ),
    );
    await pumpWith(tester, close);

    await tester.tap(key('commission_close_submit'));
    await tester.pumpAndSettle();

    expect(key('commission_close_dialog'), findsNothing);
    expect(answer?.error, isNotNull);
  });

  testWidgets('the reopen prompt says the stored lines are discarded', (
    tester,
  ) async {
    when(
      () => h.repo.reopenPeriod(month),
    ).thenAnswer((_) async => aPeriodSummary());
    await pumpWith(
      tester,
      (context) => showReopenCommissionPeriodDialog(context, month: month),
    );

    expect(find.text('Reabrir octubre de 2026'), findsOneWidget);
    expect(
      find.textContaining('Se descartarán las líneas guardadas'),
      findsOneWidget,
    );

    await tester.tap(key('commission_reopen_submit'));
    await tester.pumpAndSettle();
    verify(() => h.repo.reopenPeriod(month)).called(1);
    expect(answer?.error, isNull);
    expect(answer, isNotNull);
  });

  testWidgets('the pay prompt warns the month becomes final, with the total', (
    tester,
  ) async {
    when(
      () => h.repo.payPeriod(month),
    ).thenAnswer((_) async => aPeriodSummary());
    await pumpWith(
      tester,
      (context) => showPayCommissionPeriodDialog(
        context,
        month: month,
        total: d('1234.50'),
      ),
    );

    expect(find.text('Marcar octubre de 2026 como pagado'), findsOneWidget);
    expect(find.textContaining(r'Total $1,234.50.'), findsOneWidget);
    expect(find.textContaining('es definitivo'), findsOneWidget);

    await tester.tap(key('commission_pay_submit'));
    await tester.pumpAndSettle();
    verify(() => h.repo.payPeriod(month)).called(1);
  });
}
