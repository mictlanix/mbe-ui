import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:mbe_ui/features/commissions/domain/entities/commission_period.dart';
import 'package:mbe_ui/features/commissions/domain/entities/commission_settings.dart';
import 'package:mbe_ui/features/commissions/presentation/periods/commission_line_panel.dart';

import '../../../unit/features/commissions/commission_fixtures.dart';
import 'commission_harness.dart';

String textOf(WidgetTester tester, String id) =>
    tester.widget<Text>(key('commission_line_$id')).data!;

void main() {
  late CommissionHarness h;

  setUp(() => h = CommissionHarness());

  Future<void> open(WidgetTester tester, CommissionLine line) => h.pump(
    tester,
    location: '/panel',
    extraRoutes: [
      GoRoute(
        path: '/panel',
        builder: (_, _) => Scaffold(
          body: SingleChildScrollView(child: CommissionLinePanel(line: line)),
        ),
      ),
    ],
  );

  testWidgets('lists every value, rates as percentages', (tester) async {
    await open(tester, aLine());

    expect(textOf(tester, 'movement'), 'Venta');
    expect(textOf(tester, 'scheme'), 'Pago total');
    expect(find.textContaining('2026'), findsWidgets);
    expect(textOf(tester, 'customer'), 'Cliente');
    expect(textOf(tester, 'product'), 'Tornillo');
    expect(textOf(tester, 'label'), 'Premium');
    expect(textOf(tester, 'label_rate'), '5.00 %');
    expect(textOf(tester, 'participation'), 'CLIENTE VITALICIO');
    expect(textOf(tester, 'agent_share'), '50.00 %');
    expect(textOf(tester, 'effective_rate'), '2.50 %');
    expect(textOf(tester, 'price'), r'$100.00');
    expect(textOf(tester, 'amount'), r'$200.00');
    expect(textOf(tester, 'full_commission'), r'$10.00');
    expect(textOf(tester, 'month_commission'), r'$50.00');
    expect(find.text('Empleado 7'), findsNWidgets(2));
  });

  testWidgets('the paid percentage shows only on a scheme 2 sale', (
    tester,
  ) async {
    await open(tester, aLine());
    expect(key('commission_line_paid_percent'), findsNothing);

    await open(
      tester,
      aLine().copyWith(
        scheme: CommissionScheme.partialPayments,
        share: d('0.400000'),
      ),
    );
    expect(textOf(tester, 'scheme'), 'Pagos parciales');
    expect(textOf(tester, 'paid_percent'), '40.00 %');
  });

  testWidgets('a refund and an unlabelled line read as such', (tester) async {
    await open(
      tester,
      aLine().copyWith(
        movement: CommissionMovement.refund,
        labelId: null,
        labelName: null,
      ),
    );

    expect(textOf(tester, 'movement'), 'Devolución');
    expect(textOf(tester, 'label'), 'Sin etiqueta');
  });

  testWidgets('is read only: no fields, no edit', (tester) async {
    await open(tester, aLine());

    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
  });
}
