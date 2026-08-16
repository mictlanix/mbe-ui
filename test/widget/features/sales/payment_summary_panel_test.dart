import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbe_ui/features/sales/domain/entities/sale.dart';
import 'package:mbe_ui/features/sales/presentation/payment/payment_summary_panel.dart';
import 'package:mbe_ui/l10n/app_localizations.dart';

import 'pos_test_harness.dart';

/// The money block and the exit action, read together (spec 025 US2,
/// contracts/payment-surface.md §6): all four figures at once, a permanent
/// change row, and the gate hint shown only while the exit is disabled with
/// a balance outstanding.
void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  Future<void> pumpPanel(
    WidgetTester tester, {
    String balance = '116.00',
    PaymentTerms paymentTerms = PaymentTerms.immediate,
    VoidCallback? onClose,
  }) => pumpPos(
    tester,
    PaymentSummaryPanel(
      sale: testSale(
        status: SaleStatus.completed,
        balance: balance,
        paymentTerms: paymentTerms,
      ),
      onClose: onClose ?? () {},
    ),
  );

  FloatingActionButton closeButton(WidgetTester tester) => tester
      .widget<FloatingActionButton>(find.byKey(const Key('payment_close_button')));

  testWidgets('total, paid, remaining and change all render at once', (
    tester,
  ) async {
    await pumpPanel(tester, balance: '50.00');

    expect(find.text(l10n.posPaymentTotal), findsOneWidget);
    expect(find.text(l10n.posPaymentPaid), findsOneWidget);
    expect(find.text(l10n.posPaymentBalance), findsOneWidget);
    expect(find.text(l10n.posPaymentChangeLabel), findsOneWidget);
  });

  testWidgets('the change row reads zero with no tender keyed', (
    tester,
  ) async {
    await pumpPanel(tester, balance: '116.00');

    final changeRow = find.ancestor(
      of: find.text(l10n.posPaymentChangeLabel),
      matching: find.byType(Row),
    );
    expect(
      find.descendant(of: changeRow, matching: find.text(r'$0.00')),
      findsOneWidget,
    );
  });

  testWidgets(
    'the gate hint is shown only while the exit is disabled with a balance '
    'outstanding',
    (tester) async {
      await pumpPanel(tester, balance: '116.00');
      expect(closeButton(tester).onPressed, isNull);
      expect(find.text(l10n.posPaymentGateHint), findsOneWidget);
    },
  );

  testWidgets('the gate hint disappears once the balance reaches zero', (
    tester,
  ) async {
    await pumpPanel(tester, balance: '0.00');
    expect(closeButton(tester).onPressed, isNotNull);
    expect(find.text(l10n.posPaymentGateHint), findsNothing);
  });

  testWidgets('the gate hint is absent on credit terms — nothing is gated', (
    tester,
  ) async {
    await pumpPanel(
      tester,
      balance: '116.00',
      paymentTerms: PaymentTerms.netD,
    );
    expect(closeButton(tester).onPressed, isNotNull);
    expect(find.text(l10n.posPaymentGateHint), findsNothing);
  });

  testWidgets('closing invokes the host callback once the gate opens', (
    tester,
  ) async {
    var closed = false;
    await pumpPanel(tester, balance: '0.00', onClose: () => closed = true);

    await tester.tap(find.byKey(const Key('payment_close_button')));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
  });
}
